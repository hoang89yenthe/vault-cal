import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/vault_file.dart';
import '../../domain/repositories/media_repository.dart';
import '../theme/vault_colors.dart';

/// Decrypts and shows a file's thumbnail, with a placeholder for documents or
/// while decryption is in flight.
class VaultThumbnail extends StatefulWidget {
  const VaultThumbnail({required this.file, super.key});

  final VaultFile file;

  @override
  State<VaultThumbnail> createState() => _VaultThumbnailState();
}

class _VaultThumbnailState extends State<VaultThumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!widget.file.hasThumb) return;
    final bytes = await getIt<MediaRepository>().thumbnailBytes(widget.file.id);
    if (mounted) setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _bytes;
    if (bytes != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover),
          if (widget.file.isVideo)
            const Center(
              child: Icon(Icons.play_circle_fill, size: 34, color: Colors.white),
            ),
        ],
      );
    }
    return ColoredBox(
      color: VaultColors.progressTrack,
      child: Center(
        child: Icon(
          switch (widget.file.category) {
            MediaCategory.documents => Icons.description_outlined,
            MediaCategory.videos => Icons.videocam_outlined,
            MediaCategory.images => Icons.image_outlined,
          },
          size: 32,
          color: VaultColors.textFaint,
        ),
      ),
    );
  }
}
