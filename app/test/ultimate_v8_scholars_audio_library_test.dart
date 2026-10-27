import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/scholars_lectures_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v8.0 — 115+ Scholars & Preachers Audio Lectures Library Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      IslamicAudioService.instance.disableNativePlayerForTesting = true;
      await ScholarsLecturesService.instance.init();
    });

    test('Contains over 100 scholars (115 total: 60 Egyptian + 55 Arab/Islamic world) and 700+ lectures', () {
      final service = ScholarsLecturesService.instance;
      expect(service.totalScholarsCount, greaterThanOrEqualTo(115));
      expect(service.egyptianScholarsCount, 60);
      expect(service.arabWorldScholarsCount, 55);
      expect(service.totalLecturesCount, greaterThanOrEqualTo(700));
    });

    test('Includes Samir Mostafa, Nabil Al-Awadi, Mahmoud Al-Hasanat, and Egyptian scholars with multi-category lectures', () {
      final service = ScholarsLecturesService.instance;

      // 1. Sheikh Samir Mostafa
      final samir = service.getScholarById('samir_mostafa');
      expect(samir.name, contains('سمير مصطفى'));
      expect(samir.regionGroup, 'egypt');
      final samirLectures = service.getLecturesForScholar('samir_mostafa');
      expect(samirLectures.length, greaterThanOrEqualTo(12));
      final samirCategories = service.getCategoryCountsForScholar('samir_mostafa');
      expect(samirCategories.keys.length, greaterThanOrEqualTo(6));

      // 2. Sheikh Nabil Al-Awadi
      final awadi = service.getScholarById('nabil_alawadi');
      expect(awadi.name, contains('نبيل العوضي'));
      final awadiLectures = service.getLecturesForScholar('nabil_alawadi');
      expect(awadiLectures.length, greaterThanOrEqualTo(8));

      // 3. Preacher Mahmoud Al-Hasanat
      final hasanat = service.getScholarById('mahmoud_alhasanat');
      expect(hasanat.name, contains('محمود الحسنات'));
      final hasanatLectures = service.getLecturesForScholar('mahmoud_alhasanat');
      expect(hasanatLectures.length, greaterThanOrEqualTo(6));
    });

    test('Every scholar has multiple lectures categorized by content with valid HTTPS MP3 URLs and fallback mirrors', () {
      final service = ScholarsLecturesService.instance;
      for (final scholar in service.allScholars) {
        final lectures = service.getLecturesForScholar(scholar.id);
        expect(lectures.length, greaterThanOrEqualTo(6),
            reason: 'Scholar ${scholar.name} must have at least 6 lectures');
        for (final lec in lectures) {
          expect(lec.primaryAudioUrl.startsWith('https://'), isTrue);
          expect(lec.primaryAudioUrl.endsWith('.mp3'), isTrue);
          expect(lec.fallbackAudioUrls, isNotEmpty);
          expect(lec.category, isNot(LectureContentCategory.all));
        }
      }
    });

    test('Plays any scholar lecture and loads scholar playlist queue into IslamicAudioService', () async {
      final service = ScholarsLecturesService.instance;
      final samirLectures = service.getLecturesForScholar('samir_mostafa');

      await service.playLecture(samirLectures.first);
      expect(IslamicAudioService.instance.currentTrack?.id, samirLectures.first.id);
      expect(IslamicAudioService.instance.isPlaying, isTrue);
      expect(IslamicAudioService.instance.queue.length, samirLectures.length);
    });
  });
}
