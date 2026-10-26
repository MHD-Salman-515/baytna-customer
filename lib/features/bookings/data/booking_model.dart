import 'package:baytna_customer/core/geo/geo_point.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';

/// `data` of POST /bookings, GET /bookings/:id and POST /bookings/:id/cancel,
/// and the elements of GET /bookings — one shape, verified against staging
/// on 2026-10-26 (see test/helpers/staging_fixtures.dart).
abstract final class BookingModel {
  static Booking fromJson(Json j) {
    DateTime? date(String key) => switch (j[key]) {
      final String s => DateTime.tryParse(s),
      _ => null,
    };
    final address = asJson(j['address']);
    final pricing = j['pricing'];
    final cancellation = j['cancellation'];
    final phone = j['workerPhone'];
    return Booking(
      id: j['id'] as String,
      bookingNumber: j['bookingNumber'] as String? ?? '',
      status: BookingStatus.parse(j['status']),
      workerProfileId: j['workerProfileId'] as String? ?? '',
      serviceId: j['serviceId'] as String? ?? '',
      workerServiceId: j['workerServiceId'] as String?,
      countryId: j['countryId'] as String? ?? '',
      cityId: j['cityId'] as String? ?? '',
      scheduledFor: date('scheduledFor')!,
      estimatedDurationMinutes: (j['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      address: BookingAddress(
        point: GeoPoint.tryFromGeoJson(address['point']) ?? const GeoPoint(latitude: 0, longitude: 0),
        text: address['text'] as String? ?? '',
        landmark: address['landmark'] as String? ?? '',
        floor: address['floor'] as String?,
        notes: address['notes'] as String?,
      ),
      pricing: pricing is Map<String, dynamic>
          ? BookingPricing(
              pricingType: PricingType.parse(pricing['pricingType']),
              basePrice: pricing['basePrice'] as num? ?? 0,
              currency: pricing['currency'] as String? ?? '',
              hours: pricing['hours'] as num?,
              roomCount: (pricing['roomCount'] as num?)?.toInt(),
            )
          : null,
      responseDeadline: date('responseDeadline'),
      acceptedAt: date('acceptedAt'),
      cancelledAt: date('cancelledAt'),
      cancellation: cancellation is Map<String, dynamic>
          ? BookingCancellation(
              byRole: cancellation['byRole'] as String? ?? '',
              reason: cancellation['reason'] as String?,
              feeAmount: cancellation['feeAmount'] as num? ?? 0,
            )
          : null,
      // An empty string is as hidden as null.
      workerPhone: phone is String && phone.trim().isNotEmpty ? phone : null,
    );
  }
}
