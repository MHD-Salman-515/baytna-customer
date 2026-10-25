import 'package:equatable/equatable.dart';

/// The signed-in account, as returned by POST /auth/otp/verify (`user`) and
/// GET /auth/me.
class User extends Equatable {
  const User({
    required this.id,
    required this.phone,
    required this.countryId,
    this.cityId,
    this.roles = const [],
    this.status,
    this.locale,
    this.createdAt,
    this.lastLoginAt,
  });

  final String id;

  /// E.164, e.g. +963911111111.
  final String phone;
  final String countryId;

  /// Null until the user picks a city.
  final String? cityId;

  /// Backend role names, e.g. ["CUSTOMER"]. Kept as strings: only CUSTOMER
  /// has been observed, and inventing an enum for the rest would be a guess.
  final List<String> roles;

  /// Account status, e.g. "ACTIVE".
  final String? status;

  /// Preferred language stored on the server ('ar' | 'en').
  final String? locale;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  bool get isCustomer => roles.contains('CUSTOMER');

  @override
  List<Object?> get props => [id, phone, countryId, cityId, roles, status, locale, createdAt, lastLoginAt];
}
