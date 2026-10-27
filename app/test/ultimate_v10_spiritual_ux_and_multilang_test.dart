import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/localization/app_localizations.dart';
import 'package:almomin/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v10.0 — Spiritual UX & Natural Naming Across All 6 Languages Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.init();
    });

    test('All 5 main sanctuaries and spiritual sections have natural, non-technical names in all 6 languages', () {
      const requiredKeys = [
        'nav_home',
        'nav_quran',
        'nav_prayer',
        'nav_adhkar',
        'nav_library',
        'nav_settings',
        'home_station_mihrab',
        'home_station_quran',
        'home_station_adhkar',
        'home_station_pathways',
        'holy_quran',
        'quran_tab_mushaf',
        'quran_tab_recitations',
        'quran_tab_tafsir',
        'quran_tab_themes',
        'quran_tab_companionship',
        'prayer_tab_times',
        'prayer_tab_muezzins',
        'prayer_tab_qibla',
        'prayer_tab_covenant',
        'adhkar_hub',
        'adhkar_tab_daily',
        'adhkar_tab_tasbih',
        'adhkar_tab_healing',
        'adhkar_tab_fortress',
        'islamic_library',
        'lib_tab_gardens',
        'lib_tab_hadith',
        'lib_tab_stories',
        'lib_tab_seasons',
        'lib_tab_zakat',
        'garden_scholars',
        'garden_prophethood',
        'garden_quran_sciences',
        'garden_fiqh_wealth',
        'garden_heart_seasons',
        'scholars_gatherings',
        'hajj_umrah_companion',
        'voluntary_fasting',
        'spiritual_mood_remedy',
        'gharib_quran_dict',
        'kaffarah_fidyah_calc',
        'settings_title',
      ];

      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.locale);
        for (final key in requiredKeys) {
          final value = loc.tr(key);
          expect(value, isNotEmpty,
              reason: 'Missing translation for $key in ${lang.code}');
          expect(value, isNot(equals(key)),
              reason: 'Untranslated raw key $key in ${lang.code}');
          // Verify no technical jargon like "فورم" or "FTS5" or "ميزة جديدة"
          expect(value.contains('فورم'), isFalse);
          expect(value.contains('FTS5'), isFalse);
          expect(value.contains('ميزة جديدة'), isFalse);
        }
      }
    });

    test('Arabic spiritual names match the new serene taxonomy', () {
      final ar = AppLocalizations(const Locale('ar'));
      expect(ar.tr('nav_home'), 'إشراقة اليوم');
      expect(ar.tr('nav_quran'), 'رحاب القرآن');
      expect(ar.tr('nav_prayer'), 'محراب الصلاة');
      expect(ar.tr('nav_adhkar'), 'أُنس الذاكرين');
      expect(ar.tr('nav_library'), 'رياض العلم');
      expect(ar.tr('prayer_tracker'), 'عهد الصلاة وميزان المحافظة');
      expect(ar.tr('spiritual_mood_remedy'), 'طِبّ القلوب وسكينة الروح');
    });
  });
}
