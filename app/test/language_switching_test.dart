import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/localization/app_localizations.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/settings/widgets/settings_language_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLanguage Enum Tests', () {
    test('AppLanguage enum properties and codes', () {
      expect(AppLanguage.arabic.code, equals('ar'));
      expect(AppLanguage.arabic.nativeName, equals('العربية'));
      expect(AppLanguage.arabic.englishName, equals('Arabic'));

      expect(AppLanguage.english.code, equals('en'));
      expect(AppLanguage.english.nativeName, equals('English'));
      expect(AppLanguage.english.englishName, equals('English'));

      expect(AppLanguage.fromCode('ar'), equals(AppLanguage.arabic));
      expect(AppLanguage.fromCode('en'), equals(AppLanguage.english));
      expect(AppLanguage.fromCode('xyz'), equals(AppLanguage.arabic)); // Default fallback
    });
  });

  group('AppLocalizations Unit Tests', () {
    test('AppLocalizations returns correct Arabic strings', () {
      final locAr = AppLocalizations(const Locale('ar'));

      expect(locAr.isArabic, isTrue);
      expect(locAr.isEnglish, isFalse);
      expect(locAr.textDirection, equals(TextDirection.rtl));
      expect(locAr.tr('app_name'), equals('نور المؤمن'));
      expect(locAr.tr('nav_home'), equals('إشراقة اليوم'));
      expect(locAr.tr('nav_quran'), equals('رحاب القرآن'));
      expect(locAr.tr('nav_prayer'), equals('محراب الصلاة'));
      expect(locAr.tr('nav_adhkar'), equals('أُنس الذاكرين'));
      expect(locAr.tr('nav_library'), equals('رياض العلم'));
      expect(locAr.tr('prayer_fajr'), equals('الفجر'));
      expect(locAr.tr('prayer_dhuhr'), equals('الظهر'));
      expect(locAr.tr('prayer_asr'), equals('العصر'));
      expect(locAr.tr('prayer_maghrib'), equals('المغرب'));
      expect(locAr.tr('prayer_isha'), equals('العشاء'));
      expect(locAr.tr('app_language'), equals('لغة واجهة التطبيق (٦ لغات عالمية)'));
      expect(locAr.getPrayerName('fajr'), equals('الفجر'));
      expect(locAr.getPrayerName('مغرب'), equals('مغرب')); // Unknown fallback
    });

    test('AppLocalizations returns correct English strings', () {
      final locEn = AppLocalizations(const Locale('en'));

      expect(locEn.isArabic, isFalse);
      expect(locEn.isEnglish, isTrue);
      expect(locEn.textDirection, equals(TextDirection.ltr));
      expect(locEn.tr('app_name'), equals('Noor Al-Momin'));
      expect(locEn.tr('nav_home'), equals('Serenity'));
      expect(locEn.tr('nav_quran'), equals('Noble Quran'));
      expect(locEn.tr('nav_prayer'), equals('Mihrab'));
      expect(locEn.tr('nav_adhkar'), equals('Remembrance'));
      expect(locEn.tr('nav_library'), equals('Wisdom'));
      expect(locEn.tr('prayer_fajr'), equals('Fajr'));
      expect(locEn.tr('prayer_dhuhr'), equals('Dhuhr'));
      expect(locEn.tr('prayer_asr'), equals('Asr'));
      expect(locEn.tr('prayer_maghrib'), equals('Maghrib'));
      expect(locEn.tr('prayer_isha'), equals('Isha'));
      expect(locEn.tr('app_language'), equals('App Interface Language (6 Global Languages)'));
      expect(locEn.getPrayerName('fajr'), equals('Fajr'));
    });

    test('AppLocalizations fallback on missing key in English falls back to Arabic or key', () {
      final locEn = AppLocalizations(const Locale('en'));
      // When key does not exist anywhere, returns key
      expect(locEn.tr('non_existent_key_xyz'), equals('non_existent_key_xyz'));
    });

    test('AppLocalizations.delegate supports ar and en', () {
      final delegate = AppLocalizations.delegate;
      expect(delegate.isSupported(const Locale('ar')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('es')), isFalse);
    });
  });

  group('SettingsService Language State Tests', () {
    test('Defaults to Arabic and switches to English persistently', () async {
      final settings = SettingsService.instance;
      await settings.init();

      // Ensure fresh state
      await settings.setLanguage('ar');
      expect(settings.languageCode, equals('ar'));
      expect(settings.isArabic, isTrue);
      expect(settings.isEnglish, isFalse);
      expect(settings.currentLocale.languageCode, equals('ar'));
      expect(settings.languageName, contains('العربية'));

      // Switch to English
      await settings.setLanguage('en');
      expect(settings.languageCode, equals('en'));
      expect(settings.isArabic, isFalse);
      expect(settings.isEnglish, isTrue);
      expect(settings.currentLocale.languageCode, equals('en'));
      expect(settings.languageName, contains('English'));

      // Revert back to Arabic
      await settings.setLanguage('ar');
      expect(settings.languageCode, equals('ar'));
      expect(settings.isArabic, isTrue);
    });
  });

  group('SettingsLanguageModal Widget Tests', () {
    Widget buildTestApp(Widget homeWidget, {Locale locale = const Locale('ar')}) {
      return MaterialApp(
        locale: locale,
        supportedLocales: const [
          Locale('ar'),
          Locale('en'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: homeWidget,
      );
    }

    testWidgets('Modal opens and displays Arabic and English options with current selection', (tester) async {
      final settings = SettingsService.instance;
      await settings.setLanguage('ar');

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showSettingsLanguageModal(context),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify header and both language options are rendered
      expect(find.text('لغة واجهة التطبيق (٦ لغات عالمية)'), findsOneWidget);
      expect(find.text('اختر لغة التطبيق واتجاه العرض'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('🇪🇬'), findsOneWidget);
      expect(find.text('🇬🇧'), findsOneWidget);
    });

    testWidgets('Tapping English in modal updates SettingsService and dismisses modal', (tester) async {
      final settings = SettingsService.instance;
      await settings.setLanguage('ar');

      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showSettingsLanguageModal(context),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap English option
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verify setting updated to 'en'
      expect(settings.languageCode, equals('en'));
      expect(settings.isEnglish, isTrue);

      // Revert back to 'ar' for cleanliness
      await settings.setLanguage('ar');
    });
  });
}
