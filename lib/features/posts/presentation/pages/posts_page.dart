import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../cubit/posts_cubit.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PostsCubit>()..fetchPosts(),
      child: const _PostsView(),
    );
  }
}

class _PostsView extends StatelessWidget {
  const _PostsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.postsTitle)),
      body: BlocBuilder<PostsCubit, PostsState>(
        builder: (context, state) {
          return switch (state) {
            PostsInitial() || PostsLoading() => const LoadingIndicator(),
            PostsError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.read<PostsCubit>().fetchPosts(),
              ),
            PostsLoaded(:final posts) when posts.isEmpty =>
              Center(child: Text(context.l10n.emptyList)),
            PostsLoaded(:final posts) => RefreshIndicator(
                onRefresh: () => context.read<PostsCubit>().fetchPosts(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${post.id}')),
                        title: Text(
                          post.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
          };
        },
      ),
    );
  }
}
