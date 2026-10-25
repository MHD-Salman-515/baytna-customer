import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/widgets/directional_icon.dart';
import 'package:baytna_customer/core/widgets/ltr.dart';
import 'package:baytna_customer/core/widgets/page_scaffold.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Placeholder for the signed-in experience.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<AuthBloc>().state;
    final phone = switch (state) {
      AuthAuthenticated(:final user) => user.phone,
      AuthUnknown() || AuthUnauthenticated() => '',
    };

    return PageScaffold(
      appBarTitle: l10n.homeTitle,
      title: l10n.homeWelcome,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.homeSignedInAs, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          ltrIsolate(phone),
                          key: const ValueKey('home-phone'),
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.cleaning_services_rounded, color: theme.colorScheme.outline),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.homeComingSoon, style: theme.textTheme.bodyLarge)),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            key: const ValueKey('logout'),
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const DirectionalIcon(Icons.logout_rounded),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
