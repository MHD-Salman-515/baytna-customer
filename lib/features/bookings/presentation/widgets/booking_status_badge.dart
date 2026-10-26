import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/features/bookings/domain/entities/booking.dart';
import 'package:flutter/material.dart';

extension BookingStatusLabels on BookingStatus {
  String label(AppLocalizations l10n) => switch (this) {
    BookingStatus.searching => l10n.statusSearching,
    BookingStatus.pendingWorker => l10n.statusPendingWorker,
    BookingStatus.accepted => l10n.statusAccepted,
    BookingStatus.onTheWay => l10n.statusOnTheWay,
    BookingStatus.arrived => l10n.statusArrived,
    BookingStatus.inProgress => l10n.statusInProgress,
    BookingStatus.completed => l10n.statusCompleted,
    BookingStatus.rejected => l10n.statusRejected,
    BookingStatus.cancelled => l10n.statusCancelled,
    BookingStatus.expired => l10n.statusExpired,
    BookingStatus.noWorkerFound => l10n.statusNoWorkerFound,
    BookingStatus.noShow => l10n.statusNoShow,
    BookingStatus.unknown => l10n.statusUnknown,
  };
}

/// Colour carries meaning only alongside the text, never alone.
class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({required this.status, super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, icon) = switch (status) {
      BookingStatus.pendingWorker || BookingStatus.searching => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        Icons.hourglass_top_rounded,
      ),
      BookingStatus.accepted || BookingStatus.onTheWay || BookingStatus.arrived || BookingStatus.inProgress => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_circle_outline_rounded,
      ),
      BookingStatus.completed => (scheme.secondaryContainer, scheme.onSecondaryContainer, Icons.task_alt_rounded),
      _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant, Icons.do_not_disturb_on_outlined),
    };
    return Container(
      key: ValueKey('status-${status.wire}'),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(status.label(context.l10n), style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
