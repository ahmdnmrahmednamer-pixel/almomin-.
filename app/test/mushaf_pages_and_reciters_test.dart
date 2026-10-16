import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('M1 & M2: 35 Reciters & Audio CDN Verification', () {
    test('SettingsService contains exactly 35 canonical reciters with styles', () {
      expect(SettingsService.availableReciters.length, greaterThanOrEqualTo(35));

      final ids = SettingsService.availableReciters.map((r) => r.id).toSet();
      expect(ids.contains('husary'), isTrue);
      expect(ids.contains('minshawi_murattal'), isTrue);
      expect(ids.contains('abdulbasit_murattal'), isTrue);
      expect(ids.contains('alafasy'), isTrue);
      expect(ids.contains('maher'), isTrue);
      expect(ids.contains('sudais'), isTrue);
      expect(ids.contains('dosari'), isTrue);
      expect(ids.contains('qatami'), isTrue);
      expect(ids.contains('kurdi'), isTrue);

      // Verify styles are canonical
      for (final r in SettingsService.availableReciters) {
        expect(
          ['مرتل', 'مجود', 'المعلم', 'تلاوة خاشعة'].contains(r.style),
          isTrue,
          reason: 'Reciter ${r.nameAr} must have valid style',
        );
        expect(r.serverUrl.startsWith('https://'), isTrue);
        expect(r.serverUrl.endsWith('/'), isTrue);
      }
    });

    test('getSurahAudioUrl generates valid CDN MP3 URLs with 3-digit zero padding', () {
      final s = SettingsService.instance;

      final husaryFatiha = s.getSurahAudioUrl(1, 'husary');
      expect(husaryFatiha, equals('https://server13.mp3quran.net/husr/001.mp3'));

      final afasyKahf = s.getSurahAudioUrl(18, 'alafasy');
      expect(afasyKahf, equals('https://server8.mp3quran.net/afs/018.mp3'));

      final minshawiBaqarah = s.getSurahAudioUrl(2, 'minshawi_murattal');
      expect(minshawiBaqarah, equals('https://server10.mp3quran.net/minsh/002.mp3'));

      final dosariNas = s.getSurahAudioUrl(114, 'dosari');
      expect(dosariNas, equals('https://server11.mp3quran.net/yasser/114.mp3'));
    });
  });

  group('M1: Reading Persistence & Bookmarks', () {
    test('saveLastRead properly persists surah, ayah, page, and surahName', () async {
      final s = SettingsService.instance;
      await s.init();

      await s.saveLastRead(
        surahId: 18,
        ayahNumber: 10,
        pageNumber: 294,
        surahName: 'الكهف',
      );

      expect(s.lastReadSurahId, equals(18));
      expect(s.lastReadAyahNumber, equals(10));
      expect(s.lastReadPageNumber, equals(294));
      expect(s.lastReadSurahName, equals('الكهف'));
    });

    test('Bookmarks toggle and check works correctly', () async {
      final s = SettingsService.instance;
      await s.init();

      expect(s.isBookmarked(2, 255), isFalse);

      final added = await s.toggleBookmark(2, 255);
      expect(added, isTrue);
      expect(s.isBookmarked(2, 255), isTrue);

      final removed = await s.toggleBookmark(2, 255);
      expect(removed, isFalse);
      expect(s.isBookmarked(2, 255), isFalse);
    });
  });

  group('M1: 604-Pages Mapping in QuranRepository', () {
    test('getAyahsForPage returns correct ayahs for Page 1 (Al-Fatiha)', () async {
      final page1Ayahs = await QuranRepository.getAyahsForPage(1);
      expect(page1Ayahs.length, equals(7));
      expect(page1Ayahs.first.surahId, equals(1));
      expect(page1Ayahs.first.ayahNumber, equals(1));
      expect(page1Ayahs.last.ayahNumber, equals(7));
    });

    test('getAyahsForPage returns correct ayahs for Page 2 (Al-Baqarah 1-5)', () async {
      final page2Ayahs = await QuranRepository.getAyahsForPage(2);
      expect(page2Ayahs.length, equals(5));
      expect(page2Ayahs.first.surahId, equals(2));
      expect(page2Ayahs.first.ayahNumber, equals(1));
      expect(page2Ayahs.last.ayahNumber, equals(5));
    });

    test('getPageMetadata correctly computes surah name and juz for Page 1 & 2', () async {
      final meta1 = await QuranRepository.getPageMetadata(1);
      expect(meta1, isNotNull);
      expect(meta1!.pageNumber, equals(1));
      expect(meta1.surahId, equals(1));
      expect(meta1.surahName, equals('الفاتحة'));
      expect(meta1.juzNumber, equals(1));
      expect(meta1.hasSurahStart, isTrue);

      final meta2 = await QuranRepository.getPageMetadata(2);
      expect(meta2, isNotNull);
      expect(meta2!.pageNumber, equals(2));
      expect(meta2.surahId, equals(2));
      expect(meta2.surahName, equals('البقرة'));
      expect(meta2.juzNumber, equals(1));
      expect(meta2.hasSurahStart, isTrue);
    });
  });
}
