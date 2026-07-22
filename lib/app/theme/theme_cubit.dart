import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';

/// Holds the app-wide [ThemeMode] and persists it across launches.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_restore(_storage));

  static const String _storageKey = 'theme_mode';

  final LocalStorage _storage;

  static ThemeMode _restore(LocalStorage storage) {
    return switch (storage.getString(_storageKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _storage.setString(_storageKey, mode.name);
  }

  Future<void> toggle() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
}
