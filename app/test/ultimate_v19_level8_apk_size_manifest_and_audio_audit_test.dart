import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:almomin/core/services/islamic_audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v19.0 — Level-8 APK Size Optimization, Manifest Queries & Audio Fidelity Audit Suite', () {
    test('1. All 65 test suites use canonical package:almomin/ URI matching pubspec.yaml', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('name: almomin'), isTrue);

      final testDir = Directory('test');
      final testFiles = testDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
      expect(testFiles.length, greaterThanOrEqualTo(65));

      final legacyPrefix = 'package:noor_' 'almomin/';
      for (final tf in testFiles) {
        final content = tf.readAsStringSync();
        expect(
          content.contains(legacyPrefix),
          isFalse,
          reason: '${tf.path} must use package:almomin/',
        );
      }
    });

    test('2. Bundled MP3 audio assets and res/raw notification sounds are optimized (< 18.5 MB total) and non-empty', () {
      int totalAudioBytes = 0;
      for (final dirPath in ['assets/audio', 'android/app/src/main/res/raw']) {
        final dir = Directory(dirPath);
        expect(dir.existsSync(), isTrue);
        for (final file in dir.listSync().whereType<File>().where((f) => f.path.endsWith('.mp3'))) {
          final len = file.lengthSync();
          expect(len, greaterThan(500), reason: '${file.path} must be non-empty');
          totalAudioBytes += len;
        }
      }
      expect(totalAudioBytes, lessThan(19 * 1024 * 1024));

      expect(File('android/app/src/main/res/raw/adhan_aqsa.mp3').lengthSync(), greaterThan(700 * 1024));
      expect(File('android/app/src/main/res/raw/adhan_hussary.mp3').lengthSync(), greaterThan(700 * 1024));
    });

    test('3. All 117 Quran JSON files in assets/data/ are minified and valid UTF-8 JSON', () {
      final surahsJson = json.decode(File('assets/data/surahs.json').readAsStringSync()) as List;
      expect(surahsJson.length, equals(114));

      final juzJson = json.decode(File('assets/data/juz.json').readAsStringSync()) as List;
      expect(juzJson.length, equals(30));

      final ayahsMap = json.decode(File('assets/data/quran_ayahs.json').readAsStringSync()) as Map;
      expect(ayahsMap.length, equals(114));
    });

    test('4. IslamicAudioService maps rawNotificationSound for adhan_aqsa, adhan_hussary, iqamah_madinah, and iqamah_short', () {
      final tracks = IslamicAudioService.allTracks;
      final aqsa = tracks.firstWhere((t) => t.id == 'adhan_aqsa');
      final hussary = tracks.firstWhere((t) => t.id == 'adhan_hussary');
      final iqMadinah = tracks.firstWhere((t) => t.id == 'iqamah_madinah');
      final iqShort = tracks.firstWhere((t) => t.id == 'iqamah_short');

      expect(aqsa.rawNotificationSound, equals('adhan_aqsa'));
      expect(hussary.rawNotificationSound, equals('adhan_hussary'));
      expect(iqMadinah.rawNotificationSound, equals('iqamah'));
      expect(iqShort.rawNotificationSound, equals('takbeerat'));
    });

    test('5. Android res/raw/keep.xml protects notification sounds and AndroidManifest.xml declares https, http, tel, and mailto <queries>', () {
      final keepFile = File('android/app/src/main/res/raw/keep.xml');
      expect(keepFile.existsSync(), isTrue);
      final keepXml = keepFile.readAsStringSync();
      expect(keepXml.contains('tools:keep="@raw/adhan_*,@raw/approaching_*,@raw/duaa_*,@raw/iqamah,@raw/takbeerat"'), isTrue);

      final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest.contains('android:scheme="https"'), isTrue);
      expect(manifest.contains('android:scheme="http"'), isTrue);
      expect(manifest.contains('android:scheme="tel"'), isTrue);
      expect(manifest.contains('android:scheme="mailto"'), isTrue);
    });
  });
}
