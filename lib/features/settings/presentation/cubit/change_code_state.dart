part of 'change_code_cubit.dart';

enum ChangeCodeStep { verifyOld, enterNew, confirmNew }

class ChangeCodeState extends Equatable {
  const ChangeCodeState({
    this.step = ChangeCodeStep.verifyOld,
    this.input = '',
    this.oldCode = '',
    this.newCode = '',
    this.error,
    this.done = false,
    this.busy = false,
  });

  final ChangeCodeStep step;
  final String input;
  final String oldCode;
  final String newCode;
  final String? error;
  final bool done;
  final bool busy;

  ChangeCodeState copyWith({
    ChangeCodeStep? step,
    String? input,
    String? oldCode,
    String? newCode,
    String? error,
    bool clearError = false,
    bool? done,
    bool? busy,
  }) {
    return ChangeCodeState(
      step: step ?? this.step,
      input: input ?? this.input,
      oldCode: oldCode ?? this.oldCode,
      newCode: newCode ?? this.newCode,
      error: clearError ? null : (error ?? this.error),
      done: done ?? this.done,
      busy: busy ?? this.busy,
    );
  }

  @override
  List<Object?> get props => [step, input, oldCode, newCode, error, done, busy];
}
