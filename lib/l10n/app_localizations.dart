import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh_TW, this message translates to:
  /// **'Eco - 碳足跡追蹤'**
  String get appTitle;

  /// No description provided for @todayCarbonFootprint.
  ///
  /// In zh_TW, this message translates to:
  /// **'今日碳足跡'**
  String get todayCarbonFootprint;

  /// No description provided for @quickAdd.
  ///
  /// In zh_TW, this message translates to:
  /// **'快速添加'**
  String get quickAdd;

  /// No description provided for @transportation.
  ///
  /// In zh_TW, this message translates to:
  /// **'交通'**
  String get transportation;

  /// No description provided for @shopping.
  ///
  /// In zh_TW, this message translates to:
  /// **'購物'**
  String get shopping;

  /// No description provided for @electricity.
  ///
  /// In zh_TW, this message translates to:
  /// **'用電'**
  String get electricity;

  /// No description provided for @diet.
  ///
  /// In zh_TW, this message translates to:
  /// **'飲食'**
  String get diet;

  /// No description provided for @delivery.
  ///
  /// In zh_TW, this message translates to:
  /// **'外送'**
  String get delivery;

  /// No description provided for @express.
  ///
  /// In zh_TW, this message translates to:
  /// **'快遞'**
  String get express;

  /// No description provided for @accommodation.
  ///
  /// In zh_TW, this message translates to:
  /// **'住宿'**
  String get accommodation;

  /// No description provided for @other.
  ///
  /// In zh_TW, this message translates to:
  /// **'其他'**
  String get other;

  /// No description provided for @home.
  ///
  /// In zh_TW, this message translates to:
  /// **'首頁'**
  String get home;

  /// No description provided for @addRecord.
  ///
  /// In zh_TW, this message translates to:
  /// **'添加記錄'**
  String get addRecord;

  /// No description provided for @recordList.
  ///
  /// In zh_TW, this message translates to:
  /// **'記錄列表'**
  String get recordList;

  /// No description provided for @statistics.
  ///
  /// In zh_TW, this message translates to:
  /// **'統計'**
  String get statistics;

  /// No description provided for @profile.
  ///
  /// In zh_TW, this message translates to:
  /// **'我的'**
  String get profile;

  /// No description provided for @addCarbonRecord.
  ///
  /// In zh_TW, this message translates to:
  /// **'添加碳足跡記錄'**
  String get addCarbonRecord;

  /// No description provided for @type.
  ///
  /// In zh_TW, this message translates to:
  /// **'類型'**
  String get type;

  /// No description provided for @amount.
  ///
  /// In zh_TW, this message translates to:
  /// **'數量'**
  String get amount;

  /// No description provided for @distance.
  ///
  /// In zh_TW, this message translates to:
  /// **'距離 (公里)'**
  String get distance;

  /// No description provided for @amount_money.
  ///
  /// In zh_TW, this message translates to:
  /// **'金額 (元)'**
  String get amount_money;

  /// No description provided for @electricity_usage.
  ///
  /// In zh_TW, this message translates to:
  /// **'用電量 (kWh)'**
  String get electricity_usage;

  /// No description provided for @food_weight.
  ///
  /// In zh_TW, this message translates to:
  /// **'重量 (kg)'**
  String get food_weight;

  /// No description provided for @delivery_amount.
  ///
  /// In zh_TW, this message translates to:
  /// **'外送金額 (元)'**
  String get delivery_amount;

  /// No description provided for @express_amount.
  ///
  /// In zh_TW, this message translates to:
  /// **'快遞費用 (元)'**
  String get express_amount;

  /// No description provided for @accommodation_amount.
  ///
  /// In zh_TW, this message translates to:
  /// **'住宿費用 (元)'**
  String get accommodation_amount;

  /// No description provided for @estimatedCarbonFootprint.
  ///
  /// In zh_TW, this message translates to:
  /// **'預計碳足跡'**
  String get estimatedCarbonFootprint;

  /// No description provided for @cancel.
  ///
  /// In zh_TW, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In zh_TW, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @save.
  ///
  /// In zh_TW, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @noRecords.
  ///
  /// In zh_TW, this message translates to:
  /// **'暫無記錄'**
  String get noRecords;

  /// No description provided for @clickToAddFirstRecord.
  ///
  /// In zh_TW, this message translates to:
  /// **'點擊 + 按鈕添加第一條記錄'**
  String get clickToAddFirstRecord;

  /// No description provided for @statisticsInfo.
  ///
  /// In zh_TW, this message translates to:
  /// **'統計信息'**
  String get statisticsInfo;

  /// No description provided for @totalRecords.
  ///
  /// In zh_TW, this message translates to:
  /// **'總記錄'**
  String get totalRecords;

  /// No description provided for @totalCarbonFootprint.
  ///
  /// In zh_TW, this message translates to:
  /// **'總碳足跡'**
  String get totalCarbonFootprint;

  /// No description provided for @ecoAdvice.
  ///
  /// In zh_TW, this message translates to:
  /// **'環保建議'**
  String get ecoAdvice;

  /// No description provided for @reduceCarbonTips.
  ///
  /// In zh_TW, this message translates to:
  /// **'💡 減少碳足跡的小貼士：'**
  String get reduceCarbonTips;

  /// No description provided for @tip1.
  ///
  /// In zh_TW, this message translates to:
  /// **'• 選擇步行或騎自行車出行'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In zh_TW, this message translates to:
  /// **'• 使用公共交通工具'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In zh_TW, this message translates to:
  /// **'• 減少不必要的購物'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In zh_TW, this message translates to:
  /// **'• 節約用電，使用節能設備'**
  String get tip4;

  /// No description provided for @tip5.
  ///
  /// In zh_TW, this message translates to:
  /// **'• 選擇本地和季節性食物'**
  String get tip5;

  /// No description provided for @clickPlusToAdd.
  ///
  /// In zh_TW, this message translates to:
  /// **'點擊右下角的 + 按鈕添加記錄'**
  String get clickPlusToAdd;

  /// No description provided for @kgCO2.
  ///
  /// In zh_TW, this message translates to:
  /// **'kg CO₂'**
  String get kgCO2;

  /// No description provided for @autoDetection.
  ///
  /// In zh_TW, this message translates to:
  /// **'自動偵測'**
  String get autoDetection;

  /// No description provided for @autoDetectionEnabled.
  ///
  /// In zh_TW, this message translates to:
  /// **'自動偵測已啟用'**
  String get autoDetectionEnabled;

  /// No description provided for @autoDetectionDisabled.
  ///
  /// In zh_TW, this message translates to:
  /// **'自動偵測已停用'**
  String get autoDetectionDisabled;

  /// No description provided for @gpsTracking.
  ///
  /// In zh_TW, this message translates to:
  /// **'GPS追蹤'**
  String get gpsTracking;

  /// No description provided for @invoiceScanning.
  ///
  /// In zh_TW, this message translates to:
  /// **'發票掃描'**
  String get invoiceScanning;

  /// No description provided for @paymentMonitoring.
  ///
  /// In zh_TW, this message translates to:
  /// **'支付監控'**
  String get paymentMonitoring;

  /// No description provided for @sensorDetection.
  ///
  /// In zh_TW, this message translates to:
  /// **'感應器偵測'**
  String get sensorDetection;

  /// No description provided for @language.
  ///
  /// In zh_TW, this message translates to:
  /// **'語言'**
  String get language;

  /// No description provided for @traditionalChinese.
  ///
  /// In zh_TW, this message translates to:
  /// **'繁體中文'**
  String get traditionalChinese;

  /// No description provided for @simplifiedChinese.
  ///
  /// In zh_TW, this message translates to:
  /// **'簡體中文'**
  String get simplifiedChinese;

  /// No description provided for @english.
  ///
  /// In zh_TW, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settings.
  ///
  /// In zh_TW, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @autoDetected.
  ///
  /// In zh_TW, this message translates to:
  /// **'自動偵測'**
  String get autoDetected;

  /// No description provided for @manualEntry.
  ///
  /// In zh_TW, this message translates to:
  /// **'手動輸入'**
  String get manualEntry;

  /// No description provided for @overview.
  ///
  /// In zh_TW, this message translates to:
  /// **'總覽'**
  String get overview;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
