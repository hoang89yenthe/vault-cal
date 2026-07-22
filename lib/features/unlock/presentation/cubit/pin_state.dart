part of 'pin_cubit.dart';

enum PinResult { none, real, decoy }

class PinState extends Equatable {
  const PinState({
    this.input = '',
    this.error = false,
    this.result = PinResult.none,
  });

  final String input;
  final bool error;
  final PinResult result;

  @override
  List<Object?> get props => [input, error, result];
}
