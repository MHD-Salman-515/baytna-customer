import 'package:injectable/injectable.dart';

/// The city the customer last browsed in, for this app session, so going
/// back to home and into another service doesn't reset her choice.
@lazySingleton
class CitySelection {
  String? cityId;
}
