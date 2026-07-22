import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/platform/app_icon_channel.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../purchases/domain/purchase_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._storage, this._purchases)
      : super(_restore(_storage, _purchases.isPremium)) {
    _premiumSub = _purchases.premiumStream.listen((premium) {
      emit(state.copyWith(premium: premium));
    });
  }

  static const String _kFingerprint = 'settings_fingerprint';
  static const String _kIntruder = 'settings_intruder';
  static const String _kDisguise = 'settings_disguise';

  final LocalStorage _storage;
  final PurchaseService _purchases;
  late final StreamSubscription<bool> _premiumSub;

  static SettingsState _restore(LocalStorage storage, bool premium) {
    return SettingsState(
      fingerprint: storage.getBool(_kFingerprint) ?? true,
      intruder: storage.getBool(_kIntruder) ?? false,
      disguise: DisguiseIcon.values.asNameMap()[
              storage.getString(_kDisguise) ?? ''] ??
          DisguiseIcon.calc,
      premium: premium,
    );
  }

  Future<void> toggleFingerprint() async {
    final value = !state.fingerprint;
    emit(state.copyWith(fingerprint: value));
    await _storage.setBool(_kFingerprint, value: value);
  }

  /// Returns false when the feature is premium-gated — the caller should
  /// open the paywall instead.
  bool tryToggleIntruder() {
    if (!state.premium) return false;
    final value = !state.intruder;
    emit(state.copyWith(intruder: value));
    _storage.setBool(_kIntruder, value: value);
    return true;
  }

  /// Returns false when the chosen icon is premium-gated.
  bool trySelectDisguise(DisguiseIcon icon) {
    if (icon != DisguiseIcon.calc && !state.premium) return false;
    emit(state.copyWith(disguise: icon));
    _storage.setString(_kDisguise, icon.name);
    unawaited(AppIconChannel.setDisguise(icon));
    return true;
  }

  @override
  Future<void> close() {
    _premiumSub.cancel();
    return super.close();
  }
}
