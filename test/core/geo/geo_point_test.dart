import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/features/cities/data/models/city_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GeoJSON is [lng, lat]; GeoPoint reads and writes it that way round', () {
    // Damascus, as served by GET /cities.
    final p = GeoPoint.tryFromGeoJson({
      'type': 'Point',
      'coordinates': [36.2765, 33.5138],
    })!;
    expect(p.latitude, 33.5138);
    expect(p.longitude, 36.2765);
    expect(p.toGeoJson(), {
      'type': 'Point',
      'coordinates': [36.2765, 33.5138],
    });
  });

  test('malformed points degrade to null instead of throwing', () {
    expect(GeoPoint.tryFromGeoJson(null), isNull);
    expect(GeoPoint.tryFromGeoJson({'coordinates': [1]}), isNull);
    expect(GeoPoint.tryFromGeoJson({'coordinates': ['a', 'b']}), isNull);
  });

  test('CityModel keeps the centre of a real /cities element', () {
    final city = CityModel.fromJson({
      'id': 'c1',
      'countryId': 'k1',
      'name': {'ar': 'دمشق', 'en': 'Damascus'},
      'center': {
        'type': 'Point',
        'coordinates': [36.2765, 33.5138],
      },
    }).toEntity();
    expect(city.center?.latitude, 33.5138);
  });
}
