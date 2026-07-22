import '../../../../core/error/failures.dart';
import '../../../../core/session/vault_session.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/vault_data.dart';
import '../../domain/entities/vault_file.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/repositories/vault_repository.dart';

/// Builds the dashboard from real encrypted-file aggregates. Keeps the
/// [VaultData] shape so the dashboard UI needs no changes.
class VaultRepositoryImpl implements VaultRepository {
  const VaultRepositoryImpl(this._session, this._media);

  final VaultSession _session;
  final MediaRepository _media;

  // Display cap matching the handoff (5 GB) — real byte usage drives the bar.
  static const int _capBytes = 5 * 1024 * 1024 * 1024;

  @override
  Future<Result<VaultData>> getVault() async {
    try {
      final stats = await _media.stats();
      final isDecoy = _session.isDecoy;

      final images = stats.counts[MediaCategory.images] ?? 0;
      final videos = stats.counts[MediaCategory.videos] ?? 0;
      final documents = stats.counts[MediaCategory.documents] ?? 0;
      final notes = await _noteCount();

      final percent =
          ((stats.totalBytes / _capBytes) * 100).clamp(0, 100).round();

      return Ok(
        VaultData(
          isDecoy: isDecoy,
          usedLabel: _formatBytes(stats.totalBytes),
          totalLabel: '5 GB',
          percent: percent,
          folders: [
            VaultFolder(
              name: isDecoy ? 'Ảnh du lịch' : 'Hình ảnh',
              count: images,
              hue: 255,
              icon: VaultFolderIcon.images,
            ),
            VaultFolder(
              name: isDecoy ? 'Ảnh màn hình' : 'Video',
              count: videos,
              hue: isDecoy ? 200 : 25,
              icon: isDecoy ? VaultFolderIcon.screenshots : VaultFolderIcon.video,
            ),
            VaultFolder(
              name: isDecoy ? 'Tài liệu công việc' : 'Tài liệu',
              count: documents,
              hue: 150,
              icon: VaultFolderIcon.documents,
            ),
            VaultFolder(
              name: isDecoy ? 'Ghi chú' : 'Ghi chú mật',
              count: notes,
              hue: isDecoy ? 70 : 305,
              icon: VaultFolderIcon.notes,
              locked: !isDecoy,
            ),
          ],
        ),
      );
    } on Object catch (e) {
      return Err(UnknownFailure(e.toString()));
    }
  }

  Future<int> _noteCount() async {
    final db = _session.db;
    final rows = await db.select(db.notes).get();
    return rows.length;
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1).replaceAll('.', ',')} GB';
    }
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(mb >= 10 ? 0 : 1).replaceAll('.', ',')} MB';
  }
}
