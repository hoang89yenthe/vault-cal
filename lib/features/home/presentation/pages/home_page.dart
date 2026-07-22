import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme_cubit.dart';
import '../../../../core/extensions/context_extension.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.welcomeMessage,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(l10n.postsDemo),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.posts),
                ),
                const Divider(height: 1),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: Text(l10n.darkMode),
                      value: mode == ThemeMode.dark,
                      onChanged: (_) => context.read<ThemeCubit>().toggle(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
