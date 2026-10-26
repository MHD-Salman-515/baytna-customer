import 'package:flutter/material.dart';

class WorkerAvatar extends StatelessWidget {
  const WorkerAvatar({required this.photoUrl, this.radius = 28, super.key});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = photoUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.secondaryContainer,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Icon(Icons.person_rounded, size: radius, color: scheme.onSecondaryContainer),
    );
  }
}
