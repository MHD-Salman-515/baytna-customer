import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:flutter/material.dart';

/// Shown while AuthBloc resolves the stored session (AuthUnknown). It makes
/// no decisions itself — the router redirects once the state is known. If the
/// server is asleep, the global waking-up banner appears over it.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Icon(Icons.home_rounded, size: 52, color: scheme.onPrimary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.appTitle,
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.appTagline,
              style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
