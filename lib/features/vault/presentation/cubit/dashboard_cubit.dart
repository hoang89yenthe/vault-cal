import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/vault_data.dart';
import '../../domain/repositories/vault_repository.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardInitial());

  final VaultRepository _repository;

  Future<void> load() async {
    emit(const DashboardLoading());

    final result = await _repository.getVault();
    switch (result) {
      case Ok(:final value):
        emit(DashboardLoaded(value));
      case Err(:final failure):
        emit(DashboardError(failure.message));
    }
  }
}
