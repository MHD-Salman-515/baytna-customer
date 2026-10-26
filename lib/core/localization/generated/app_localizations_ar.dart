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
}
