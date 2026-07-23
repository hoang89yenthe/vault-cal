import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_cal/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:vault_cal/features/unlock/domain/repositories/credentials_repository.dart';

class MockCredentialsRepository extends Mock implements CredentialsRepository {}

void main() {
  late MockCredentialsRepository credentials;

  setUp(() {
    credentials = MockCredentialsRepository();
    when(
      () => credentials.initialize(
        secret: any(named: 'secret'),
        realPin: any(named: 'realPin'),
        decoyPin: any(named: 'decoyPin'),
      ),
    ).thenAnswer((_) async {});
  });

  void enterPin(OnboardingCubit c, String pin) {
    for (final d in pin.split('')) {
      c.addDigit(d);
    }
  }

  test('full happy path initializes with chosen codes', () async {
    final c = OnboardingCubit(credentials);

    // Secret (variable length, needs submitSecret)
    enterPin(c, '1984');
    c.submitSecret();
    expect(c.state.step, OnboardingStep.secretConfirm);
    enterPin(c, '1984');
    c.submitSecret();
    expect(c.state.step, OnboardingStep.realPin);

    // Real PIN (auto-submits at 4 digits)
    enterPin(c, '2468');
    expect(c.state.step, OnboardingStep.realPinConfirm);
    enterPin(c, '2468');
    expect(c.state.step, OnboardingStep.decoyPin);

    // Decoy PIN
    enterPin(c, '1111');
    expect(c.state.step, OnboardingStep.decoyPinConfirm);
    enterPin(c, '1111');
    await Future<void>.delayed(Duration.zero);

    verify(
      () => credentials.initialize(
        secret: '1984',
        realPin: '2468',
        decoyPin: '1111',
      ),
    ).called(1);
    expect(c.state.done, isTrue);
    await c.close();
  });

  test('mismatched confirmation resets that step with an error', () async {
    final c = OnboardingCubit(credentials);
    enterPin(c, '1984');
    c.submitSecret();
    enterPin(c, '9999');
    c.submitSecret();
    expect(c.state.step, OnboardingStep.secret);
    expect(c.state.error, isNotNull);
    await c.close();
  });

  test('decoy PIN cannot equal the real PIN', () async {
    final c = OnboardingCubit(credentials);
    enterPin(c, '1984');
    c.submitSecret();
    enterPin(c, '1984');
    c.submitSecret();
    enterPin(c, '2468');
    enterPin(c, '2468');
    // Decoy same as real → rejected
    enterPin(c, '2468');
    expect(c.state.step, OnboardingStep.decoyPin);
    expect(c.state.error, isNotNull);
    await c.close();
  });
}
