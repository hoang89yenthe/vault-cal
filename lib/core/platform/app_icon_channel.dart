import 'package:flutter/services.dart';

import '../../features/settings/presentation/cubit/settings_cubit.dart';

/// Switches the launcher icon between the calculator disguise and the premium
/// Weather / Compass aliases (Android activity-alias). No-op on platforms that
/// don't implement the channel.
abstract final class AppIconChannel {
  static const MethodChannel _channel = MethodChannel('vault/app_icon');

  static Future<void> setDisguise(DisguiseIcon icon) async {
    try {
      await _channel.invokeMethod<void>('setIcon', {'icon': icon.name});
    } on PlatformException {
      // Ignore on devices/launchers that don't support alias switching.
    } on MissingPluginException {
      // Channel not wired (e.g. iOS/web) — silently ignore.
    }
  }
}
