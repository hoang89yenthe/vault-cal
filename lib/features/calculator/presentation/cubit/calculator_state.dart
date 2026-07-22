part of 'calculator_cubit.dart';

class CalculatorState extends Equatable {
  const CalculatorState({
    this.current = '0',
    this.subline = '',
    this.accumulator,
    this.pendingOp,
    this.justEvaluated = false,
    this.secretTriggered = false,
  });

  /// Digits currently being typed (or last result).
  final String current;

  /// Small expression line shown above the main display.
  final String subline;

  final double? accumulator;
  final String? pendingOp;
  final bool justEvaluated;

  /// True when the secret code was entered followed by `=`.
  final bool secretTriggered;

  @override
  List<Object?> get props =>
      [current, subline, accumulator, pendingOp, justEvaluated, secretTriggered];
}
