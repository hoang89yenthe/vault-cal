part of 'intruder_log_cubit.dart';

sealed class IntruderLogState extends Equatable {
  const IntruderLogState();

  @override
  List<Object?> get props => [];
}

final class IntruderLogLoading extends IntruderLogState {
  const IntruderLogLoading();
}

final class IntruderLogLoaded extends IntruderLogState {
  const IntruderLogLoaded(this.events);

  final List<IntruderEvent> events;

  @override
  List<Object?> get props => [events];
}

final class IntruderLogError extends IntruderLogState {
  const IntruderLogError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
