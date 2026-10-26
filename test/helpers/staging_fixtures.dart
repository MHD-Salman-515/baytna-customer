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

  static const workerServiceId = '6adf3e0f9915d0e047e12441';

  /// `data` of POST /bookings (201), status PENDING_WORKER.
  static const booking = <String, dynamic>{
    'id': '6adf3eee9915d0e047e124b8',
    'bookingNumber': 'BK-4S2DC6',
    'customerId': '6adf37349915d0e047e12234',
    'workerProfileId': workerId,
    'serviceId': cleaningId,
    'workerServiceId': workerServiceId,
    'countryId': '6adbb9bbd141d68e87375528',
    'cityId': damascusId,
    'type': 'SCHEDULED',
    'status': 'PENDING_WORKER',
    'scheduledFor': '2026-11-05T07:00:00.000Z',
    'estimatedDurationMinutes': 120,
    'address': {
      'point': {
        'type': 'Point',
        'coordinates': [36.2765, 33.5138],
      },
      'text': 'المزة، شارع 12',
      'landmark': 'probe: بجانب الجامع الأزرق',
      'floor': '3',
      'notes': 'probe booking',
    },
    'pricing': {'pricingType': 'HOURLY', 'hours': 2, 'roomCount': null, 'basePrice': 12000, 'currency': 'SYP'},
    'finalPricing': null,
    'responseDeadline': '2026-10-26T23:52:13.967Z',
    'acceptedAt': null,
    'startedAt': null,
    'completedAt': null,
    'cancelledAt': null,
    'cancellation': null,
    'rejectionReason': null,
    'customerNote': null,
    'workerPhone': null,
  };

  /// The same booking after a late customer cancel (fee charged).
  static final cancelledLate = <String, dynamic>{
    ...booking,
    'status': 'CANCELLED',
    'cancelledAt': '2026-10-26T11:53:08.514Z',
    'cancellation': {
      'byUserId': '6adf37349915d0e047e12234',
      'byRole': 'CUSTOMER',
      'reason': 'probe: late cancel fee check',
      'feeAmount': 2400,
    },
  };
}
