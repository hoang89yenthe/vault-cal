import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/vault_file.dart';
import '../cubit/folder_cubit.dart';
import '../theme/vault_colors.dart';
import '../widgets/vault_thumbnail.dart';

class FolderPage extends StatelessWidget {
  const FolderPage({required this.category, required this.title, super.key});

  final MediaCategory category;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FolderCubit>()..load(category),
      child: _FolderView(category: category, title: title),
    );
  }
}

class _FolderView extends StatelessWidget {
  const _FolderView({required this.category, required this.title});

  final MediaCategory category;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FolderCubit, FolderState>(
      builder: (context, state) {
        final cubit = context.read<FolderCubit>();
        final selecting = state is FolderLoaded && state.selecting;

        return Scaffold(
          backgroundColor: VaultColors.background,
          appBar: AppBar(
            backgroundColor: VaultColors.background,
            foregroundColor: VaultColors.text,
            leading: selecting
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: cubit.clearSelection,
                  )
                : null,
            title: Text(
              selecting ? '${state.selectedIds.length} đã chọn' : title,
            ),
            actions: [
              if (selecting)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: VaultColors.red,
                  ),
                  onPressed: () => _confirmDelete(context, cubit),
                ),
            ],
          ),
          body: switch (state) {
            FolderLoading() => const LoadingIndicator(),
            FolderError(:final message) => AppErrorView(
              message: message,
              onRetry: () => cubit.load(category),
            ),
            FolderLoaded(:final files) when files.isEmpty => Center(
              child: Text(
                context.l10n.emptyList,
                style: const TextStyle(color: VaultColors.textSub),
              ),
            ),
            FolderLoaded(:final files, :final selectedIds) => GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final selected = selectedIds.contains(file.id);
                return _Tile(
                  file: file,
                  selected: selected,
                  selecting: selecting,
                  onTap: () {
                    if (selecting) {
                      cubit.toggleSelect(file.id);
                    } else {
                      context.push('${AppRoutes.viewer}/${file.id}');
                    }
                  },
                  onLongPress: () => cubit.toggleSelect(file.id),
                );
              },
            ),
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, FolderCubit cubit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.card,
        title: const Text(
          'Xóa tệp?',
          style: TextStyle(color: VaultColors.text),
        ),
        content: const Text(
          'Các tệp đã chọn sẽ bị xóa vĩnh viễn khỏi kho.',
          style: TextStyle(color: VaultColors.textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: VaultColors.red)),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.deleteSelected();
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.file,
    required this.selected,
    required this.selecting,
    required this.onTap,
    required this.onLongPress,
  });

  final VaultFile file;
  final bool selected;
  final bool selecting;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VaultThumbnail(file: file),
          if (selecting)
            Container(
              color: selected
                  ? VaultColors.accent.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.15),
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(6),
              child: Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
