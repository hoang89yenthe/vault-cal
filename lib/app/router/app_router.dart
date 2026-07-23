import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/credentials_gate.dart';
import '../../features/calculator/presentation/pages/calculator_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
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
  static const String onboarding = '/onboarding';
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
  refreshListenable: credentialsInitialized,
  redirect: (context, state) {
    final ready = credentialsInitialized.value;
    final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
    // Force first-run setup before anything else; never show onboarding again.
    if (!ready && !atOnboarding) return AppRoutes.onboarding;
    if (ready && atOnboarding) return AppRoutes.calculator;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      pageBuilder: (context, state) => _page(state, const OnboardingPage()),
    ),
    GoRoute(
      path: AppRoutes.calculator,
      pageBuilder: (context, state) => _page(state, const CalculatorPage()),
    ),
    GoRoute(
      path: AppRoutes.unlock,
      pageBuilder: (context, state) => _page(state, const UnlockPage()),
    ),
    GoRoute(
      path: AppRoutes.pin,
      pageBuilder: (context, state) => _page(state, const PinPage()),
    ),
    GoRoute(
      path: AppRoutes.vault,
      pageBuilder: (context, state) => _page(state, const DashboardPage()),
    ),
    GoRoute(
      path: '${AppRoutes.folder}/:category',
      pageBuilder: (context, state) {
        final category = MediaCategoryX.fromKey(
          state.pathParameters['category']!,
        );
        final title = state.uri.queryParameters['title'] ?? '';
        return _page(state, FolderPage(category: category, title: title));
      },
    ),
    GoRoute(
      path: '${AppRoutes.viewer}/:id',
      pageBuilder: (context, state) =>
          _page(state, MediaViewerPage(fileId: state.pathParameters['id']!)),
    ),
    GoRoute(
      path: AppRoutes.notes,
      pageBuilder: (context, state) => _page(state, const NotesPage()),
    ),
    GoRoute(
      path: AppRoutes.settings,
      pageBuilder: (context, state) => _page(state, const SettingsPage()),
    ),
    GoRoute(
      path: '${AppRoutes.changeCode}/:type',
      pageBuilder: (context, state) {
        final type = CodeType.values.byName(state.pathParameters['type']!);
        final firstTime = state.uri.queryParameters['firstTime'] == '1';
        return _page(state, ChangeCodePage(type: type, firstTime: firstTime));
      },
    ),
    GoRoute(
      path: AppRoutes.intruderLog,
      pageBuilder: (context, state) => _page(state, const IntruderLogPage()),
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

/// iOS-style page: the native push transition (incoming slides in opaque,
/// outgoing parallaxes + dims) PLUS the interactive swipe-from-left-edge back
/// gesture. Screens reached via `go()` (calculator → unlock → PIN → vault)
/// replace the stack, so they have no back target; pushed screens (settings,
/// folders, viewer, notes, …) get swipe-back for free.
Page<void> _page(GoRouterState state, Widget child) {
  return CupertinoPage<void>(key: state.pageKey, child: child);
}
