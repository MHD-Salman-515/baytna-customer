import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/features/pricing/domain/job_size.dart';
import 'package:baytna_customer/features/pricing/presentation/bloc/quote_bloc.dart';
import 'package:baytna_customer/features/pricing/presentation/widgets/duration_labels.dart';
import 'package:baytna_customer/features/pricing/presentation/widgets/stepper_row.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Size the job, see the server's price. For HOURLY her minimum is stated
/// BEFORE the hours control, and the control can't go below it, so the
/// price never jumps unexpectedly.
class QuotePanel extends StatelessWidget {
  const QuotePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuoteBloc, QuoteState>(
      builder: (context, state) {
        if (state.status == QuoteStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.status == QuoteStatus.failure && state.quote == null) {
          return FailureView(
            failure: state.failure!,
            onRetry: () => context.read<QuoteBloc>().add(QuoteStarted(
              workerServiceId: state.workerServiceId!,
              pricingType: state.pricingType,
            )),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._sizeControls(context, state),
            const SizedBox(height: 16),
            _PriceBox(state: state),
          ],
        );
      },
    );
  }

  List<Widget> _sizeControls(BuildContext context, QuoteState state) {
    final l10n = context.l10n;
    final bloc = context.read<QuoteBloc>();
    const step = DurationSteps.step;
    Widget duration() => StepperRow(
      keyPrefix: 'duration',
      label: l10n.quoteExpectedDuration,
      value: context.hoursLabel(state.durationHours),
      onDecrement: state.durationHours > step ? () => bloc.add(QuoteDurationChanged(state.durationHours - step)) : null,
      onIncrement: state.durationHours < DurationSteps.maxHours
          ? () => bloc.add(QuoteDurationChanged(state.durationHours + step))
          : null,
    );
    switch (state.pricingType) {
      case PricingType.hourly:
        final min = state.minHours ?? step;
        return [
          _MinimumNotice(minHours: min),
          const SizedBox(height: 12),
          StepperRow(
            keyPrefix: 'hours',
            label: l10n.quoteHours,
            value: context.hoursLabel(state.hours),
            onDecrement: state.hours > min ? () => bloc.add(QuoteSizeChanged(hours: state.hours - step)) : null,
            onIncrement: state.hours < DurationSteps.maxHours
                ? () => bloc.add(QuoteSizeChanged(hours: state.hours + step))
                : null,
          ),
        ];
      case PricingType.bySize:
        return [
          StepperRow(
            keyPrefix: 'rooms',
            label: l10n.quoteRooms,
            value: l10n.roomsCount(state.rooms),
            onDecrement: state.rooms > 1 ? () => bloc.add(QuoteSizeChanged(rooms: state.rooms - 1)) : null,
            onIncrement: state.rooms < QuoteBloc.maxRooms
                ? () => bloc.add(QuoteSizeChanged(rooms: state.rooms + 1))
                : null,
          ),
          const SizedBox(height: 8),
          duration(),
        ];
      case PricingType.fixed || PricingType.unknown:
        return [duration()];
    }
  }
}

class _MinimumNotice extends StatelessWidget {
  const _MinimumNotice({required this.minHours});

  final num minHours;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = context.hoursLabel(minHours);
    return Container(
      key: const ValueKey('min-hours-notice'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.quoteMinimumHours(label),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.state});

  final QuoteState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final quote = state.quote;
    if (quote == null) return const SizedBox.shrink();
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: state.quoting ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.quotePriceLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              context.money(quote.price, quote.currency),
              key: const ValueKey('quote-price'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            if (quote.hours case final hours?) Text(l10n.quoteForHours(context.hoursLabel(hours))),
            if (quote.roomCount case final rooms?) Text(l10n.quoteForRooms(l10n.roomsCount(rooms))),
            const SizedBox(height: 8),
            Text(
              l10n.quoteFrozenNote,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
