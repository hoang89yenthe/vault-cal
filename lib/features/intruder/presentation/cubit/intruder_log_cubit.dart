import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/intruder_event.dart';
import '../../domain/repositories/intruder_repository.dart';

part 'intruder_log_state.dart';

class IntruderLogCubit extends Cubit<IntruderLogState> {
  IntruderLogCubit(this._repository) : super(const IntruderLogLoading());

  final IntruderRepository _repository;

  Future<void> load() async {
    emit(const IntruderLogLoading());
    final result = await _repository.listEvents();
    switch (result) {
      case Ok(:final value):
        emit(IntruderLogLoaded(value));
      case Err(:final failure):
        emit(IntruderLogError(failure.message));
    }
  }
}
