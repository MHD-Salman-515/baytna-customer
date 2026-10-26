import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/core/widgets/language_toggle_button.dart';
import 'package:baytna_customer/core/widgets/primary_button.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_customer/features/pricing/presentation/bloc/quote_bloc.dart';
import 'package:baytna_customer/features/pricing/presentation/widgets/quote_panel.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/presentation/bloc/detail/worker_detail_bloc.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/pricing_explainer.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/rating_label.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_avatar.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Her public profile and the services she offers. Shows only what the
/// public projection contains.
class WorkerDetailScreen extends StatelessWidget {
  const WorkerDetailScreen({
    required this.workerId,
    required this.serviceId,
    required this.cityId,
    super.key,
  });

  final String workerId;

  /// The service she was browsed for; pre-selected.
  final String serviceId;

  /// The city the customer is booking in.
  final String cityId;

  @override
  Widget build(BuildContext context) {
    final countryId = switch (context.read<AuthBloc>().state) {
      AuthAuthenticated(:final user) => user.countryId,
      AuthUnknown() || AuthUnauthenticated() => '',
    };
    void load(BuildContext context) => context.read<WorkerDetailBloc>().add(
      WorkerDetailRequested(workerId: workerId, countryId: countryId),
    );
    return BlocProvider(
      create: (context) =>
          getIt<WorkerDetailBloc>()..add(WorkerDetailRequested(workerId: workerId, countryId: countryId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.workerProfileTitle),
          actions: const [LanguageToggleButton(), SizedBox(width: 8)],
        ),
        body: SafeArea(
          child: BlocBuilder<WorkerDetailBloc, WorkerDetailState>(
            builder: (context, state) => switch (state) {
              WorkerDetailLoading() => const Center(child: CircularProgressIndicator()),
              WorkerDetailFailure(:final failure) => FailureView(failure: failure, onRetry: () => load(context)),
              WorkerDetailLoaded(:final worker, :final cities) => WorkerProfileBody(
                worker: worker,
                cityNames: [
                  for (final id in worker.serviceAreas)
                    if (cities[id] case final city?) context.localize(city.name),
                ],
                initialServiceId: serviceId,
                cityId: cityId,
              ),
            },
          ),
        ),
      ),
    );
  }
}

class WorkerProfileBody extends StatefulWidget {
  const WorkerProfileBody({
    required this.worker,
    required this.cityNames,
    required this.initialServiceId,
    required this.cityId,
    super.key,
  });

  final Worker worker;
  final List<String> cityNames;
  final String initialServiceId;
  final String cityId;

  @override
  State<WorkerProfileBody> createState() => _WorkerProfileBodyState();
}

class _WorkerProfileBodyState extends State<WorkerProfileBody> {
  late String _serviceId = widget.worker.offeringFor(widget.initialServiceId) != null
      ? widget.initialServiceId
      : widget.worker.offerings.firstOrNull?.serviceId ?? widget.initialServiceId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final worker = widget.worker;
    final bio = context.localize(worker.bio);
    final selected = worker.offeringFor(_serviceId);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
          children: [
            Row(
              children: [
                WorkerAvatar(photoUrl: worker.photoUrl, radius: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.workerName(worker),
                        key: const ValueKey('worker-name'),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      RatingLabel(rating: worker.rating),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.cityNames.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.place_rounded, size: 18, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.workerServesCities(widget.cityNames.join('، ')))),
                ],
              ),
            ],
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(l10n.workerAbout, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(bio, key: const ValueKey('worker-bio'), style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 24),
            Text(l10n.workerServices, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final o in worker.offerings) ...[
              _OfferingTile(
                offering: o,
                selected: o.serviceId == _serviceId,
                onTap: () => setState(() => _serviceId = o.serviceId),
              ),
              const SizedBox(height: 8),
            ],
            if (selected != null && selected.isBookable) ...[
              const SizedBox(height: 16),
              Text(
                l10n.quoteSectionTitle,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              BlocProvider(
                // A new offering is a new quote, not a continuation of the old one.
                key: ValueKey(selected.workerServiceId),
                create: (_) => getIt<QuoteBloc>()
                  ..add(QuoteStarted(
                    workerServiceId: selected.workerServiceId!,
                    pricingType: selected.pricingType,
                  )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const QuotePanel(),
                    const SizedBox(height: 16),
                    BlocBuilder<QuoteBloc, QuoteState>(
                      builder: (context, quote) => PrimaryButton(
                        key: const ValueKey('continue-booking'),
                        label: l10n.quoteContinue,
                        onPressed: quote.canContinue
                            ? () => context.push(AppRoutes.bookFor(
                                worker.id,
                                serviceId: selected.serviceId,
                                cityId: widget.cityId,
                                hours: quote.jobSize.hours,
                                rooms: quote.jobSize.roomCount,
                                durationMinutes: quote.jobSize.durationMinutes,
                              ))
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (selected != null && !selected.isBookable) ...[
              const SizedBox(height: 8),
              Text(
                l10n.offeringNotBookable,
                key: const ValueKey('offering-not-bookable'),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OfferingTile extends StatelessWidget {
  const _OfferingTile({required this.offering, required this.selected, required this.onTap});

  final WorkerOffering offering;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.6) : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
      ),
      child: InkWell(
        key: ValueKey('offering-${offering.serviceId}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.localize(offering.serviceName),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    context.offeringPrice(offering),
                    style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PricingExplainer(offering: offering),
            ],
          ),
        ),
      ),
    );
  }
}
