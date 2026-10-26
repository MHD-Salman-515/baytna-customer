import 'package:baytna_customer/core/time/country_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final damascus = CountryTime('Asia/Damascus');

  test('staging slot 05:00Z is 08:00 in Damascus (UTC+3)', () {
    final t = damascus.local(DateTime.utc(2026, 10, 28, 5));
    expect((t.hour, t.minute), (8, 0));
  });

  test('the date key is the COUNTRY date, not the phone/UTC date', () {
    // 22:30 UTC on the 27th is already 01:30 on the 28th in Damascus.
    expect(damascus.dateKey(DateTime.utc(2026, 10, 27, 22, 30)), '2026-10-28');
  });

  test('day(n) is country midnight n days on', () {
    final d = damascus.day(DateTime.utc(2026, 10, 27, 22, 30), 1);
    expect((d.year, d.month, d.day, d.hour), (2026, 10, 29, 0));
  });

  test('an unknown zone degrades to UTC instead of crashing', () {
    expect(CountryTime('Mars/Olympus').dateKey(DateTime.utc(2026, 1, 1, 23)), '2026-01-01');
  });
}
