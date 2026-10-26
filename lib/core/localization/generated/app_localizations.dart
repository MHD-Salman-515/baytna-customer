import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name shown on splash and window title.
  ///
  /// In ar, this message translates to:
  /// **'بيتنا'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'خدمات منزلية موثوقة بين يديك'**
  String get appTagline;

  /// Label of the button that switches to the OTHER language, written in that language.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get switchLanguage;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// Shown when a request is slow because the staging server is cold-starting.
  ///
  /// In ar, this message translates to:
  /// **'الخادم يستيقظ، قد يستغرق ذلك دقيقة…'**
  String get serverWakingUp;

  /// No description provided for @countrySelectTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر بلدك'**
  String get countrySelectTitle;

  /// No description provided for @countrySelectSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'نعرض الخدمات والأسعار حسب بلدك'**
  String get countrySelectSubtitle;

  /// No description provided for @countriesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد دول متاحة حالياً'**
  String get countriesEmpty;

  /// No description provided for @phoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك المحمول وسنرسل لك رمز تحقق'**
  String get phoneSubtitle;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف المحمول'**
  String get phoneFieldLabel;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيحاً'**
  String get phoneInvalid;

  /// No description provided for @phoneRejected.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرقم غير صالح للبلد المختار'**
  String get phoneRejected;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من 6 أرقام المرسل إلى {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @otpVerify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get otpVerify;

  /// No description provided for @otpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إعادة الإرسال بعد {seconds, plural, =1{ثانية واحدة} =2{ثانيتين} few{{seconds} ثوانٍ} other{{seconds} ثانية}}'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResend;

  /// No description provided for @otpResent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد'**
  String get otpResent;

  /// No description provided for @otpInvalid.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح أو منتهي الصلاحية'**
  String get otpInvalid;

  /// No description provided for @otpTooManyAttempts.
  ///
  /// In ar, this message translates to:
  /// **'محاولات خاطئة كثيرة. اطلب رمزاً جديداً للمتابعة.'**
  String get otpTooManyAttempts;

  /// No description provided for @changeNumber.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get changeNumber;

  /// No description provided for @homeTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get homeTitle;

  /// No description provided for @homeWelcome.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في بيتنا'**
  String get homeWelcome;

  /// No description provided for @homeSignedInAs.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بالرقم'**
  String get homeSignedInAs;

  /// No description provided for @homeChooseService.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخدمة التي تحتاجها'**
  String get homeChooseService;

  /// No description provided for @homeServicesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد خدمات متاحة حالياً.'**
  String get homeServicesEmpty;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @sessionExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك. يرجى تسجيل الدخول مجدداً.'**
  String get sessionExpired;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال. تحقق من اتصالك بالإنترنت.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In ar, this message translates to:
  /// **'استغرق الخادم وقتاً طويلاً للرد. حاول مجدداً.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ في الخادم. حاول لاحقاً.'**
  String get errorServer;

  /// No description provided for @errorRateLimited.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة. انتظر قليلاً ثم حاول مجدداً.'**
  String get errorRateLimited;

  /// No description provided for @errorValidation.
  ///
  /// In ar, this message translates to:
  /// **'البيانات المدخلة غير صحيحة.'**
  String get errorValidation;

  /// No description provided for @errorUnauthorized.
  ///
  /// In ar, this message translates to:
  /// **'ليست لديك صلاحية للقيام بذلك.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'العنصر المطلوب غير موجود.'**
  String get errorNotFound;

  /// No description provided for @errorUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع.'**
  String get errorUnknown;

  /// No description provided for @devFillOtp.
  ///
  /// In ar, this message translates to:
  /// **'تعبئة الرمز تلقائياً (وضع التطوير)'**
  String get devFillOtp;

  /// No description provided for @devOtpUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر جلب الرمز: {reason}'**
  String devOtpUnavailable(String reason);

  /// No description provided for @browseTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر عاملة'**
  String get browseTitle;

  /// No description provided for @browseCity.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get browseCity;

  /// No description provided for @browseSortRating.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييماً'**
  String get browseSortRating;

  /// No description provided for @browseSortPriceAsc.
  ///
  /// In ar, this message translates to:
  /// **'الأقل سعراً'**
  String get browseSortPriceAsc;

  /// No description provided for @browseSortPriceDesc.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى سعراً'**
  String get browseSortPriceDesc;

  /// No description provided for @browseEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عاملات متاحات لهذه الخدمة في {city} الآن.'**
  String browseEmpty(String city);

  /// No description provided for @browseEmptyHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب مدينة أخرى، أو عد لاحقاً.'**
  String get browseEmptyHint;

  /// No description provided for @browseNoCities.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مدن متاحة في بلدك بعد.'**
  String get browseNoCities;

  /// No description provided for @workerUnnamed.
  ///
  /// In ar, this message translates to:
  /// **'عاملة منزلية'**
  String get workerUnnamed;

  /// No description provided for @workerNew.
  ///
  /// In ar, this message translates to:
  /// **'جديدة على بيتنا'**
  String get workerNew;

  /// No description provided for @priceHourly.
  ///
  /// In ar, this message translates to:
  /// **'{price} / ساعة'**
  String priceHourly(String price);

  /// No description provided for @priceFixed.
  ///
  /// In ar, this message translates to:
  /// **'{price} · سعر ثابت'**
  String priceFixed(String price);

  /// No description provided for @priceBySize.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ من {price}'**
  String priceBySize(String price);

  /// No description provided for @workerProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get workerProfileTitle;

  /// No description provided for @workerServesCities.
  ///
  /// In ar, this message translates to:
  /// **'تعمل في: {cities}'**
  String workerServesCities(String cities);

  /// No description provided for @workerAbout.
  ///
  /// In ar, this message translates to:
  /// **'نبذة عنها'**
  String get workerAbout;

  /// No description provided for @workerServices.
  ///
  /// In ar, this message translates to:
  /// **'خدماتها وأسعارها'**
  String get workerServices;

  /// No description provided for @offeringNotBookable.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حجز هذه الخدمة من التطبيق بعد.'**
  String get offeringNotBookable;

  /// No description provided for @pricingExplainHourly.
  ///
  /// In ar, this message translates to:
  /// **'تُحسب بالساعة: {rate} لكل ساعة.'**
  String pricingExplainHourly(String rate);

  /// No description provided for @pricingExplainBySize.
  ///
  /// In ar, this message translates to:
  /// **'يُحسب السعر حسب عدد الغرف، ويبدأ من {price}.'**
  String pricingExplainBySize(String price);

  /// No description provided for @pricingExplainFixed.
  ///
  /// In ar, this message translates to:
  /// **'سعر ثابت للخدمة كاملة: {price}.'**
  String pricingExplainFixed(String price);

  /// No description provided for @pricingExplainUnknown.
  ///
  /// In ar, this message translates to:
  /// **'ستعرف السعر قبل تأكيد الحجز.'**
  String get pricingExplainUnknown;

  /// No description provided for @hoursCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{ساعة واحدة} =2{ساعتان} few{{count} ساعات} many{{count} ساعة} other{{count} ساعة}}'**
  String hoursCount(int count);

  /// No description provided for @hoursDecimal.
  ///
  /// In ar, this message translates to:
  /// **'{hours} ساعة'**
  String hoursDecimal(String hours);

  /// No description provided for @roomsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{غرفة واحدة} =2{غرفتان} few{{count} غرف} many{{count} غرفة} other{{count} غرفة}}'**
  String roomsCount(int count);

  /// No description provided for @quoteSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'احسب السعر'**
  String get quoteSectionTitle;

  /// No description provided for @quoteHours.
  ///
  /// In ar, this message translates to:
  /// **'عدد الساعات'**
  String get quoteHours;

  /// No description provided for @quoteRooms.
  ///
  /// In ar, this message translates to:
  /// **'عدد الغرف'**
  String get quoteRooms;

  /// No description provided for @quoteExpectedDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة المتوقعة للعمل'**
  String get quoteExpectedDuration;

  /// No description provided for @quoteMinimumHours.
  ///
  /// In ar, this message translates to:
  /// **'أقل مدة يمكن حجزها مع هذه العاملة {duration}. تُحسب {duration} على الأقل حتى لو انتهى العمل أبكر.'**
  String quoteMinimumHours(String duration);

  /// No description provided for @quotePriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get quotePriceLabel;

  /// No description provided for @quoteForHours.
  ///
  /// In ar, this message translates to:
  /// **'مقابل {duration}'**
  String quoteForHours(String duration);

  /// No description provided for @quoteForRooms.
  ///
  /// In ar, this message translates to:
  /// **'مقابل {rooms}'**
  String quoteForRooms(String rooms);

  /// No description provided for @quoteFrozenNote.
  ///
  /// In ar, this message translates to:
  /// **'هذا السعر من بيتنا، ويُثبَّت عند تأكيد الحجز.'**
  String get quoteFrozenNote;

  /// No description provided for @quoteContinue.
  ///
  /// In ar, this message translates to:
  /// **'اختر الموعد'**
  String get quoteContinue;

  /// No description provided for @bookingTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجز موعد'**
  String get bookingTitle;

  /// No description provided for @bookingStepTime.
  ///
  /// In ar, this message translates to:
  /// **'الموعد'**
  String get bookingStepTime;

  /// No description provided for @bookingStepAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get bookingStepAddress;

  /// No description provided for @bookingStepReview.
  ///
  /// In ar, this message translates to:
  /// **'المراجعة'**
  String get bookingStepReview;

  /// No description provided for @bookingNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get bookingNext;

  /// No description provided for @bookingOtherDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم آخر'**
  String get bookingOtherDay;

  /// No description provided for @dayToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In ar, this message translates to:
  /// **'غداً'**
  String get dayTomorrow;

  /// No description provided for @bookingTimesNote.
  ///
  /// In ar, this message translates to:
  /// **'الأوقات بتوقيت {city}، وكلها أوقات تكون فيها متاحة فعلاً.'**
  String bookingTimesNote(String city);

  /// No description provided for @bookingNoTimes.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أوقات متاحة لها في هذا اليوم. جرّب يوماً آخر.'**
  String get bookingNoTimes;

  /// No description provided for @bookingTakesAbout.
  ///
  /// In ar, this message translates to:
  /// **'تستغرق نحو {duration}'**
  String bookingTakesAbout(String duration);

  /// No description provided for @addressMapTitle.
  ///
  /// In ar, this message translates to:
  /// **'أين البيت؟'**
  String get addressMapTitle;

  /// No description provided for @addressMapHint.
  ///
  /// In ar, this message translates to:
  /// **'حرّك الخريطة حتى يقع الدبوس على البيت، أو المس المكان مباشرة.'**
  String get addressMapHint;

  /// No description provided for @addressLocateMe.
  ///
  /// In ar, this message translates to:
  /// **'موقعي الحالي'**
  String get addressLocateMe;

  /// No description provided for @addressPinFromGps.
  ///
  /// In ar, this message translates to:
  /// **'بدأنا من موقعك الحالي. عدّل الدبوس إن لزم.'**
  String get addressPinFromGps;

  /// No description provided for @addressPinFromCity.
  ///
  /// In ar, this message translates to:
  /// **'بدأنا من وسط {city}. حرّك الخريطة إلى البيت.'**
  String addressPinFromCity(String city);

  /// No description provided for @addressPinGpsTooFar.
  ///
  /// In ar, this message translates to:
  /// **'موقعك الحالي خارج {city}، فبدأنا من وسط المدينة.'**
  String addressPinGpsTooFar(String city);

  /// No description provided for @addressLandmark.
  ///
  /// In ar, this message translates to:
  /// **'أقرب معلم معروف'**
  String get addressLandmark;

  /// No description provided for @addressLandmarkHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: مقابل صيدلية الشفاء، البناء ذو الباب الأخضر'**
  String get addressLandmarkHint;

  /// No description provided for @addressLandmarkHelper.
  ///
  /// In ar, this message translates to:
  /// **'هكذا ستصل العاملة إلى بابك، فاكتبه كما تصفه لضيف.'**
  String get addressLandmarkHelper;

  /// No description provided for @addressLandmarkRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب معلماً قريباً لتصل إليك العاملة.'**
  String get addressLandmarkRequired;

  /// No description provided for @addressText.
  ///
  /// In ar, this message translates to:
  /// **'الحي والشارع'**
  String get addressText;

  /// No description provided for @addressTextHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: المزة، شارع الجلاء'**
  String get addressTextHint;

  /// No description provided for @addressTextRequired.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الحي والشارع.'**
  String get addressTextRequired;

  /// No description provided for @addressFloor.
  ///
  /// In ar, this message translates to:
  /// **'الطابق (اختياري)'**
  String get addressFloor;

  /// No description provided for @addressNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات للعاملة (اختياري)'**
  String get addressNotes;

  /// No description provided for @addressNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'مثلاً: اطرقي الجرس مرتين'**
  String get addressNotesHint;

  /// No description provided for @reviewService.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة'**
  String get reviewService;

  /// No description provided for @reviewWhen.
  ///
  /// In ar, this message translates to:
  /// **'الموعد'**
  String get reviewWhen;

  /// No description provided for @reviewFloor.
  ///
  /// In ar, this message translates to:
  /// **'الطابق {floor}'**
  String reviewFloor(String floor);

  /// No description provided for @reviewWhatNext.
  ///
  /// In ar, this message translates to:
  /// **'بعد التأكيد يُرسل طلبك إلى العاملة لتقبله. يظهر رقم هاتفها في حجزك عندما تقبل.'**
  String get reviewWhatNext;

  /// No description provided for @reviewConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحجز'**
  String get reviewConfirm;

  /// No description provided for @bookingSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب الحجز'**
  String get bookingSent;

  /// No description provided for @bookingNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحجز: {number}'**
  String bookingNumber(String number);

  /// No description provided for @bookingSentNext.
  ///
  /// In ar, this message translates to:
  /// **'سنُعلمك عندما تقبل العاملة طلبك.'**
  String get bookingSentNext;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get backToHome;

  /// No description provided for @bookingErrorSlotTaken.
  ///
  /// In ar, this message translates to:
  /// **'حُجز هذا الوقت للتو. اختر وقتاً آخر من القائمة المحدّثة.'**
  String get bookingErrorSlotTaken;

  /// No description provided for @bookingErrorBeyondHorizon.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الحجز لأكثر من {days} يوماً مقدماً.'**
  String bookingErrorBeyondHorizon(int days);

  /// No description provided for @bookingErrorOutsideHours.
  ///
  /// In ar, this message translates to:
  /// **'هذا الوقت خارج ساعات عملها. اختر وقتاً من القائمة.'**
  String get bookingErrorOutsideHours;

  /// No description provided for @bookingErrorInPast.
  ///
  /// In ar, this message translates to:
  /// **'هذا الوقت مضى. اختر وقتاً لاحقاً.'**
  String get bookingErrorInPast;

  /// No description provided for @bookingErrorCityNotServed.
  ///
  /// In ar, this message translates to:
  /// **'هذه العاملة لا تعمل في هذه المدينة.'**
  String get bookingErrorCityNotServed;

  /// No description provided for @bookingErrorWorkerUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'لم تعد هذه العاملة متاحة للحجز. اختر عاملة أخرى.'**
  String get bookingErrorWorkerUnavailable;

  /// No description provided for @myBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get myBookings;

  /// No description provided for @bookingView.
  ///
  /// In ar, this message translates to:
  /// **'عرض الحجز'**
  String get bookingView;

  /// No description provided for @bookingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get bookingsTitle;

  /// No description provided for @bookingsFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get bookingsFilterAll;

  /// No description provided for @bookingsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حجوزات هنا بعد.'**
  String get bookingsEmpty;

  /// No description provided for @bookingDetailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحجز'**
  String get bookingDetailTitle;

  /// No description provided for @bookingFrozenPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر المثبّت'**
  String get bookingFrozenPrice;

  /// No description provided for @statusSearching.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث'**
  String get statusSearching;

  /// No description provided for @statusPendingWorker.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار رد العاملة'**
  String get statusPendingWorker;

  /// No description provided for @statusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get statusAccepted;

  /// No description provided for @statusOnTheWay.
  ///
  /// In ar, this message translates to:
  /// **'العاملة في الطريق'**
  String get statusOnTheWay;

  /// No description provided for @statusArrived.
  ///
  /// In ar, this message translates to:
  /// **'وصلت العاملة'**
  String get statusArrived;

  /// No description provided for @statusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get statusCompleted;

  /// No description provided for @statusRejected.
  ///
  /// In ar, this message translates to:
  /// **'اعتذرت العاملة'**
  String get statusRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغى'**
  String get statusCancelled;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الرد'**
  String get statusExpired;

  /// No description provided for @statusNoWorkerFound.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد عاملة'**
  String get statusNoWorkerFound;

  /// No description provided for @statusNoShow.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم الحضور'**
  String get statusNoShow;

  /// No description provided for @statusUnknown.
  ///
  /// In ar, this message translates to:
  /// **'حالة غير معروفة'**
  String get statusUnknown;

  /// No description provided for @explainPending.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل طلبك إلى العاملة وننتظر ردها.'**
  String get explainPending;

  /// No description provided for @explainPendingUntil.
  ///
  /// In ar, this message translates to:
  /// **'أُرسل طلبك إلى العاملة. إن لم ترد قبل {deadline} يُلغى الطلب تلقائياً.'**
  String explainPendingUntil(String deadline);

  /// No description provided for @explainAccepted.
  ///
  /// In ar, this message translates to:
  /// **'قبلت العاملة الحجز. رقم هاتفها ظاهر أدناه.'**
  String get explainAccepted;

  /// No description provided for @explainUnderway.
  ///
  /// In ar, this message translates to:
  /// **'الزيارة جارية.'**
  String get explainUnderway;

  /// No description provided for @explainCompleted.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت الزيارة.'**
  String get explainCompleted;

  /// No description provided for @explainRejected.
  ///
  /// In ar, this message translates to:
  /// **'اعتذرت العاملة عن هذا الحجز. يمكنك حجز عاملة أخرى.'**
  String get explainRejected;

  /// No description provided for @explainExpired.
  ///
  /// In ar, this message translates to:
  /// **'لم ترد العاملة في الوقت المحدد، فلم يُثبَّت الحجز.'**
  String get explainExpired;

  /// No description provided for @explainCancelled.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي هذا الحجز.'**
  String get explainCancelled;

  /// No description provided for @workerPhoneHidden.
  ///
  /// In ar, this message translates to:
  /// **'يظهر رقم هاتفها هنا عندما تقبل الحجز.'**
  String get workerPhoneHidden;

  /// No description provided for @workerPhoneNotShared.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم مشاركة رقمها لهذا الحجز.'**
  String get workerPhoneNotShared;

  /// No description provided for @copyPhone.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الرقم'**
  String get copyPhone;

  /// No description provided for @cancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز'**
  String get cancelBooking;

  /// No description provided for @cancelTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الحجز؟'**
  String get cancelTitle;

  /// No description provided for @cancelFeeFree.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء مجاني الآن، وحتى {until}.'**
  String cancelFeeFree(String until);

  /// No description provided for @cancelFeeLate.
  ///
  /// In ar, this message translates to:
  /// **'ستُحتسب رسوم إلغاء قدرها {fee}، لأن الموعد بعد أقل من {hours} ساعة. (الرسوم {percent}% من سعر الحجز)'**
  String cancelFeeLate(String fee, int hours, String percent);

  /// No description provided for @cancelReasonLabel.
  ///
  /// In ar, this message translates to:
  /// **'سبب الإلغاء'**
  String get cancelReasonLabel;

  /// No description provided for @cancelReasonPlans.
  ///
  /// In ar, this message translates to:
  /// **'تغيّرت خططي'**
  String get cancelReasonPlans;

  /// No description provided for @cancelReasonTime.
  ///
  /// In ar, this message translates to:
  /// **'الموعد لم يعد مناسباً'**
  String get cancelReasonTime;

  /// No description provided for @cancelReasonElse.
  ///
  /// In ar, this message translates to:
  /// **'وجدت حلاً آخر'**
  String get cancelReasonElse;

  /// No description provided for @cancelReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get cancelReasonOther;

  /// No description provided for @cancelReasonOtherHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب السبب'**
  String get cancelReasonOtherHint;

  /// No description provided for @cancelConfirmFree.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الإلغاء'**
  String get cancelConfirmFree;

  /// No description provided for @cancelConfirmWithFee.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء ودفع {fee}'**
  String cancelConfirmWithFee(String fee);

  /// No description provided for @cancelKeep.
  ///
  /// In ar, this message translates to:
  /// **'الإبقاء على الحجز'**
  String get cancelKeep;

  /// No description provided for @cancelledFree.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي دون رسوم.'**
  String get cancelledFree;

  /// No description provided for @cancelledWithFee.
  ///
  /// In ar, this message translates to:
  /// **'أُلغي برسوم قدرها {fee}.'**
  String cancelledWithFee(String fee);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
