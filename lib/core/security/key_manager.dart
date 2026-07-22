import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../error/exceptions.dart';
import '../storage/secure_storage.dart';

/// Owns the per-namespace master keys and derives subordinate keys.
///
/// Key hierarchy (each namespace `real` / `decoy` is fully independent):
///   masterKey (32B random, in Keystore/Keychain)
///     ├─ HKDF("db")  → SQLCipher key for that namespace's database
///     └─ wraps each file's DEK via AES-GCM
class KeyManager {
  KeyManager(this._storage);

  final SecureStorage _storage;
  final _aesGcm = AesGcm.with256bits();
  final Map<String, SecretKey> _masterCache = {};

  static String _masterKeyId(String namespace) => 'mk_$namespace';

  /// Returns the master key for [namespace], creating it on first use.
  Future<SecretKey> masterKey(String namespace) async {
    final cached = _masterCache[namespace];
    if (cached != null) return cached;

    final id = _masterKeyId(namespace);
    final existing = await _storage.read(id);
    final Uint8List bytes;
    if (existing != null) {
      bytes = base64.decode(existing);
    } else {
      bytes = _randomBytes(32);
      await _storage.write(id, base64.encode(bytes));
    }
    final key = SecretKey(bytes);
    _masterCache[namespace] = key;
    return key;
  }

  /// Fails closed if a namespace has a database but the master key is gone —
  /// the data is unrecoverable and we must not silently create a new key.
  Future<void> assertRecoverable(
    String namespace, {
    required bool dbExists,
  }) async {
    if (dbExists && !await _storage.contains(_masterKeyId(namespace))) {
      throw const CryptoException('Vault key missing — data unrecoverable');
    }
  }

  /// Derives the hex SQLCipher passphrase for [namespace].
  Future<String> databaseKey(String namespace) async {
    final master = await masterKey(namespace);
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derived = await hkdf.deriveKey(
      secretKey: master,
      info: utf8.encode('db'),
      nonce: utf8.encode(namespace),
    );
    final bytes = await derived.extractBytes();
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Wraps a freshly generated data-encryption key for storage in the DB.
  Future<({Uint8List dek, String wrapped})> newWrappedDek(
    String namespace,
  ) async {
    final dek = _randomBytes(32);
    final wrapped = await _wrap(namespace, dek);
    return (dek: dek, wrapped: wrapped);
  }

  Future<Uint8List> unwrapDek(String namespace, String wrapped) async {
    final master = await masterKey(namespace);
    final box = SecretBox.fromConcatenation(
      base64.decode(wrapped),
      nonceLength: 12,
      macLength: 16,
    );
    final clear = await _aesGcm.decrypt(box, secretKey: master);
    return Uint8List.fromList(clear);
  }

  Future<String> _wrap(String namespace, Uint8List dek) async {
    final master = await masterKey(namespace);
    final box = await _aesGcm.encrypt(dek, secretKey: master);
    return base64.encode(box.concatenation());
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }
}
