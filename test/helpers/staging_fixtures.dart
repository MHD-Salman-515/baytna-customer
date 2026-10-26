/// Verbatim payloads captured from staging on 2026-10-26. Tests decode these
/// so a model can't drift from what the backend really sends.
abstract final class StagingFixtures {
  static const damascusId = '6adbb9c1d141d68e8737555d';
  static const aleppoId = '6adbb9c2d141d68e87375563';
  static const cleaningId = '6adbb9cad141d68e8737557b';
  static const workerId = '6adf1a91b4c4645d759bc2a0';

  /// Element of GET /workers, identical to GET /workers/:id `data`.
  static const worker = <String, dynamic>{
    'id': workerId,
    'displayName': 'Worker',
    'profilePhotoUrl': null,
    'bio': {
      'ar': 'خبرة خمس سنوات في تنظيف المنازل والطبخ والكي.',
      'en': 'Five years of home cleaning, cooking and ironing.',
    },
    'rating': 0,
    'cityId': damascusId,
    'serviceAreas': [aleppoId, damascusId],
    'services': [
      {
        'serviceId': cleaningId,
        'serviceName': {'ar': 'تنظيف', 'en': 'Cleaning'},
        'pricingType': 'HOURLY',
        'displayPrice': 6000,
        'currency': 'SYP',
      },
    ],
  };

  static const damascus = <String, dynamic>{
    'countryId': '6adbb9bbd141d68e87375528',
    'name': {'ar': 'دمشق', 'en': 'Damascus'},
    'center': {
      'type': 'Point',
      'coordinates': [36.2765, 33.5138],
    },
    'isActive': true,
    'id': damascusId,
  };
}
