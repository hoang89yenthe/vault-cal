import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/vault_data.dart';
import '../theme/vault_colors.dart';

class FolderCard extends StatelessWidget {
  const FolderCard({required this.folder, super.key});

  final VaultFolder folder;

  IconData get _icon => switch (folder.icon) {
    VaultFolderIcon.images => Icons.image_outlined,
    VaultFolderIcon.video => Icons.videocam_outlined,
    VaultFolderIcon.documents => Icons.description_outlined,
    VaultFolderIcon.notes => Icons.sticky_note_2_outlined,
    VaultFolderIcon.screenshots => Icons.smartphone_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final tone = folderTone(folder.hue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaultColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VaultColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tone.bg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(_icon, size: 24, color: tone.fg),
              ),
              if (folder.locked)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: VaultColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            folder.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: VaultColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.itemsCount(folder.count),
            style: const TextStyle(fontSize: 13, color: VaultColors.textSub),
          ),
        ],
      ),
    );
  }
}
