import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.phone, this.locale});

  final String id;

  /// E.164, e.g. +963911111111.
  final String phone;

  /// Preferred language stored on the server ('ar' | 'en'), if any.
  final String? locale;

  @override
  List<Object?> get props => [id, phone, locale];
}
