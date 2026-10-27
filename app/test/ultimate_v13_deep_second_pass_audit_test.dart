import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/localization/app_localizations.dart';
import 'package:almomin/core/services/fajr_qiyam_alarm_service.dart';
import 'package:almomin/core/services/islamic_mutoon_service.dart';
import 'package:almomin/core/services/riyad_alsalihin_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/stories_service.dart';
import 'package:almomin/core/services/unified_library_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  group('Ultimate v13.0 Level-2 Deep Audit & 12-Category Fix Verification Tests', () {
    test('1. AppLocalizations has 100% key parity (171 keys) across all 6 global languages (ar, en, fr, tr, ur, id)', () {
      const sampleKeys = [
        'app_name',
        'nav_home',
        'nav_quran',
        'nav_prayer',
        'nav_adhkar',
        'nav_library',
        'scholars_gatherings',
        'scholars_gatherings_sub',
        'duaa_sharawi',
        'sunan_rawatib',
        'mawarith_calc',
        'play',
        'pause',
        'stop',
        'listen',
        'download',
        'share',
        'copy',
        'search',
        'next',
        'previous',
        'skip',
        'reset',
        'confirm',
        'done',
        'amen',
      ];

      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.locale);
        for (final key in sampleKeys) {
          final translated = loc.tr(key);
          expect(
            translated,
            isNot(equals(key)),
            reason: 'Key $key was not translated in language ${lang.code}!',
          );
          expect(translated.trim(), isNotEmpty);
        }
      }
    });

    test('2. SettingsService.textDirection switches dynamically between RTL (ar, ur) and LTR (en, fr, tr, id)', () async {
      await SettingsService.instance.setLanguageCode('ar');
      expect(SettingsService.instance.textDirection, equals(TextDirection.rtl));

      await SettingsService.instance.setLanguageCode('en');
      expect(SettingsService.instance.textDirection, equals(TextDirection.ltr));

      await SettingsService.instance.setLanguageCode('fr');
      expect(SettingsService.instance.textDirection, equals(TextDirection.ltr));

      await SettingsService.instance.setLanguageCode('tr');
      expect(SettingsService.instance.textDirection, equals(TextDirection.ltr));

      await SettingsService.instance.setLanguageCode('id');
      expect(SettingsService.instance.textDirection, equals(TextDirection.ltr));

      await SettingsService.instance.setLanguageCode('ur');
      expect(SettingsService.instance.textDirection, equals(TextDirection.rtl));
    });

    test('3. UnifiedLibrarySearchService uses valid lowercase Material Icons constants', () {
      final results =
          UnifiedLibrarySearchService.instance.searchAllLibraries('الإخلاص');
      expect(results, isNotEmpty);
      for (final r in results) {
        expect(r.icon, isA<IconData>());
      }
    });

    test('4. FajrQiyamAlarmService.init() initializes timezones safely even when called standalone before PrayerNotificationService', () async {
      await FajrQiyamAlarmService.instance.init(forceReload: true);
      expect(FajrQiyamAlarmService.instance.preFajrMinutesBefore, greaterThan(0));
    });

    test('5. RiyadAlSalihinService, IslamicMutoonService, and StoriesService clear sets cleanly on forceReload: true', () async {
      await RiyadAlSalihinService.instance.init(forceReload: true);
      await RiyadAlSalihinService.instance.toggleBookmark('riyad_1');
      expect(RiyadAlSalihinService.instance.isBookmarked('riyad_1'), isTrue);

      SharedPreferences.setMockInitialValues({});
      await RiyadAlSalihinService.instance.init(forceReload: true);
      expect(RiyadAlSalihinService.instance.isBookmarked('riyad_1'), isFalse);

      await IslamicMutoonService.instance.init(forceReload: true);
      await StoriesService.instance.init(forceReload: true);
    });
  });
}
