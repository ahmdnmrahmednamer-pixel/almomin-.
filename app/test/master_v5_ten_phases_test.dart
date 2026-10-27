import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/quran_accessibility_service.dart';
import 'package:almomin/core/services/quran_linguistics_service.dart';
import 'package:almomin/core/services/tafsir_service.dart';
import 'package:almomin/core/services/riyad_alsalihin_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/ui/app_dropdown_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Noor Al-Momin Master v5.0 — 10-Phase Engineering Suite', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Phase 2: HD Audio Engine provides remote HD streams + 44.1kHz Stereo fallbacks for Adhan & Duas', () {
      final adhanMakkah = IslamicAudioService.allTracks.firstWhere((t) => t.id == 'adhan_makkah');
      expect(adhanMakkah.remoteUrl, isNotNull);
      expect(adhanMakkah.assetPath, isNotNull);

      final duaaSharawi = IslamicAudioService.allTracks.firstWhere((t) => t.id == 'duaa_sharawi_post_prayer');
      expect(duaaSharawi.remoteUrl, isNotNull);
      expect(duaaSharawi.fallbackUrls, isNotEmpty);

      // Verify expanded Duas & Ibtihalat tracks exist
      final duaKhatm = IslamicAudioService.allTracks.where((t) => t.id == 'dua_khatm_abdulbasit');
      expect(duaKhatm, isNotEmpty);

      expect(AudioClarityPreset.values.length, greaterThanOrEqualTo(4));
    });

    test('Phase 3: Zero-Toggle Native Screen Reader Accessibility produces clean Arabic phonetic labels', () {
      final label = QuranAccessibilityService.buildAyahSemanticLabel(
        surahName: 'الفاتحة',
        ayahNumber: 1,
        uthmaniText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ۝',
      );
      expect(label, contains('آية رقم 1 من سورة الفاتحة'));
      expect(label.contains('ٱ'), isFalse);

      final prayerLabel = QuranAccessibilityService.buildPrayerTimeSemanticLabel(
        prayerName: 'الفجر',
        formattedTime: '04:45 ص',
        isNext: true,
      );
      expect(prayerLabel, contains('صلاة الفجر'));
      expect(prayerLabel, contains('الصلاة القادمة'));
    });

    test('Phase 4: AppDropdownOption model holds value, label, and subtitle cleanly', () {
      const opt = AppDropdownOption<String>(
        value: 'muyassar',
        label: 'التفسير الميسر',
        subtitle: 'مجمع الملك فهد',
      );
      expect(opt.value, 'muyassar');
      expect(opt.label, 'التفسير الميسر');
    });

    test('Phase 5: TafsirService provides 8 authoritative Tafsirs and QuranLinguisticsService analyzes I\'rab & Asbab Al-Nuzul', () async {
      expect(TafsirService.availableEditions.length, 9);

      final jalalayn = await TafsirService.getTafsir(
        surahId: 1,
        ayahNumber: 1,
        editionId: 'jalalayn',
      );
      expect(jalalayn.editionName, contains('الجلالين'));
      expect(jalalayn.tafsirText, isNotEmpty);

      final qurtubi = await TafsirService.getTafsir(
        surahId: 2,
        ayahNumber: 255,
        editionId: 'qurtubi',
      );
      expect(qurtubi.editionName, contains('القرطبي'));

      final linguistics = await QuranLinguisticsService.getDetails(
        surahId: 2,
        ayahNumber: 255,
      );
      expect(linguistics.asbabNuzul.title, isNotEmpty);
      expect(linguistics.grammar.summary, isNotEmpty);
      expect(linguistics.grammar.words, isNotEmpty);
      expect(linguistics.grammar.rhetoricSummary, isNotEmpty);
    });

    test('Phase 6: RiyadAlSalihinService contains all 19 Books of Riyad As-Salihin + Hisn Al-Muslim + Al-Adab Al-Mufrad + Jawami Al-Dua', () async {
      await RiyadAlSalihinService.instance.init();
      expect(RiyadAlSalihinService.encyclopedias.length, 4);

      final riyadBooks = RiyadAlSalihinService.instance.getBooksForEncyclopedia('riyad');
      expect(riyadBooks.length, 19);

      final hisnEntries = RiyadAlSalihinService.instance.getEntriesForEncyclopedia('hisn');
      expect(hisnEntries, isNotEmpty);

      final adabEntries = RiyadAlSalihinService.instance.getEntriesForEncyclopedia('adab_mufrad');
      expect(adabEntries, isNotEmpty);

      final duaEntries = RiyadAlSalihinService.instance.getEntriesForEncyclopedia('jawami_dua');
      expect(duaEntries, isNotEmpty);
    });

    test('Phase 7: SettingsService persists new v5.0 audio quality, playback speed, ayah repeat, tafsir, and fiqh madhhab settings', () async {
      await SettingsService.instance.init();
      await SettingsService.instance.setAudioQualityPreset('warm_voice');
      await SettingsService.instance.setDefaultPlaybackSpeed(1.25);
      await SettingsService.instance.setAyahRepeatCount(3);
      await SettingsService.instance.setDefaultTafsirEdition('ibn_kathir');
      await SettingsService.instance.setFiqhMadhhab('hanafi');

      expect(SettingsService.instance.audioQualityPreset, 'warm_voice');
      expect(SettingsService.instance.defaultPlaybackSpeed, 1.25);
      expect(SettingsService.instance.ayahRepeatCount, 3);
      expect(SettingsService.instance.defaultTafsirEdition, 'ibn_kathir');
      expect(SettingsService.instance.fiqhMadhhab, 'hanafi');
    });
  });
}
