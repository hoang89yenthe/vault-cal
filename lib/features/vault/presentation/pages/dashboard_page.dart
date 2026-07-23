import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/session/vault_session.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../domain/entities/vault_data.dart';
import '../../domain/entities/vault_file.dart';
import '../cubit/dashboard_cubit.dart';
import '../theme/vault_colors.dart';
import '../widgets/add_sheet.dart';
import '../widgets/folder_card.dart';
import '../widgets/storage_card.dart';

/// Vault dashboard. Real vs decoy is read from the active [VaultSession].
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  bool _fabOpen = false;
  bool get _isDecoy => getIt<VaultSession>().isDecoy;

  Future<void> _onFabTap() async {
    setState(() => _fabOpen = true);
    await showAddSheet(context);
    if (mounted) {
      setState(() => _fabOpen = false);
      context.read<DashboardCubit>().load();
    }
  }

  Future<void> _openFolder(VaultFolder folder) async {
    final category = switch (folder.icon) {
      VaultFolderIcon.images => MediaCategory.images,
      VaultFolderIcon.video ||
      VaultFolderIcon.screenshots => MediaCategory.videos,
      VaultFolderIcon.documents => MediaCategory.documents,
      VaultFolderIcon.notes => null,
    };
    if (category == null) {
      await context.push(AppRoutes.notes);
    } else {
      await context.push(
        '${AppRoutes.folder}/${category.storageKey}?title=${Uri.encodeComponent(folder.name)}',
      );
    }
    if (mounted) context.read<DashboardCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: _onFabTap,
          backgroundColor: VaultColors.accent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: AnimatedRotation(
            turns: _fabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return switch (state) {
              DashboardInitial() ||
              DashboardLoading() => const LoadingIndicator(),
              DashboardError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.read<DashboardCubit>().load(),
              ),
              DashboardLoaded(:final data) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                children: [
                  _Header(isDecoy: _isDecoy),
                  const SizedBox(height: 20),
                  StorageCard(
                    usedLabel: data.usedLabel,
                    totalLabel: data.totalLabel,
                    percent: data.percent,
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 136,
                        ),
                    itemCount: data.folders.length,
                    itemBuilder: (context, index) {
                      final folder = data.folders[index];
                      return GestureDetector(
                        onTap: () => _openFolder(folder),
                        child: FolderCard(folder: folder),
                      );
                    },
                  ),
                ],
              ),
            };
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isDecoy});

  final bool isDecoy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDecoy)
                Text(
                  l10n.decoyGreeting,
                  style: const TextStyle(
                    fontSize: 13,
                    color: VaultColors.textSub,
                  ),
                )
              else
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: VaultColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.unlockedBadge,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: VaultColors.green,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              Text(
                isDecoy ? l10n.decoyVaultTitle : l10n.privateVaultTitle,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: VaultColors.text,
                ),
              ),
            ],
          ),
        ),
        _CircleButton(
          icon: Icons.settings_outlined,
          onTap: () => context.push(AppRoutes.settings),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            getIt<VaultSession>().lock();
            MediaRepositoryImpl.clearDecryptedArtifacts();
            context.go(AppRoutes.calculator);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: VaultColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: VaultColors.cardBorder),
            ),
            child: Text(
              l10n.lockAction,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: VaultColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: VaultColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: VaultColors.cardBorder),
        ),
        child: Icon(icon, size: 20, color: VaultColors.text),
      ),
    );
  }
}
