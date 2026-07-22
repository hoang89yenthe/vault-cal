import 'package:equatable/equatable.dart';

/// Logical folders a vault file can belong to.
enum MediaCategory { images, videos, documents }

extension MediaCategoryX on MediaCategory {
  String get storageKey => name;

  static MediaCategory fromKey(String key) =>
      MediaCategory.values.firstWhere((c) => c.name == key);
}

class VaultFile extends Equatable {
  const VaultFile({
    required this.id,
    required this.category,
    required this.name,
    required this.mime,
    required this.sizeBytes,
    required this.createdAt,
    required this.hasThumb,
  });

  final String id;
  final MediaCategory category;
  final String name;
  final String mime;
  final int sizeBytes;
  final DateTime createdAt;
  final bool hasThumb;

  bool get isVideo => mime.startsWith('video/');
  bool get isImage => mime.startsWith('image/');

  @override
  List<Object?> get props =>
      [id, category, name, mime, sizeBytes, createdAt, hasThumb];
}
