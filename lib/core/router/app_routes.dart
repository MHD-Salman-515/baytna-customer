/// Every path in one place. Auth-flow screens take their inputs from the
/// query string (not `extra`), so a browser refresh mid-flow still works.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const authPrefix = '/auth';
  static const country = '/auth/country';
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';
  static const home = '/home';

  static String phoneFor(String countryId) =>
      Uri(path: phone, queryParameters: {'countryId': countryId}).toString();

  static String otpFor({required String countryId, required String phoneE164}) => Uri(
    path: otp,
    queryParameters: {'countryId': countryId, 'phone': phoneE164},
  ).toString();
}
