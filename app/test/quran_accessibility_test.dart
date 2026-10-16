import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/models/surah.dart';
import 'package:almomin/core/services/quran_repository.dart';
import 'package:almomin/core/services/quran_accessibility_service.dart';
import 'package:almomin/core/services/settings_service.dart';
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

      expect(spoken, isNot(contains('ٱ'))); // Waslah Alef removed/converted
      expect(spoken, isNot(contains('ی'))); // Farsi Yeh converted to standard Arabic Yeh
      expect(spoken, isNot(contains('\u06E1'))); // Quranic Sukun converted
      expect(spoken, contains('بِسْمِ')); // Contains standard sukun or clean root
      expect(spoken, contains('الرَّحِيمِ'));
    });

    test('toScreenReaderText strips recitation stop signs and zero-width chars', () {
      // Verse containing stop sign (قلي ۗ) and small madda (ۤ)
      const textWithRecitationSigns = 'ذَ ٰ⁠لِكَ ٱلۡكِتَـٰبُ لَا رَیۡبَۛ فِیهِۛ هُدࣰى لِّلۡمُتَّقِینَ';
      final spoken = QuranAccessibilityService.toScreenReaderText(textWithRecitationSigns);

      expect(spoken, isNot(contains('ۛ'))); // Stop mark stripped
      expect(spoken, isNot(contains('ی'))); // Farsi yeh normalized
      expect(spoken, isNot(contains('ٱ'))); // Waslah normalized
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

    test('buildSurahHeaderSemanticLabel formats type and counts', () {
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

  group('SettingsService Screen Reader Preferences', () {
    test('toggleScreenReaderOptimization toggles and notifies listeners', () async {
      await SettingsService.instance.toggleScreenReaderOptimization(true);
      expect(SettingsService.instance.screenReaderOptimized, isTrue);

      await SettingsService.instance.toggleScreenReaderOptimization(false);
      expect(SettingsService.instance.screenReaderOptimized, isFalse);
    });
  });

  group('SurahReaderScreen Accessibility Widget Tests', () {
    setUp(() async {
      await QuranRepository.getAyahsForSurah(1);
    });

    testWidgets('renders accessibility toggle button in AppBar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SurahReaderScreen(surah: testSurahFatihah),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.accessibility_new_rounded), findsOneWidget);
    });

    testWidgets('toggling accessibility button switches to Accessible Ayah List mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SurahReaderScreen(surah: testSurahFatihah),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap accessibility toggle
      final a11yBtn = find.byIcon(Icons.accessibility_new_rounded);
      await tester.tap(a11yBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Banner should appear
      expect(find.textContaining('نمط النفاذية وقارئ الشاشة (TalkBack)'), findsOneWidget);
      expect(find.textContaining('آية ١ / ٧'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill_rounded), findsWidgets);
      expect(find.byIcon(Icons.menu_book_outlined), findsWidgets);
    });

    testWidgets('inline Tafsir toggles visibility when tapping book icon in accessible mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SurahReaderScreen(surah: testSurahFatihah),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to accessible mode
      await tester.tap(find.byIcon(Icons.accessibility_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap first Tafseer button
      final tafseerBtn = find.byIcon(Icons.menu_book_outlined).first;
      await tester.tap(tafseerBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should reveal Tafseer section
      expect(find.text('التفسير الميسر:'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays TalkBack optimization switch tile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final tile = find.text('تحسين التوافق مع قارئات الشاشة (TalkBack)');
      await tester.scrollUntilVisible(tile, 300);
      expect(tile, findsOneWidget);
      expect(find.textContaining('نطق صوتي فصيح للآيات واستبعاد الرموز المشوشة'), findsOneWidget);
    });
  });
}
