import 'package:baytna_customer/core/dev/dev_otp.dart';
import 'package:baytna_customer/features/auth/domain/phone_number.dart';
import 'package:baytna_customer/main.dart' as app;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Full login against the LIVE staging backend, through the real UI:
/// country → phone → OTP (via the debug-only dev helper) → home → logout.
///
///   flutter drive -d chrome \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/login_e2e_test.dart \
///     --dart-define-from-file=secrets.json
///
/// Override the number with --dart-define=E2E_PHONE=0933333333.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const phone = String.fromEnvironment('E2E_PHONE', defaultValue: '0911111111');

  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    int seconds = 120,
  }) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Timed out after ${seconds}s waiting for $finder');
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await tester.pump(
      const Duration(milliseconds: 400),
    ); // let animations settle
    await binding.takeScreenshot(name);
  }

  void log(String message) => debugPrint('[e2e] $message');

  testWidgets('live login end-to-end', (tester) async {
    expect(
      DevOtp.enabled,
      isTrue,
      reason: 'Run with --dart-define-from-file=secrets.json',
    );
    final started = DateTime.now();

    // On web, debugPrint only reaches the browser console. Capture the app's
    // log ([api] / [dev-otp] / [e2e]) and hand it to the driver, which writes
    // build/e2e_screenshots/log.txt.
    final captured = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      final t = DateTime.now().difference(started).inMilliseconds / 1000;
      if (message != null) {
        captured.add('${t.toStringAsFixed(1).padLeft(6)}s  $message');
      }
      originalDebugPrint(message, wrapWidth: wrapWidth);
    };
    try {
      await app.main();
      // Android can only screenshot after the surface is converted to an image.
      if (defaultTargetPlatform == TargetPlatform.android) {
        await binding.convertFlutterSurfaceToImage();
      }
      log('app started; waiting for countries (server may be cold)…');
      await waitFor(tester, find.byKey(const ValueKey('country-SY')));
      log(
        'countries loaded after ${DateTime.now().difference(started).inSeconds}s',
      );
      await tester.pump(
        const Duration(seconds: 2),
      ); // web fetches the emoji (flag) font lazily
      await shot(tester, '1-country');

      await tester.tap(find.byKey(const ValueKey('country-SY')));
      await waitFor(tester, find.byKey(const ValueKey('phone-field')));
      await tester.enterText(find.byKey(const ValueKey('phone-field')), phone);
      await tester.pump();
      await shot(tester, '2-phone');
      log('entered $phone, requesting OTP');

      await tester.tap(find.byKey(const ValueKey('send-code')));
      await waitFor(
        tester,
        find.byKey(const ValueKey('otp-field')),
        seconds: 90,
      );
      final subtitle = find.textContaining('+963');
      log('OTP screen: "${tester.widget<Text>(subtitle.first).data}"');
      await shot(tester, '3-otp');

      await tester.tap(find.byKey(const ValueKey('dev-otp-fill')));
      log('dev helper fetching the code; six digits auto-submit');
      await waitFor(
        tester,
        find.byKey(const ValueKey('home-phone')),
        seconds: 90,
      );

      final shown = tester
          .widget<Text>(find.byKey(const ValueKey('home-phone')))
          .data!;
      log('HOME shows phone: $shown');
      expect(shown, contains(PhoneNumber.toE164(phone, prefix: '+963')));
      await waitFor(tester, find.byKey(const ValueKey('service-CLEANING')));
      for (final key in ['CLEANING', 'COOKING', 'IRONING']) {
        expect(find.byKey(ValueKey('service-$key')), findsOneWidget);
      }
      log('HOME lists the live services: ${find.textContaining('تنظيف').evaluate().isNotEmpty ? 'تنظيف, طبخ, كوي الملابس' : '?'}');
      await tester.pump(
        const Duration(seconds: 3),
      ); // let PATCH /users/me/locale finish
      await shot(tester, '4-home');

      await tester.tap(find.byKey(const ValueKey('logout')));
      await waitFor(
        tester,
        find.byKey(const ValueKey('country-SY')),
        seconds: 30,
      );
      log('logged out → back at country selection');
      await shot(tester, '5-after-logout');
      log('total ${DateTime.now().difference(started).inSeconds}s');
    } finally {
      debugPrint = originalDebugPrint;
      (binding.reportData ??= <String, dynamic>{})['log'] = captured;
    }
  }, timeout: const Timeout(Duration(minutes: 6)));
}
