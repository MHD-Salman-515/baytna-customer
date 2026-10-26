import 'dart:async';

import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/core/router/auth_redirect.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_customer/features/auth/presentation/screens/country_selection_screen.dart';
import 'package:baytna_customer/features/auth/presentation/screens/otp_screen.dart';
import 'package:baytna_customer/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:baytna_customer/features/auth/presentation/screens/splash_screen.dart';
import 'package:baytna_customer/features/home/presentation/screens/home_screen.dart';
import 'package:baytna_customer/features/workers/presentation/screens/browse_workers_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppRouter {
  AppRouter(this._auth);

  final AuthBloc _auth;

  late final GoRouter config = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _StreamListenable(_auth.stream),
    redirect: (context, state) => authRedirect(_auth.state, state.uri),
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: AppRoutes.country, builder: (_, _) => const CountrySelectionScreen()),
      GoRoute(
        path: AppRoutes.phone,
        redirect: (_, state) => _require(state, ['countryId']),
        builder: (_, state) => PhoneEntryScreen(countryId: state.uri.queryParameters['countryId']!),
      ),
      GoRoute(
        path: AppRoutes.otp,
        redirect: (_, state) => _require(state, ['countryId', 'phone']),
        builder: (_, state) => OtpScreen(
          countryId: state.uri.queryParameters['countryId']!,
          phone: state.uri.queryParameters['phone']!,
        ),
      ),
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.workers,
        redirect: (_, state) => _requireOrHome(state, ['serviceId']),
        builder: (_, state) => BrowseWorkersScreen(
          serviceId: state.uri.queryParameters['serviceId']!,
          cityId: state.uri.queryParameters['cityId'],
        ),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );

  /// Signed-in screens missing a parameter fall back to home.
  static String? _requireOrHome(GoRouterState state, List<String> params) {
    final q = state.uri.queryParameters;
    return params.every((p) => (q[p] ?? '').isNotEmpty) ? null : AppRoutes.home;
  }

  /// A hand-edited or truncated URL restarts the flow instead of crashing.
  static String? _require(GoRouterState state, List<String> params) {
    final q = state.uri.queryParameters;
    return params.every((p) => (q[p] ?? '').isNotEmpty) ? null : AppRoutes.country;
  }
}

/// Re-runs redirects whenever the AuthBloc emits.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _sub;

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.errorNotFound),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: Text(context.l10n.continueAction),
            ),
          ],
        ),
      ),
    );
  }
}
