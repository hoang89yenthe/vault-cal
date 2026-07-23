import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_cal/core/security/lockout_service.dart';
import 'package:vault_cal/core/session/vault_session.dart';
import 'package:vault_cal/features/intruder/domain/intruder_trigger.dart';
import 'package:vault_cal/features/unlock/domain/entities/pin_match.dart';
import 'package:vault_cal/features/unlock/domain/repositories/credentials_repository.dart';
import 'package:vault_cal/features/unlock/presentation/cubit/pin_cubit.dart';

class MockCredentialsRepository extends Mock implements CredentialsRepository {}

class MockVaultSession extends Mock implements VaultSession {}

class MockLockoutService extends Mock implements LockoutService {}

class SpyIntruderTrigger implements IntruderTrigger {
  int lastCount = 0;
  int calls = 0;

  @override
  void onFailedAttempts(int attemptCount) {
    calls++;
    lastCount = attemptCount;
  }
}

void main() {
  late MockCredentialsRepository credentials;
  late MockVaultSession session;
  late MockLockoutService lockout;
  late SpyIntruderTrigger intruder;

  setUp(() {
    credentials = MockCredentialsRepository();
    session = MockVaultSession();
    lockout = MockLockoutService();
    intruder = SpyIntruderTrigger();
    when(
      () => session.activate(isDecoy: any(named: 'isDecoy')),
    ).thenAnswer((_) async {});
    when(() => lockout.lockRemaining()).thenAnswer((_) async => null);
    when(() => lockout.reset()).thenAnswer((_) async {});
    when(() => lockout.recordFailure()).thenAnswer((_) async => 1);
  });

  PinCubit build() => PinCubit(credentials, session, intruder, lockout);

  group('PinCubit', () {
    blocTest<PinCubit, PinState>(
      'real PIN activates real session and resets lockout',
      build: () {
        when(
          () => credentials.matchPin('2468'),
        ).thenAnswer((_) async => PinMatch.real);
        return build();
      },
      act: (cubit) async {
        for (final d in ['2', '4', '6', '8']) {
          await cubit.addDigit(d);
        }
      },
      verify: (_) {
        verify(() => session.activate(isDecoy: false)).called(1);
        verify(() => lockout.reset()).called(1);
      },
      expect: () => const [
        PinState(input: '2'),
        PinState(input: '24'),
        PinState(input: '246'),
        PinState(input: '2468'),
        PinState(input: '2468', result: PinResult.real),
      ],
    );

    blocTest<PinCubit, PinState>(
      'wrong PIN records failure, shows error then resets',
      build: () {
        when(
          () => credentials.matchPin(any()),
        ).thenAnswer((_) async => PinMatch.none);
        return build();
      },
      act: (cubit) async {
        for (final d in ['9', '9', '9', '9']) {
          await cubit.addDigit(d);
        }
      },
      wait: const Duration(milliseconds: 500),
      verify: (_) {
        verify(() => lockout.recordFailure()).called(1);
      },
      expect: () => const [
        PinState(input: '9'),
        PinState(input: '99'),
        PinState(input: '999'),
        PinState(input: '9999'),
        PinState(input: '9999', error: true),
        PinState(),
      ],
    );

    test('locks the keypad when lockout is active', () async {
      when(
        () => lockout.lockRemaining(),
      ).thenAnswer((_) async => const Duration(seconds: 20));
      final cubit = build();
      for (final d in ['9', '9', '9', '9']) {
        await cubit.addDigit(d);
      }
      expect(cubit.state.locked, isTrue);
      verifyNever(() => credentials.matchPin(any()));
      await cubit.close();
    });

    test('fires intruder trigger once failures reach the threshold', () async {
      when(
        () => credentials.matchPin(any()),
      ).thenAnswer((_) async => PinMatch.none);
      when(() => lockout.recordFailure()).thenAnswer((_) async => 3);
      final cubit = build();
      for (final d in ['9', '9', '9', '9']) {
        await cubit.addDigit(d);
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(intruder.calls, 1);
      expect(intruder.lastCount, 3);
      await cubit.close();
    });
  });
}
