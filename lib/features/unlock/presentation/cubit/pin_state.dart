part of 'pin_cubit.dart';

enum PinResult { none, real, decoy }

class PinState extends Equatable {
  const PinState({
    this.input = '',
    this.error = false,
    this.result = PinResult.none,
    this.lockMessage,
  });

  final String input;
  final bool error;
  final PinResult result;

  /// Non-null while the keypad is locked out after too many wrong attempts.
  final String? lockMessage;

  bool get locked => lockMessage != null;

  @override
  List<Object?> get props => [input, error, result, lockMessage];
}
