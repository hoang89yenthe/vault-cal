import 'package:flutter_test/flutter_test.dart';
import 'package:vault_cal/core/security/lockout_service.dart';
import 'package:vault_cal/core/storage/secure_storage.dart';

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
  late LockoutService lockout;
  late int now;

  setUp(() {
    storage = FakeSecureStorage();
    lockout = LockoutService(storage);
    now = 1000000;
    lockout.debugSetClock(() => now);
  });

  test('no lockout below the threshold', () async {
    for (var i = 0; i < 4; i++) {
      await lockout.recordFailure();
    }
    expect(await lockout.lockRemaining(), isNull);
  });

  test('locks after 5 failures and clears when the window passes', () async {
    for (var i = 0; i < 5; i++) {
      await lockout.recordFailure();
    }
    final remaining = await lockout.lockRemaining();
    expect(remaining, isNotNull);
    expect(remaining!.inSeconds, greaterThan(0));

    now += const Duration(seconds: 31).inMilliseconds;
    expect(await lockout.lockRemaining(), isNull);
  });

  test('backoff escalates with more failures', () async {
    for (var i = 0; i < 5; i++) {
      await lockout.recordFailure();
    }
    final first = (await lockout.lockRemaining())!.inSeconds;
    for (var i = 5; i < 10; i++) {
      await lockout.recordFailure();
    }
    final second = (await lockout.lockRemaining())!.inSeconds;
    expect(second, greaterThan(first));
  });

  test('reset clears count and lock', () async {
    for (var i = 0; i < 6; i++) {
      await lockout.recordFailure();
    }
    await lockout.reset();
    expect(await lockout.lockRemaining(), isNull);
    // Next failure starts the count over → still below threshold.
    await lockout.recordFailure();
    expect(await lockout.lockRemaining(), isNull);
  });
}
