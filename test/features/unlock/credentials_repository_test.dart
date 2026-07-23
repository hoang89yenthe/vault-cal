import 'package:flutter_test/flutter_test.dart';
import 'package:vault_cal/core/security/pin_hasher.dart';
import 'package:vault_cal/core/storage/secure_storage.dart';
import 'package:vault_cal/features/unlock/data/repositories/credentials_repository_impl.dart';
import 'package:vault_cal/features/unlock/domain/entities/pin_match.dart';
import 'package:vault_cal/core/utils/result.dart';

/// In-memory SecureStorage stand-in.
class FakeSecureStorage implements SecureStorage {
  final Map<String, String> _map = {};

  @override
  Future<bool> contains(String key) async => _map.containsKey(key);

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<void> delete(String key) async => _map.remove(key);
}

void main() {
  late FakeSecureStorage storage;
  late CredentialsRepositoryImpl repo;

  setUp(() async {
    storage = FakeSecureStorage();
    repo = CredentialsRepositoryImpl(storage, PinHasher(iterations: 500));
    await repo.initialize(secret: '1984', realPin: '2468', decoyPin: '1111');
  });

  test('is not initialized before setup, is after', () async {
    final fresh = CredentialsRepositoryImpl(
      FakeSecureStorage(),
      PinHasher(iterations: 500),
    );
    expect(await fresh.isInitialized(), isFalse);
    expect(await repo.isInitialized(), isTrue);
  });

  test('verifies the chosen secret code', () async {
    expect(await repo.verifySecretCode('1984'), isTrue);
    expect(await repo.verifySecretCode('0000'), isFalse);
  });

  test('no codes verify before initialization', () async {
    final fresh = CredentialsRepositoryImpl(
      FakeSecureStorage(),
      PinHasher(iterations: 500),
    );
    expect(await fresh.verifySecretCode('1984'), isFalse);
    expect(await fresh.matchPin('2468'), PinMatch.none);
  });

  test('matches real and decoy PINs', () async {
    expect(await repo.matchPin('2468'), PinMatch.real);
    expect(await repo.matchPin('1111'), PinMatch.decoy);
    expect(await repo.matchPin('9999'), PinMatch.none);
  });

  test('changes the real PIN after verifying the old one', () async {
    final result = await repo.changeCode(
      type: CodeType.realPin,
      oldCode: '2468',
      newCode: '5555',
    );
    expect(result, isA<Ok<void>>());
    expect(await repo.matchPin('5555'), PinMatch.real);
    expect(await repo.matchPin('2468'), PinMatch.none);
  });

  test('rejects change when old code is wrong', () async {
    final result = await repo.changeCode(
      type: CodeType.realPin,
      oldCode: '0000',
      newCode: '5555',
    );
    expect(result, isA<Err<void>>());
    expect(await repo.matchPin('2468'), PinMatch.real);
  });

  test('rejects a new real PIN that collides with the decoy PIN', () async {
    final result = await repo.changeCode(
      type: CodeType.realPin,
      oldCode: '2468',
      newCode: '1111',
    );
    expect(result, isA<Err<void>>());
  });
}
