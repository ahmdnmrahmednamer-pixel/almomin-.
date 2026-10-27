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
    test('generates accurate EveryAyah URLs for default (Minshawi) and chosen reciters', () async {
      final settings = SettingsService.instance;

      // Default reciter is Sheikh Al-Minshawi
      expect(settings.selectedReciterId, equals('minshawi_murattal'));
      expect(settings.currentReciter.nameAr, contains('المنشاوي'));

      final url1 = settings.getAyahAudioUrl(1, 1);
      expect(url1, 'https://everyayah.com/data/Minshawy_Murattal_128kbps/001001.mp3');

      final urlBaqarah = settings.getAyahAudioUrl(2, 255);
      expect(urlBaqarah, 'https://everyayah.com/data/Minshawy_Murattal_128kbps/002255.mp3');

      // User changes to another reciter (e.g. Alafasy)
      await settings.setSelectedReciter('alafasy');
      expect(settings.selectedReciterId, equals('alafasy'));
      expect(settings.getAyahAudioUrl(1, 1), 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3');

      // Revert back to Minshawi as default
      await settings.setSelectedReciter('minshawi_murattal');
      expect(settings.selectedReciterId, equals('minshawi_murattal'));
    });
  });
}
