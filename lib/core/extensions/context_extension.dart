import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);
}
