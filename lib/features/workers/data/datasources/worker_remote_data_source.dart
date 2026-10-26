import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/core/network/paged.dart';
import 'package:baytna_customer/features/workers/data/models/worker_model.dart';
import 'package:baytna_customer/features/workers/domain/entities/free_interval.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker_query.dart';
import 'package:injectable/injectable.dart';

/// Browsing requires a signed-in customer: GET /workers answers 401 without a
/// bearer token, so none of these are `authenticated: false`.
@lazySingleton
class WorkerRemoteDataSource {
  WorkerRemoteDataSource(this._api);

  final ApiClient _api;

  static const pageSize = 20;

  Future<Paged<Worker>> fetchPage(WorkerQuery query, {int page = 1}) => _api.getPage(
    '/workers',
    query: {
      'cityId': query.cityId,
      'serviceId': query.serviceId,
      ...switch (query.sort) {
        WorkerSort.ratingDesc => {'sortBy': 'rating', 'sortOrder': 'desc'},
        WorkerSort.priceAsc => {'sortBy': 'price', 'sortOrder': 'asc'},
        WorkerSort.priceDesc => {'sortBy': 'price', 'sortOrder': 'desc'},
      },
      'page': page,
      'limit': pageSize,
    },
    decodeItem: WorkerModel.fromJson,
  );

  Future<Worker> fetchById(String id) =>
      _api.get('/workers/$id', decode: (data) => WorkerModel.fromJson(asJson(data)));

  /// [date] is `YYYY-MM-DD` in the worker's country timezone.
  Future<List<FreeInterval>> fetchSlots(String workerId, String date) => _api.get(
    '/workers/$workerId/slots',
    query: {'date': date},
    decode: (data) => asJsonList(data)
        .map((j) => FreeInterval(
              start: DateTime.parse(j['start'] as String),
              end: DateTime.parse(j['end'] as String),
            ))
        .toList(growable: false),
  );
}
