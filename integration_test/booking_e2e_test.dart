import 'dart:math';

import 'package:baytna_customer/core/dev/dev_otp.dart';
import 'package:baytna_customer/core/dev/dev_worker_services.dart';
import 'package:baytna_customer/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The minimum path to a real booking, against the LIVE staging backend,
/// through the real UI on an Android emulator:
///
///   sign in → CLEANING → browse (Damascus) → her profile → price preview
///   (minimum stated first) → a day and a free time → map pin + landmark →
///   review → POST /bookings → …
///
/// Location: grant ACCESS_FINE_LOCATION once the app is installed and put
/// the emulator in Damascus (`adb emu geo fix 36.25 33.5005`) to see the pin
/// start at "her" position; without it, the pin starts at the city centre.
///
///   flutter drive -d emulator-5556 \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/booking_e2e_test.dart \
///     --dart-define-from-file=secrets.json
///
/// Needs DEV_OTP_KEY and DEV_WORKER_SERVICES in secrets.json (see README).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // A fresh customer each run (staging rate-limits OTP requests per number).
  const phoneOverride = String.fromEnvironment('E2E_PHONE');
  final phone = phoneOverride.isNotEmpty
      ? phoneOverride
      : '0955${Random().nextInt(1000000).toString().padLeft(6, '0')}';
  const workerId = String.fromEnvironment('E2E_WORKER', defaultValue: '6adf1a91b4c4645d759bc2a0');

  Future<void> waitFor(WidgetTester tester, Finder finder, {int seconds = 120}) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out after ${seconds}s waiting for $finder');
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(const Duration(milliseconds: 600));
    await binding.takeScreenshot(name);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder);
    await tester.pump();
  }

  String textOf(WidgetTester tester, Finder finder) => tester.widget<Text>(finder).data ?? '';

  void log(String message) => debugPrint('[e2e] $message');

  testWidgets('live booking end-to-end', (tester) async {
    expect(DevOtp.enabled, isTrue, reason: 'Run with --dart-define-from-file=secrets.json');
    expect(DevWorkerServices.enabled, isTrue, reason: 'DEV_WORKER_SERVICES missing from secrets.json');
    final started = DateTime.now();
    final captured = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      final t = DateTime.now().difference(started).inMilliseconds / 1000;
      if (message != null) captured.add('${t.toStringAsFixed(1).padLeft(6)}s  $message');
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };
    try {
      await app.main();
      if (defaultTargetPlatform == TargetPlatform.android) await binding.convertFlutterSurfaceToImage();

      // ── Sign in ───────────────────────────────────────────────────────────
      await waitFor(tester, find.byKey(const ValueKey('country-SY')));
      await tester.tap(find.byKey(const ValueKey('country-SY')));
      await waitFor(tester, find.byKey(const ValueKey('phone-field')));
      await tester.enterText(find.byKey(const ValueKey('phone-field')), phone);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('send-code')));
      await waitFor(tester, find.byKey(const ValueKey('dev-otp-fill')), seconds: 90);
      await tester.tap(find.byKey(const ValueKey('dev-otp-fill')));
      await waitFor(tester, find.byKey(const ValueKey('service-CLEANING')), seconds: 90);
      log('signed in as $phone; home lists the services');

      // ── 1. Browse ─────────────────────────────────────────────────────────
      await tester.tap(find.byKey(const ValueKey('service-CLEANING')));
      await waitFor(tester, find.byKey(const ValueKey('city-picker')));
      // A new account has no home city: choose Damascus in the picker.
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byKey(const ValueKey('city-picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('دمشق').last);
      await tester.pump();
      await waitFor(tester, find.byKey(const ValueKey('worker-$workerId')));
      log('BROWSE: ${find.byType(Card).evaluate().length} worker card(s) for CLEANING in the selected city');
      await shot(tester, '01-browse');

      // ── 2. Her profile ────────────────────────────────────────────────────
      await tester.tap(find.byKey(const ValueKey('worker-$workerId')));
      await waitFor(tester, find.byKey(const ValueKey('worker-name')));
      log('PROFILE: name shown as "${textOf(tester, find.byKey(const ValueKey('worker-name')))}"');
      await shot(tester, '02-profile');

      // ── 3. Price preview: minimum first, then pick hours ─────────────────
      await waitFor(tester, find.byKey(const ValueKey('quote-price')));
      final notice = find.descendant(of: find.byKey(const ValueKey('min-hours-notice')), matching: find.byType(Text));
      log('MINIMUM NOTICE: "${textOf(tester, notice)}"');
      log('QUOTE at minimum: ${textOf(tester, find.byKey(const ValueKey('hours-value')))} → '
          '${textOf(tester, find.byKey(const ValueKey('quote-price')))}');
      expect(
        tester.widget<IconButton>(find.byKey(const ValueKey('hours-minus'))).onPressed,
        isNull,
        reason: 'cannot go below her minimum',
      );
      await tapVisible(tester, find.byKey(const ValueKey('hours-plus')));
      await tapVisible(tester, find.byKey(const ValueKey('hours-plus')));
      await tester.pump(const Duration(seconds: 3));
      await waitFor(tester, find.byKey(const ValueKey('quote-price')));
      log('QUOTE after +1h: ${textOf(tester, find.byKey(const ValueKey('hours-value')))} → '
          '${textOf(tester, find.byKey(const ValueKey('quote-price')))}');
      await shot(tester, '03-quote');

      // ── 4. A day and a free time ──────────────────────────────────────────
      await tapVisible(tester, find.byKey(const ValueKey('continue-booking')));
      await waitFor(tester, find.byKey(const ValueKey('day-3')));
      await tapVisible(tester, find.byKey(const ValueKey('day-3')));
      final firstTime = find.byWidgetPredicate(
        (w) => w is ChoiceChip && (w.key as ValueKey<String>?)?.value.startsWith('time-') == true,
      );
      await waitFor(tester, firstTime);
      final chips = firstTime.evaluate().length;
      final timeKey = (tester.widget<ChoiceChip>(firstTime.first).key! as ValueKey<String>).value;
      log('SLOTS for ${textOf(tester, find.byKey(const ValueKey('selected-day')))}: $chips start times; '
          'first = ${(tester.widget<ChoiceChip>(firstTime.first).label as Text).data} ($timeKey)');
      await tapVisible(tester, firstTime.first);
      await shot(tester, '04-slot');

      // ── 5. Pin + landmark ─────────────────────────────────────────────────
      await tapVisible(tester, find.byKey(const ValueKey('time-next')));
      await waitFor(tester, find.byKey(const ValueKey('address-map')));
      await tester.pump(const Duration(seconds: 4)); // location + tiles
      log('PIN start: "${textOf(tester, find.byKey(const ValueKey('pin-source')))}"');
      // Drag the map: the pin (fixed at the centre) lands somewhere else.
      await tester.drag(find.byKey(const ValueKey('address-map')), const Offset(-60, 80));
      await tester.pump(const Duration(seconds: 2));
      await tester.enterText(find.byKey(const ValueKey('landmark-field')), 'مقابل صيدلية الشفاء، البناء ذو الباب الأخضر');
      await tester.enterText(find.byKey(const ValueKey('address-text-field')), 'المزة، شارع الجلاء');
      await tester.enterText(find.byKey(const ValueKey('floor-field')), '3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump(const Duration(seconds: 1));
      await tester.ensureVisible(find.byKey(const ValueKey('address-map')));
      await shot(tester, '05-pin-landmark');

      // ── 6. Review and create ──────────────────────────────────────────────
      await tapVisible(tester, find.byKey(const ValueKey('address-next')));
      await waitFor(tester, find.byKey(const ValueKey('review-price')));
      log('REVIEW: ${textOf(tester, find.byKey(const ValueKey('review-when'))).replaceAll('\n', ' ')} | '
          'landmark "${textOf(tester, find.byKey(const ValueKey('review-landmark')))}" | '
          'price ${textOf(tester, find.byKey(const ValueKey('review-price')))}');
      await shot(tester, '06-review');
      await tapVisible(tester, find.byKey(const ValueKey('confirm-booking')));
      await waitFor(tester, find.byKey(const ValueKey('booking-created')), seconds: 90);
      final number = textOf(tester, find.byKey(const ValueKey('created-number')));
      log('CREATED: $number');
      await shot(tester, '07-created');

      log('total ${DateTime.now().difference(started).inSeconds}s');
    } finally {
      debugPrint = originalDebugPrint;
      (binding.reportData ??= <String, dynamic>{})['log'] = captured;
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}
