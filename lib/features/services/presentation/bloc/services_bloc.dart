import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/services/domain/repositories/service_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'services_event.dart';
part 'services_state.dart';

@injectable
class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  ServicesBloc(this._repository) : super(const ServicesLoading()) {
    on<ServicesRequested>(_onRequested);
  }

  final ServiceRepository _repository;

  Future<void> _onRequested(
    ServicesRequested event,
    Emitter<ServicesState> emit,
  ) async {
    emit(const ServicesLoading());
    final result = await _repository.getServices(
      forceRefresh: event.forceRefresh,
    );
    emit(switch (result) {
      Ok(:final value) => ServicesLoaded(value),
      Err(:final failure) => ServicesFailure(failure),
    });
  }
}
