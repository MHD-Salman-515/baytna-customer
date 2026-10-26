import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:flutter/material.dart';

/// A rating of 0 means no reviews yet: say "new", never "0 stars".
class RatingLabel extends StatelessWidget {
  const RatingLabel({required this.rating, super.key});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (rating <= 0) {
      return Text(
        context.l10n.workerNew,
        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.tertiary),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: Color(0xFFE8A33D)),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1), style: theme.textTheme.labelLarge),
      ],
    );
  }
}
