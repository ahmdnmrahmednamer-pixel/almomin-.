import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/scholar_audio_resolver_service.dart';
import 'package:almomin/core/services/scholars_lectures_service.dart';
import 'package:almomin/core/audio/fast_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    IslamicAudioService.instance.disableNativePlayerForTesting = true;
    await ScholarsLecturesService.instance.init();
    await ScholarAudioResolverService.instance.init();
  });

  group('Ultimate v11.0 Strict Scholar Audio Isolation & Multi-Source Engine Tests', () {
    test('1. Zero URLs (Primary or Fallback) are ever shared between any two different scholars across all 115 scholars', () {
      final service = ScholarsLecturesService.instance;
      expect(service.totalScholarsCount, equals(115));
      expect(service.totalLecturesCount, greaterThanOrEqualTo(700));

      final urlOwnerMap = <String, String>{};
      for (final lecture in service.allLectures) {
        final allUrls = [
          lecture.primaryAudioUrl,
          ...lecture.fallbackAudioUrls,
        ];
        for (final url in allUrls) {
          final existingOwner = urlOwnerMap[url];
          if (existingOwner != null) {
            expect(
              existingOwner,
              equals(lecture.scholarId),
              reason:
                  'URL $url is shared between $existingOwner and ${lecture.scholarId}!',
            );
          } else {
            urlOwnerMap[url] = lecture.scholarId;
          }
        }
      }
    });

    test('2. ScholarAudioResolverService.verifyUrlBelongsToScholar enforces strict cross-scholar isolation', () {
      final resolver = ScholarAudioResolverService.instance;

      // Samir Mostafa URL belongs to samir_mostafa ONLY
      const samirUrl = 'https://archive.org/download/mostafa-mohazarat/00.mp3';
      expect(resolver.verifyUrlBelongsToScholar(samirUrl, 'samir_mostafa'), isTrue);
      expect(resolver.verifyUrlBelongsToScholar(samirUrl, 'mahmoud_alhasanat'), isFalse);
      expect(resolver.verifyUrlBelongsToScholar(samirUrl, 'nabil_alawadi'), isFalse);

      // Nabil Al-Awadi URL belongs to nabil_alawadi ONLY
      const awadiUrl = 'https://archive.org/download/qasas-anbiya/01.mp3';
      expect(resolver.verifyUrlBelongsToScholar(awadiUrl, 'nabil_alawadi'), isTrue);
      expect(resolver.verifyUrlBelongsToScholar(awadiUrl, 'samir_mostafa'), isFalse);
      expect(resolver.verifyUrlBelongsToScholar(awadiUrl, 'mahmoud_alhasanat'), isFalse);

      // Mahmoud Al-Hasanat URL belongs to mahmoud_alhasanat ONLY
      const hasanatUrl =
          'https://archive.org/download/20230918_20230918_0013/01.mp3';
      expect(resolver.verifyUrlBelongsToScholar(hasanatUrl, 'mahmoud_alhasanat'), isTrue);
      expect(resolver.verifyUrlBelongsToScholar(hasanatUrl, 'samir_mostafa'), isFalse);
      expect(resolver.verifyUrlBelongsToScholar(hasanatUrl, 'nabil_alawadi'), isFalse);
    });

    test('3. ScholarAudioResolverService.verifyMetadataMatchesScholar validates scholar Arabic name tokens and rejects other scholars', () {
      final resolver = ScholarAudioResolverService.instance;

      expect(
        resolver.verifyMetadataMatchesScholar(
          'خطبة كفى يا نفس ما كان - الشيخ محمود الحسنات',
          'mahmoud_alhasanat',
        ),
        isTrue,
      );
      expect(
        resolver.verifyMetadataMatchesScholar(
          'سلسلة السيرة النبوية - الشيخ سمير مصطفى',
          'mahmoud_alhasanat',
        ),
        isFalse,
      );
      expect(
        resolver.verifyMetadataMatchesScholar(
          'قصص الأنبياء - الشيخ نبيل العوضي',
          'nabil_alawadi',
        ),
        isTrue,
      );
    });

    test('4. FastAudioService.buildUrlBoundCacheKey produces distinct cache keys when URL changes for same track ID', () {
      final fastAudio = FastAudioService.instance;
      final keyA = fastAudio.buildUrlBoundCacheKey(
        'audio_hd_hasanat_khutbah_01',
        'https://archive.org/download/mostafa-mohazarat/30.mp3',
      );
      final keyB = fastAudio.buildUrlBoundCacheKey(
        'audio_hd_hasanat_khutbah_01',
        'https://archive.org/download/20230918_20230918_0013/008.mp3',
      );
      expect(keyA, isNot(equals(keyB)));
    });

    test('5. Playing lectures across different scholars updates IslamicAudioService with strictly isolated URLs', () async {
      final service = ScholarsLecturesService.instance;
      final audio = IslamicAudioService.instance;
      final resolver = ScholarAudioResolverService.instance;

      final samirLec = service.getLecturesForScholar('samir_mostafa').first;
      await service.playLecture(samirLec);
      expect(audio.currentTrack?.id, equals(samirLec.id));
      expect(
        resolver.verifyUrlBelongsToScholar(
          audio.currentTrack!.remoteUrl!,
          'samir_mostafa',
        ),
        isTrue,
      );

      final hasanatLec =
          service.getLecturesForScholar('mahmoud_alhasanat').first;
      await service.playLecture(hasanatLec);
      expect(audio.currentTrack?.id, equals(hasanatLec.id));
      expect(
        resolver.verifyUrlBelongsToScholar(
          audio.currentTrack!.remoteUrl!,
          'mahmoud_alhasanat',
        ),
        isTrue,
      );
      expect(
        resolver.verifyUrlBelongsToScholar(
          audio.currentTrack!.remoteUrl!,
          'samir_mostafa',
        ),
        isFalse,
      );
    });
  });
}
