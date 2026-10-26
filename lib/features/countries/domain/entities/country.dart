import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// A market the app operates in. The backend also sends instant-matching,
/// wallet and review policies; they're added here when a feature needs them.
class Country extends Equatable {
  const Country({
    required this.id,
    required this.code,
    required this.name,
    required this.phonePrefix,
    required this.currencyCode,
    required this.timezone,
    this.bookingPolicy = BookingPolicy.defaults,
  });

  final String id;

  /// ISO 3166-1 alpha-2, e.g. "SY".
  final String code;
  final LocalizedText name;

  /// With the plus sign, e.g. "+963".
  final String phonePrefix;
  final String currencyCode;
  /// IANA zone, e.g. "Asia/Damascus". Slot dates and times are in this zone.
  final String timezone;
  final BookingPolicy bookingPolicy;

  /// Regional-indicator flag emoji derived from [code].
  String get flag => String.fromCharCodes(
    code.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 0x41),
  );

  @override
  List<Object?> get props => [id, code, name, phonePrefix, currencyCode, timezone, bookingPolicy];
}

/// The country's `bookingPolicy` block. Data-driven per country: never
/// hard-code these numbers in a screen.
class BookingPolicy extends Equatable {
  const BookingPolicy({
    required this.bookingHorizonDays,
    required this.freeCancellationHours,
    required this.cancellationFeeBasisPoints,
    required this.interBookingBufferMinutes,
  });

  /// Tolerates a missing block or field by falling back to the backend's own
  /// documented defaults (Swagger: CountryBookingPolicyDto).
  factory BookingPolicy.fromJson(Object? json) {
    final m = json is Map ? json : const <String, Object?>{};
    int read(String key, int fallback) => (m[key] as num?)?.toInt() ?? fallback;
    return BookingPolicy(
      bookingHorizonDays: read('bookingHorizonDays', defaults.bookingHorizonDays),
      freeCancellationHours: read('freeCancellationHours', defaults.freeCancellationHours),
      cancellationFeeBasisPoints: read('cancellationFeeBasisPoints', defaults.cancellationFeeBasisPoints),
      interBookingBufferMinutes: read('interBookingBufferMinutes', defaults.interBookingBufferMinutes),
    );
  }

  static const defaults = BookingPolicy(
    bookingHorizonDays: 90,
    freeCancellationHours: 24,
    cancellationFeeBasisPoints: 2000,
    interBookingBufferMinutes: 30,
  );

  /// Max days ahead a booking may be placed.
  final int bookingHorizonDays;

  /// Cancelling at least this many hours before `scheduledFor` is free.
  final int freeCancellationHours;

  /// Share of the frozen `basePrice` owed on a late cancel (2000 = 20%).
  final int cancellationFeeBasisPoints;
  final int interBookingBufferMinutes;

  @override
  List<Object?> get props => [
    bookingHorizonDays,
    freeCancellationHours,
    cancellationFeeBasisPoints,
    interBookingBufferMinutes,
  ];
}
