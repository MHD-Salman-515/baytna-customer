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
///   (minimum stated first) → …
///
///   flutter drive -d emulator-5556 \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/booking_e2e_test.dart \
///     --dart-define-from-file=secrets.json
///
/// Needs DEV_OTP_KEY and DEV_WORKER_SERVICES in secrets.json (see README).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phone = String.fromEnvironment('E2E_PHONE', defaultValue: '0955500101');
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

      log('total ${DateTime.now().difference(started).inSeconds}s');
    } finally {
      debugPrint = originalDebugPrint;
      (binding.reportData ??= <String, dynamic>{})['log'] = captured;
    }
  }, timeout: const Timeout(Duration(minutes: 8)));
}
