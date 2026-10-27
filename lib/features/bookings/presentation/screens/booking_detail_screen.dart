import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/time/country_time.dart';
import 'package:baytna_customer/core/widgets/failure_message.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/core/widgets/language_toggle_button.dart';
import 'package:baytna_customer/core/widgets/ltr.dart';
import 'package:baytna_customer/core/widgets/primary_button.dart';
import 'package:baytna_customer/features/bookings/domain/cancellation_fee.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/presentation/bloc/detail/booking_detail_bloc.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/booking_status_badge.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/time_labels.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/pricing/presentation/widgets/duration_labels.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({required this.bookingId, super.key});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingDetailBloc>()..add(BookingDetailRequested(bookingId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.bookingDetailTitle),
          actions: const [LanguageToggleButton(), SizedBox(width: 8)],
        ),
        body: SafeArea(
          child: BlocConsumer<BookingDetailBloc, BookingDetailState>(
            listenWhen: (a, b) => a.cancelFailure != b.cancelFailure && b.cancelFailure != null,
            listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.cancelFailure!.message(context.l10n))),
            ),
            builder: (context, state) => switch (state.status) {
              DetailStatus.loading => const Center(child: CircularProgressIndicator()),
              DetailStatus.failure when state.booking == null => FailureView(
                failure: state.failure!,
                onRetry: () => context.read<BookingDetailBloc>().add(BookingDetailRequested(bookingId)),
              ),
              _ => RefreshIndicator(
                onRefresh: () async => context.read<BookingDetailBloc>().add(BookingDetailRequested(bookingId)),
                child: _Details(state: state),
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.state});

  final BookingDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final booking = state.booking!;
    final time = CountryTime(state.country?.timezone ?? 'UTC');
    final when = time.local(booking.scheduledFor);
    final pricing = booking.pricing;
    final cancellation = booking.cancellation;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.service == null ? '' : context.localize(state.service!.name),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.bookingNumber(booking.bookingNumber),
              key: const ValueKey('detail-number'),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              _statusExplanation(context, booking, time),
              key: const ValueKey('status-explanation'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _WorkerContact(booking: booking, workerName: state.worker == null ? null : context.workerName(state.worker!)),
            const Divider(height: 32),
            _Row(
              icon: Icons.event_rounded,
              label: l10n.reviewWhen,
              value: '${context.longDate(when)}\n${context.clockTime(when)} · '
                  '${context.hoursLabel(booking.estimatedDurationMinutes / 60)}',
            ),
            _Row(
              icon: Icons.storefront_rounded,
              label: l10n.addressLandmark,
              value: booking.address.landmark,
              emphasize: true,
            ),
            _Row(
              icon: Icons.signpost_rounded,
              label: l10n.addressText,
              value: [
                booking.address.text,
                if (booking.address.floor case final f? when f.isNotEmpty) l10n.reviewFloor(f),
              ].join('، '),
            ),
            if (booking.address.notes case final n? when n.isNotEmpty)
              _Row(icon: Icons.sticky_note_2_rounded, label: l10n.addressNotes, value: n),
            if (pricing != null) ...[
              const Divider(height: 32),
              Row(
                children: [
                  Expanded(child: Text(l10n.bookingFrozenPrice, style: theme.textTheme.titleMedium)),
                  Text(
                    context.money(pricing.basePrice, pricing.currency),
                    key: const ValueKey('detail-price'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (pricing.hours case final h?) Text(l10n.quoteForHours(context.hoursLabel(h))),
              if (pricing.roomCount case final r?) Text(l10n.quoteForRooms(l10n.roomsCount(r))),
            ],
            if (cancellation != null) ...[
              const SizedBox(height: 16),
              Text(
                cancellation.feeAmount > 0
                    ? l10n.cancelledWithFee(context.money(cancellation.feeAmount, pricing?.currency ?? ''))
                    : l10n.cancelledFree,
                key: const ValueKey('cancellation-result'),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            if (booking.status.customerCanCancel) ...[
              const SizedBox(height: 32),
              OutlinedButton.icon(
                key: const ValueKey('cancel-booking'),
                style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                onPressed: state.cancelling ? null : () => _confirmCancel(context),
                icon: const Icon(Icons.cancel_outlined),
                label: Text(l10n.cancelBooking),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusExplanation(BuildContext context, Booking booking, CountryTime time) {
    final l10n = context.l10n;
    return switch (booking.status) {
      BookingStatus.pendingWorker => booking.responseDeadline == null
          ? l10n.explainPending
          : l10n.explainPendingUntil(
              '${context.longDate(time.local(booking.responseDeadline!))} ${context.clockTime(time.local(booking.responseDeadline!))}',
            ),
      BookingStatus.accepted => l10n.explainAccepted,
      BookingStatus.onTheWay || BookingStatus.arrived || BookingStatus.inProgress => l10n.explainUnderway,
      BookingStatus.completed => l10n.explainCompleted,
      BookingStatus.rejected => l10n.explainRejected,
      BookingStatus.expired => l10n.explainExpired,
      BookingStatus.cancelled => l10n.explainCancelled,
      BookingStatus.searching || BookingStatus.noWorkerFound || BookingStatus.noShow || BookingStatus.unknown => '',
    };
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final bloc = context.read<BookingDetailBloc>();
    final reason = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(value: bloc, child: const _CancelSheet()),
    );
    if (reason != null) bloc.add(BookingCancelRequested(reason));
  }
}

/// The worker's phone appears only after she ACCEPTS; until then the
/// backend sends null and the app says when it will appear.
class _WorkerContact extends StatelessWidget {
  const _WorkerContact({required this.booking, required this.workerName});

  final Booking booking;
  final String? workerName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final phone = booking.workerPhone;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(phone == null ? Icons.lock_clock_rounded : Icons.phone_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workerName ?? l10n.workerUnnamed, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                if (phone != null)
                  SelectableText(
                    ltrIsolate(phone),
                    key: const ValueKey('worker-phone'),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  )
                else
                  Text(
                    booking.status.isFinished ? l10n.workerPhoneNotShared : l10n.workerPhoneHidden,
                    key: const ValueKey('worker-phone-hidden'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (phone != null)
            IconButton(
              tooltip: l10n.copyPhone,
              onPressed: () => Clipboard.setData(ClipboardData(text: phone)),
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, this.emphasize = false});

  final IconData icon;
  final String label;
  final String value;
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

/// Shows the fee BEFORE she confirms, from her country's real policy, and
/// asks for the reason the server requires. Pops with the reason.
class _CancelSheet extends StatefulWidget {
  const _CancelSheet();

  @override
  State<_CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<_CancelSheet> {
  final _other = TextEditingController();
  int? _choice;

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bloc = context.read<BookingDetailBloc>();
    final state = bloc.state;
    final booking = state.booking!;
    final policy = state.country?.bookingPolicy ?? BookingPolicy.defaults;
    final fee = bloc.feePreview();
    final currency = booking.pricing?.currency ?? '';
    final time = CountryTime(state.country?.timezone ?? 'UTC');
    final freeUntil = time.local(CancellationFee.freeUntil(booking, policy));
    final reasons = [l10n.cancelReasonPlans, l10n.cancelReasonTime, l10n.cancelReasonElse, l10n.cancelReasonOther];
    final isOther = _choice == reasons.length - 1;
    final reason = _choice == null ? '' : (isOther ? _other.text.trim() : reasons[_choice!]);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.cancelTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            key: const ValueKey('cancel-fee'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: fee > 0 ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              fee > 0
                  ? l10n.cancelFeeLate(
                      context.money(fee, currency),
                      policy.freeCancellationHours,
                      (policy.cancellationFeeBasisPoints / 100).toStringAsFixed(0),
                    )
                  : l10n.cancelFeeFree('${context.longDate(freeUntil)} ${context.clockTime(freeUntil)}'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fee > 0 ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.cancelReasonLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < reasons.length; i++)
                ChoiceChip(
                  key: ValueKey('cancel-reason-$i'),
                  label: Text(reasons[i]),
                  selected: _choice == i,
                  onSelected: (_) => setState(() => _choice = i),
                ),
            ],
          ),
          if (isOther) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _other,
              maxLength: 200,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.cancelReasonOtherHint),
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            key: const ValueKey('cancel-confirm'),
            label: fee > 0 ? l10n.cancelConfirmWithFee(context.money(fee, currency)) : l10n.cancelConfirmFree,
            onPressed: reason.isEmpty ? null : () => Navigator.of(context).pop(reason),
          ),
          TextButton(
            key: const ValueKey('cancel-keep'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelKeep),
          ),
        ],
      ),
    );
  }
}
