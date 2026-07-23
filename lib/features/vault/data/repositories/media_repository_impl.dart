import 'dart:io';

import 'package:drift/drift.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/vault_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/security/file_crypto.dart';
import '../../../../core/security/key_manager.dart';
import '../../../../core/session/vault_session.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/vault_file.dart';
import '../../domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._session, this._keyManager);

  final VaultSession _session;
  final KeyManager _keyManager;
  final _uuid = const Uuid();

  // Decrypted-thumbnail cache (keyed by namespace:id) so scrolling and
  // re-entering a folder never re-runs isolate decryption. Thumbnails are
  // ~20 KB, so a couple hundred entries stay well within memory.
  static final Map<String, Uint8List> _thumbCache = {};
  static const int _thumbCacheMax = 256;

  VaultDatabase get _db => _session.db;
  String get _ns => _session.namespace;

  @override
  Stream<int> importFiles(List<PickedSource> sources) async* {
    var done = 0;
    for (final source in sources) {
      try {
        await _importOne(source);
      } on Object {
        // Skip a file that fails to import rather than aborting the batch.
      }
      done++;
      yield done;
    }
  }

  Future<void> _importOne(PickedSource source) async {
    final id = _uuid.v4();
    final wrapped = await _keyManager.newWrappedDek(_ns);
    final dek = wrapped.dek;

    final mediaFileName = '$id.vlt';
    await FileCrypto.encryptFile(
      sourcePath: source.path,
      destPath: _session.mediaPath(mediaFileName),
      dek: dek,
    );

    final sizeBytes = File(source.path).lengthSync();
    final hasThumb = await _generateThumbnail(id, source, dek);

    await _db
        .into(_db.vaultFiles)
        .insert(
          VaultFilesCompanion.insert(
            id: id,
            category: source.category.storageKey,
            name: source.name,
            mime: source.mime,
            sizeBytes: sizeBytes,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            wrappedDek: wrapped.wrapped,
            hasThumb: Value(hasThumb),
          ),
        );
  }

  /// Generates a 320px thumbnail from the plaintext source and encrypts it.
  Future<bool> _generateThumbnail(
    String id,
    PickedSource source,
    Uint8List dek,
  ) async {
    try {
      final tmpDir = await getTemporaryDirectory();
      final tmpThumb = p.join(tmpDir.path, 'thumb_$id.jpg');

      if (source.category == MediaCategory.images) {
        final result = await FlutterImageCompress.compressAndGetFile(
          source.path,
          tmpThumb,
          minWidth: 320,
          minHeight: 320,
          quality: 70,
        );
        if (result == null) return false;
      } else if (source.category == MediaCategory.videos) {
        final ok = await FcNativeVideoThumbnail().getVideoThumbnail(
          srcFile: source.path,
          destFile: tmpThumb,
          width: 320,
          height: 320,
          format: 'jpeg',
          quality: 70,
        );
        if (!ok) return false;
      } else {
        return false; // documents have no visual thumbnail
      }

      final bytes = File(tmpThumb).readAsBytesSync();
      await FileCrypto.encryptBytes(
        bytes: bytes,
        destPath: _session.thumbPath('$id.vlt'),
        dek: dek,
      );
      File(tmpThumb).deleteSync();
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<Result<List<VaultFile>>> listFiles(MediaCategory category) async {
    try {
      final rows =
          await (_db.select(_db.vaultFiles)
                ..where((t) => t.category.equals(category.storageKey))
                ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
              .get();
      return Ok(rows.map(_mapRow).toList());
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteFiles(List<String> ids) async {
    try {
      for (final id in ids) {
        _safeDelete(_session.mediaPath('$id.vlt'));
        _safeDelete(_session.thumbPath('$id.vlt'));
        _thumbCache.remove('$_ns:$id');
      }
      await (_db.delete(_db.vaultFiles)..where((t) => t.id.isIn(ids))).go();
      return const Ok(null);
    } on Object catch (e) {
      return Err(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Uint8List?> thumbnailBytes(String id) async {
    final cacheKey = '$_ns:$id';
    final cached = _thumbCache[cacheKey];
    if (cached != null) return cached;
    try {
      final path = _session.thumbPath('$id.vlt');
      if (!File(path).existsSync()) return null;
      final dek = await _dekFor(id);
      if (dek == null) return null;
      final bytes = await FileCrypto.decryptToBytes(sourcePath: path, dek: dek);
      if (_thumbCache.length >= _thumbCacheMax) {
        _thumbCache.remove(_thumbCache.keys.first);
      }
      _thumbCache[cacheKey] = bytes;
      return bytes;
    } on Object {
      return null;
    }
  }

  @override
  Future<Result<Uint8List>> decryptToBytes(String id) async {
    try {
      final dek = await _dekFor(id);
      if (dek == null) return const Err(StorageFailure('File not found'));
      final bytes = await FileCrypto.decryptToBytes(
        sourcePath: _session.mediaPath('$id.vlt'),
        dek: dek,
      );
      return Ok(bytes);
    } on Object catch (e) {
      return Err(CryptoFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> decryptToTempFile(String id) async {
    try {
      final row = await _rawRow(id);
      if (row == null) return const Err(StorageFailure('File not found'));
      final dek = await _keyManager.unwrapDek(_ns, row.wrappedDek);

      final cacheDir = await getApplicationCacheDirectory();
      final decryptDir = Directory(p.join(cacheDir.path, 'decrypt'))
        ..createSync(recursive: true);
      final ext = p.extension(row.name);
      final destPath = p.join(decryptDir.path, '$id$ext');

      await FileCrypto.decryptToFile(
        sourcePath: _session.mediaPath('$id.vlt'),
        destPath: destPath,
        dek: dek,
      );
      return Ok(destPath);
    } on Object catch (e) {
      return Err(CryptoFailure(e.toString()));
    }
  }

  @override
  Future<({Map<MediaCategory, int> counts, int totalBytes})> stats() async {
    final rows = await _db.select(_db.vaultFiles).get();
    final counts = <MediaCategory, int>{
      for (final c in MediaCategory.values) c: 0,
    };
    var total = 0;
    for (final row in rows) {
      final category = MediaCategoryX.fromKey(row.category);
      counts[category] = (counts[category] ?? 0) + 1;
      total += row.sizeBytes;
    }
    return (counts: counts, totalBytes: total);
  }

  /// Cleans up any decrypted temp files left from a previous session.
  static Future<void> sweepDecryptCache() async {
    try {
      final cacheDir = await getApplicationCacheDirectory();
      final decryptDir = Directory(p.join(cacheDir.path, 'decrypt'));
      if (decryptDir.existsSync()) {
        decryptDir.deleteSync(recursive: true);
      }
    } on Object {
      // Best-effort cleanup.
    }
  }

  Future<Uint8List?> _dekFor(String id) async {
    final row = await _rawRow(id);
    if (row == null) return null;
    return _keyManager.unwrapDek(_ns, row.wrappedDek);
  }

  Future<VaultFileRow?> _rawRow(String id) {
    return (_db.select(
      _db.vaultFiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  void _safeDelete(String path) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }

  VaultFile _mapRow(VaultFileRow row) => VaultFile(
    id: row.id,
    category: MediaCategoryX.fromKey(row.category),
    name: row.name,
    mime: row.mime,
    sizeBytes: row.sizeBytes,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    hasThumb: row.hasThumb,
  );
}
