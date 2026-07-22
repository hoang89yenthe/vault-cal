import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper over [FlutterSecureStorage] (Android Keystore / iOS Keychain)
/// so features never depend on the package directly and it can be mocked.
class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _options = AndroidOptions(encryptedSharedPreferences: true);

  Future<String?> read(String key) =>
      _storage.read(key: key, aOptions: _options);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value, aOptions: _options);

  Future<bool> contains(String key) =>
      _storage.containsKey(key: key, aOptions: _options);

  Future<void> delete(String key) =>
      _storage.delete(key: key, aOptions: _options);
}
