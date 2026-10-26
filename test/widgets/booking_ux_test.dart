import 'package:baytna_customer/core/di/injection.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/localization/localized_text.dart';
import 'package:baytna_customer/features/bookings/data/booking_model.dart';
import 'package:baytna_customer/features/bookings/presentation/bloc/detail/booking_detail_bloc.dart';
import 'package:baytna_customer/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:baytna_customer/features/countries/domain/entities/country.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:baytna_customer/features/pricing/presentation/bloc/quote_bloc.dart';
import 'package:baytna_customer/features/pricing/presentation/widgets/quote_panel.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/staging_fixtures.dart';

class _QuoteBloc extends MockBloc<QuoteEvent, QuoteState> implements QuoteBloc;

class _DetailBloc extends MockBloc<BookingDetailEvent, BookingDetailState> implements BookingDetailBloc;

Widget _app(Widget child) => MaterialApp(
  locale: const Locale('ar'),
  supportedLocales: AppLocales.supported,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('HOURLY: the minimum is stated ABOVE the hours control, which stops at it', (tester) async {
    final bloc = _QuoteBloc();
    whenListen(
      bloc,
      const Stream<QuoteState>.empty(),
      initialState: const QuoteState(
        status: QuoteStatus.ready,
        workerServiceId: 'ws',
        pricingType: PricingType.hourly,
        minHours: 2,
        hours: 2,
        quote: Quote(price: 12000, currency: 'SYP', pricingType: PricingType.hourly, hours: 2),
      ),
    );
    await tester.pumpWidget(_app(BlocProvider<QuoteBloc>.value(value: bloc, child: const QuotePanel())));

    final notice = find.byKey(const ValueKey('min-hours-notice'));
    expect(find.descendant(of: notice, matching: find.textContaining('ساعتان')), findsOneWidget);
    expect(
      tester.getTopLeft(notice).dy,
      lessThan(tester.getTopLeft(find.byKey(const ValueKey('hours-value'))).dy),
    );
    expect(tester.widget<IconButton>(find.byKey(const ValueKey('hours-minus'))).onPressed, isNull);
    expect(find.text('12,000 ل.س'), findsOneWidget);
  });

  group('booking detail', () {
    tearDown(getIt.reset);

    Future<void> show(WidgetTester tester, Map<String, dynamic> json) async {
      final bloc = _DetailBloc();
      whenListen(
        bloc,
        const Stream<BookingDetailState>.empty(),
        initialState: BookingDetailState(
          status: DetailStatus.loaded,
          booking: BookingModel.fromJson(json),
          country: const Country(
            id: 'sy',
            code: 'SY',
            name: LocalizedText(ar: 'سوريا', en: 'Syria'),
            phonePrefix: '+963',
            currencyCode: 'SYP',
            timezone: 'Asia/Damascus',
          ),
        ),
      );
      getIt.registerFactory<BookingDetailBloc>(() => bloc);
      await tester.pumpWidget(_app(const SizedBox(height: 1400, child: BookingDetailScreen(bookingId: 'b'))));
      await tester.pump();
    }

    testWidgets('PENDING: no phone, a sentence saying when it appears', (tester) async {
      await show(tester, StagingFixtures.booking);
      expect(find.byKey(const ValueKey('worker-phone')), findsNothing);
      expect(find.text('يظهر رقم هاتفها هنا عندما تقبل الحجز.'), findsOneWidget);
      expect(find.byKey(const ValueKey('status-PENDING_WORKER')), findsOneWidget);
      expect(find.text('12,000 ل.س'), findsOneWidget);
    });

    testWidgets('ACCEPTED: the number the server sends is shown', (tester) async {
      await show(tester, {...StagingFixtures.booking, 'status': 'ACCEPTED', 'workerPhone': '+963945958947'});
      expect(find.byKey(const ValueKey('worker-phone')), findsOneWidget);
      expect(find.byKey(const ValueKey('worker-phone-hidden')), findsNothing);
    });
  });
}
