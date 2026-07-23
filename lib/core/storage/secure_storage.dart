import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper over [FlutterSecureStorage] (Android Keystore / iOS Keychain)
/// so features never depend on the package directly and it can be mocked.
class SecureStorage {
  const SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _android = AndroidOptions(encryptedSharedPreferences: true);

  // ThisDeviceOnly keeps the master keys and PIN hashes OUT of encrypted device
  // backups and prevents restoring them onto another device — closing the
  // "extract keys from an iTunes/Finder backup" path. AfterFirstUnlock still
  // allows the app to read them in the background.
  static const _ios = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  Future<String?> read(String key) =>
      _storage.read(key: key, aOptions: _android, iOptions: _ios);

  Future<void> write(String key, String value) => _storage.write(
    key: key,
    value: value,
    aOptions: _android,
    iOptions: _ios,
  );

  Future<bool> contains(String key) =>
      _storage.containsKey(key: key, aOptions: _android, iOptions: _ios);

  Future<void> delete(String key) =>
      _storage.delete(key: key, aOptions: _android, iOptions: _ios);
}
