import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calculator/presentation/pages/calculator_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../../features/intruder/presentation/pages/intruder_log_page.dart';
import '../../features/settings/presentation/pages/change_code_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/unlock/domain/entities/pin_match.dart';
import '../../features/unlock/presentation/pages/pin_page.dart';
import '../../features/unlock/presentation/pages/unlock_page.dart';
import '../../features/vault/domain/entities/vault_file.dart';
import '../../features/vault/presentation/pages/dashboard_page.dart';
import '../../features/vault/presentation/pages/folder_page.dart';
import '../../features/vault/presentation/pages/media_viewer_page.dart';
import '../../features/vault/presentation/pages/notes_page.dart';

abstract final class AppRoutes {
  static const String calculator = '/';
  static const String unlock = '/unlock';
  static const String pin = '/pin';
  static const String vault = '/vault';
  static const String folder = '/vault/folder';
  static const String viewer = '/vault/viewer';
  static const String notes = '/vault/notes';
  static const String settings = '/settings';
  static const String changeCode = '/settings/change-code';
  static const String intruderLog = '/settings/intruder-log';

  // Base-project demo screens.
  static const String demo = '/demo';
  static const String posts = '/posts';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.calculator,
  routes: [
    GoRoute(
      path: AppRoutes.calculator,
      pageBuilder: (context, state) =>
          _slideFadePage(state, const CalculatorPage()),
    ),
    GoRoute(
      path: AppRoutes.unlock,
      pageBuilder: (context, state) =>
          _slideFadePage(state, const UnlockPage()),
    ),
    GoRoute(
      path: AppRoutes.pin,
      pageBuilder: (context, state) => _slideFadePage(state, const PinPage()),
    ),
    GoRoute(
      path: AppRoutes.vault,
      pageBuilder: (context, state) =>
          _slideFadePage(state, const DashboardPage()),
    ),
    GoRoute(
      path: '${AppRoutes.folder}/:category',
      pageBuilder: (context, state) {
        final category = MediaCategoryX.fromKey(
          state.pathParameters['category']!,
        );
        final title = state.uri.queryParameters['title'] ?? '';
        return _slideFadePage(
          state,
          FolderPage(category: category, title: title),
        );
      },
    ),
    GoRoute(
      path: '${AppRoutes.viewer}/:id',
      pageBuilder: (context, state) => _slideFadePage(
        state,
        MediaViewerPage(fileId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: AppRoutes.notes,
      pageBuilder: (context, state) => _slideFadePage(state, const NotesPage()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) =>
          _slideFadePage(state, const SettingsPage()),
    ),
    GoRoute(
      path: '${AppRoutes.changeCode}/:type',
      pageBuilder: (context, state) {
        final type = CodeType.values.byName(state.pathParameters['type']!);
        return _slideFadePage(state, ChangeCodePage(type: type));
      },
    ),
    GoRoute(
      path: AppRoutes.intruderLog,
      pageBuilder: (context, state) =>
          _slideFadePage(state, const IntruderLogPage()),
    ),
    GoRoute(
      path: AppRoutes.demo,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.posts,
      builder: (context, state) => const PostsPage(),
    ),
  ],
);

/// iOS-style push transition: the incoming page slides in opaque from the
/// right while the outgoing page parallaxes left and dims for depth. The
/// incoming page never goes translucent, so light and dark screens never
/// bleed through each other.
CustomTransitionPage<void> _slideFadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final leave = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slideIn = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(enter);
      final parallax = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.22, 0),
      ).animate(leave);
      final dim = Tween<double>(begin: 0, end: 0.32).animate(leave);

      return SlideTransition(
        position: parallax,
        child: SlideTransition(
          position: slideIn,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              child,
              Positioned.fill(
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: dim,
                    child: const ColoredBox(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
