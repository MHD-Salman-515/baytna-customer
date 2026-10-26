import 'package:baytna_customer/core/error/failure.dart';
import 'package:baytna_customer/core/localization/l10n.dart';
import 'package:baytna_customer/core/widgets/failure_message.dart';
import 'package:baytna_customer/features/bookings/domain/booking_failures.dart';

/// Clear Arabic (and English) for every refusal the server explains.
String bookingFailureMessage(AppLocalizations l10n, Failure failure, {required int horizonDays}) =>
    switch (failure) {
      SlotTaken() => l10n.bookingErrorSlotTaken,
      BeyondHorizon() => l10n.bookingErrorBeyondHorizon(horizonDays),
      OutsideHerHours() => l10n.bookingErrorOutsideHours,
      InThePast() => l10n.bookingErrorInPast,
      CityNotServed() => l10n.bookingErrorCityNotServed,
      LandmarkMissing() => l10n.addressLandmarkRequired,
      WorkerUnavailable() => l10n.bookingErrorWorkerUnavailable,
      _ => failure.message(l10n),
    };
