// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بيتنا';

  @override
  String get appTagline => 'خدمات منزلية موثوقة بين يديك';

  @override
  String get switchLanguage => 'English';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get continueAction => 'متابعة';

  @override
  String get serverWakingUp => 'الخادم يستيقظ، قد يستغرق ذلك دقيقة…';

  @override
  String get countrySelectTitle => 'اختر بلدك';

  @override
  String get countrySelectSubtitle => 'نعرض الخدمات والأسعار حسب بلدك';

  @override
  String get countriesEmpty => 'لا توجد دول متاحة حالياً';

  @override
  String get phoneTitle => 'رقم الهاتف';

  @override
  String get phoneSubtitle => 'أدخل رقم هاتفك المحمول وسنرسل لك رمز تحقق';

  @override
  String get phoneFieldLabel => 'رقم الهاتف المحمول';

  @override
  String get phoneInvalid => 'أدخل رقم هاتف صحيحاً';

  @override
  String get phoneRejected => 'هذا الرقم غير صالح للبلد المختار';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSubtitle(String phone) {
    return 'أدخل الرمز المكوّن من 6 أرقام المرسل إلى $phone';
  }

  @override
  String get otpVerify => 'تحقق';

  @override
  String otpResendIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds ثانية',
      few: '$seconds ثوانٍ',
      two: 'ثانيتين',
      one: 'ثانية واحدة',
    );
    return 'يمكنك إعادة الإرسال بعد $_temp0';
  }

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String get otpResent => 'تم إرسال رمز جديد';

  @override
  String get otpInvalid => 'الرمز غير صحيح أو منتهي الصلاحية';

  @override
  String get otpTooManyAttempts =>
      'محاولات خاطئة كثيرة. اطلب رمزاً جديداً للمتابعة.';

  @override
  String get changeNumber => 'تغيير الرقم';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeWelcome => 'أهلاً بك في بيتنا';

  @override
  String get homeSignedInAs => 'تم تسجيل الدخول بالرقم';

  @override
  String get homeChooseService => 'اختر الخدمة التي تحتاجها';

  @override
  String get homeServicesEmpty => 'لا توجد خدمات متاحة حالياً.';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get sessionExpired => 'انتهت جلستك. يرجى تسجيل الدخول مجدداً.';

  @override
  String get errorNetwork => 'تعذّر الاتصال. تحقق من اتصالك بالإنترنت.';

  @override
  String get errorTimeout => 'استغرق الخادم وقتاً طويلاً للرد. حاول مجدداً.';

  @override
  String get errorServer => 'حدث خطأ في الخادم. حاول لاحقاً.';

  @override
  String get errorRateLimited => 'طلبات كثيرة. انتظر قليلاً ثم حاول مجدداً.';

  @override
  String get errorValidation => 'البيانات المدخلة غير صحيحة.';

  @override
  String get errorUnauthorized => 'ليست لديك صلاحية للقيام بذلك.';

  @override
  String get errorNotFound => 'العنصر المطلوب غير موجود.';

  @override
  String get errorUnknown => 'حدث خطأ غير متوقع.';

  @override
  String get devFillOtp => 'تعبئة الرمز تلقائياً (وضع التطوير)';

  @override
  String devOtpUnavailable(String reason) {
    return 'تعذّر جلب الرمز: $reason';
  }

  @override
  String get browseTitle => 'اختر عاملة';

  @override
  String get browseCity => 'المدينة';

  @override
  String get browseSortRating => 'الأعلى تقييماً';

  @override
  String get browseSortPriceAsc => 'الأقل سعراً';

  @override
  String get browseSortPriceDesc => 'الأعلى سعراً';

  @override
  String browseEmpty(String city) {
    return 'لا توجد عاملات متاحات لهذه الخدمة في $city الآن.';
  }

  @override
  String get browseEmptyHint => 'جرّب مدينة أخرى، أو عد لاحقاً.';

  @override
  String get browseNoCities => 'لا توجد مدن متاحة في بلدك بعد.';

  @override
  String get workerUnnamed => 'عاملة منزلية';

  @override
  String get workerNew => 'جديدة على بيتنا';

  @override
  String priceHourly(String price) {
    return '$price / ساعة';
  }

  @override
  String priceFixed(String price) {
    return '$price · سعر ثابت';
  }

  @override
  String priceBySize(String price) {
    return 'يبدأ من $price';
  }

  @override
  String get workerProfileTitle => 'الملف الشخصي';

  @override
  String workerServesCities(String cities) {
    return 'تعمل في: $cities';
  }

  @override
  String get workerAbout => 'نبذة عنها';

  @override
  String get workerServices => 'خدماتها وأسعارها';

  @override
  String get offeringNotBookable => 'لا يمكن حجز هذه الخدمة من التطبيق بعد.';

  @override
  String pricingExplainHourly(String rate) {
    return 'تُحسب بالساعة: $rate لكل ساعة.';
  }

  @override
  String pricingExplainBySize(String price) {
    return 'يُحسب السعر حسب عدد الغرف، ويبدأ من $price.';
  }

  @override
  String pricingExplainFixed(String price) {
    return 'سعر ثابت للخدمة كاملة: $price.';
  }

  @override
  String get pricingExplainUnknown => 'ستعرف السعر قبل تأكيد الحجز.';

  @override
  String hoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ساعة',
      many: '$count ساعة',
      few: '$count ساعات',
      two: 'ساعتان',
      one: 'ساعة واحدة',
    );
    return '$_temp0';
  }

  @override
  String hoursDecimal(String hours) {
    return '$hours ساعة';
  }

  @override
  String roomsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غرفة',
      many: '$count غرفة',
      few: '$count غرف',
      two: 'غرفتان',
      one: 'غرفة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get quoteSectionTitle => 'احسب السعر';

  @override
  String get quoteHours => 'عدد الساعات';

  @override
  String get quoteRooms => 'عدد الغرف';

  @override
  String get quoteExpectedDuration => 'المدة المتوقعة للعمل';

  @override
  String quoteMinimumHours(String duration) {
    return 'أقل مدة يمكن حجزها مع هذه العاملة $duration. تُحسب $duration على الأقل حتى لو انتهى العمل أبكر.';
  }

  @override
  String get quotePriceLabel => 'السعر';

  @override
  String quoteForHours(String duration) {
    return 'مقابل $duration';
  }

  @override
  String quoteForRooms(String rooms) {
    return 'مقابل $rooms';
  }

  @override
  String get quoteFrozenNote => 'هذا السعر من بيتنا، ويُثبَّت عند تأكيد الحجز.';

  @override
  String get quoteContinue => 'اختر الموعد';

  @override
  String get bookingTitle => 'حجز موعد';

  @override
  String get bookingStepTime => 'الموعد';

  @override
  String get bookingStepAddress => 'العنوان';

  @override
  String get bookingStepReview => 'المراجعة';

  @override
  String get bookingNext => 'التالي';

  @override
  String get bookingOtherDay => 'يوم آخر';

  @override
  String get dayToday => 'اليوم';

  @override
  String get dayTomorrow => 'غداً';

  @override
  String bookingTimesNote(String city) {
    return 'الأوقات بتوقيت $city، وكلها أوقات تكون فيها متاحة فعلاً.';
  }

  @override
  String get bookingNoTimes =>
      'لا توجد أوقات متاحة لها في هذا اليوم. جرّب يوماً آخر.';

  @override
  String bookingTakesAbout(String duration) {
    return 'تستغرق نحو $duration';
  }

  @override
  String get addressMapTitle => 'أين البيت؟';

  @override
  String get addressMapHint =>
      'حرّك الخريطة حتى يقع الدبوس على البيت، أو المس المكان مباشرة.';

  @override
  String get addressLocateMe => 'موقعي الحالي';

  @override
  String get addressPinFromGps => 'بدأنا من موقعك الحالي. عدّل الدبوس إن لزم.';

  @override
  String addressPinFromCity(String city) {
    return 'بدأنا من وسط $city. حرّك الخريطة إلى البيت.';
  }

  @override
  String addressPinGpsTooFar(String city) {
    return 'موقعك الحالي خارج $city، فبدأنا من وسط المدينة.';
  }

  @override
  String get addressLandmark => 'أقرب معلم معروف';

  @override
  String get addressLandmarkHint =>
      'مثلاً: مقابل صيدلية الشفاء، البناء ذو الباب الأخضر';

  @override
  String get addressLandmarkHelper =>
      'هكذا ستصل العاملة إلى بابك، فاكتبه كما تصفه لضيف.';

  @override
  String get addressLandmarkRequired => 'اكتب معلماً قريباً لتصل إليك العاملة.';

  @override
  String get addressText => 'الحي والشارع';

  @override
  String get addressTextHint => 'مثلاً: المزة، شارع الجلاء';

  @override
  String get addressTextRequired => 'اكتب الحي والشارع.';

  @override
  String get addressFloor => 'الطابق (اختياري)';

  @override
  String get addressNotes => 'ملاحظات للعاملة (اختياري)';

  @override
  String get addressNotesHint => 'مثلاً: اطرقي الجرس مرتين';

  @override
  String get reviewService => 'الخدمة';

  @override
  String get reviewWhen => 'الموعد';

  @override
  String reviewFloor(String floor) {
    return 'الطابق $floor';
  }

  @override
  String get reviewWhatNext =>
      'بعد التأكيد يُرسل طلبك إلى العاملة لتقبله. يظهر رقم هاتفها في حجزك عندما تقبل.';

  @override
  String get reviewConfirm => 'تأكيد الحجز';

  @override
  String get bookingSent => 'تم إرسال طلب الحجز';

  @override
  String bookingNumber(String number) {
    return 'رقم الحجز: $number';
  }

  @override
  String get bookingSentNext => 'سنُعلمك عندما تقبل العاملة طلبك.';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get bookingErrorSlotTaken =>
      'حُجز هذا الوقت للتو. اختر وقتاً آخر من القائمة المحدّثة.';

  @override
  String bookingErrorBeyondHorizon(int days) {
    return 'لا يمكن الحجز لأكثر من $days يوماً مقدماً.';
  }

  @override
  String get bookingErrorOutsideHours =>
      'هذا الوقت خارج ساعات عملها. اختر وقتاً من القائمة.';

  @override
  String get bookingErrorInPast => 'هذا الوقت مضى. اختر وقتاً لاحقاً.';

  @override
  String get bookingErrorCityNotServed => 'هذه العاملة لا تعمل في هذه المدينة.';

  @override
  String get bookingErrorWorkerUnavailable =>
      'لم تعد هذه العاملة متاحة للحجز. اختر عاملة أخرى.';

  @override
  String get myBookings => 'حجوزاتي';

  @override
  String get bookingView => 'عرض الحجز';

  @override
  String get bookingsTitle => 'حجوزاتي';

  @override
  String get bookingsFilterAll => 'الكل';

  @override
  String get bookingsEmpty => 'لا توجد حجوزات هنا بعد.';

  @override
  String get bookingDetailTitle => 'تفاصيل الحجز';

  @override
  String get bookingFrozenPrice => 'السعر المثبّت';

  @override
  String get statusSearching => 'جارٍ البحث';

  @override
  String get statusPendingWorker => 'بانتظار رد العاملة';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusOnTheWay => 'العاملة في الطريق';

  @override
  String get statusArrived => 'وصلت العاملة';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusRejected => 'اعتذرت العاملة';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get statusExpired => 'انتهت مهلة الرد';

  @override
  String get statusNoWorkerFound => 'لم نجد عاملة';

  @override
  String get statusNoShow => 'لم يتم الحضور';

  @override
  String get statusUnknown => 'حالة غير معروفة';

  @override
  String get explainPending => 'أُرسل طلبك إلى العاملة وننتظر ردها.';

  @override
  String explainPendingUntil(String deadline) {
    return 'أُرسل طلبك إلى العاملة. إن لم ترد قبل $deadline يُلغى الطلب تلقائياً.';
  }

  @override
  String get explainAccepted => 'قبلت العاملة الحجز. رقم هاتفها ظاهر أدناه.';

  @override
  String get explainUnderway => 'الزيارة جارية.';

  @override
  String get explainCompleted => 'اكتملت الزيارة.';

  @override
  String get explainRejected =>
      'اعتذرت العاملة عن هذا الحجز. يمكنك حجز عاملة أخرى.';

  @override
  String get explainExpired =>
      'لم ترد العاملة في الوقت المحدد، فلم يُثبَّت الحجز.';

  @override
  String get explainCancelled => 'أُلغي هذا الحجز.';

  @override
  String get workerPhoneHidden => 'يظهر رقم هاتفها هنا عندما تقبل الحجز.';

  @override
  String get workerPhoneNotShared => 'لم تتم مشاركة رقمها لهذا الحجز.';

  @override
  String get copyPhone => 'نسخ الرقم';

  @override
  String get cancelBooking => 'إلغاء الحجز';

  @override
  String get cancelTitle => 'إلغاء الحجز؟';

  @override
  String cancelFeeFree(String until) {
    return 'الإلغاء مجاني الآن، وحتى $until.';
  }

  @override
  String cancelFeeLate(String fee, int hours, String percent) {
    return 'ستُحتسب رسوم إلغاء قدرها $fee، لأن الموعد بعد أقل من $hours ساعة. (الرسوم $percent% من سعر الحجز)';
  }

  @override
  String get cancelReasonLabel => 'سبب الإلغاء';

  @override
  String get cancelReasonPlans => 'تغيّرت خططي';

  @override
  String get cancelReasonTime => 'الموعد لم يعد مناسباً';

  @override
  String get cancelReasonElse => 'وجدت حلاً آخر';

  @override
  String get cancelReasonOther => 'سبب آخر';

  @override
  String get cancelReasonOtherHint => 'اكتب السبب';

  @override
  String get cancelConfirmFree => 'تأكيد الإلغاء';

  @override
  String cancelConfirmWithFee(String fee) {
    return 'إلغاء ودفع $fee';
  }

  @override
  String get cancelKeep => 'الإبقاء على الحجز';

  @override
  String get cancelledFree => 'أُلغي دون رسوم.';

  @override
  String cancelledWithFee(String fee) {
    return 'أُلغي برسوم قدرها $fee.';
  }
}
