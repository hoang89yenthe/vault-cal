import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/vault_file.dart';
import '../../domain/repositories/media_repository.dart';

part 'import_state.dart';

class ImportCubit extends Cubit<ImportState> {
  ImportCubit(this._media) : super(const ImportIdle());

  final MediaRepository _media;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndImportMedia() async {
    try {
      final picked = await _picker.pickMultipleMedia();
      if (picked.isEmpty) {
        emit(const ImportIdle());
        return;
      }
      final sources = picked.map((x) {
        final mime = x.mimeType ?? _guessMime(x.name);
        return PickedSource(
          path: x.path,
          name: x.name,
          mime: mime,
          category: mime.startsWith('video/')
              ? MediaCategory.videos
              : MediaCategory.images,
        );
      }).toList();
      await _run(sources);
    } on Object catch (e) {
      emit(ImportFailed(e.toString()));
    }
  }

  Future<void> pickAndImportDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      final files = result?.files ?? [];
      if (files.isEmpty) {
        emit(const ImportIdle());
        return;
      }
      final sources = [
        for (final f in files)
          if (f.path != null)
            PickedSource(
              path: f.path!,
              name: f.name,
              mime: _guessMime(f.name),
              category: MediaCategory.documents,
            ),
      ];
      await _run(sources);
    } on Object catch (e) {
      emit(ImportFailed(e.toString()));
    }
  }

  Future<void> _run(List<PickedSource> sources) async {
    final total = sources.length;
    emit(ImportInProgress(done: 0, total: total));
    var last = 0;
    await for (final done in _media.importFiles(sources)) {
      last = done;
      emit(ImportInProgress(done: done, total: total));
    }
    emit(ImportDone(last));
  }

  String _guessMime(String name) {
    final ext = name.toLowerCase().split('.').last;
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'pdf' => 'application/pdf',
      'doc' || 'docx' => 'application/msword',
      'xls' || 'xlsx' => 'application/vnd.ms-excel',
      _ => 'application/octet-stream',
    };
  }
}
