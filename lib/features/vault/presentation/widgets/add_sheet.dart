import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../cubit/import_cubit.dart';
import '../theme/vault_colors.dart';

/// "Thêm vào kho" bottom sheet (30px top radius per the handoff). Drives the
/// [ImportCubit] and shows encryption progress.
Future<void> showAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: VaultColors.card,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      return BlocProvider(
        create: (_) => getIt<ImportCubit>(),
        child: const _AddSheetBody(),
      );
    },
  );
}

class _AddSheetBody extends StatelessWidget {
  const _AddSheetBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<ImportCubit, ImportState>(
      listener: (context, state) {
        if (state is ImportDone) Navigator.of(context).pop();
        if (state is ImportFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final cubit = context.read<ImportCubit>();
        final importing = state is ImportInProgress;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: VaultColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.addToVault,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: VaultColors.text,
                  ),
                ),
                const SizedBox(height: 14),
                if (importing)
                  _ImportProgress(state: state)
                else ...[
                  _AddOption(
                    icon: Icons.photo_library_outlined,
                    tone: folderTone(255),
                    title: l10n.addPhotosVideos,
                    subtitle: l10n.addPhotosVideosSub,
                    onTap: cubit.pickAndImportMedia,
                  ),
                  const SizedBox(height: 10),
                  _AddOption(
                    icon: Icons.description_outlined,
                    tone: folderTone(150),
                    title: l10n.addDocuments,
                    subtitle: l10n.addDocumentsSub,
                    onTap: cubit.pickAndImportDocuments,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImportProgress extends StatelessWidget {
  const _ImportProgress({required this.state});

  final ImportInProgress state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.total == 0 ? null : state.done / state.total,
            backgroundColor: VaultColors.progressTrack,
            color: VaultColors.accent,
          ),
          const SizedBox(height: 14),
          Text(
            'Đang mã hóa ${state.done}/${state.total}…',
            style: const TextStyle(color: VaultColors.textSub),
          ),
        ],
      ),
    );
  }
}

class _AddOption extends StatelessWidget {
  const _AddOption({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final ({Color bg, Color fg}) tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VaultColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tone.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: tone.fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: VaultColors.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: VaultColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: VaultColors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
