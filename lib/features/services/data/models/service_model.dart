import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:json_annotation/json_annotation.dart';

part 'service_model.g.dart';

/// Element of GET /services `data` (shape verified against staging):
/// `{ key, name: {ar,en}, description: {ar,en}, icon: null,
///    allowedPricingTypes: ["HOURLY","BY_SIZE"], commissionRate: null,
///    isActive, displayOrder, id, … }`.
///
/// `commissionRate` is deliberately not mapped: the customer never sees it.
@JsonSerializable(createToJson: false)
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    this.icon,
    this.allowedPricingTypes = const [],
    this.displayOrder = 0,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  final String id;
  final String key;
  @JsonKey(fromJson: LocalizedText.fromJson)
  final LocalizedText name;
  @JsonKey(fromJson: LocalizedText.fromJson)
  final LocalizedText description;
  final String? icon;
  final List<String> allowedPricingTypes;
  final int displayOrder;

  Service toEntity() => Service(
    id: id,
    key: key,
    name: name,
    description: description,
    icon: icon,
    allowedPricingTypes: allowedPricingTypes
        .map(PricingType.parse)
        .toList(growable: false),
    displayOrder: displayOrder,
  );
}
