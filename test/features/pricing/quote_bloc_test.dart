import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/utils/result.dart';
import 'package:baytna_customer/features/pricing/domain/pricing_repository.dart';
import 'package:baytna_customer/features/pricing/domain/quote.dart';
import 'package:baytna_customer/features/pricing/presentation/bloc/quote_bloc.dart';
import 'package:baytna_customer/features/services/domain/entities/service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Pricing extends Mock implements PricingRepository;

/// Mirrors staging for her CLEANING offering: 6000/h, minHours 2. The server
/// raises anything below 2 to 2 and echoes the effective hours.
Future<Result<Quote>> _staging(Invocation i) async {
  final asked = i.namedArguments[#hours] as num?;
  final hours = (asked == null || asked < 2) ? 2 : asked;
  return Ok(Quote(price: hours * 6000, currency: 'SYP', pricingType: PricingType.hourly, hours: hours));
}

void main() {
  late _Pricing pricing;
  setUp(() => pricing = _Pricing());

  Future<QuoteState> settle(QuoteBloc bloc) async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return bloc.state;
  }

  group('HOURLY', () {
    setUp(() {
      when(() => pricing.quote(any(), hours: any(named: 'hours'), roomCount: any(named: 'roomCount')))
          .thenAnswer(_staging);
    });

    test('learns her minimum from a quote WITHOUT hours, before she picks any', () async {
      final bloc = QuoteBloc(pricing)
        ..add(const QuoteStarted(workerServiceId: 'ws', pricingType: PricingType.hourly));
      final s = await settle(bloc);
      verify(() => pricing.quote('ws')).called(1);
      expect(s.minHours, 2);
      expect(s.hours, 2);
      expect(s.quote!.price, 12000);
      expect(s.jobSize.durationMinutes, 120);
    });

    test('never asks for less than the minimum', () async {
      final bloc = QuoteBloc(pricing)
        ..add(const QuoteStarted(workerServiceId: 'ws', pricingType: PricingType.hourly));
      await settle(bloc);
      bloc.add(const QuoteSizeChanged(hours: 1));
      final s = await settle(bloc);
      verify(() => pricing.quote('ws', hours: 2)).called(1);
      verifyNever(() => pricing.quote('ws', hours: 1));
      expect(s.hours, 2);
    });

    test('3.5 hours → the server price for 3.5 hours', () async {
      final bloc = QuoteBloc(pricing)
        ..add(const QuoteStarted(workerServiceId: 'ws', pricingType: PricingType.hourly));
      await settle(bloc);
      bloc.add(const QuoteSizeChanged(hours: 3.5));
      final s = await settle(bloc);
      expect(s.quote!.price, 21000);
      expect(s.jobSize.hours, 3.5);
      expect(s.jobSize.durationMinutes, 210);
    });
  });

  test('BY_SIZE quotes by rooms; duration is for scheduling only', () async {
    when(() => pricing.quote(any(), hours: any(named: 'hours'), roomCount: any(named: 'roomCount'))).thenAnswer(
      (i) async => Ok(Quote(
        price: (i.namedArguments[#roomCount] as int) * 10000,
        currency: 'SYP',
        pricingType: PricingType.bySize,
        roomCount: i.namedArguments[#roomCount] as int,
      )),
    );
    final bloc = QuoteBloc(pricing)..add(const QuoteStarted(workerServiceId: 'ws', pricingType: PricingType.bySize));
    await settle(bloc);
    bloc.add(const QuoteSizeChanged(rooms: 4));
    var s = await settle(bloc);
    expect(s.quote!.price, 40000);
    bloc.add(const QuoteDurationChanged(3));
    s = await settle(bloc);
    expect(s.jobSize.roomCount, 4);
    expect(s.jobSize.hours, isNull);
    expect(s.jobSize.durationMinutes, 180);
    verifyNever(() => pricing.quote(any(), hours: any(named: 'hours', that: isNotNull)));
  });

  test('FIXED quotes once with no size', () async {
    when(() => pricing.quote(any())).thenAnswer(
      (_) async => const Ok(Quote(price: 50000, currency: 'SYP', pricingType: PricingType.fixed)),
    );
    final bloc = QuoteBloc(pricing)..add(const QuoteStarted(workerServiceId: 'ws', pricingType: PricingType.fixed));
    final s = await settle(bloc);
    expect(s.quote!.price, 50000);
    expect(s.canContinue, isTrue);
  });

  test('a failed re-quote keeps the last price but blocks continuing', () async {
    var calls = 0;
    when(() => pricing.quote(any(), hours: any(named: 'hours'))).thenAnswer((i) async {
      calls++;
      return calls == 1 ? await _staging(i) : const Err(NetworkFailure());
    });
    final bloc = QuoteBloc(pricing)
      ..add(const QuoteStarted(workerServiceId: 'ws', pricingType: PricingType.hourly));
    await settle(bloc);
    bloc.add(const QuoteSizeChanged(hours: 3));
    final s = await settle(bloc);
    expect(s.status, QuoteStatus.failure);
    expect(s.quote!.price, 12000);
    expect(s.canContinue, isFalse);
  });
}
