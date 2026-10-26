import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A city within a country. [center] is where the address map opens when the
/// customer hasn't shared her location.
class City extends Equatable {
  const City({required this.id, required this.countryId, required this.name, this.center});

  final String id;
  final String countryId;
  final LocalizedText name;
  final GeoPoint? center;

  @override
  List<Object?> get props => [id, countryId, name, center];
}
