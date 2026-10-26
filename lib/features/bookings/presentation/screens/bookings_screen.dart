import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/core/router/app_routes.dart';
import 'package:baytna_customer/core/time/country_time.dart';
import 'package:baytna_customer/core/widgets/failure_view.dart';
import 'package:baytna_customer/core/widgets/page_scaffold.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:baytna_customer/features/bookings/presentation/bloc/list/bookings_list_bloc.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/booking_status_badge.dart';
import 'package:baytna_customer/features/bookings/presentation/widgets/time_labels.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// "My bookings": a simple, filterable list.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  static const filters = <BookingStatus?>[
    null,
    BookingStatus.pendingWorker,
    BookingStatus.accepted,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookingsListBloc>()..add(const BookingsRequested()),
      child: PageScaffold(title: context.l10n.bookingsTitle, body: const _Body()),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<BookingsListBloc>().state;
    final bloc = context.read<BookingsListBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final f in BookingsScreen.filters) ...[
                ChoiceChip(
                  key: ValueKey('filter-${f?.wire ?? 'ALL'}'),
                  label: Text(f == null ? l10n.bookingsFilterAll : f.label(l10n)),
                  selected: state.filter == f,
                  onSelected: (_) => bloc.add(BookingsRequested(status: f)),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: switch (state.status) {
            ListStatus.loading => const Center(child: CircularProgressIndicator()),
            ListStatus.failure => FailureView(
              failure: state.failure!,
              onRetry: () => bloc.add(BookingsRequested(status: state.filter)),
            ),
            ListStatus.loaded when state.items.isEmpty => Center(
              child: Text(l10n.bookingsEmpty, key: const ValueKey('bookings-empty'), textAlign: TextAlign.center),
            ),
            ListStatus.loaded => NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 300) bloc.add(const BookingsNextPageRequested());
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () async => bloc.add(BookingsRequested(status: state.filter)),
                child: ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _BookingTile(booking: state.items[i]),
                ),
              ),
            ),
          },
        ),
      ],
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<BookingsListBloc>().state;
    final service = state.services[booking.serviceId];
    final country = state.countries[booking.countryId];
    final time = CountryTime(country?.timezone ?? 'UTC');
    final when = time.local(booking.scheduledFor);
    final pricing = booking.pricing;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        key: ValueKey('booking-${booking.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await context.push(AppRoutes.bookingFor(booking.id));
          // She may have cancelled it on the detail screen.
          if (context.mounted) {
            context.read<BookingsListBloc>().add(BookingsRequested(status: state.filter));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service == null ? booking.bookingNumber : context.localize(service.name),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  BookingStatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 6),
              Text('${context.longDate(when)} · ${context.clockTime(when)}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.bookingNumber,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                  if (pricing != null)
                    Text(
                      context.money(pricing.basePrice, pricing.currency),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
