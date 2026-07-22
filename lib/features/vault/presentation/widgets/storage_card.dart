import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';
import '../theme/vault_colors.dart';

class StorageCard extends StatelessWidget {
  const StorageCard({
    required this.usedLabel,
    required this.totalLabel,
    required this.percent,
    super.key,
  });

  final String usedLabel;
  final String totalLabel;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VaultColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VaultColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.storageUsed,
            style: const TextStyle(fontSize: 13, color: VaultColors.textSub),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$usedLabel / $totalLabel',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: VaultColors.text,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VaultColors.accentLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percent / 100),
                duration: const Duration(milliseconds: 900),
                curve: Curves.fastOutSlowIn,
                builder: (context, value, _) {
                  return Stack(
                    children: [
                      Container(color: VaultColors.progressTrack),
                      FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                VaultColors.accent,
                                VaultColors.accentLight,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Legend(color: VaultColors.accent, label: l10n.legendPhotos),
              const SizedBox(width: 16),
              _Legend(color: VaultColors.green, label: l10n.legendVideos),
              const SizedBox(width: 16),
              _Legend(color: VaultColors.textSub, label: l10n.legendOther),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: VaultColors.textSub),
        ),
      ],
    );
  }
}
