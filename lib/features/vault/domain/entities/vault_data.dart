import 'package:equatable/equatable.dart';

enum VaultFolderIcon { images, video, documents, notes, screenshots }

class VaultFolder extends Equatable {
  const VaultFolder({
    required this.name,
    required this.count,
    required this.hue,
    required this.icon,
    this.locked = false,
  });

  final String name;
  final int count;

  /// oklch hue from the design tokens; mapped to colors in presentation.
  final int hue;
  final VaultFolderIcon icon;
  final bool locked;

  @override
  List<Object?> get props => [name, count, hue, icon, locked];
}

class VaultData extends Equatable {
  const VaultData({
    required this.isDecoy,
    required this.usedLabel,
    required this.totalLabel,
    required this.percent,
    required this.folders,
  });

  final bool isDecoy;
  final String usedLabel;
  final String totalLabel;

  /// 0–100.
  final int percent;
  final List<VaultFolder> folders;

  @override
  List<Object?> get props => [isDecoy, usedLabel, totalLabel, percent, folders];
}
