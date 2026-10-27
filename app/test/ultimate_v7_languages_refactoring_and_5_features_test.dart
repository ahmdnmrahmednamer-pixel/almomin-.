import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/localization/app_localizations.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/hajj_umrah_service.dart';
import 'package:almomin/core/services/voluntary_fasting_service.dart';
import 'package:almomin/core/services/spiritual_mood_remedy_service.dart';
import 'package:almomin/core/services/gharib_quran_service.dart';
import 'package:almomin/core/services/kaffarah_fidyah_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v7.0 — 6-Language Switcher & Localization Engine Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.init();
    });

    test('Supports all 6 global Islamic languages with accurate RTL/LTR directionality', () async {
      expect(AppLanguage.values.length, 6);
      expect(AppLocalizations.supportedLocales.length, 6);

      // Arabic & Urdu must be RTL
      await SettingsService.instance.setLanguage('ar');
      expect(SettingsService.instance.isRtl, isTrue);
      expect(SettingsService.instance.textDirection, TextDirection.rtl);

      await SettingsService.instance.setLanguage('ur');
      expect(SettingsService.instance.isRtl, isTrue);
      expect(SettingsService.instance.textDirection, TextDirection.rtl);
      expect(SettingsService.instance.quranTranslationEdition, 'ur_jalandhry');

      // English, French, Turkish, Indonesian must be LTR
      for (final code in ['en', 'fr', 'tr', 'id']) {
        await SettingsService.instance.setLanguage(code);
        expect(SettingsService.instance.languageCode, code);
        expect(SettingsService.instance.isRtl, isFalse);
        expect(SettingsService.instance.textDirection, TextDirection.ltr);
        expect(SettingsService.instance.bilingualDisplayEnabled, isTrue);
      }
    });

    test('AppLocalizations translates keys across all 6 languages with safe fallback', () {
      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.locale);
        expect(loc.tr('nav_home').isNotEmpty, isTrue);
        expect(loc.tr('settings_title').isNotEmpty, isTrue);
        expect(loc.tr('hajj_umrah_companion').isNotEmpty, isTrue);
        expect(loc.tr('voluntary_fasting').isNotEmpty, isTrue);
        expect(loc.tr('spiritual_mood_remedy').isNotEmpty, isTrue);
        expect(loc.tr('gharib_quran_dict').isNotEmpty, isTrue);
        expect(loc.tr('kaffarah_fidyah_calc').isNotEmpty, isTrue);
      }
    });
  });

  group('Ultimate v7.0 — 5 Brand-New Islamic Features Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await HajjUmrahService.instance.init();
      await VoluntaryFastingService.instance.init();
      await GharibQuranService.instance.init();
    });

    test('Feature 1: HajjUmrahService tracks Umrah/Hajj steps and 7-lap Tawaf/Sai counters', () async {
      final service = HajjUmrahService.instance;
      expect(service.getStepsByType('umrah').length, 5);
      expect(service.getStepsByType('hajj').length, 5);
      expect(HajjUmrahService.tawafLaps.length, 7);
      expect(HajjUmrahService.saiLaps.length, 7);

      await service.resetTawaf();
      for (int i = 0; i < 7; i++) {
        await service.incrementTawafLap();
      }
      expect(service.tawafLap, 7);
      expect(service.isTawafComplete, isTrue);
    });

    test('Feature 2: VoluntaryFastingService tracks Prophetic fasts and White Days', () async {
      final service = VoluntaryFastingService.instance;
      expect(VoluntaryFastingService.fastTypes.length, 7);
      expect(service.isWhiteDay(13), isTrue);
      expect(service.isWhiteDay(14), isTrue);
      expect(service.isWhiteDay(15), isTrue);
      expect(service.isWhiteDay(10), isFalse);

      await service.logFastedDay('monday_thursday');
      expect(service.getCountForType('monday_thursday'), 1);
      expect(service.totalFastedDays, greaterThanOrEqualTo(1));
    });

    test('Feature 3: SpiritualMoodRemedyService provides Quranic & Prophetic remedies for 9 moods', () {
      final service = SpiritualMoodRemedyService.instance;
      expect(SpiritualMoodRemedyService.allRemedies.length, 9);

      service.selectMood('sadness_grief');
      expect(service.currentRemedy.id, 'sadness_grief');
      expect(service.currentRemedy.practicalSteps.length, 3);

      service.incrementDhikr();
      expect(service.activeDhikrProgress, 1);
      service.resetDhikr();
      expect(service.activeDhikrProgress, 0);
    });

    test('Feature 4: GharibQuranService searches Quranic words by root/meaning and tracks quiz score', () async {
      final service = GharibQuranService.instance;
      expect(GharibQuranService.allWords.length, 10);

      final results = service.searchWords('الصمد');
      expect(results.isNotEmpty, isTrue);

      await service.toggleMastered('gh_8_samad');
      expect(service.masteredWordIds.contains('gh_8_samad'), isTrue);

      await service.recordQuizScore(9);
      expect(service.quizBestScore, 9);
    });

    test('Feature 5: KaffarahFidyahService calculates Zakat Al-Fitr, Fidyah, and Oath Kaffarah accurately', () {
      final service = KaffarahFidyahService.instance;

      final fitr = service.calculateZakatAlFitr(
        familyMembersCount: 4,
        valuePerPersonEgp: 50.0,
      );
      expect(fitr.totalCashAmountEgp, 200.0);
      expect(fitr.totalFoodWeightKg, 10.0); // 4 * 2.5 kg

      final fidyah = service.calculateFastingFidyah(
        missedDaysCount: 30,
        mealCostPerDayEgp: 45.0,
      );
      expect(fidyah.totalCashAmountEgp, 1350.0);

      final kaffarah = service.calculateOathKaffarah(
        oathsCount: 2,
        mealCostPerPoorPersonEgp: 60.0,
      );
      expect(kaffarah.beneficiariesOrDaysCount, 20); // 2 oaths * 10 poor people
      expect(kaffarah.totalCashAmountEgp, 1200.0);
    });
  });
}
