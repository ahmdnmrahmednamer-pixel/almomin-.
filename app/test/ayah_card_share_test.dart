import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/surah.dart';
import 'package:almomin/core/models/ayah.dart';
import 'package:almomin/core/services/ayah_card_service.dart';
import 'package:almomin/features/mushaf/widgets/ayah_card_widget.dart';
import 'package:almomin/features/mushaf/widgets/ayah_card_share_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

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

  group('AyahCardService & Themes Unit Tests (FR-QUR-007)', () {
    test('Verifies 4 distinct Islamic themes and fallback', () {
      expect(AyahCardTheme.availableThemes.length, 4);

      final emerald = AyahCardTheme.getTheme(AyahCardThemeId.emerald);
      expect(emerald.nameAr, 'الفجر الزمردي');
      expect(emerald.borderColor, const Color(0xFFD4AF37));

      final midnight = AyahCardTheme.getTheme(AyahCardThemeId.midnight);
      expect(midnight.nameAr, 'الليل الساجي');

      final sepia = AyahCardTheme.getTheme(AyahCardThemeId.sepia);
      expect(sepia.nameAr, 'المصحف العتيق');

      final royal = AyahCardTheme.getTheme(AyahCardThemeId.royal);
      expect(royal.nameAr, 'الأزرق الملكي');
    });

    test('formatShareCaption produces verified text with dedication to Mo\'men Ibrahim', () {
      final caption = AyahCardService.formatShareCaption(
        surah: testSurah,
        ayah: testAyah,
        tafsirText: 'قل هو الله المستحق للعبادة وحده لا شريك له.',
      );

      expect(caption.contains('قُلْ هُوَ اللَّهُ أَحَدٌ'), isTrue);
      expect(caption.contains('سورة الإخلاص'), isTrue);
      expect(caption.contains('الآية 1'), isTrue);
      expect(caption.contains('التفسير الميسر'), isTrue);
      expect(caption.contains('تطبيق نور المؤمن'), isTrue);
    });

    test('saveCardImageFile writes PNG bytes to temp file safely', () async {
      final dummyBytes = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]); // PNG magic bytes
      final file = await AyahCardService.saveCardImageFile(
        dummyBytes,
        surahId: 112,
        ayahNumber: 1,
      );

      expect(file.path.endsWith('.png'), isTrue);
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), dummyBytes);
    });
  });

  group('AyahIslamicCardWidget Rendering Tests', () {
    testWidgets('Renders card with header, ayah text, and charity dedication', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AyahIslamicCardWidget(
                surah: testSurah,
                ayah: testAyah,
                theme: AyahCardTheme.availableThemes[0],
                includeTafsir: true,
                includeSurahHeader: true,
                includeDedication: true,
                tafsirText: 'الله واحد أحد لا شريك له.',
              ),
            ),
          ),
        ),
      );

      expect(find.text('سورة الإخلاص'), findsOneWidget);
      expect(find.text('﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾'), findsOneWidget);
      expect(find.text('التفسير الميسر'), findsOneWidget);
      expect(find.text('الله واحد أحد لا شريك له.'), findsOneWidget);
      expect(find.text('مؤمن إبراهيم (رحمهُ الله)'), findsOneWidget);
      expect(find.text('إهداء ودعاء بالرحمة والمغفرة للمرحوم'), findsOneWidget);
    });

    testWidgets('Respects toggles to hide tafsir, header, or dedication', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AyahIslamicCardWidget(
                surah: testSurah,
                ayah: testAyah,
                theme: AyahCardTheme.availableThemes[1],
                includeTafsir: false,
                includeSurahHeader: false,
                includeDedication: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('سورة الإخلاص'), findsNothing);
      expect(find.text('﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾'), findsOneWidget);
      expect(find.text('التفسير الميسر'), findsNothing);
      expect(find.text('مؤمن إبراهيم (رحمهُ الله)'), findsNothing);
    });
  });

  group('AyahCardShareSheet Widget Interaction Tests', () {
    testWidgets('Renders AyahCardShareSheet with theme options, switches, and buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AyahCardShareSheet(
              surah: testSurah,
              ayah: testAyah,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تصميم بطاقة الآية الدعوية'), findsOneWidget);
      expect(find.text('معاينة البطاقة:'), findsOneWidget);
      expect(find.text('الفجر الزمردي'), findsOneWidget);
      expect(find.text('الليل الساجي'), findsOneWidget);
      expect(find.text('المصحف العتيق'), findsOneWidget);
      expect(find.text('الأزرق الملكي'), findsOneWidget);
      expect(find.text('صغير'), findsOneWidget);
      expect(find.text('متوسط'), findsOneWidget);
      expect(find.text('كبير'), findsOneWidget);
      expect(find.text('مشاركة البطاقة كصورة'), findsOneWidget);
      expect(find.text('نسخ'), findsOneWidget);

      // Tap on a theme chip
      await tester.tap(find.text('الليل الساجي'));
      await tester.pumpAndSettle();

      // Tap on font size option
      await tester.tap(find.text('كبير'));
      await tester.pumpAndSettle();

      // Tap on copy button
      await tester.tap(find.text('نسخ'));
      await tester.pumpAndSettle();
      expect(find.text('تم نسخ نص الآية الكريمة والتفسير بنجاح'), findsOneWidget);
    });
  });
}
