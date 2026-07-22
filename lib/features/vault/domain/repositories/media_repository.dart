import 'dart:typed_data';

import '../../../../core/utils/result.dart';
import '../entities/vault_file.dart';

/// A file the user picked for import, before encryption.
class PickedSource {
  const PickedSource({
    required this.path,
    required this.name,
    required this.mime,
    required this.category,
  });

  final String path;
  final String name;
  final String mime;
  final MediaCategory category;
}

abstract interface class MediaRepository {
  /// Encrypts and stores each picked file. Emits progress as (done, total).
  Stream<int> importFiles(List<PickedSource> sources);

  Future<Result<List<VaultFile>>> listFiles(MediaCategory category);

  Future<Result<void>> deleteFiles(List<String> ids);

  /// Decrypted thumbnail bytes for grid display (null if none).
  Future<Uint8List?> thumbnailBytes(String id);

  /// Decrypts a full image into memory (photos only).
  Future<Result<Uint8List>> decryptToBytes(String id);

  /// Decrypts a file to a temp path for playback / external viewing.
  Future<Result<String>> decryptToTempFile(String id);

  /// Aggregate counts per category and total bytes, for the dashboard.
  Future<({Map<MediaCategory, int> counts, int totalBytes})> stats();
}
