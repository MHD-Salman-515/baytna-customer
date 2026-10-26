import 'package:baytna_customer/features/bookings/domain/start_times.dart';
import 'package:baytna_customer/features/workers/domain/entities/free_interval.dart';
import 'package:flutter_test/flutter_test.dart';

FreeInterval _i(String start, String end) => FreeInterval(start: DateTime.parse(start), end: DateTime.parse(end));

void main() {
  const twoHours = Duration(hours: 2);

  test('a job must END by the end of the interval', () {
    // Staging, 2026-11-05, after one 07:00–09:00Z booking (30 min buffer each side).
    final times = StartTimes.compute(
      intervals: [
        _i('2026-11-05T05:00:00.000Z', '2026-11-05T06:30:00.000Z'),
        _i('2026-11-05T09:30:00.000Z', '2026-11-05T17:00:00.000Z'),
      ],
      duration: twoHours,
      now: DateTime.utc(2026, 11),
      horizonDays: 90,
    );
    // 05:00–06:30 is too short for two hours.
    expect(times.first, DateTime.utc(2026, 11, 5, 9, 30));
    expect(times.last, DateTime.utc(2026, 11, 5, 15));
    expect(times, hasLength(12));
  });

  test("today's interval includes the past: only times an hour from now are offered", () {
    final times = StartTimes.compute(
      intervals: [_i('2026-10-26T05:00:00.000Z', '2026-10-26T17:00:00.000Z')],
      duration: twoHours,
      now: DateTime.utc(2026, 10, 26, 11, 53),
      horizonDays: 90,
    );
    expect(times.first, DateTime.utc(2026, 10, 26, 13));
  });

  test('slots past the horizon are dropped (the server still returns them)', () {
    final now = DateTime.utc(2026, 10, 26, 12);
    final times = StartTimes.compute(
      intervals: [_i('2027-01-24T05:00:00.000Z', '2027-01-24T17:00:00.000Z')],
      duration: twoHours,
      now: now,
      horizonDays: 90,
    );
    expect(times.every((t) => !t.isAfter(now.add(const Duration(days: 90)))), isTrue);
    expect(times.last, DateTime.utc(2027, 1, 24, 12));
  });

  test('odd interval starts round up to the half hour', () {
    final times = StartTimes.compute(
      intervals: [_i('2026-11-05T09:10:00.000Z', '2026-11-05T11:00:00.000Z')],
      duration: const Duration(hours: 1),
      now: DateTime.utc(2026, 11),
      horizonDays: 90,
    );
    expect(times, [DateTime.utc(2026, 11, 5, 9, 30), DateTime.utc(2026, 11, 5, 10)]);
  });

  test('no intervals → no times', () {
    expect(
      StartTimes.compute(intervals: const [], duration: twoHours, now: DateTime.utc(2026), horizonDays: 90),
      isEmpty,
    );
  });
}
