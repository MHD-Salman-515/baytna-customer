import 'package:flutter/material.dart';

/// The glyph for a service. The backend's `icon` is null on every service
/// today and its format is undocumented, so this keys off the stable `key`
/// and falls back to a generic glyph for services added later.
IconData serviceIconFor(String key) => switch (key) {
  'CLEANING' => Icons.cleaning_services_rounded,
  'COOKING' => Icons.restaurant_rounded,
  'IRONING' => Icons.iron_rounded,
  _ => Icons.home_repair_service_rounded,
};
