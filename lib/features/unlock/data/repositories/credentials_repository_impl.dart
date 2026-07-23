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

  static const _keyInitialized = 'cred_initialized';
  static const _keySecret = 'cred_secret';
  static const _keyRealPin = 'cred_real_pin';
  static const _keyDecoyPin = 'cred_decoy_pin';

  String _keyFor(CodeType type) => switch (type) {
    CodeType.secret => _keySecret,
    CodeType.realPin => _keyRealPin,
    CodeType.decoyPin => _keyDecoyPin,
  };

  @override
  Future<bool> isInitialized() async {
    return await _storage.read(_keyInitialized) == '1';
  }

  @override
  Future<void> initialize({
    required String secret,
    required String realPin,
    String? decoyPin,
  }) async {
    await _storage.write(_keySecret, await _hasher.hash(secret));
    await _storage.write(_keyRealPin, await _hasher.hash(realPin));
    if (decoyPin != null) {
      await _storage.write(_keyDecoyPin, await _hasher.hash(decoyPin));
    }
    await _storage.write(_keyInitialized, '1');
  }

  @override
  Future<bool> hasDecoyPin() async {
    return await _storage.read(_keyDecoyPin) != null;
  }

  @override
  Future<Result<void>> setDecoyPin(String pin) async {
    final real = await _storage.read(_keyRealPin);
    if (real != null && await _hasher.verify(pin, real)) {
      return const Err(AuthFailure('PIN giả phải khác PIN thật'));
    }
    await _storage.write(_keyDecoyPin, await _hasher.hash(pin));
    return const Ok(null);
  }

  @override
  Future<bool> verifySecretCode(String code) async {
    final stored = await _storage.read(_keySecret);
    if (stored == null) return false;
    return _hasher.verify(code, stored);
  }

  @override
  Future<PinMatch> matchPin(String pin) async {
    // Constant work: always verify against BOTH hashes before deciding, so the
    // time to open the real vault is indistinguishable from opening the decoy —
    // otherwise a coercer timing the unlock could tell a duress open from a
    // real one and keep pressing.
    final real = await _storage.read(_keyRealPin);
    final decoy = await _storage.read(_keyDecoyPin);
    final realMatch = real != null && await _hasher.verify(pin, real);
    final decoyMatch = decoy != null && await _hasher.verify(pin, decoy);
    if (realMatch) return PinMatch.real;
    if (decoyMatch) return PinMatch.decoy;
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
