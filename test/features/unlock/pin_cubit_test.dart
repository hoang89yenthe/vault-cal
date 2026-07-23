import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_cal/core/session/vault_session.dart';
import 'package:vault_cal/features/intruder/domain/intruder_trigger.dart';
import 'package:vault_cal/features/unlock/domain/entities/pin_match.dart';
import 'package:vault_cal/features/unlock/domain/repositories/credentials_repository.dart';
import 'package:vault_cal/features/unlock/presentation/cubit/pin_cubit.dart';

class MockCredentialsRepository extends Mock implements CredentialsRepository {}

class MockVaultSession extends Mock implements VaultSession {}

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
  late SpyIntruderTrigger intruder;

  setUp(() {
    credentials = MockCredentialsRepository();
    session = MockVaultSession();
    intruder = SpyIntruderTrigger();
    when(
      () => session.activate(isDecoy: any(named: 'isDecoy')),
    ).thenAnswer((_) async {});
  });

  PinCubit build() => PinCubit(credentials, session, intruder);

  group('PinCubit', () {
    blocTest<PinCubit, PinState>(
      'real PIN activates real session and emits real result',
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
      'decoy PIN activates decoy session and emits decoy result',
      build: () {
        when(
          () => credentials.matchPin('1111'),
        ).thenAnswer((_) async => PinMatch.decoy);
        return build();
      },
      act: (cubit) async {
        for (final d in ['1', '1', '1', '1']) {
          await cubit.addDigit(d);
        }
      },
      verify: (_) {
        verify(() => session.activate(isDecoy: true)).called(1);
      },
      expect: () => const [
        PinState(input: '1'),
        PinState(input: '11'),
        PinState(input: '111'),
        PinState(input: '1111'),
        PinState(input: '1111', result: PinResult.decoy),
      ],
    );

    blocTest<PinCubit, PinState>(
      'wrong PIN shows error then resets',
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
      expect: () => const [
        PinState(input: '9'),
        PinState(input: '99'),
        PinState(input: '999'),
        PinState(input: '9999'),
        PinState(input: '9999', error: true),
        PinState(),
      ],
    );

    test('fires intruder trigger on the 3rd wrong attempt', () async {
      when(
        () => credentials.matchPin(any()),
      ).thenAnswer((_) async => PinMatch.none);
      final cubit = build();
      for (var attempt = 0; attempt < 3; attempt++) {
        for (final d in ['9', '9', '9', '9']) {
          await cubit.addDigit(d);
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      expect(intruder.calls, 1);
      expect(intruder.lastCount, 3);
      await cubit.close();
    });
  });
}
