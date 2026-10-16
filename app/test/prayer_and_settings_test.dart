import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/services/prayer_service.dart';
import 'package:almomin/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HijriDateHelper Tests', () {
    test('converts 2026-10-16 to Hijri accurately (1448-05-04)', () {
      final date = DateTime(2026, 10, 16);
      final hijri = HijriDateHelper.toHijri(date);

      expect(hijri['year'], 1448);
      expect(hijri['month'], 5); // Jumada al-Awwal
      expect(hijri['day'], 4);

      final hijriStr = HijriDateHelper.getHijriDateString(date);
      expect(hijriStr, contains('جمادى الأولى'));
      expect(hijriStr, contains('1448'));

      final gregStr = HijriDateHelper.getGregorianDateString(date);
      expect(gregStr, contains('أكتوبر'));
      expect(gregStr, contains('2026'));

      final dayStr = HijriDateHelper.getDayOfWeek(date);
      expect(dayStr, 'الجمعة');
    });
  });

  group('SettingsService Audio Url Generator Tests', () {
    test('generates accurate EveryAyah URLs for default and chosen reciters', () {
      final settings = SettingsService.instance;

      // Default reciter is Alafasy
      final url1 = settings.getAyahAudioUrl(1, 1);
      expect(url1, 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3');

      final urlBaqarah = settings.getAyahAudioUrl(2, 255);
      expect(urlBaqarah, 'https://everyayah.com/data/Alafasy_128kbps/002255.mp3');
    });
  });
}
