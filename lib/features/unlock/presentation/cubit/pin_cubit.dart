import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/session/vault_session.dart';
import '../../../intruder/domain/intruder_trigger.dart';
import '../../domain/entities/pin_match.dart';
import '../../domain/repositories/credentials_repository.dart';

part 'pin_state.dart';

/// Layer-2 PIN with the duress mechanic: the real PIN opens the real vault,
/// the decoy PIN silently opens the decoy vault. Three wrong attempts fire the
/// intruder trigger.
class PinCubit extends Cubit<PinState> {
  PinCubit(this._credentials, this._session, this._intruder)
    : super(const PinState());

  final CredentialsRepository _credentials;
  final VaultSession _session;
  final IntruderTrigger _intruder;

  static const Duration _errorReset = Duration(milliseconds: 450);
  static const int _intruderThreshold = 3;

  int _wrongAttempts = 0;

  Future<void> addDigit(String digit) async {
    if (state.error ||
        state.result != PinResult.none ||
        state.input.length >= 4) {
      return;
    }

    // Reflect the tap immediately so the 4th dot fills before the (async)
    // key-derivation check runs — otherwise the last digit feels laggy.
    final input = state.input + digit;
    emit(PinState(input: input));
    if (input.length < 4) return;

    final match = await _credentials.matchPin(input);
    switch (match) {
      case PinMatch.real:
        _wrongAttempts = 0;
        await _session.activate(isDecoy: false);
        emit(PinState(input: input, result: PinResult.real));
      case PinMatch.decoy:
        _wrongAttempts = 0;
        await _session.activate(isDecoy: true);
        emit(PinState(input: input, result: PinResult.decoy));
      case PinMatch.none:
        _wrongAttempts++;
        if (_wrongAttempts >= _intruderThreshold) {
          _intruder.onFailedAttempts(_wrongAttempts);
        }
        emit(PinState(input: input, error: true));
        await Future<void>.delayed(_errorReset);
        if (!isClosed) emit(const PinState());
    }
  }

  void backspace() {
    if (state.error || state.input.isEmpty) return;
    emit(PinState(input: state.input.substring(0, state.input.length - 1)));
  }
}
