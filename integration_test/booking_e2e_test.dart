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
///   review → POST /bookings → the booking (worker's phone hidden while
///   pending; cancel fee previewed, NOT confirmed) → My bookings.
///
/// It leaves a real PENDING_WORKER booking on staging; it lapses on its own
/// after the country's response deadline if the worker doesn't answer.
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
  // Re-verify an EXISTING booking without creating another: pass
  // E2E_VERIFY_ONLY=true, E2E_PHONE=<its customer> and E2E_BOOKING=<its number>.
  const verifyOnly = bool.fromEnvironment('E2E_VERIFY_ONLY');
  const existingBooking = String.fromEnvironment('E2E_BOOKING');

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

  String textOf(WidgetTester tester, Finder finder) =>
      finder.evaluate().isEmpty ? '(missing)' : tester.widget<Text>(finder.first).data ?? '';

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
      await tester.pump(const Duration(seconds: 1));
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
      // Before ANY duration is picked: the notice must sit above the control.
      final noticeY = tester.getTopLeft(find.byKey(const ValueKey('min-hours-notice'))).dy;
      final controlY = tester.getTopLeft(find.byKey(const ValueKey('hours-value'))).dy;
      expect(noticeY, lessThan(controlY));
      log('ORDER (before any tap): minimum notice at y=${noticeY.round()}, hours control at '
          'y=${controlY.round()} → the minimum is stated first; "−" disabled at the minimum');
      await tester.ensureVisible(find.byKey(const ValueKey('min-hours-notice')));
      await shot(tester, '03a-minimum-before-choosing');
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
      await tester.pump(const Duration(seconds: 10)); // location (≤10 s) + tiles
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
      await shot(tester, '06-review');
      log('REVIEW texts: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).whereType<String>().where((t) => t.trim().isNotEmpty).join(' | ')}');
      log('REVIEW: ${textOf(tester, find.byKey(const ValueKey('review-when'))).replaceAll('\n', ' ')} | '
          'landmark "${textOf(tester, find.byKey(const ValueKey('review-landmark')))}" | '
          'price ${textOf(tester, find.byKey(const ValueKey('review-price')))}');
      // The booking screen: status, frozen price, phone hidden until accepted;
      // the cancellation fee is previewed BEFORE confirming, and we keep it.
      Future<void> checkDetail() async {
        await waitFor(tester, find.byKey(const ValueKey('detail-price')));
        expect(find.byKey(const ValueKey('status-PENDING_WORKER')), findsOneWidget);
        expect(find.byKey(const ValueKey('worker-phone')), findsNothing);
        log('DETAIL: ${textOf(tester, find.byKey(const ValueKey('detail-number')))} | status PENDING_WORKER | '
            'frozen price ${textOf(tester, find.byKey(const ValueKey('detail-price')))}');
        log('PHONE: "${textOf(tester, find.byKey(const ValueKey('worker-phone-hidden')))}"');
        log('STATUS NOTE: "${textOf(tester, find.byKey(const ValueKey('status-explanation')))}"');
        await shot(tester, '08-detail-phone-hidden');
        await tapVisible(tester, find.byKey(const ValueKey('cancel-booking')));
        await waitFor(tester, find.byKey(const ValueKey('cancel-fee')));
        await tester.pump(const Duration(milliseconds: 500));
        final fee = find.descendant(of: find.byKey(const ValueKey('cancel-fee')), matching: find.byType(Text));
        log('CANCEL PREVIEW: "${textOf(tester, fee)}"');
        await shot(tester, '09-cancel-preview');
        await tester.tap(find.byKey(const ValueKey('cancel-keep')));
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(const ValueKey('cancel-fee')), findsNothing, reason: 'kept, sheet closed');
      }

      Future<void> backToHome() async {
        for (var i = 0; i < 10 && find.byKey(const ValueKey('my-bookings')).evaluate().isEmpty; i++) {
          await tester.tap(find.byType(BackButton).first);
          await tester.pump(const Duration(seconds: 1));
        }
        await waitFor(tester, find.byKey(const ValueKey('my-bookings')));
      }

      Future<void> openMyBookings(String number) async {
        await tester.tap(find.byKey(const ValueKey('my-bookings')));
        await waitFor(tester, find.text(number));
        final tiles = find.byWidgetPredicate(
          (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('booking-'),
        );
        log('MY BOOKINGS lists $number (${tiles.evaluate().length} booking(s); '
            'status badge: ${find.byKey(const ValueKey('status-PENDING_WORKER')).evaluate().length} × بانتظار رد العاملة)');
        await shot(tester, '10-my-bookings');
      }

      if (verifyOnly) {
        // ── 7'. An existing booking: do NOT create a duplicate ──────────────
        log('VERIFY-ONLY: stopping at review (no POST /bookings); checking $existingBooking');
        await backToHome();
        await openMyBookings(existingBooking);
        await tester.tap(find.text(existingBooking));
        await checkDetail();
      } else {
        // ── 7. Create ─────────────────────────────────────────────────────────
        await tapVisible(tester, find.byKey(const ValueKey('confirm-booking')));
        await waitFor(tester, find.byKey(const ValueKey('booking-created')), seconds: 90);
        final number = textOf(tester, find.byKey(const ValueKey('created-number'))).split(' ').last;
        log('CREATED: $number');
        await shot(tester, '07-created');
        await tapVisible(tester, find.byKey(const ValueKey('view-booking')));
        await checkDetail();
        // ── 8. My bookings ────────────────────────────────────────────────────
        await backToHome();
        await openMyBookings(number);
      }

      log('total ${DateTime.now().difference(started).inSeconds}s');
    } finally {
      debugPrint = originalDebugPrint;
      (binding.reportData ??= <String, dynamic>{})['log'] = captured;
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}
