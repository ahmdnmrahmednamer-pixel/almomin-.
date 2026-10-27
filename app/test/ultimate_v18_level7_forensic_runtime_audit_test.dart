import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:almomin/core/models/memorization_item.dart';
import 'package:almomin/core/models/zakat_calculation.dart';
import 'package:almomin/core/services/ayah_notes_service.dart';
import 'package:almomin/core/services/egyptian_heritage_service.dart';
import 'package:almomin/core/services/gharib_quran_service.dart';
import 'package:almomin/core/services/khatma_service.dart';
import 'package:almomin/core/services/riyad_alsalihin_service.dart';
import 'package:almomin/core/services/tajweed_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v18.0 — Level-7 Forensic Runtime & Normalized Search Audit Suite', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. Core services (AyahNotes, GharibQuran, RiyadAlSalihin, Tajweed) match diacritic-vocalized Arabic text using unvocalized queries', () async {
      // 1a. AyahNotesService
      await AyahNotesService.instance.init(forceReload: true);
      await AyahNotesService.instance.saveNote(
        surahId: 1,
        surahName: 'الفاتحة',
        ayahNumber: 1,
        ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        noteText: 'تأمل في رحمة الله الواسعة',
      );
      final notesMatch = AyahNotesService.instance.getAllNotes(searchQuery: 'الرحمن الرحيم');
      expect(notesMatch, isNotEmpty);
      final noteLooseMatch = AyahNotesService.instance.getAllNotes(searchQuery: 'تامل في رحمه');
      expect(noteLooseMatch, isNotEmpty);

      // 1b. GharibQuranService
      await GharibQuranService.instance.init(forceReload: true);
      final firstWord = GharibQuranService.instance.allWords.first;
      // Search using unvocalized word
      final gharibMatches = GharibQuranService.instance.searchWords(firstWord.surahName.replaceAll('ة', 'ه'));
      expect(gharibMatches, isNotEmpty);

      // 1c. RiyadAlSalihinService
      await RiyadAlSalihinService.instance.init(forceReload: true);
      final riyadMatches = RiyadAlSalihinService.instance.getEntriesForEncyclopedia(
        'riyad',
        query: 'الاعمال بالنيات',
      );
      expect(riyadMatches, isNotEmpty);

      // 1d. TajweedService
      await TajweedService.instance.init(forceReload: true);
      final tajweedMatches = TajweedService.instance.searchRules('ادغام');
      expect(tajweedMatches, isNotEmpty);
    });

    test('2. EgyptianHeritageService Mubtahil filter normalizes Arabic Ya/Alif Maqsura (النقشبندى -> النقشبندي)', () async {
      await EgyptianHeritageService.instance.init(forceReload: true);
      final results = EgyptianHeritageService.instance.searchIbtihalat(
        '',
        mubtahilFilter: 'النقشبندى',
      );
      expect(results, isNotEmpty);
    });

    test('3. MemorizationItem.fromJson, KhatmaPlan.fromJson, and ZakatCalculation.fromJson safely handle partial or out-of-range JSON fields', () {
      // Missing surah_id / ayah_number / out-of-bounds leitner_box
      final item = MemorizationItem.fromJson({
        'surah_id': 999,
        'ayah_number': -5,
        'leitner_box': 99,
        'last_rating': 12345, // non-String rating
      });
      expect(item.surahId, equals(114));
      expect(item.ayahNumber, equals(1));
      expect(item.leitnerBox, equals(5));
      expect(item.lastRating, isNull);

      // KhatmaPlan with targetDays: 0 is safely clamped to 1
      final plan = KhatmaPlan.fromJson({
        'targetDays': 0,
        'currentPage': 700,
      });
      expect(plan.targetDays, equals(1));
      expect(plan.currentPage, equals(604));

      // ZakatCalculation with non-String hawl_date
      final zakat = ZakatCalculation.fromJson({
        'cash_on_hand': 50000,
        'hawl_date': 20261027,
      });
      expect(zakat.cashOnHand, equals(50000.0));
    });

    test('4. Static verification of Level-7 ArabicNormalizer in 6 UI screens & StreamSubscription/Timer cancellation guards', () {
      for (final uiPath in [
        'lib/features/mushaf/mushaf_screen.dart',
        'lib/features/audio/audio_screen.dart',
        'lib/features/adhkar/adhkar_hub_screen.dart',
        'lib/features/prayer/widgets/arab_city_picker_modal.dart',
        'lib/features/settings/widgets/settings_adhan_voice_modal.dart',
        'lib/features/settings/widgets/settings_reciter_modal.dart',
      ]) {
        final content = File(uiPath).readAsStringSync();
        expect(
          content.contains('ArabicNormalizer.normalize'),
          isTrue,
          reason: 'Expected ArabicNormalizer.normalize in $uiPath',
        );
      }

      expect(
        File('lib/core/services/adhan_sensor_gesture_service.dart')
            .readAsStringSync()
            .contains('_accelSub?.cancel();'),
        isTrue,
      );
      expect(
        File('lib/features/prayer/qibla_compass_screen.dart')
            .readAsStringSync()
            .contains('_magnetometerSub?.cancel();'),
        isTrue,
      );
      expect(
        File('lib/features/prayer/adhan_control_screen.dart')
            .readAsStringSync()
            .contains('_clockTimer?.cancel();'),
        isTrue,
      );
    });
  });
}
