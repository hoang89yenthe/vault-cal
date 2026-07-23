import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Chunked AES-256-GCM file encryption, run inside isolates so multi-gigabyte
/// media never loads fully into the Dart heap.
///
/// File format (.vlt) v2:
///   header (17B) = magic "VCV2" (4) | version (1) | noncePrefix (8) |
///                  totalChunks uint32 LE (4)
///   repeated: chunkLen uint32 LE (4) | ciphertext+tag (GCM)
///   nonce per chunk = noncePrefix ++ uint32(chunkIndex)  → 12B, never reused.
///
/// The full 17-byte header is fed as GCM associated data on EVERY chunk, so the
/// version and the authenticated total-chunk count can't be tampered with, and
/// decryption fails unless exactly totalChunks chunks are present — detecting
/// silent tail-truncation of an encrypted file.
abstract final class FileCrypto {
  static const List<int> _magic = [0x56, 0x43, 0x56, 0x32]; // "VCV2"
  static const int _version = 2;
  static const int _headerLength = 17;
  static const int _chunkSize = 4 * 1024 * 1024; // 4 MiB plaintext
  static const int _tagLength = 16;

  static int _chunkCountFor(int byteLength) =>
      byteLength == 0 ? 0 : (byteLength + _chunkSize - 1) ~/ _chunkSize;

  /// Encrypts [sourcePath] into [destPath] using raw 32-byte [dek].
  static Future<void> encryptFile({
    required String sourcePath,
    required String destPath,
    required Uint8List dek,
  }) {
    return Isolate.run(() => _EncryptRequest(sourcePath, destPath, dek).run());
  }

  /// Decrypts [sourcePath] fully into memory. Use only for images/thumbnails.
  static Future<Uint8List> decryptToBytes({
    required String sourcePath,
    required Uint8List dek,
  }) {
    return Isolate.run(() => _DecryptToBytesRequest(sourcePath, dek).run());
  }

  /// Decrypts [sourcePath] to [destPath] on disk. Use for videos/documents.
  static Future<void> decryptToFile({
    required String sourcePath,
    required String destPath,
    required Uint8List dek,
  }) {
    return Isolate.run(
      () => _DecryptToFileRequest(sourcePath, destPath, dek).run(),
    );
  }

  /// Encrypts an in-memory [bytes] buffer (single or multi chunk) to [destPath].
  /// Used for thumbnails and intruder selfies already held in memory.
  static Future<void> encryptBytes({
    required Uint8List bytes,
    required String destPath,
    required Uint8List dek,
  }) {
    return Isolate.run(() => _EncryptBytesRequest(bytes, destPath, dek).run());
  }
}

// ----- Isolate entry helpers (must be top-level-runnable closures) -----

Uint8List _nonceFor(Uint8List prefix, int index) {
  final nonce = Uint8List(12)..setRange(0, 8, prefix);
  ByteData.sublistView(nonce).setUint32(8, index, Endian.little);
  return nonce;
}

Uint8List _randomPrefix() {
  final algo = AesGcm.with256bits();
  return Uint8List.fromList(algo.newNonce().sublist(0, 8));
}

Uint8List _buildHeader(Uint8List prefix, int totalChunks) {
  final h = Uint8List(FileCrypto._headerLength)
    ..setRange(0, 4, FileCrypto._magic)
    ..[4] = FileCrypto._version
    ..setRange(5, 13, prefix);
  ByteData.sublistView(h).setUint32(13, totalChunks, Endian.little);
  return h;
}

Uint8List _packPayload(SecretBox box) {
  return Uint8List(box.cipherText.length + box.mac.bytes.length)
    ..setRange(0, box.cipherText.length, box.cipherText)
    ..setRange(
      box.cipherText.length,
      box.cipherText.length + box.mac.bytes.length,
      box.mac.bytes,
    );
}

void _writeChunk(RandomAccessFile output, Uint8List payload) {
  final lenHeader = ByteData(4)..setUint32(0, payload.length, Endian.little);
  output
    ..writeFromSync(lenHeader.buffer.asUint8List())
    ..writeFromSync(payload);
}

class _EncryptRequest {
  _EncryptRequest(this.sourcePath, this.destPath, this.dek);
  final String sourcePath;
  final String destPath;
  final Uint8List dek;

  Future<void> run() async {
    final algo = AesGcm.with256bits();
    final key = await algo.newSecretKeyFromBytes(dek);
    final prefix = _randomPrefix();
    final total = FileCrypto._chunkCountFor(File(sourcePath).lengthSync());
    final header = _buildHeader(prefix, total);

    final input = File(sourcePath).openSync();
    final output = File(destPath).openSync(mode: FileMode.write);
    try {
      output.writeFromSync(header);
      var index = 0;
      while (true) {
        final plain = input.readSync(FileCrypto._chunkSize);
        if (plain.isEmpty) break;
        final box = await algo.encrypt(
          plain,
          secretKey: key,
          nonce: _nonceFor(prefix, index),
          aad: header,
        );
        _writeChunk(output, _packPayload(box));
        index++;
        if (plain.length < FileCrypto._chunkSize) break;
      }
    } finally {
      input.closeSync();
      output.closeSync();
    }
  }
}

