import 'package:flutter/foundation.dart';

/// DEBUG-ONLY stand-in for a field the backend doesn't send yet.
///
/// POST /bookings and GET /pricing/quote need a `workerServiceId`, but the
/// customer-facing projection (GET /workers, GET /workers/:id) only lists
/// `serviceId` per offering, and no customer route exposes the id (verified
/// against staging on 2026-10-26; see README → Backend gaps). Until the
/// backend adds it, a debug build can be told the ids out of band:
///
///   `secrets.json`: `{ "DEV_WORKER_SERVICES": "<workerProfileId>/<serviceId>=<workerServiceId>;…" }`
///
/// Removed from release builds exactly like `DevOtp`: [_raw] is `''` unless
/// `kDebugMode`, so a release build can never book through this path and
/// shows "not bookable yet" instead.
abstract final class DevWorkerServices {
  static const String _raw = kDebugMode ? String.fromEnvironment('DEV_WORKER_SERVICES') : '';

  static const bool enabled = kDebugMode && _raw != '';

  static final Map<String, String> _map = parse(_raw);

  static String? lookup({required String workerId, required String serviceId}) =>
      enabled ? _map['$workerId/$serviceId'] : null;

  @visibleForTesting
  static Map<String, String> parse(String raw) => {
    for (final entry in raw.split(';'))
      if (entry.split('=') case [final key, final value] when key.trim().isNotEmpty)
        key.trim(): value.trim(),
  };
}
