import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/cities/domain/entities/city.dart';

abstract interface class CityRepository {
  /// Every active city of [countryId] (all pages), cached per country.
  Future<Result<List<City>>> getCities(String countryId, {bool forceRefresh = false});
}
