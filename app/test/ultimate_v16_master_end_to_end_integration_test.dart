import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:almomin/core/audio/fast_audio_service.dart';
import 'package:almomin/core/localization/app_localizations.dart';
import 'package:almomin/core/services/adhan_sensor_gesture_service.dart';
import 'package:almomin/core/services/adhkar_service.dart';
import 'package:almomin/core/services/ayah_notes_service.dart';
import 'package:almomin/core/services/backup_restore_service.dart';
import 'package:almomin/core/services/daily_wird_service.dart';
import 'package:almomin/core/services/egyptian_heritage_service.dart';
import 'package:almomin/core/services/fajr_qiyam_alarm_service.dart';
import 'package:almomin/core/services/fiqh_library_service.dart';
import 'package:almomin/core/services/gharib_quran_service.dart';
import 'package:almomin/core/services/hadith_service.dart';
import 'package:almomin/core/services/hajj_umrah_service.dart';
import 'package:almomin/core/services/islamic_mutoon_service.dart';
import 'package:almomin/core/services/kaffarah_fidyah_service.dart';
import 'package:almomin/core/services/khatma_service.dart';
import 'package:almomin/core/services/mawarith_calculator_service.dart';
import 'package:almomin/core/services/memorization_service.dart';
import 'package:almomin/core/services/prayer_service.dart';
import 'package:almomin/core/services/prayer_tracker_service.dart';
import 'package:almomin/core/services/ramadan_service.dart';
import 'package:almomin/core/services/riyad_alsalihin_service.dart';
import 'package:almomin/core/services/scholar_audio_resolver_service.dart';
import 'package:almomin/core/services/scholars_lectures_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/stories_service.dart';
import 'package:almomin/core/services/sunan_rawatib_service.dart';
import 'package:almomin/core/services/tadabbur_journal_service.dart';
import 'package:almomin/core/services/tajweed_service.dart';
import 'package:almomin/core/services/unified_library_search_service.dart';
import 'package:almomin/core/services/voluntary_fasting_service.dart';
import 'package:almomin/core/services/zakat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v16.0 — Level-5 Deep Research & Master End-to-End Integration Suite', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.init(forceReload: true);
      await AdhkarService.instance.init(forceReload: true);
    });

    test('1. Backup & Restore preserves tasbih_total_today, tasbih_last_date, and all extended v16 feature states without data loss', () async {
      final prefs = await SharedPreferences.getInstance();

      // Populate rich user state across all services
      await SettingsService.instance.setLanguage('en');
      await SettingsService.instance.setMushafFontSize(30.0);
      await SettingsService.instance.setDefaultPlaybackSpeed(1.5);
      await SettingsService.instance.setFiqhMadhhab('maliki');
      await SettingsService.instance.setTasbihVolumeButtonEnabled(true);
      await SettingsService.instance.setTasbihSliderEnabled(true);

      await AdhkarService.instance.setTasbihTarget(100);
      await AdhkarService.instance.incrementTasbih(step: 42);
      expect(AdhkarService.instance.tasbihCount, equals(42));
      expect(AdhkarService.instance.tasbihTotalToday, equals(42));

      await GharibQuranService.instance.init(forceReload: true);
      await GharibQuranService.instance.toggleMastered('gh_1');
      await GharibQuranService.instance.recordQuizScore(10);

      await prefs.setStringList('stories_favorites', ['prophet_yusuf', 'prophet_musa']);
      await prefs.setString('stories_last_read', 'prophet_yusuf');
      await prefs.setInt('hadith_last_read_id', 12);
      await prefs.setStringList('quran_search_history_v1', ['الرحمن', 'آية الكرسي']);
      await prefs.setString('scholars_last_played_lecture', 'samir_mustafa_seerah_01');
      await prefs.setString('tadabbur_daily_accountability_v1', '{"2026-10-26":{"read_wird":true}}');

      // Export full backup JSON
      final exportedJson = await BackupRestoreService.instance.exportBackupJson();
      final validation = BackupRestoreService.instance.validateBackup(exportedJson);
      expect(validation.isValid, isTrue, reason: validation.errorMessage);

      // Simulate fresh device wipe
      await prefs.clear();
      await SettingsService.instance.init(forceReload: true);
      await AdhkarService.instance.init(forceReload: true);
      await GharibQuranService.instance.init(forceReload: true);
      expect(AdhkarService.instance.tasbihTotalToday, equals(0));
      expect(GharibQuranService.instance.masteredCount, equals(0));
      expect(SettingsService.instance.languageCode, equals('ar'));

      // Restore from backup envelope
      final restoredOk = await BackupRestoreService.instance.restoreBackup(
        validation.rawData!,
        replaceMode: true,
      );
      expect(restoredOk, isTrue);

      // Verify AdhkarService did NOT wipe tasbihTotalToday upon init(forceReload: true)
      expect(AdhkarService.instance.tasbihCount, equals(42));
      expect(AdhkarService.instance.tasbihTotalToday, equals(42));
      expect(AdhkarService.instance.tasbihTarget, equals(100));

      // Verify GharibQuranService, Stories, Hadith, Search History, Scholars, and Settings restored
      expect(GharibQuranService.instance.isMastered('gh_1'), isTrue);
      expect(GharibQuranService.instance.quizBestScore, equals(10));
      expect(SettingsService.instance.languageCode, equals('en'));
      expect(SettingsService.instance.mushafFontSize, equals(30.0));
      expect(SettingsService.instance.defaultPlaybackSpeed, equals(1.5));
      expect(SettingsService.instance.fiqhMadhhab, equals('maliki'));
      expect(prefs.getStringList('stories_favorites'), containsAll(['prophet_yusuf', 'prophet_musa']));
      expect(prefs.getString('stories_last_read'), equals('prophet_yusuf'));
      expect(prefs.getInt('hadith_last_read_id'), equals(12));
      expect(prefs.getStringList('quran_search_history_v1'), contains('آية الكرسي'));
      expect(prefs.getString('scholars_last_played_lecture'), equals('samir_mustafa_seerah_01'));
      expect(prefs.getString('tadabbur_daily_accountability_v1'), contains('read_wird'));
    });

    test('2. All 26 stateful services support standardized init(forceReload: true)', () async {
      await SettingsService.instance.init(forceReload: true);
      await AdhkarService.instance.init(forceReload: true);
      await GharibQuranService.instance.init(forceReload: true);
      await HajjUmrahService.instance.init(forceReload: true);
      await PrayerTrackerService.instance.init(forceReload: true);
      await VoluntaryFastingService.instance.init(forceReload: true);
      await PrayerService.instance.init(forceReload: true);
      await KhatmaService.instance.init(forceReload: true);
      await AyahNotesService.instance.init(forceReload: true);
      await MemorizationService.instance.init(forceReload: true);
      await ZakatService.instance.init(forceReload: true);
      await HadithService.instance.init(forceReload: true);
      await EgyptianHeritageService.instance.init(forceReload: true);
      await FiqhLibraryService.instance.init(forceReload: true);
      await DailyWirdService.instance.init(forceReload: true);
      await FajrQiyamAlarmService.instance.init(forceReload: true);
      await ScholarsLecturesService.instance.init(forceReload: true);
      await ScholarAudioResolverService.instance.init(forceReload: true);
      await SunanRawatibService.instance.init(forceReload: true);
      await RamadanService.instance.init(forceReload: true);
      await TadabburJournalService.instance.init(forceReload: true);
      await RiyadAlSalihinService.instance.init(forceReload: true);
      await IslamicMutoonService.instance.init(forceReload: true);
      await TajweedService.instance.init(forceReload: true);
      await StoriesService.instance.init(forceReload: true);
      await AdhanSensorGestureService.instance.init(forceReload: true);
    });

    test('3. Scholars Audio Library strict voice isolation across all 115 scholars and 708 lectures', () async {
      final service = ScholarsLecturesService.instance;
      await service.init(forceReload: true);

      expect(service.totalScholarsCount, equals(115));
      expect(service.egyptianScholarsCount, equals(60));
      expect(service.arabWorldScholarsCount, equals(55));
      expect(service.totalLecturesCount, greaterThanOrEqualTo(708));

      final urlOwner = <String, String>{};
      for (final scholar in service.scholars) {
        expect(scholar.lectures.length, greaterThanOrEqualTo(6));
        for (final lec in scholar.lectures) {
          final candidates = ScholarAudioResolverService.instance
              .buildPrioritizedCandidateUrls(scholar, lec);
          expect(candidates, isNotEmpty);
          for (final url in candidates) {
            expect(
              ScholarAudioResolverService.instance.verifyUrlBelongsToScholar(url, scholar),
              isTrue,
              reason: 'URL $url must belong strictly to ${scholar.id}',
            );
            final existing = urlOwner[url];
            expect(
              existing == null || existing == scholar.id,
              isTrue,
              reason: 'URL $url shared between $existing and ${scholar.id}',
            );
            urlOwner[url] = scholar.id;
          }
        }
      }

      // FastAudioService URL-bound cache key verification
      final keyA = FastAudioService.buildIsolatedCacheKey(
        'track_1',
        'https://archive.org/download/samir_mustafa/001.mp3',
      );
      final keyB = FastAudioService.buildIsolatedCacheKey(
        'track_1',
        'https://archive.org/download/nabil_alawadi/001.mp3',
      );
      expect(keyA, isNot(equals(keyB)));
    });

    test('4. Multi-language localization (6 languages x 171 keys) & dynamic RTL/LTR directionality', () async {
      expect(AppLanguage.values.length, equals(6));
      for (final lang in AppLanguage.values) {
        await SettingsService.instance.setLanguage(lang.code);
        final expectedDir = (lang.code == 'ar' || lang.code == 'ur')
            ? TextDirection.rtl
            : TextDirection.ltr;
        expect(SettingsService.instance.textDirection, equals(expectedDir));

        for (final key in AppStrings.allKeys) {
          final val = AppStrings.of(key, langOverride: lang.code);
          expect(val.trim(), isNotEmpty, reason: 'Missing translation for $key in ${lang.code}');
        }
      }
    });

    test('5. Fiqh Calculators, Voluntary Fasting Hijri White Days, and Unified Library 13-Encyclopedia Search', () async {
      // Mawarith clamping & calculation
      final mawarith = MawarithCalculatorService.instance.calculate(
        estateValue: 240000,
        debts: 0,
        funeralExpenses: 0,
        bequestAmount: 0,
        hasHusband: false,
        wivesCount: 5, // Clamped to 4 max
        sonsCount: 2,
        daughtersCount: 1,
        hasFather: true,
        hasMother: true,
      );
      expect(mawarith.netEstate, equals(240000));
      expect(mawarith.shares, isNotEmpty);

      // Kaffarah & Fidyah calculation
      final kaffarah = KaffarahFidyahService.instance.calculateOathKaffarah(
        mealCostPerPerson: 100,
      );
      expect(kaffarah.totalFeedingCost, equals(1000));
      expect(kaffarah.fastingDaysIfUnable, equals(3));

      // Voluntary Fasting Hijri White Days & logs
      final vf = VoluntaryFastingService.instance;
      await vf.init(forceReload: true);
      expect(vf.isWhiteDay(13), isTrue);
      expect(vf.isWhiteDay(14), isTrue);
      expect(vf.isWhiteDay(15), isTrue);
      expect(vf.isWhiteDay(16), isFalse);
      expect(vf.getTodayHijriFastRecommendation(), isNotEmpty);

      // Unified Library 14 filters (all + 13 encyclopedias)
      expect(UnifiedLibrarySearchService.libraryFilters.length, equals(14));
      final results = await UnifiedLibrarySearchService.instance.search('الصلاة');
      expect(results, isNotEmpty);
    });

    test('6. Static source code verification of Level-5 guards (PageController, TabController, HapticFeedback, Clipboard, QuranRepository)', () {
      final pageMushaf = File('lib/features/mushaf/page_mode_mushaf_screen.dart').readAsStringSync();
      expect(pageMushaf.contains('if (_pageController.hasClients)'), isTrue);

      final onboarding = File('lib/features/onboarding/onboarding_screen.dart').readAsStringSync();
      expect(onboarding.contains('if (_pageController.hasClients)'), isTrue);

      final libScreen = File('lib/features/library/islamic_library_screen.dart').readAsStringSync();
      expect(libScreen.contains('_tabController.length - 1'), isTrue);

      final lingSheet = File('lib/features/mushaf/widgets/ayah_linguistics_sheet.dart').readAsStringSync();
      expect(lingSheet.contains('_tabController.length - 1'), isTrue);

      final egyptScreen = File('lib/features/egypt/egyptian_heritage_screen.dart').readAsStringSync();
      expect(egyptScreen.contains('_tabController.length - 1'), isTrue);

      final qiblaScreen = File('lib/features/prayer/qibla_compass_screen.dart').readAsStringSync();
      expect(qiblaScreen.contains('if (SettingsService.instance.hapticEnabled)'), isTrue);

      final quranRepo = File('lib/core/services/quran_repository.dart').readAsStringSync();
      expect(quranRepo.contains('return _cachedSurahs ?? const <Surah>[];'), isTrue);
      expect(quranRepo.contains('return _cachedJuz ?? const <Juz>[];'), isTrue);
    });
  });
}
