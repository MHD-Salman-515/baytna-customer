import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/core/widgets/directional_icon.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/core/widgets/ltr.dart';
import 'package:baytna_customer/core/widgets/page_scaffold.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_customer/features/services/presentation/bloc/services_bloc.dart';
import 'package:baytna_customer/features/services/presentation/widgets/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Signed-in entry point: the service catalog. Choosing a service starts the
/// browse-workers flow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final phone = switch (context.watch<AuthBloc>().state) {
      AuthAuthenticated(:final user) => user.phone,
      AuthUnknown() || AuthUnauthenticated() => '',
    };

    return BlocProvider(
      create: (_) => getIt<ServicesBloc>()..add(const ServicesRequested()),
      child: PageScaffold(
        appBarTitle: l10n.homeTitle,
        title: l10n.homeWelcome,
        subtitle: l10n.homeChooseService,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: _ServiceList()),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.homeSignedInAs, style: theme.textTheme.bodySmall),
                      Text(
                        ltrIsolate(phone),
                        key: const ValueKey('home-phone'),
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  key: const ValueKey('logout'),
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthLogoutRequested()),
                  icon: const DirectionalIcon(Icons.logout_rounded, size: 18),
                  label: Text(l10n.logout),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) => switch (state) {
        ServicesLoading() => const Center(child: CircularProgressIndicator()),
        ServicesFailure(:final failure) => FailureView(
          failure: failure,
          onRetry: () => context.read<ServicesBloc>().add(
            const ServicesRequested(forceRefresh: true),
          ),
        ),
        ServicesLoaded(:final services) when services.isEmpty => Center(
          child: Text(context.l10n.homeServicesEmpty),
        ),
        ServicesLoaded(:final services) => RefreshIndicator(
          onRefresh: () async => context.read<ServicesBloc>().add(
            const ServicesRequested(forceRefresh: true),
          ),
          child: ListView.separated(
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => ServiceCard(
              service: services[i],
              onTap: () => context.push(AppRoutes.workersFor(services[i].id)),
            ),
          ),
        ),
      },
    );
  }
}
