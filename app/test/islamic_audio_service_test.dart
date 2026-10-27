import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/notifications/prayer_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('IslamicAudioService Catalog & Integration Tests', () {
    test('Track catalog includes all required Adhan, Iqamah, and Adhkar tracks', () {
      final tracks = IslamicAudioService.allTracks;
      expect(tracks.isNotEmpty, isTrue);

      final adhanTracks = tracks.where((t) => t.type == IslamicAudioType.adhan).toList();
      expect(adhanTracks.length, greaterThanOrEqualTo(5));

      final adhanIds = adhanTracks.map((t) => t.id).toList();
      expect(adhanIds, contains('adhan_makkah'));
      expect(adhanIds, contains('adhan_madinah'));
      expect(adhanIds, contains('adhan_cairo_refaat'));
      expect(adhanIds, contains('adhan_fajr'));
      expect(adhanIds, contains('adhan_aqsa'));
      expect(adhanIds, contains('takbeerat'));

      final iqamahTracks = tracks.where((t) => t.type == IslamicAudioType.iqamah).toList();
      expect(iqamahTracks.length, greaterThanOrEqualTo(1));
      expect(iqamahTracks.any((t) => t.id == 'iqamah_full'), isTrue);

      final adhkarTracks = tracks.where((t) => t.type == IslamicAudioType.adhkar).toList();
      expect(adhkarTracks.length, greaterThanOrEqualTo(8));
      final adhkarIds = adhkarTracks.map((t) => t.id).toList();
      expect(adhkarIds, containsAll([
        'adhkar_morning',
        'adhkar_evening',
        'adhkar_post_prayer',
        'adhkar_sleep',
        'adhkar_waking',
        'adhkar_home_mosque',
        'prophetic_duas',
        'ruqyah_shariah',
      ]));
    });

    test('All Adhkar and Duas tracks stream online by default with valid remoteUrl and no assetPath', () {
      final adhkarTracks = IslamicAudioService.allTracks
          .where((t) => t.type == IslamicAudioType.adhkar && t.id != 'duaa_sharawi_post_prayer')
          .toList();
      expect(adhkarTracks.isNotEmpty, isTrue);
      for (final track in adhkarTracks) {
        expect(track.remoteUrl, isNotNull, reason: 'Track ${track.id} must have a valid remote streaming URL');
        expect(track.remoteUrl!.startsWith('https://'), isTrue);
        expect(track.assetPath, isNull, reason: 'Track ${track.id} should stream online and not bundle local asset');
        expect(track.isBundled, isFalse);
      }
    });

    test('All bundled offline audio files (Adhan & Iqamah alarms) exist on disk with valid file size', () {
      final bundledTracks = IslamicAudioService.allTracks.where((t) => t.isBundled);
      expect(bundledTracks.isNotEmpty, isTrue);
      for (final track in bundledTracks) {
        expect(
          track.type == IslamicAudioType.adhan ||
              track.type == IslamicAudioType.iqamah ||
              track.id == 'duaa_sharawi_post_prayer',
          isTrue,
        );
        final file = File(track.assetPath!);
        expect(file.existsSync(), isTrue, reason: 'Bundled asset file ${track.assetPath} must exist on disk');
        expect(file.lengthSync(), greaterThan(500), reason: 'Audio file ${track.assetPath} must be non-empty');
      }
    });

    test('IslamicAudioService download tracking and storage helpers function properly', () async {
      final service = IslamicAudioService.instance;
      await service.init();

      expect(service.isDownloaded('adhkar_morning'), isFalse);
      expect(service.getLocalAudioPath('adhkar_morning'), isNull);
      expect(service.getDownloadedTracks(), isEmpty);
      expect(service.totalDownloadedBytes, equals(0));
      expect(service.formattedTotalDownloadedStorage, equals('0 MB'));
    });

    test('getTracksByType accurately filters catalog', () {
      final service = IslamicAudioService.instance;
      final adhans = service.getTracksByType(IslamicAudioType.adhan);
      expect(adhans.every((t) => t.type == IslamicAudioType.adhan), isTrue);

      final iqamahs = service.getTracksByType(IslamicAudioType.iqamah);
      expect(iqamahs.every((t) => t.type == IslamicAudioType.iqamah), isTrue);

      final adhkars = service.getTracksByType(IslamicAudioType.adhkar);
      expect(adhkars.every((t) => t.type == IslamicAudioType.adhkar), isTrue);
    });

    test('Initial playback states are clean and default', () {
      final service = IslamicAudioService.instance;
      expect(service.isPlaying, isFalse);
      expect(service.isBuffering, isFalse);
      expect(service.playbackSpeed, equals(1.0));
      expect(service.position, equals(Duration.zero));
    });
  });

  group('PrayerNotificationService Audio & Iqamah Preferences Tests', () {
    test('setSelectedAdhanVoice persists selection in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.init();

      await notif.setSelectedAdhanVoice('adhan_cairo');
      expect(notif.selectedAdhanVoice, 'adhan_cairo');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('notif_selected_adhan'), 'adhan_cairo');
    });

    test('toggleIqamahReminder and setIqamahOffset persist values', () async {
      final notif = PrayerNotificationService.instance;
      await notif.init();

      await notif.toggleIqamahReminder(true);
      await notif.setIqamahOffset(20);

      expect(notif.iqamahReminderEnabled, isTrue);
      expect(notif.iqamahOffsetMinutes, 20);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_iqamah_enabled'), isTrue);
      expect(prefs.getInt('notif_iqamah_offset'), 20);
    });
  });
}