class _EncryptBytesRequest {
  _EncryptBytesRequest(this.bytes, this.destPath, this.dek);
  final Uint8List bytes;
  final String destPath;
  final Uint8List dek;

  Future<void> run() async {
    final algo = AesGcm.with256bits();
    final key = await algo.newSecretKeyFromBytes(dek);
    final prefix = _randomPrefix();
    final total = FileCrypto._chunkCountFor(bytes.length);
    final header = _buildHeader(prefix, total);

    final output = File(destPath).openSync(mode: FileMode.write);
    try {
      output.writeFromSync(header);
      var index = 0;
      var offset = 0;
      while (offset < bytes.length) {
        final end = (offset + FileCrypto._chunkSize).clamp(0, bytes.length);
        final plain = bytes.sublist(offset, end);
        final box = await algo.encrypt(
          plain,
          secretKey: key,
          nonce: _nonceFor(prefix, index),
          aad: header,
        );
        _writeChunk(output, _packPayload(box));
        index++;
        offset = end;
      }
    } finally {
      output.closeSync();
    }
  }
}

class _ChunkReader {
  _ChunkReader(this.raf) {
    final header = raf.readSync(FileCrypto._headerLength);
    if (header.length < FileCrypto._headerLength) {
      throw const FormatException('Truncated vault header');
    }
    for (var i = 0; i < 4; i++) {
      if (header[i] != FileCrypto._magic[i]) {
        throw const FormatException('Bad vault magic');
      }
    }
    if (header[4] != FileCrypto._version) {
      throw const FormatException('Unsupported vault version');
    }
    this.header = Uint8List.fromList(header);
    prefix = Uint8List.fromList(header.sublist(5, 13));
    totalChunks = ByteData.sublistView(
      this.header,
    ).getUint32(13, Endian.little);
  }

  final RandomAccessFile raf;
  late final Uint8List header;
  late final Uint8List prefix;
  late final int totalChunks;
  int index = 0;

  /// Returns the next decrypted plaintext chunk, or null at EOF.
  Future<Uint8List?> next(AesGcm algo, SecretKey key) async {
    final lenBytes = raf.readSync(4);
    if (lenBytes.isEmpty) return null;
    final payloadLen = ByteData.sublistView(
      Uint8List.fromList(lenBytes),
    ).getUint32(0, Endian.little);
    final payload = raf.readSync(payloadLen);
    final cipherText = payload.sublist(
      0,
      payload.length - FileCrypto._tagLength,
    );
    final mac = Mac(payload.sublist(payload.length - FileCrypto._tagLength));
    final clear = await algo.decrypt(
      SecretBox(cipherText, nonce: _nonceFor(prefix, index), mac: mac),
      secretKey: key,
      aad: header,
    );
    index++;
    return Uint8List.fromList(clear);
  }

  /// Verifies that every declared chunk was present — catches tail truncation.
  void assertComplete() {
    if (index != totalChunks) {
      throw const FormatException('Vault file truncated or extended');
    }
  }
}

class _DecryptToBytesRequest {
  _DecryptToBytesRequest(this.sourcePath, this.dek);
  final String sourcePath;
  final Uint8List dek;

  Future<Uint8List> run() async {
    final algo = AesGcm.with256bits();
    final key = await algo.newSecretKeyFromBytes(dek);
    final raf = File(sourcePath).openSync();
    final builder = BytesBuilder(copy: false);
    try {
      final reader = _ChunkReader(raf);
      while (true) {
        final chunk = await reader.next(algo, key);
        if (chunk == null) break;
        builder.add(chunk);
      }
      reader.assertComplete();
    } finally {
      raf.closeSync();
    }
    return builder.toBytes();
  }
}

class _DecryptToFileRequest {
  _DecryptToFileRequest(this.sourcePath, this.destPath, this.dek);
  final String sourcePath;
  final String destPath;
  final Uint8List dek;

  Future<void> run() async {
    final algo = AesGcm.with256bits();
    final key = await algo.newSecretKeyFromBytes(dek);
    final raf = File(sourcePath).openSync();
    final output = File(destPath).openSync(mode: FileMode.write);
    try {
      final reader = _ChunkReader(raf);
      while (true) {
        final chunk = await reader.next(algo, key);
        if (chunk == null) break;
        output.writeFromSync(chunk);
      }
      reader.assertComplete();
    } finally {
      raf.closeSync();
      output.closeSync();
    }
  }
}
