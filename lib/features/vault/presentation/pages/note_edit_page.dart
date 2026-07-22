import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/vault_note.dart';
import '../cubit/notes_cubit.dart';
import '../theme/vault_colors.dart';

class NoteEditPage extends StatefulWidget {
  const NoteEditPage({this.note, super.key});

  final VaultNote? note;

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late final TextEditingController _title =
      TextEditingController(text: widget.note?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.note?.body ?? '');

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty && body.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    await context.read<NotesCubit>().save(
          id: widget.note?.id,
          title: title,
          body: body,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: VaultColors.background,
        foregroundColor: VaultColors.text,
        title: Text(widget.note == null ? 'Ghi chú mới' : 'Sửa ghi chú'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              style: const TextStyle(
                color: VaultColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Tiêu đề',
                hintStyle: TextStyle(color: VaultColors.textFaint),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: VaultColors.divider),
            Expanded(
              child: TextField(
                controller: _body,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: VaultColors.text, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Nội dung ghi chú…',
                  hintStyle: TextStyle(color: VaultColors.textFaint),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
