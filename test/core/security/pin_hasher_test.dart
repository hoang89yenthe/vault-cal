import 'package:flutter_test/flutter_test.dart';
import 'package:vault_cal/core/security/pin_hasher.dart';

void main() {
  // Fewer iterations keep the test fast; behaviour is identical.
  final hasher = PinHasher(iterations: 1000);

  test('verifies a correct code', () async {
    final stored = await hasher.hash('2468');
    expect(await hasher.verify('2468', stored), isTrue);
  });

  test('rejects a wrong code', () async {
    final stored = await hasher.hash('2468');
    expect(await hasher.verify('1111', stored), isFalse);
  });

  test('produces a different salt each time', () async {
    final a = await hasher.hash('2468');
    final b = await hasher.hash('2468');
    expect(a, isNot(equals(b)));
    expect(await hasher.verify('2468', a), isTrue);
    expect(await hasher.verify('2468', b), isTrue);
  });

  test('rejects malformed stored value', () async {
    expect(await hasher.verify('2468', 'garbage'), isFalse);
  });
}
