import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../unlock/domain/entities/pin_match.dart';
import '../../../unlock/domain/repositories/credentials_repository.dart';

part 'change_code_state.dart';

/// Reusable 3-step flow: verify current code → enter new → confirm new.
/// Parameterized by [CodeType] so it serves the secret code and both PINs.
class ChangeCodeCubit extends Cubit<ChangeCodeState> {
  ChangeCodeCubit(this._credentials, this.type)
    : super(const ChangeCodeState());

  final CredentialsRepository _credentials;
  final CodeType type;

  static const int _codeLength = 4;

  Future<void> addDigit(String digit) async {
    if (state.busy || state.done || state.input.length >= _codeLength) return;
    final input = state.input + digit;
    emit(state.copyWith(input: input, clearError: true));
    if (input.length == _codeLength) {
      await _submitStep(input);
    }
  }

  void backspace() {
    if (state.input.isEmpty) return;
    emit(
      state.copyWith(input: state.input.substring(0, state.input.length - 1)),
    );
  }

  Future<void> _submitStep(String code) async {
    switch (state.step) {
      case ChangeCodeStep.verifyOld:
        emit(state.copyWith(busy: true));
        final ok = await _verifyCurrent(code);
        if (ok) {
          emit(
            state.copyWith(
              step: ChangeCodeStep.enterNew,
              oldCode: code,
              input: '',
              busy: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              input: '',
              error: 'Mã hiện tại không đúng',
              busy: false,
            ),
          );
        }
      case ChangeCodeStep.enterNew:
        emit(
          state.copyWith(
            step: ChangeCodeStep.confirmNew,
            newCode: code,
            input: '',
          ),
        );
      case ChangeCodeStep.confirmNew:
        if (code != state.newCode) {
          emit(
            state.copyWith(
              step: ChangeCodeStep.enterNew,
              newCode: '',
              input: '',
              error: 'Mã xác nhận không khớp',
            ),
          );
          return;
        }
        emit(state.copyWith(busy: true));
        final result = await _credentials.changeCode(
          type: type,
          oldCode: state.oldCode,
          newCode: code,
        );
        switch (result) {
          case Ok():
            emit(state.copyWith(done: true, busy: false));
          case Err(:final failure):
            emit(
              state.copyWith(
                step: ChangeCodeStep.enterNew,
                newCode: '',
                input: '',
                error: failure.message,
                busy: false,
              ),
            );
        }
    }
  }

  Future<bool> _verifyCurrent(String code) async {
    if (type == CodeType.secret) {
      return _credentials.verifySecretCode(code);
    }
    final match = await _credentials.matchPin(code);
    return switch (type) {
      CodeType.realPin => match == PinMatch.real,
      CodeType.decoyPin => match == PinMatch.decoy,
      CodeType.secret => false,
    };
  }
}
