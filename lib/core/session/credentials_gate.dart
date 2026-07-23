import 'package:flutter/foundation.dart';

/// Whether the user has completed first-run credential setup. Drives the
/// router redirect between onboarding and the calculator. Loaded once at
/// startup and flipped to true when onboarding finishes.
final ValueNotifier<bool> credentialsInitialized = ValueNotifier<bool>(false);
