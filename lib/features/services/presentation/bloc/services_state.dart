part of 'services_bloc.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

final class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

final class ServicesLoaded extends ServicesState {
  const ServicesLoaded(this.services);

  final List<Service> services;

  @override
  List<Object?> get props => [services];
}

final class ServicesFailure extends ServicesState {
  const ServicesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
