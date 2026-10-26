import 'package:equatable/equatable.dart';

enum WorkerSort {
  /// Backend default.
  ratingDesc,

  /// Price of THE selected service; the backend ignores price sorting
  /// without a serviceId.
  priceAsc,
  priceDesc,
}

class WorkerQuery extends Equatable {
  const WorkerQuery({required this.cityId, required this.serviceId, this.sort = WorkerSort.ratingDesc});

  final String cityId;
  final String serviceId;
  final WorkerSort sort;

  WorkerQuery copyWith({String? cityId, WorkerSort? sort}) =>
      WorkerQuery(cityId: cityId ?? this.cityId, serviceId: serviceId, sort: sort ?? this.sort);

  @override
  List<Object?> get props => [cityId, serviceId, sort];
}
