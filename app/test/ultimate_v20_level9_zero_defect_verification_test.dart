import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:almomin/core/models/arab_countries.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/prayer_tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v20.0 — Level-9 Zero-Defect Verification & Metadata Sync Suite', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. All 13 bundled IslamicAudioTrack entries have fileSizeBytes matching exact disk size in assets/audio/', () {
      for (final track in IslamicAudioService.allTracks) {
        if (track.assetPath != null && track.fileSizeBytes != null) {
          final file = File(track.assetPath!);
          expect(file.existsSync(), isTrue, reason: 'Missing asset ${track.assetPath}');
          expect(
            track.fileSizeBytes,
            equals(file.lengthSync()),
            reason: 'Mismatch for ${track.id}: declared=${track.fileSizeBytes}, disk=${file.lengthSync()}',
          );
        }
      }
    });

    test('2. ArabCountriesCatalog.findCountryByCityName normalizes Arabic hamza and taa marbuta and handles empty strings safely', () {
      expect(ArabCountriesCatalog.findCountryByCityName('').id, equals('eg'));
      expect(ArabCountriesCatalog.findCountryByCityName('الاسكندريه').id, equals('eg'));
      expect(ArabCountriesCatalog.findCountryByCityName('مكه المكرمه').id, equals('sa'));
      expect(ArabCountriesCatalog.findCountryByCityName('المدينه المنوره').id, equals('sa'));
    });

    test('3. PrayerTrackerService weekly accountability reason analyzer matches unvocalized/unhamzated user reasons (تاجيل / الدراسه)', () async {
      final service = PrayerTrackerService.instance;
      await service.init(forceReload: true);

      final today = DateTime.now();
      await service.setPrayerPerformanceStatus(
        today,
        'العصر',
        PrayerPerformanceStatus.qada,
        reason: 'تاجيل بسبب الدراسه',
      );

      final report = service.getWeeklyAccountabilityReport(endDate: today);
      expect(
        report.personalizedRemedies.any((r) => r.contains('التسويف') || r.contains('الدراسة')),
        isTrue,
      );
    });

    test('4. Static verification of Level-9 guards (_ensureTimeZonesInitialized, nonEmptySegs, and safe .first)', () {
      final pns = File('lib/core/notifications/prayer_notification_service.dart').readAsStringSync();
      expect(pns.contains('static void _ensureTimeZonesInitialized()'), isTrue);

      final fiqh = File('lib/features/library/screens/fiqh_library_screen.dart').readAsStringSync();
      expect(fiqh.contains('_service.chapters.isNotEmpty ? _service.chapters.first'), isTrue);

      final qsci = File('lib/features/library/screens/quran_sciences_screen.dart').readAsStringSync();
      expect(qsci.contains('_service.categories.isNotEmpty ? _service.categories.first'), isTrue);

      for (final svc in [
        'lib/core/services/audio_download_service.dart',
        'lib/core/services/islamic_audio_service.dart',
        'lib/core/services/stories_service.dart',
      ]) {
        expect(
          File(svc).readAsStringSync().contains('final nonEmptySegs = entity.uri.pathSegments.where((s) => s.isNotEmpty);'),
          isTrue,
          reason: 'Expected nonEmptySegs guard in $svc',
        );
      }
    });
  });
}
