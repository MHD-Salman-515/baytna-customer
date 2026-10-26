/// Every path in one place. Auth-flow screens take their inputs from the
/// query string (not `extra`), so a browser refresh mid-flow still works.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const authPrefix = '/auth';
  static const country = '/auth/country';
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';
  static const home = '/home';

  /// Browse: `/workers?serviceId=…[&cityId=…]`. Signed-in only (the backend
  /// answers 401 to an anonymous GET /workers).
  static const workers = '/workers';

  static String phoneFor(String countryId) =>
      Uri(path: phone, queryParameters: {'countryId': countryId}).toString();

  static String otpFor({required String countryId, required String phoneE164}) => Uri(
    path: otp,
    queryParameters: {'countryId': countryId, 'phone': phoneE164},
  ).toString();

  static String workersFor(String serviceId, {String? cityId}) => Uri(
    path: workers,
    queryParameters: {'serviceId': serviceId, 'cityId': ?cityId},
  ).toString();

  static String workerFor(String workerId, {required String serviceId, required String cityId}) => Uri(
    path: '$workers/$workerId',
    queryParameters: {'serviceId': serviceId, 'cityId': cityId},
  ).toString();

  /// The booking flow for one offering; carries the size chosen on the
  /// price preview so the flow books exactly what was quoted.
  static String bookFor(
    String workerId, {
    required String serviceId,
    required String cityId,
    num? hours,
    int? rooms,
    int? durationMinutes,
  }) => Uri(
    path: '$workers/$workerId/book',
    queryParameters: {
      'serviceId': serviceId,
      'cityId': cityId,
      'hours': ?hours?.toString(),
      'rooms': ?rooms?.toString(),
      'minutes': ?durationMinutes?.toString(),
    },
  ).toString();
}
