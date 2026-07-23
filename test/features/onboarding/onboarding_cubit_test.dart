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

  void type(OnboardingCubit c, String digits) {
    for (final d in digits.split('')) {
      c.addDigit(d);
    }
  }

  test('starts on the intro step', () {
    expect(OnboardingCubit(credentials).state.step, OnboardingStep.intro);
  });

  test('happy path sets secret + real PIN, no decoy', () async {
    final c = OnboardingCubit(credentials);
    c.start();
    expect(c.state.step, OnboardingStep.secret);

    type(c, '1984');
    c.submitSecret();
    expect(c.state.step, OnboardingStep.secretConfirm);
    type(c, '1984');
    c.submitSecret();
    expect(c.state.step, OnboardingStep.realPin);

    type(c, '2468'); // auto-advance at 4 digits
    expect(c.state.step, OnboardingStep.realPinConfirm);
    type(c, '2468');
    await Future<void>.delayed(Duration.zero);

    verify(
      () => credentials.initialize(secret: '1984', realPin: '2468'),
    ).called(1);
    expect(c.state.done, isTrue);
    await c.close();
  });

  test('mismatched PIN confirmation resets with an error', () async {
    final c = OnboardingCubit(credentials);
    c.start();
    type(c, '1984');
    c.submitSecret();
    type(c, '1984');
    c.submitSecret();
    type(c, '2468');
    type(c, '9999');
    expect(c.state.step, OnboardingStep.realPin);
    expect(c.state.error, isNotNull);
    await c.close();
  });
}
