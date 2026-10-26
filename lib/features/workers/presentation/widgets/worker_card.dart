import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/features/workers/domain/entities/worker.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/rating_label.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_avatar.dart';
import 'package:baytna_customer/features/workers/presentation/widgets/worker_labels.dart';
import 'package:flutter/material.dart';

class WorkerCard extends StatelessWidget {
  const WorkerCard({
    required this.worker,
    required this.serviceId,
    required this.cityName,
    required this.onTap,
    super.key,
  });

  final Worker worker;
  final String serviceId;
  final String cityName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offering = worker.offeringFor(serviceId);
    final bio = context.localize(worker.bio);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: InkWell(
        key: ValueKey('worker-${worker.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkerAvatar(photoUrl: worker.photoUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.workerName(worker),
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        RatingLabel(rating: worker.rating),
                      ],
                    ),
                    // The list is filtered by city, so she serves this one.
                    Text(context.l10n.workerServesCities(cityName), style: theme.textTheme.bodySmall),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    if (offering != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        context.offeringPrice(offering),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
