import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/vault_file.dart';
import '../../domain/repositories/media_repository.dart';

/// Decrypts and displays a single vault file. Images decrypt to memory;
/// videos and documents decrypt to a sandboxed temp file that is deleted on
/// exit.
class MediaViewerPage extends StatefulWidget {
  const MediaViewerPage({required this.fileId, super.key});

  final String fileId;

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  final _media = getIt<MediaRepository>();

  VaultFile? _file;
  Uint8List? _imageBytes;
  VideoPlayerController? _videoController;
  String? _tempPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    final files = await _findFile();
    if (files == null) {
      setState(() => _error = 'Không tìm thấy tệp');
      return;
    }
    _file = files;

    if (files.isImage) {
      final result = await _media.decryptToBytes(files.id);
      switch (result) {
        case Ok(:final value):
          if (mounted) setState(() => _imageBytes = value);
        case Err(:final failure):
          if (mounted) setState(() => _error = failure.message);
      }
    } else {
      final result = await _media.decryptToTempFile(files.id);
      switch (result) {
        case Ok(:final value):
          _tempPath = value;
          if (files.isVideo) {
            final controller = VideoPlayerController.file(File(value));
            await controller.initialize();
            await controller.setLooping(true);
            await controller.play();
            if (mounted) setState(() => _videoController = controller);
          } else {
            await OpenFilex.open(value);
            if (mounted) Navigator.of(context).pop();
          }
        case Err(:final failure):
          if (mounted) setState(() => _error = failure.message);
      }
    }
  }

  /// Looks the file up across categories by id.
  Future<VaultFile?> _findFile() async {
    for (final category in MediaCategory.values) {
      final result = await _media.listFiles(category);
      if (result is Ok<List<VaultFile>>) {
        for (final f in result.value) {
          if (f.id == widget.fileId) return f;
        }
      }
    }
    return null;
  }

  @override
  void dispose() {
    _videoController?.dispose();
    final path = _tempPath;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_file?.name ?? '', style: const TextStyle(fontSize: 15)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return AppErrorView(message: _error!);
    }
    if (_imageBytes != null) {
      return PhotoView(
        imageProvider: MemoryImage(_imageBytes!),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    }
    final video = _videoController;
    if (video != null && video.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: video.value.aspectRatio,
          child: GestureDetector(
            onTap: () => setState(() {
              video.value.isPlaying ? video.pause() : video.play();
            }),
            child: VideoPlayer(video),
          ),
        ),
      );
    }
    return const LoadingIndicator();
  }
}
