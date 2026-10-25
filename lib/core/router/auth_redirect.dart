import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';

/// The routing policy, as a pure function of auth state and location:
///
/// * unknown (bootstrapping) → splash, remembering where the user was going;
/// * unauthenticated → only the auth flow is reachable;
/// * authenticated → the auth flow and splash are skipped.
///
/// [location] is the full URI (path + query); returns where to go instead,
/// or null to stay.
String? authRedirect(AuthState auth, Uri location) {
  final path = location.path;
  final atSplash = path == AppRoutes.splash;
  final inAuthFlow = path.startsWith(AppRoutes.authPrefix);
  final from = atSplash ? location.queryParameters['from'] : null;

  switch (auth) {
    case AuthUnknown():
      if (atSplash) return null;
      return Uri(path: AppRoutes.splash, queryParameters: {'from': location.toString()}).toString();

    case AuthUnauthenticated():
      if (inAuthFlow) return null;
      if (from != null && from.startsWith(AppRoutes.authPrefix)) return from;
      return AppRoutes.country;

    case AuthAuthenticated():
      if (!inAuthFlow && !atSplash) return null;
      final resumable = from != null &&
          from.startsWith('/') &&
          !from.startsWith('//') &&
          !from.startsWith(AppRoutes.authPrefix) &&
          !from.startsWith(AppRoutes.splash);
      return resumable ? from : AppRoutes.home;
  }
}
