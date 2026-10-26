import 'package:flutter/material.dart';

/// `label   [−] value [+]`. A null callback disables that side.
class StepperRow extends StatelessWidget {
  const StepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.keyPrefix = 'stepper',
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
        IconButton.outlined(
          key: ValueKey('$keyPrefix-minus'),
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_rounded),
        ),
        SizedBox(
          width: 96,
          child: Text(
            value,
            key: ValueKey('$keyPrefix-value'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.outlined(
          key: ValueKey('$keyPrefix-plus'),
          onPressed: onIncrement,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
