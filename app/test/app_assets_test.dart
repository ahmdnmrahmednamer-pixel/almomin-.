import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/app/theme/app_assets.dart';

void main() {
  group('Al-Momin AppAssets Tests (Assets Inventory & Prayer Mapping)', () {
    test('All registered assets in AppAssets exist on disk in assets/images/', () {
      final allAssets = AppAssets.allAssets;
      expect(allAssets.isNotEmpty, isTrue);

      for (final assetPath in allAssets) {
        // Strip leading assets/ to test local path relative to app/
        final file = File(assetPath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Expected asset file to exist at $assetPath',
        );
      }
    });

    test('backgroundForPrayer maps correctly for all prayer names', () {
      expect(AppAssets.backgroundForPrayer('fajr'), AppAssets.bgPrayerFajr);
      expect(AppAssets.backgroundForPrayer('Fajr'), AppAssets.bgPrayerFajr);
      expect(AppAssets.backgroundForPrayer('الفجر'), AppAssets.bgPrayerFajr);

      expect(AppAssets.backgroundForPrayer('dhuhr'), AppAssets.bgPrayerDhuhr);
      expect(AppAssets.backgroundForPrayer('الظهر'), AppAssets.bgPrayerDhuhr);

      expect(AppAssets.backgroundForPrayer('asr'), AppAssets.bgPrayerAsr);
      expect(AppAssets.backgroundForPrayer('العصر'), AppAssets.bgPrayerAsr);

      expect(AppAssets.backgroundForPrayer('maghrib'), AppAssets.bgPrayerMaghrib);
      expect(AppAssets.backgroundForPrayer('المغرب'), AppAssets.bgPrayerMaghrib);

      expect(AppAssets.backgroundForPrayer('isha'), AppAssets.bgPrayerIsha);
      expect(AppAssets.backgroundForPrayer('العشاء'), AppAssets.bgPrayerIsha);

      // Unknown fallback
      expect(AppAssets.backgroundForPrayer('unknown_prayer'), AppAssets.bgHomeHeaderBanner);
    });

    test('AppAssets categories contain expected counts', () {
      expect(AppAssets.backgrounds.length, 12);
      expect(AppAssets.patterns.length, 2);
      expect(AppAssets.brand.length, 3);
      expect(AppAssets.occasions.length, 4);
      expect(AppAssets.shareBackgrounds.length, 6);
      expect(AppAssets.allAssets.length, 27);
    });
  });
}
