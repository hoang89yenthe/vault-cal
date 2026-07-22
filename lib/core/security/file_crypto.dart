import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Chunked AES-256-GCM file encryption, run inside isolates so multi-gigabyte
/// media never loads fully into the Dart heap.
///
/// File format (.vlt):
///   magic "VCV1" (4B) | version (1B) | noncePrefix (8B)
///   repeated: chunkLen uint32 LE (4B) | ciphertext+tag (GCM)
///   nonce per chunk = noncePrefix ++ uint32(chunkIndex)  → 12B, never reused.
abstract final class FileCrypto {
  static const List<int> _magic = [0x56, 0x43, 0x56, 0x31]; // "VCV1"
  static const int _version = 1;
  static const int _chunkSize = 4 * 1024 * 1024; // 4 MiB plaintext
  static const int _tagLength = 16;

  /// Encrypts [source] into [destPath] using raw 32-byte [dek].
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
  final bd = ByteData.sublistView(nonce);
  bd.setUint32(8, index, Endian.little);
  return nonce;
}

Uint8List _randomPrefix() {
  final algo = AesGcm.with256bits();
  return Uint8List.fromList(algo.newNonce().sublist(0, 8));
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

    final input = File(sourcePath).openSync();
    final output = File(destPath).openSync(mode: FileMode.write);
    try {
      output.writeFromSync([
        ...FileCrypto._magic,
        FileCrypto._version,
        ...prefix,
      ]);
      var index = 0;
      while (true) {
        final plain = input.readSync(FileCrypto._chunkSize);
        if (plain.isEmpty) break;
        final box = await algo.encrypt(
          plain,
          secretKey: key,
          nonce: _nonceFor(prefix, index),
        );
        final payload = Uint8List(box.cipherText.length + box.mac.bytes.length)
          ..setRange(0, box.cipherText.length, box.cipherText)
          ..setRange(
            box.cipherText.length,
            box.cipherText.length + box.mac.bytes.length,
            box.mac.bytes,
          );
        final lenHeader = ByteData(4)
          ..setUint32(0, payload.length, Endian.little);
        output.writeFromSync(lenHeader.buffer.asUint8List());
        output.writeFromSync(payload);
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
    final output = File(destPath).openSync(mode: FileMode.write);
    try {
      output.writeFromSync([
        ...FileCrypto._magic,
        FileCrypto._version,
        ...prefix,
      ]);
      var index = 0;
      var offset = 0;
      while (offset < bytes.length) {
        final end = (offset + FileCrypto._chunkSize).clamp(0, bytes.length);
        final plain = bytes.sublist(offset, end);
        final box = await algo.encrypt(
          plain,
          secretKey: key,
          nonce: _nonceFor(prefix, index),
        );
        final payload = Uint8List(box.cipherText.length + box.mac.bytes.length)
          ..setRange(0, box.cipherText.length, box.cipherText)
          ..setRange(
            box.cipherText.length,
            box.cipherText.length + box.mac.bytes.length,
            box.mac.bytes,
          );
        final lenHeader = ByteData(4)
          ..setUint32(0, payload.length, Endian.little);
        output.writeFromSync(lenHeader.buffer.asUint8List());
        output.writeFromSync(payload);
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
    final header = raf.readSync(13);
    if (header.length < 13) {
      throw const FormatException('Truncated vault header');
    }
    for (var i = 0; i < 4; i++) {
      if (header[i] != FileCrypto._magic[i]) {
        throw const FormatException('Bad vault magic');
      }
    }
    prefix = Uint8List.fromList(header.sublist(5, 13));
  }

  final RandomAccessFile raf;
  late final Uint8List prefix;
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
    );
    index++;
    return Uint8List.fromList(clear);
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
    } finally {
      raf.closeSync();
      output.closeSync();
    }
  }
}
