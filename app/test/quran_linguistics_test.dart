import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/surah.dart';
import 'package:almomin/core/models/ayah.dart';
import 'package:almomin/core/services/quran_repository.dart';
import 'package:almomin/core/services/quran_linguistics_service.dart';
import 'package:almomin/features/mushaf/widgets/ayah_linguistics_sheet.dart';
import 'package:almomin/features/mushaf/widgets/ayah_action_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('QuranLinguisticsService Unit Tests (FR-QUR-005 & FR-QUR-006)', () {
    test('Resolves specific authentic Asbab al-Nuzul for Surat Al-Ikhlas', () async {
      final res = await QuranLinguisticsService.getDetails(surahId: 112, ayahNumber: 1);

      expect(res.asbabNuzul.hasSpecificIncident, isTrue);
      expect(res.asbabNuzul.title.contains('نسب الله'), isTrue);
      expect(res.asbabNuzul.source.contains('الترمذي') || res.asbabNuzul.source.contains('أحمد'), isTrue);
      expect(res.asbabNuzul.narration.contains('انسب لنا ربك'), isTrue);
    });

    test('Resolves specific authentic Asbab al-Nuzul for Surat Al-Kawthar and Al-Masad', () async {
      final kawthar = await QuranLinguisticsService.getDetails(surahId: 108, ayahNumber: 1);
      expect(kawthar.asbabNuzul.hasSpecificIncident, isTrue);
      expect(kawthar.asbabNuzul.narration.contains('العاص بن وائل') || kawthar.asbabNuzul.narration.contains('أبتر'), isTrue);

      final masad = await QuranLinguisticsService.getDetails(surahId: 111, ayahNumber: 1);
      expect(masad.asbabNuzul.hasSpecificIncident, isTrue);
      expect(masad.asbabNuzul.narration.contains('الصفا') || masad.asbabNuzul.narration.contains('أبي لهب'), isTrue);
    });

    test('Provides classical Ghareeb vocabulary dictionary meanings', () async {
      final res = await QuranLinguisticsService.getDetails(surahId: 112, ayahNumber: 2);
      // Contains ﴿الصمد﴾
      final hasSamad = res.wordMeanings.any((w) => w.word == 'الصمد');
      expect(hasSamad, isTrue);

      final samadMeaning = res.wordMeanings.firstWhere((w) => w.word == 'الصمد');
      expect(samadMeaning.meaning.contains('يُصمد إليه في الحوائج'), isTrue);
    });

    test('Resolves foundational scholarly rule for ayahs without specific historical incident', () async {
      // Surah 18, Ayah 10 (or general ayah)
      final res = await QuranLinguisticsService.getDetails(surahId: 18, ayahNumber: 10);
      expect(res.asbabNuzul.narration.contains('النزول') || res.asbabNuzul.narration.contains('تشريعاً'), isTrue);
    });

    test('Formats linguistics results for share and copy per FR-QUR-006', () async {
      final res = await QuranLinguisticsService.getDetails(surahId: 112, ayahNumber: 1);
      final shareText = res.formatForShare('الإخلاص');

      expect(shareText.contains('سورة الإخلاص'), isTrue);
      expect(shareText.contains('سبب النزول'), isTrue);
      expect(shareText.contains('الإعراب والدلالة النحوية'), isTrue);
      expect(shareText.contains('تطبيق نور المؤمن'), isTrue);
    });
  });

  group('AyahLinguisticsSheet & AyahActionSheet Widget Tests', () {
    const testSurah = Surah(
      id: 112,
      nameAr: 'الإخلاص',
      nameSimple: 'Al-Ikhlas',
      revelationPlace: 'makkah',
      revelationOrder: 22,
      ayahCount: 4,
      hasBasmala: true,
      pageStart: 604,
      pageEnd: 604,
    );

    const testAyah = Ayah(
      id: 6222,
      surahId: 112,
      ayahNumber: 1,
      juz: 30,
      hizb: 60,
      rub: 240,
      page: 604,
      sajdah: 0,
      textUthmani: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      textImlaei: 'قل هو الله أحد',
      textSearch: 'قل هو الله احد',
    );

    testWidgets('Renders AyahLinguisticsSheet with 3 tabs and displays content', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AyahLinguisticsSheet(
              surah: testSurah,
              ayah: testAyah,
              initialTabIndex: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header and Tabs
      expect(find.text('سورة الإخلاص — آية ١'), findsOneWidget);
      expect(find.text('معاني الكلمات'), findsOneWidget);
      expect(find.text('أسباب النزول'), findsOneWidget);
      expect(find.text('إعراب الآية'), findsOneWidget);

      // Switch to Asbab al-Nuzul Tab
      await tester.tap(find.text('أسباب النزول'));
      await tester.pumpAndSettle();

      expect(find.text('سؤال المشركين عن نسب الله وصفته'), findsOneWidget);

      // Switch to I'rab Tab
      await tester.tap(find.text('إعراب الآية'));
      await tester.pumpAndSettle();

      expect(find.text('الإعراب الإجمالي للآية:'), findsOneWidget);
    });

    testWidgets('AyahActionSheet includes dedicated buttons for Meanings, Asbab, and Irab', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AyahActionSheet(
              surah: testSurah,
              ayah: testAyah,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('معاني الكلمات'), findsOneWidget);
      expect(find.text('أسباب النزول'), findsOneWidget);
      expect(find.text('إعراب الآية'), findsOneWidget);
      expect(find.text('التفسير والشروح'), findsOneWidget);
    });
  });
}
