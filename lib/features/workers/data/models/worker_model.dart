import 'package:baytna_customer/core/dev/dev_worker_services.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/network/json.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';

/// Element of GET /workers and `data` of GET /workers/:id (identical shapes,
/// verified against staging on 2026-10-26):
///
/// ```json
/// { "id": "6adf…", "displayName": "Worker", "profilePhotoUrl": null,
///   "bio": {"ar": "…", "en": "…"}, "rating": 0, "cityId": "6adb…",
///   "serviceAreas": ["6adb…", "6adb…"],
///   "services": [{ "serviceId": "6adb…", "serviceName": {"ar","en"},
///                  "pricingType": "HOURLY", "displayPrice": 6000, "currency": "SYP" }] }
/// ```
///
/// Hand-decoded so that one odd field degrades instead of failing the list.
abstract final class WorkerModel {
  /// What the backend sends when she hasn't set a name.
  static const _unsetName = 'Worker';

  static Worker fromJson(Json json) {
    final id = json['id'] as String;
    final name = (json['displayName'] as String?)?.trim();
    final photo = json['profilePhotoUrl'] as String?;
    return Worker(
      id: id,
      displayName: (name == null || name.isEmpty || name == _unsetName) ? null : name,
      photoUrl: (photo != null && photo.startsWith('https://')) ? photo : null,
      bio: LocalizedText.fromJson(json['bio']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      cityId: json['cityId'] as String? ?? '',
      serviceAreas: (json['serviceAreas'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      offerings: (json['services'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((s) => _offering(id, s))
          .toList(growable: false),
    );
  }

  static WorkerOffering _offering(String workerId, Json json) {
    final serviceId = json['serviceId'] as String;
    return WorkerOffering(
      serviceId: serviceId,
      serviceName: LocalizedText.fromJson(json['serviceName']),
      pricingType: PricingType.parse(json['pricingType']),
      displayPrice: json['displayPrice'] as num? ?? 0,
      currency: json['currency'] as String? ?? '',
      // Read it the moment the backend starts sending it; until then a debug
      // build may supply it (compiled out of release).
      workerServiceId:
          json['workerServiceId'] as String? ??
          DevWorkerServices.lookup(workerId: workerId, serviceId: serviceId),
    );
  }
}
