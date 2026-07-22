import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_cal/features/calculator/presentation/cubit/calculator_cubit.dart';
import 'package:vault_cal/features/unlock/domain/repositories/credentials_repository.dart';

class MockCredentialsRepository extends Mock implements CredentialsRepository {}

void main() {
  late MockCredentialsRepository credentials;

  setUp(() {
    credentials = MockCredentialsRepository();
    // Only "1984" is the secret code in these tests.
    when(() => credentials.verifySecretCode(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first == '1984',
    );
  });

  group('CalculatorCubit', () {
    late CalculatorCubit cubit;

    setUp(() => cubit = CalculatorCubit(credentials));
    tearDown(() => cubit.close());

    void type(String keys) {
      for (final k in keys.split('')) {
        cubit.inputDigit(k);
      }
    }

    test('computes a chained expression', () async {
      type('12');
      cubit.setOperator('+');
      type('7');
      await cubit.evaluate();
      expect(cubit.state.current, '19');
      expect(cubit.state.subline, '12 + 7 =');
    });

    test('division by zero shows Error', () async {
      type('5');
      cubit.setOperator('÷');
      type('0');
      await cubit.evaluate();
      expect(cubit.state.current, 'Error');
    });

    test('secret code + equals triggers unlock', () async {
      type('1984');
      await cubit.evaluate();
      expect(cubit.state.secretTriggered, isTrue);
    });

    test('secret code inside an expression does NOT trigger unlock', () async {
      type('1');
      cubit.setOperator('+');
      type('1984');
      await cubit.evaluate();
      expect(cubit.state.secretTriggered, isFalse);
      expect(cubit.state.current, '1985');
    });

    test('consumeSecret resets the display', () async {
      type('1984');
      await cubit.evaluate();
      cubit.consumeSecret();
      expect(cubit.state, const CalculatorState());
    });
  });
}
