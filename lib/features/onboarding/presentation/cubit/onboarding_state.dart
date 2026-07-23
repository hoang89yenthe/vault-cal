part of 'onboarding_cubit.dart';

enum OnboardingStep { intro, secret, secretConfirm, realPin, realPinConfirm }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = OnboardingStep.intro,
    this.input = '',
    this.error,
    this.busy = false,
    this.done = false,
  });

  final OnboardingStep step;
  final String input;
  final String? error;
  final bool busy;
  final bool done;

  /// PIN steps take exactly 4 digits; the secret code is variable length.
  bool get isPinStep =>
      step != OnboardingStep.secret && step != OnboardingStep.secretConfirm;

  OnboardingState copyWith({
    OnboardingStep? step,
    String? input,
    String? error,
    bool clearError = false,
    bool? busy,
    bool? done,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      input: input ?? this.input,
      error: clearError ? null : (error ?? this.error),
      busy: busy ?? this.busy,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [step, input, error, busy, done];
}
