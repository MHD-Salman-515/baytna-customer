import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';

/// One sentence on how this offering is priced, so nothing in the quote
/// comes as a surprise. Covers the three pricing models.
class PricingExplainer extends StatelessWidget {
  const PricingExplainer({required this.offering, super.key});

  final WorkerOffering offering;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final price = context.money(offering.displayPrice, offering.currency);
    final (icon, text) = switch (offering.pricingType) {
      PricingType.hourly => (Icons.schedule_rounded, l10n.pricingExplainHourly(price)),
      PricingType.bySize => (Icons.meeting_room_rounded, l10n.pricingExplainBySize(price)),
      PricingType.fixed => (Icons.sell_rounded, l10n.pricingExplainFixed(price)),
      PricingType.unknown => (Icons.help_outline_rounded, l10n.pricingExplainUnknown),
    };
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
