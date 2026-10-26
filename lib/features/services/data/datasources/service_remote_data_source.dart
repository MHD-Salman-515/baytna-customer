import 'package:baytna_customer/core/network/api_client.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/features/services/data/models/service_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ServiceRemoteDataSource {
  ServiceRemoteDataSource(this._api);

  final ApiClient _api;

  /// Active services only (the backend filters). Not paginated.
  Future<List<ServiceModel>> fetchActive() => _api.get(
    '/services',
    decode: (data) => asJsonList(data).map(ServiceModel.fromJson).toList(),
  );
}
