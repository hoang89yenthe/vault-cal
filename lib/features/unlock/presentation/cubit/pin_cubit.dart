import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/security/lockout_service.dart';
import '../../../../core/session/vault_session.dart';
import '../../../intruder/domain/intruder_trigger.dart';
import '../../domain/entities/pin_match.dart';
import '../../domain/repositories/credentials_repository.dart';

part 'pin_state.dart';

/// Layer-2 PIN with the duress mechanic: the real PIN opens the real vault,
/// the decoy PIN silently opens the decoy vault. Wrong attempts feed a
/// persistent, escalating lockout and (from the 3rd) the intruder trigger.
class PinCubit extends Cubit<PinState> {
  PinCubit(this._credentials, this._session, this._intruder, this._lockout)
    : super(const PinState());

  final CredentialsRepository _credentials;
  final VaultSession _session;
  final IntruderTrigger _intruder;
  final LockoutService _lockout;

  static const Duration _errorReset = Duration(milliseconds: 450);
  static const int _intruderThreshold = 3;

  /// Shows any active lockout when the screen opens.
  Future<void> checkLock() async {
    final remaining = await _lockout.lockRemaining();
    if (remaining != null && !isClosed) {
      emit(PinState(lockMessage: _lockText(remaining)));
    }
  }

  Future<void> addDigit(String digit) async {
    if (state.error ||
        state.locked ||
        state.result != PinResult.none ||
        state.input.length >= 4) {
      return;
    }

    final input = state.input + digit;
    emit(PinState(input: input));
    if (input.length < 4) return;

    // Enforce lockout before doing any verification work.
    final remaining = await _lockout.lockRemaining();
    if (remaining != null) {
      emit(PinState(lockMessage: _lockText(remaining)));
      return;
    }

    final match = await _credentials.matchPin(input);
    switch (match) {
      case PinMatch.real:
        await _lockout.reset();
        await _session.activate(isDecoy: false);
        emit(PinState(input: input, result: PinResult.real));
      case PinMatch.decoy:
        await _lockout.reset();
        await _session.activate(isDecoy: true);
        emit(PinState(input: input, result: PinResult.decoy));
      case PinMatch.none:
        final count = await _lockout.recordFailure();
        if (count >= _intruderThreshold) {
          _intruder.onFailedAttempts(count);
        }
        final locked = await _lockout.lockRemaining();
        if (locked != null) {
          emit(PinState(lockMessage: _lockText(locked)));
        } else {
          emit(PinState(input: input, error: true));
          await Future<void>.delayed(_errorReset);
          if (!isClosed) emit(const PinState());
        }
    }
  }

  void backspace() {
    if (state.error || state.locked || state.input.isEmpty) return;
    emit(PinState(input: state.input.substring(0, state.input.length - 1)));
  }

  String _lockText(Duration d) {
    if (d.inMinutes >= 1) {
      return 'Nhập sai quá nhiều. Thử lại sau ${d.inMinutes + 1} phút';
    }
    return 'Nhập sai quá nhiều. Thử lại sau ${d.inSeconds + 1} giây';
  }
}
