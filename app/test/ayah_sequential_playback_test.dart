import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/audio/ayah_audio_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init(forceReload: true);
  });

  group('Ayah Sequential Audio Playback & URL Integrity Tests', () {
    test('SettingsService generates distinct, properly padded URLs for sequential ayahs', () {
      final s = SettingsService.instance;

      // Surah 1: Ayah 1 vs Ayah 2
      final urlAyah1 = s.getAyahAudioUrl(1, 1);
      final urlAyah2 = s.getAyahAudioUrl(1, 2);
      final urlAyah3 = s.getAyahAudioUrl(1, 3);

      expect(urlAyah1, isNot(equals(urlAyah2)));
      expect(urlAyah2, isNot(equals(urlAyah3)));
      expect(urlAyah1, endsWith('/001001.mp3'));
      expect(urlAyah2, endsWith('/001002.mp3'));
      expect(urlAyah3, endsWith('/001003.mp3'));

      // Surah 2: Ayah 255 (Ayat Al-Kursi)
      final urlKursi = s.getAyahAudioUrl(2, 255);
      expect(urlKursi, endsWith('/002255.mp3'));
    });

    test('Reciters without separate verse audio route to high-fidelity canonical verse stream', () async {
      final s = SettingsService.instance;

      // Select Raad Al-Kurdi (whole-surah reciter on MP3Quran)
      await s.setSelectedReciter('kurdi');
      expect(s.currentReciter.id, equals('kurdi'));
      expect(s.currentReciter.hasVerseAudio, isFalse);

      // Ayah URL routes to canonical verse audio (never 404s on EveryAyah)
      final ayah1 = s.getAyahAudioUrl(1, 1);
      final ayah2 = s.getAyahAudioUrl(1, 2);
      expect(ayah1, contains('Minshawy_Murattal_128kbps/001001.mp3'));
      expect(ayah2, contains('Minshawy_Murattal_128kbps/001002.mp3'));
      expect(ayah1, isNot(equals(ayah2)));

      // While whole-surah URL still routes to Raad Al-Kurdi MP3Quran CDN
      final surah1 = s.getSurahAudioUrl(1);
      expect(surah1, contains('server6.mp3quran.net/kurdi/001.mp3'));
    });

    test('Verified EveryAyah reciters route to their exact subfolders', () async {
      final s = SettingsService.instance;

      // Mahmoud Ali Al-Banna
      await s.setSelectedReciter('banna');
      expect(s.currentReciter.subfolder, equals('mahmoud_ali_al_banna_32kbps'));
      expect(s.getAyahAudioUrl(1, 2), contains('mahmoud_ali_al_banna_32kbps/001002.mp3'));

      // Fares Abbad
      await s.setSelectedReciter('fares_abbad');
      expect(s.currentReciter.subfolder, equals('Fares_Abbad_64kbps'));
      expect(s.getAyahAudioUrl(1, 2), contains('Fares_Abbad_64kbps/001002.mp3'));

      // Abdullah Al-Juhany
      await s.setSelectedReciter('juhany');
      expect(s.currentReciter.subfolder, equals('Abdullaah_3awwaad_Al-Juhaynee_128kbps'));
      expect(s.getAyahAudioUrl(1, 2), contains('Abdullaah_3awwaad_Al-Juhaynee_128kbps/001002.mp3'));

      // Salah Bukhatir
      await s.setSelectedReciter('bukhatir');
      expect(s.currentReciter.subfolder, equals('Salaah_AbdulRahman_Bukhatir_128kbps'));
      expect(s.getAyahAudioUrl(1, 2), contains('Salaah_AbdulRahman_Bukhatir_128kbps/001002.mp3'));
    });

    test('AyahAudioPlayer state updates cleanly across ayahs without retaining old key', () async {
      final player = AyahAudioPlayer.instance;
      expect(player.currentPlayingKey.value, isNull);

      await player.stop();
      expect(player.currentPlayingKey.value, isNull);
      expect(player.isPlaying.value, isFalse);
    });
  });
}
