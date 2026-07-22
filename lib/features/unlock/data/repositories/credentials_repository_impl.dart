import '../../../../core/error/failures.dart';
import '../../../../core/security/pin_hasher.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/pin_match.dart';
import '../../domain/repositories/credentials_repository.dart';

class CredentialsRepositoryImpl implements CredentialsRepository {
  CredentialsRepositoryImpl(this._storage, this._hasher);

  final SecureStorage _storage;
  final PinHasher _hasher;

  static const _keySecret = 'cred_secret';
  static const _keyRealPin = 'cred_real_pin';
  static const _keyDecoyPin = 'cred_decoy_pin';

  // Defaults from the design handoff, seeded once on first launch.
  static const _defaultSecret = '1984';
  static const _defaultRealPin = '2468';
  static const _defaultDecoyPin = '1111';

  String _keyFor(CodeType type) => switch (type) {
        CodeType.secret => _keySecret,
        CodeType.realPin => _keyRealPin,
        CodeType.decoyPin => _keyDecoyPin,
      };

  @override
  Future<void> ensureSeeded() async {
    await _seed(_keySecret, _defaultSecret);
    await _seed(_keyRealPin, _defaultRealPin);
    await _seed(_keyDecoyPin, _defaultDecoyPin);
  }

  Future<void> _seed(String key, String value) async {
    if (!await _storage.contains(key)) {
      await _storage.write(key, await _hasher.hash(value));
    }
  }

  @override
  Future<bool> verifySecretCode(String code) async {
    final stored = await _storage.read(_keySecret);
    if (stored == null) return false;
    return _hasher.verify(code, stored);
  }

  @override
  Future<PinMatch> matchPin(String pin) async {
    final real = await _storage.read(_keyRealPin);
    if (real != null && await _hasher.verify(pin, real)) return PinMatch.real;
    final decoy = await _storage.read(_keyDecoyPin);
    if (decoy != null && await _hasher.verify(pin, decoy)) return PinMatch.decoy;
    return PinMatch.none;
  }

  @override
  Future<Result<void>> changeCode({
    required CodeType type,
    required String oldCode,
    required String newCode,
  }) async {
    final key = _keyFor(type);
    final stored = await _storage.read(key);
    if (stored == null || !await _hasher.verify(oldCode, stored)) {
      return const Err(AuthFailure('Current code is incorrect'));
    }
    // A new real PIN must not collide with the decoy PIN and vice-versa.
    if (type == CodeType.realPin || type == CodeType.decoyPin) {
      final otherKey = type == CodeType.realPin ? _keyDecoyPin : _keyRealPin;
      final other = await _storage.read(otherKey);
      if (other != null && await _hasher.verify(newCode, other)) {
        return const Err(AuthFailure('That PIN is already in use'));
      }
    }
    await _storage.write(key, await _hasher.hash(newCode));
    return const Ok(null);
  }
}
