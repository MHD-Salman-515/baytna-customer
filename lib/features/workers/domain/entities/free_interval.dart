import 'package:equatable/equatable.dart';

/// One element of GET /workers/:id/slots: a stretch of time she's free.
/// The travel buffer between jobs is already carved out, so a job may start
/// at [start] and must END by [end].
class FreeInterval extends Equatable {
  const FreeInterval({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  List<Object?> get props => [start, end];
}
