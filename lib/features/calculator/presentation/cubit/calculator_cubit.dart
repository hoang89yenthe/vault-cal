import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../unlock/domain/repositories/credentials_repository.dart';

part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit(this._credentials) : super(const CalculatorState());

  final CredentialsRepository _credentials;

  static const int _maxLength = 15;

  void inputDigit(String digit) {
    if (state.justEvaluated) {
      emit(CalculatorState(current: digit));
      return;
    }
    final current = state.current;
    if (current.length >= _maxLength) return;
    emit(_withCurrent(current == '0' ? digit : current + digit));
  }

  void inputDot() {
    if (state.justEvaluated) {
      emit(const CalculatorState(current: '0.'));
      return;
    }
    if (state.current.contains('.')) return;
    emit(_withCurrent(state.current.isEmpty ? '0.' : '${state.current}.'));
  }

  void setOperator(String op) {
    var acc = state.accumulator;
    if (state.current.isNotEmpty) {
      final value = double.tryParse(state.current) ?? 0;
      acc = (state.pendingOp == null || acc == null)
          ? value
          : _compute(acc, value, state.pendingOp!);
    }
    acc ??= 0;
    emit(
      CalculatorState(
        current: '',
        subline: '${_format(acc)} $op',
        accumulator: acc,
        pendingOp: op,
      ),
    );
  }

  Future<void> evaluate() async {
    if (state.pendingOp == null || state.current.isEmpty) {
      // The disguise trigger: secret code typed as a plain number, then `=`.
      if (state.current.isNotEmpty &&
          await _credentials.verifySecretCode(state.current)) {
        emit(CalculatorState(current: state.current, secretTriggered: true));
      }
      return;
    }
    final a = state.accumulator ?? 0;
    final b = double.tryParse(state.current) ?? 0;
    final result = _compute(a, b, state.pendingOp!);
    emit(
      CalculatorState(
        current: _format(result),
        subline: '${_format(a)} ${state.pendingOp} ${state.current} =',
        justEvaluated: true,
      ),
    );
  }

  void percent() {
    if (state.current.isEmpty) return;
    final value = (double.tryParse(state.current) ?? 0) / 100;
    emit(_withCurrent(_format(value)));
  }

  void backspace() {
    if (state.justEvaluated) {
      emit(const CalculatorState());
      return;
    }
    if (state.current.isEmpty) return;
    final cut = state.current.substring(0, state.current.length - 1);
    emit(_withCurrent(cut.isEmpty ? '0' : cut));
  }

  void clear() => emit(const CalculatorState());

  /// Called after navigation to the unlock flow so the display is clean
  /// when the user comes back.
  void consumeSecret() => emit(const CalculatorState());

  CalculatorState _withCurrent(String current) => CalculatorState(
    current: current,
    subline: state.subline,
    accumulator: state.accumulator,
    pendingOp: state.pendingOp,
  );

  double _compute(double a, double b, String op) => switch (op) {
    '÷' => b == 0 ? double.nan : a / b,
    '×' => a * b,
    '−' => a - b,
    _ => a + b,
  };

  String _format(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.truncate().toString();
    }
    var text = value.toStringAsFixed(8);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    return text.endsWith('.') ? text.substring(0, text.length - 1) : text;
  }
}
