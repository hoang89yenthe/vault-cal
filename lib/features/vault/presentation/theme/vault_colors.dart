import 'package:flutter/material.dart';

/// Vault / Dashboard / Settings palette — always dark, per the handoff.
abstract final class VaultColors {
  static const Color background = Color(0xFF0C0C0F);
  static const Color card = Color(0xFF16161B);
  static const Color cardBorder = Color(0xFF23232B);
  static const Color divider = Color(0xFF202027);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSub = Color(0xFF8A8A92);
  static const Color textFaint = Color(0xFF6A6A72);
  static const Color green = Color(0xFF48D18A);
  static const Color accent = Color(0xFF5B6FE0);
  static const Color accentLight = Color(0xFF8AB0FF);
  static const Color red = Color(0xFFE5484D);
  static const Color gold = Color(0xFFF5C518);
  static const Color premiumCardBg = Color(0xFF1B1810);
  static const Color premiumCardBorder = Color(0xFF423916);
  static const Color progressTrack = Color(0xFF26262B);
}

/// Folder icon tile colors — hex approximations of the handoff's
/// oklch(0.33 0.07 H) background / oklch(0.76 0.15 H) foreground per hue.
({Color bg, Color fg}) folderTone(int hue) => switch (hue) {
      255 => (bg: const Color(0xFF212C4E), fg: const Color(0xFF8FB0FF)),
      25 => (bg: const Color(0xFF46241B), fg: const Color(0xFFFF9E8A)),
      150 => (bg: const Color(0xFF143526), fg: const Color(0xFF4ED39B)),
      305 => (bg: const Color(0xFF3B2148), fg: const Color(0xFFDB9BF2)),
      200 => (bg: const Color(0xFF0F3542), fg: const Color(0xFF55C6E8)),
      _ => (bg: const Color(0xFF3C2E12), fg: const Color(0xFFE3B45C)),
    };
