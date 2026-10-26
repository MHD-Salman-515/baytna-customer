import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:equatable/equatable.dart';

/// How a worker may price a service. Mirrors the backend enum; an unknown
/// value from a newer backend is kept as [unknown] rather than crashing.
enum PricingType {
  hourly,
  bySize,
  fixed,
  unknown;

  static PricingType parse(Object? raw) => switch (raw) {
    'HOURLY' => hourly,
    'BY_SIZE' => bySize,
    'FIXED' => fixed,
    _ => unknown,
  };
}

/// A service Baytna offers (cleaning, cooking, ironing…), from GET /services.
class Service extends Equatable {
  const Service({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.allowedPricingTypes,
    required this.displayOrder,
    this.icon,
  });

  final String id;

  /// Stable machine key, e.g. "CLEANING". The UI picks its glyph from this.
  final String key;
  final LocalizedText name;
  final LocalizedText description;

  /// Server-provided icon. `null` on every staging service today, so the UI
  /// falls back to a glyph chosen by [key].
  final String? icon;
  final List<PricingType> allowedPricingTypes;
  final int displayOrder;

  @override
  List<Object?> get props => [
    id,
    key,
    name,
    description,
    icon,
    allowedPricingTypes,
    displayOrder,
  ];
}
