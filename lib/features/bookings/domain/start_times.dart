import 'package:baytna_customer/features/workers/domain/entities/free_interval.dart';

/// Turns her free intervals into start times the server will accept.
///
/// Verified against staging: the intervals already exclude her other
/// bookings plus the travel buffer, so a job may start at `start` and must
/// END by `end`. They do NOT exclude the past (today's intervals start at
/// her opening hour even in the afternoon) and they are returned for dates
/// beyond the booking horizon, so both are filtered here.
abstract final class StartTimes {
  static const step = Duration(minutes: 30);

  /// Don't offer a time so close that it's past by the time she confirms.
  static const minimumLead = Duration(hours: 1);

  static List<DateTime> compute({
    required List<FreeInterval> intervals,
    required Duration duration,
    required DateTime now,
    required int horizonDays,
  }) {
    final earliest = now.add(minimumLead);
    final latest = now.add(Duration(days: horizonDays));
    final result = <DateTime>{};
    for (final interval in intervals) {
      var t = _roundUp(interval.start.toUtc());
      while (!t.add(duration).isAfter(interval.end.toUtc())) {
        if (!t.isBefore(earliest) && !t.isAfter(latest)) result.add(t);
        t = t.add(step);
      }
    }
    return result.toList()..sort();
  }

  /// To the next half hour (UTC; every zone we serve is a whole-hour offset).
  static DateTime _roundUp(DateTime t) {
    final ms = step.inMilliseconds;
    final rem = t.millisecondsSinceEpoch % ms;
    return rem == 0 ? t : DateTime.fromMillisecondsSinceEpoch(t.millisecondsSinceEpoch - rem + ms, isUtc: true);
  }
}
