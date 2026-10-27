import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:almomin/core/audio/fast_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FastAudioService High-Speed Audio Engine Tests', () {
    test('Fast streaming headers contain keep-alive and identity encoding', () {
      final headers = FastAudioService.fastStreamingHeaders;
      expect(headers['Connection'], 'keep-alive');
      expect(headers['Accept-Encoding'], 'identity');
      expect(headers['User-Agent'], contains('High-Speed-Audio-Engine'));
    });

    test('getFastAudioSource returns Uri/LockCaching source for remote URL', () async {
      final service = FastAudioService.instance;
      final source = await service.getFastAudioSource(
        'https://server8.mp3quran.net/afs/001.mp3',
        cacheKey: 'test_surah_001',
      );
      expect(source, isNotNull);
    });

    test('getFastAudioSource returns file source when valid local path is passed', () async {
      final tempFile = File('${Directory.systemTemp.path}/almomin_test_audio.mp3');
      await tempFile.writeAsBytes(List.filled(2048, 1));

      final service = FastAudioService.instance;
      final source = await service.getFastAudioSource(
        'https://server8.mp3quran.net/afs/001.mp3',
        cacheKey: 'test_surah_local',
        localDownloadedPath: tempFile.path,
      );

      expect(source, isNotNull);
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }
    });

    test('getCachedFile returns null for non-existent cache keys', () {
      final service = FastAudioService.instance;
      final nonExistent = service.getCachedFile('unknown_key_99999');
      expect(nonExistent, isNull);
    });
  });
}
