import 'dart:async';

import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/core/widgets/language_toggle_button.dart';
import 'package:baytna_customer/core/widgets/primary_button.dart';
import 'package:baytna_customer/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:baytna_customer/features/bookings/domain/booking_failures.dart';
import 'package:baytna_customer/features/bookings/presentation/bloc/flow/booking_flow_bloc.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/address_map.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/booking_failure_message.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/time_labels.dart';
import 'package:baytna_customer/features/pricing/presentation/widgets/duration_labels.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BookingFlowScreen extends StatelessWidget {
  const BookingFlowScreen({
    required this.workerId,
    required this.serviceId,
    required this.cityId,
    this.hours,
    this.rooms,
    this.durationMinutes,
    super.key,
  });

  final String workerId;
  final String serviceId;
  final String cityId;
  final num? hours;
  final int? rooms;
  final int? durationMinutes;

  @override
  Widget build(BuildContext context) {
    final countryId = switch (context.read<AuthBloc>().state) {
      AuthAuthenticated(:final user) => user.countryId,
      AuthUnknown() || AuthUnauthenticated() => '',
    };
    final start = FlowStarted(
      workerId: workerId,
      serviceId: serviceId,
      cityId: cityId,
      countryId: countryId,
      hours: hours,
      rooms: rooms,
      durationMinutes: durationMinutes,
    );
    return BlocProvider(
      create: (_) => getIt<BookingFlowBloc>()..add(start),
      child: BlocBuilder<BookingFlowBloc, BookingFlowState>(
        buildWhen: (a, b) => a.setup != b.setup || a.step != b.step || (a.created == null) != (b.created == null),
        builder: (context, state) {
          final bloc = context.read<BookingFlowBloc>();
          final previous = switch (state.step) {
            FlowStep.time => null,
            FlowStep.address => FlowStep.time,
            FlowStep.review => FlowStep.address,
          };
          final inSteps = state.setup == SetupStatus.ready && state.created == null;
          return PopScope(
            canPop: !inSteps || previous == null,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop && previous != null) bloc.add(FlowStepRequested(previous));
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(context.l10n.bookingTitle),
                actions: const [LanguageToggleButton(), SizedBox(width: 8)],
              ),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: switch (state.setup) {
                      SetupStatus.loading => const Center(child: CircularProgressIndicator()),
                      SetupStatus.failure => _SetupFailure(onRetry: () => bloc.add(start)),
                      SetupStatus.ready when state.created != null => const _Done(),
                      SetupStatus.ready => Column(
                        children: [
                          _StepHeader(step: state.step),
                          Expanded(
                            child: IndexedStack(
                              index: state.step.index,
                              children: const [_TimeStep(), _AddressStep(), _ReviewStep()],
                            ),
                          ),
                        ],
                      ),
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SetupFailure extends StatelessWidget {
  const _SetupFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = context.read<BookingFlowBloc>().state.failure!;
    if (failure is WorkerUnavailable) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.l10n.bookingErrorWorkerUnavailable, textAlign: TextAlign.center),
        ),
      );
    }
    return FailureView(failure: failure, onRetry: onRetry);
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final FlowStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final labels = [l10n.bookingStepTime, l10n.bookingStepAddress, l10n.bookingStepReview];
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 12),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= step.index ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: i == step.index ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown above a step when the server refused the booking.
class _SubmitFailureBanner extends StatelessWidget {
  const _SubmitFailureBanner();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BookingFlowBloc>().state;
    final failure = state.submitFailure;
    if (failure == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('booking-error'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(12)),
      child: Text(
        bookingFailureMessage(
          context.l10n,
          failure,
          horizonDays: state.country?.bookingPolicy.bookingHorizonDays ?? 90,
        ),
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}

// ── Step 1: day and time ────────────────────────────────────────────────────

class _TimeStep extends StatelessWidget {
  const _TimeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<BookingFlowBloc>().state;
    final bloc = context.read<BookingFlowBloc>();
    final time = state.time!;
    final now = DateTime.now();
    final horizon = state.country!.bookingPolicy.bookingHorizonDays;
    final selectedDay = time.day(now, state.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            children: [
              const _SubmitFailureBanner(),
              _JobSummary(state: state),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: BookingFlowBloc.quickDays + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i == BookingFlowBloc.quickDays) {
                      return ActionChip(
                        key: const ValueKey('day-calendar'),
                        avatar: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text(l10n.bookingOtherDay),
                        onPressed: () => _pickDay(context, horizon),
                      );
                    }
                    return ChoiceChip(
                      key: ValueKey('day-$i'),
                      label: Text(context.dayChip(time.day(now, i), i)),
                      selected: state.day == i,
                      onSelected: (_) => bloc.add(FlowDaySelected(i)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.longDate(selectedDay),
                key: const ValueKey('selected-day'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                l10n.bookingTimesNote(context.localize(state.city!.name)),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              switch (state.slots) {
                SlotsStatus.loading => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                SlotsStatus.failure => FailureView(
                  failure: state.failure!,
                  onRetry: () => bloc.add(FlowDaySelected(state.day)),
                ),
                SlotsStatus.ready when state.startTimes.isEmpty => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.bookingNoTimes,
                    key: const ValueKey('no-times'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                SlotsStatus.ready => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in state.startTimes)
                      ChoiceChip(
                        key: ValueKey('time-${t.toUtc().toIso8601String()}'),
                        label: Text(context.clockTime(time.local(t))),
                        selected: state.start == t,
                        onSelected: (_) => bloc.add(FlowStartSelected(t)),
                      ),
                  ],
                ),
              },
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: PrimaryButton(
            key: const ValueKey('time-next'),
            label: l10n.bookingNext,
            onPressed: state.start == null ? null : () => bloc.add(const FlowStepRequested(FlowStep.address)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDay(BuildContext context, int horizon) async {
    final bloc = context.read<BookingFlowBloc>();
    final time = bloc.state.time!;
    final today = time.day(DateTime.now(), 0);
    final first = DateTime(today.year, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: first.add(Duration(days: horizon)),
      initialDate: first.add(Duration(days: bloc.state.day)),
    );
    if (picked == null) return;
    bloc.add(FlowDaySelected(DateTime.utc(picked.year, picked.month, picked.day)
        .difference(DateTime.utc(first.year, first.month, first.day))
        .inDays));
  }
}

class _JobSummary extends StatelessWidget {
  const _JobSummary({required this.state});

  final BookingFlowState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = state.size!;
    final parts = [
      context.localize(state.offering!.serviceName),
      context.workerName(state.worker!),
      if (size.hours case final h?) context.hoursLabel(h),
      if (size.roomCount case final r?) context.l10n.roomsCount(r),
      if (size.hours == null) context.l10n.bookingTakesAbout(context.hoursLabel(size.durationMinutes / 60)),
    ];
    return Text(
      parts.join(' · '),
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

// ── Step 2: pin + landmark ─────────────────────────────────────────────────

class _AddressStep extends StatefulWidget {
  const _AddressStep();

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  final _form = GlobalKey<FormState>();
  final _landmark = TextEditingController();
  final _text = TextEditingController();
  final _floor = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    for (final c in [_landmark, _text, _floor, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (!(_form.currentState?.validate() ?? false)) return;
    context.read<BookingFlowBloc>().add(FlowAddressSubmitted(
      landmark: _landmark.text,
      text: _text.text,
      floor: _floor.text,
      notes: _notes.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<BookingFlowBloc>().state;
    final bloc = context.read<BookingFlowBloc>();
    final pin = state.pin;
    String? required(String? v, String message) => (v ?? '').trim().isEmpty ? message : null;

    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              children: [
                const _SubmitFailureBanner(),
                Text(l10n.addressMapTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l10n.addressMapHint, style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: pin == null
                      ? const Center(child: CircularProgressIndicator())
                      : AddressMap(
                          pin: pin,
                          locating: state.locating,
                          onPinMoved: (p) => bloc.add(FlowPinMoved(p)),
                          onLocateMe: () => bloc.add(const FlowLocateRequested()),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.pinFromGps
                      ? l10n.addressPinFromGps
                      : state.gpsTooFar
                      ? l10n.addressPinGpsTooFar(context.localize(state.city!.name))
                      : l10n.addressPinFromCity(context.localize(state.city!.name)),
                  key: const ValueKey('pin-source'),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                // The landmark comes first and reads like any other field: in
                // our markets it is how she will actually find the door.
                TextFormField(
                  key: const ValueKey('landmark-field'),
                  controller: _landmark,
                  textInputAction: TextInputAction.next,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: l10n.addressLandmark,
                    hintText: l10n.addressLandmarkHint,
                    helperText: l10n.addressLandmarkHelper,
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.storefront_rounded),
                  ),
                  validator: (v) => required(v, l10n.addressLandmarkRequired),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('address-text-field'),
                  controller: _text,
                  textInputAction: TextInputAction.next,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: l10n.addressText,
                    hintText: l10n.addressTextHint,
                    prefixIcon: const Icon(Icons.signpost_rounded),
                  ),
                  validator: (v) => required(v, l10n.addressTextRequired),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('floor-field'),
                  controller: _floor,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.addressFloor,
                    prefixIcon: const Icon(Icons.stairs_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('notes-field'),
                  controller: _notes,
                  maxLines: 2,
                  maxLength: 300,
                  decoration: InputDecoration(
                    labelText: l10n.addressNotes,
                    hintText: l10n.addressNotesHint,
                    prefixIcon: const Icon(Icons.sticky_note_2_rounded),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: PrimaryButton(
              key: const ValueKey('address-next'),
              label: l10n.bookingNext,
              onPressed: pin == null ? null : _next,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: review and confirm ─────────────────────────────────────────────

class _ReviewStep extends StatelessWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<BookingFlowBloc>().state;
    final address = state.address;
    final start = state.start;
    if (address == null || start == null) return const SizedBox.shrink();
    final time = state.time!;
    final size = state.size!;
    final quote = state.quote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            children: [
              const _SubmitFailureBanner(),
              _ReviewRow(
                icon: Icons.cleaning_services_rounded,
                label: l10n.reviewService,
                value: '${context.localize(state.offering!.serviceName)} · ${context.workerName(state.worker!)}',
              ),
              _ReviewRow(
                icon: Icons.event_rounded,
                label: l10n.reviewWhen,
                value: '${context.longDate(time.local(start))}\n'
                    '${context.clockTime(time.local(start))} · ${context.hoursLabel(size.durationMinutes / 60)}',
                valueKey: 'review-when',
              ),
              _ReviewRow(
                icon: Icons.storefront_rounded,
                label: l10n.addressLandmark,
                value: address.landmark,
                valueKey: 'review-landmark',
                emphasize: true,
              ),
              _ReviewRow(
                icon: Icons.signpost_rounded,
                label: l10n.addressText,
                value: [
                  address.text,
                  if (address.floor case final f? when f.isNotEmpty) l10n.reviewFloor(f),
                  context.localize(state.city!.name),
                ].join('، '),
              ),
              if (address.notes case final n? when n.isNotEmpty)
                _ReviewRow(icon: Icons.sticky_note_2_rounded, label: l10n.addressNotes, value: n),
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(child: Text(l10n.quotePriceLabel, style: theme.textTheme.titleMedium)),
                  if (quote == null)
                    const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text(
                      context.money(quote.price, quote.currency),
                      key: const ValueKey('review-price'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l10n.quoteFrozenNote, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              Text(
                l10n.reviewWhatNext,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: PrimaryButton(
            key: const ValueKey('confirm-booking'),
            label: l10n.reviewConfirm,
            loading: state.submitting,
            onPressed: () => context.read<BookingFlowBloc>().add(const FlowSubmitted()),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueKey,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? valueKey;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Text(
                  value,
                  key: valueKey == null ? null : ValueKey(valueKey),
                  style: (emphasize ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge)
                      ?.copyWith(fontWeight: emphasize ? FontWeight.w700 : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Done ───────────────────────────────────────────────────────────────────

class _Done extends StatelessWidget {
  const _Done();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final booking = context.read<BookingFlowBloc>().state.created!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        key: const ValueKey('booking-created'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.check_circle_rounded, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            l10n.bookingSent,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bookingNumber(booking.bookingNumber),
            key: const ValueKey('created-number'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.bookingSentNext, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(
            key: const ValueKey('view-booking'),
            // Home underneath, so "back" from the booking lands somewhere sensible.
            onPressed: () {
              final router = GoRouter.of(context)..go(AppRoutes.home);
              unawaited(router.push(AppRoutes.bookingFor(booking.id)));
            },
            child: Text(l10n.bookingView),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey('back-home'),
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.backToHome),
          ),
        ],
      ),
    );
  }
}
