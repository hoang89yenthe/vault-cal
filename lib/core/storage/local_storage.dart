import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] so features never depend on the
/// package directly and storage can be swapped or mocked in tests.
class LocalStorage {
  const LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}
