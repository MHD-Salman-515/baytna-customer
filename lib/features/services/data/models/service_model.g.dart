// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
  id: json['id'] as String,
  key: json['key'] as String,
  name: LocalizedText.fromJson(json['name']),
  description: LocalizedText.fromJson(json['description']),
  icon: json['icon'] as String?,
  allowedPricingTypes:
      (json['allowedPricingTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
);
