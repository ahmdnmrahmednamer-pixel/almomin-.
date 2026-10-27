import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/models/surah.dart';
import 'package:almomin/core/services/quran_repository.dart';
import 'package:almomin/core/services/quran_accessibility_service.dart';
import 'package:almomin/features/mushaf/surah_reader_screen.dart';
import 'package:almomin/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testSurahFatihah = Surah(
    id: 1,
    nameAr: 'الفاتحة',
    nameSimple: 'Al-Fatihah',
    revelationPlace: 'makkah',
    revelationOrder: 5,
    ayahCount: 7,
    hasBasmala: true,
    pageStart: 1,
    pageEnd: 1,
  );

  group('QuranAccessibilityService Unit Tests', () {
    test('toScreenReaderText normalizes Waslah Alef, Farsi Yeh, and Quranic Sukun', () {
      const rawUthmani = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ';
      final spoken = QuranAccessibilityService.toScreenReaderText(rawUthmani);

      expect(spoken, isNot(contains('ٱ')));
      expect(spoken, isNot(contains('ی')));
      expect(spoken, isNot(contains('\u06E1')));
      expect(spoken, contains('بِسْمِ'));
      expect(spoken, contains('الرَّحِيمِ'));
    });

    test('toScreenReaderText strips recitation stop signs and zero-width chars', () {
      const textWithRecitationSigns = 'ذَ ٰ⁠لِكَ ٱلۡكِتَـٰبُ لَا رَیۡبَۛ فِیهِۛ هُدࣰى لِّلۡمُتَّقِینَ';
      final spoken = QuranAccessibilityService.toScreenReaderText(textWithRecitationSigns);

      expect(spoken, isNot(contains('ۛ')));
      expect(spoken, isNot(contains('ی')));
      expect(spoken, isNot(contains('ٱ')));
      expect(spoken, contains('لِّلْمُتَّقِينَ'));
    });

    test('buildAyahSemanticLabel returns complete context for TalkBack', () {
      final label = QuranAccessibilityService.buildAyahSemanticLabel(
        surahName: 'الفاتحة',
        ayahNumber: 2,
        uthmaniText: 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَـٰلَمِینَ',
      );

      expect(label, contains('آية رقم 2 من سورة الفاتحة:'));
      expect(label, contains('الْحَمْدُ لِلَّهِ'));
      expect(label, contains('الْعَالَمِينَ'));
    });

    test('buildSurahHeaderSemanticLabel formats surah metadata clearly', () {
      final headerLabel = QuranAccessibilityService.buildSurahHeaderSemanticLabel(
        surahName: 'الفاتحة',
        isMakki: true,
        ayahCount: 7,
        revelationOrder: 5,
      );

      expect(headerLabel, 'سورة الفاتحة، مكية، عدد آياتها 7 آية، ترتيب نزولها 5.');
    });

    test('buildPageSemanticLabel formats page, surah, and juz metadata', () {
      final pageLabel = QuranAccessibilityService.buildPageSemanticLabel(
        pageNumber: 1,
        juz: 1,
        hizb: 1,
        surahName: 'الفاتحة',
      );

      expect(pageLabel, 'صفحة المصحف رقم 1 من 604، سورة الفاتحة، الجزء 1، الحزب 1.');
    });
  });

  group('Zero-Toggle Native Accessibility Widget Verification', () {
    setUp(() async {
      await QuranRepository.getAyahsForSurah(1);
    });

    testWidgets('SurahReaderScreen works natively with screen readers without any manual TalkBack toggle icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SurahReaderScreen(surah: testSurahFatihah),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify zero manual accessibility toggle icon
      expect(find.byIcon(Icons.accessibility_new_rounded), findsNothing);
      // Verify toolbar dropdown for reading display mode is present
      expect(find.text('المصحف المتصل'), findsOneWidget);
    });

    testWidgets('SettingsScreen has zero manual TalkBack optimization switch tile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('تحسين التوافق مع قارئات الشاشة (TalkBack)'), findsNothing);
    });
  });
}
