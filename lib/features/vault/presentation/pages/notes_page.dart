import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/vault_note.dart';
import '../cubit/notes_cubit.dart';
import '../theme/vault_colors.dart';
import 'note_edit_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotesCubit>()..load(),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        foregroundColor: VaultColors.text,
        title: const Text('Ghi chú mật'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: VaultColors.accent,
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<NotesCubit, NotesState>(
        builder: (context, state) {
          return switch (state) {
            NotesLoading() => const LoadingIndicator(),
            NotesError(:final message) => AppErrorView(
                message: message,
                onRetry: () => context.read<NotesCubit>().load(),
              ),
            NotesLoaded(:final notes) when notes.isEmpty => const Center(
                child: Text(
                  'Chưa có ghi chú nào',
                  style: TextStyle(color: VaultColors.textSub),
                ),
              ),
            NotesLoaded(:final notes) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _NoteCard(note: notes[index]),
              ),
          };
        },
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, [VaultNote? note]) async {
    final cubit = context.read<NotesCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: NoteEditPage(note: note),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final VaultNote note;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<NotesCubit>();
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: VaultColors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => cubit.delete(note.id),
      child: Material(
        color: VaultColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: NoteEditPage(note: note),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.isEmpty ? '(Không tiêu đề)' : note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VaultColors.text,
                  ),
                ),
                if (note.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: VaultColors.textSub,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
