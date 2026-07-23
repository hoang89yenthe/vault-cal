import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/credentials_gate.dart';
import '../../../unlock/domain/repositories/credentials_repository.dart';

part 'onboarding_state.dart';

/// First-run setup. Kept intentionally light: an intro, then the two codes
/// every user needs — a secret code and a real PIN (each entered twice). The
/// advanced decoy/duress PIN is opt-in later from Settings, not here.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._credentials) : super(const OnboardingState());

  final CredentialsRepository _credentials;

  static const int _pinLength = 4;
  static const int _secretMin = 4;
  static const int _secretMax = 10;

  String _secret = '';
  String _pendingFirst = '';

  void start() {
    if (state.step == OnboardingStep.intro) {
      emit(state.copyWith(step: OnboardingStep.secret));
    }
  }

  void addDigit(String digit) {
    if (state.busy || state.done || state.step == OnboardingStep.intro) return;
    final max = state.isPinStep ? _pinLength : _secretMax;
    if (state.input.length >= max) return;
    final input = state.input + digit;
    emit(state.copyWith(input: input, clearError: true));
    if (state.isPinStep && input.length == _pinLength) {
      _submit(input);
    }
  }

  void backspace() {
    if (state.input.isEmpty) return;
    emit(
      state.copyWith(input: state.input.substring(0, state.input.length - 1)),
    );
  }

  /// Only used by the secret-code steps (variable length).
  void submitSecret() {
    if (state.busy || state.input.length < _secretMin) return;
    _submit(state.input);
  }

  Future<void> _submit(String value) async {
    switch (state.step) {
      case OnboardingStep.intro:
        return;
      case OnboardingStep.secret:
        _pendingFirst = value;
        emit(state.copyWith(step: OnboardingStep.secretConfirm, input: ''));
      case OnboardingStep.secretConfirm:
        if (value != _pendingFirst) {
          emit(
            state.copyWith(
              step: OnboardingStep.secret,
              input: '',
              error: 'Mã bí mật không khớp, thử lại',
            ),
          );
          return;
        }
        _secret = value;
        emit(state.copyWith(step: OnboardingStep.realPin, input: ''));
      case OnboardingStep.realPin:
        _pendingFirst = value;
        emit(state.copyWith(step: OnboardingStep.realPinConfirm, input: ''));
      case OnboardingStep.realPinConfirm:
        if (value != _pendingFirst) {
          emit(
            state.copyWith(
              step: OnboardingStep.realPin,
              input: '',
              error: 'PIN không khớp, thử lại',
            ),
          );
          return;
        }
        emit(state.copyWith(busy: true));
        await _credentials.initialize(secret: _secret, realPin: value);
        credentialsInitialized.value = true;
        emit(state.copyWith(busy: false, done: true));
    }
  }
}
