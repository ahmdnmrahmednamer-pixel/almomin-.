import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/quran_search_service.dart';
import 'package:almomin/features/search/quran_search_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranSearchService Unit Tests (FR-SRC-001..004)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('parses standard colon reference (e.g. 2:255)', () async {
      final match = await QuranSearchService.instance.parseReference('2:255');
      expect(match, isNotNull);
      expect(match!.surahId, 2);
      expect(match.ayahNumber, 255);
      expect(match.title, contains('البقرة'));
    });

    test('parses Arabic-Indic colon reference (e.g. ٢:٢٥٥)', () async {
      final match = await QuranSearchService.instance.parseReference('٢:٢٥٥');
      expect(match, isNotNull);
      expect(match!.surahId, 2);
      expect(match.ayahNumber, 255);
    });

    test('parses Surah name with ayah number (e.g. البقرة 255)', () async {
      final match = await QuranSearchService.instance.parseReference('البقرة 255');
      expect(match, isNotNull);
      expect(match!.surahId, 2);
      expect(match.ayahNumber, 255);
    });

    test('parses Surah name with prefix (e.g. سورة الكهف 10)', () async {
      final match = await QuranSearchService.instance.parseReference('سورة الكهف 10');
      expect(match, isNotNull);
      expect(match!.surahId, 18);
      expect(match.ayahNumber, 10);
    });

    test('resolves popular Islamic aliases (آية الكرسي, خواتيم البقرة, آية الدين)', () async {
      final matchKursi = await QuranSearchService.instance.parseReference('آية الكرسي');
      expect(matchKursi, isNotNull);
      expect(matchKursi!.surahId, 2);
      expect(matchKursi.ayahNumber, 255);

      final matchDayn = await QuranSearchService.instance.parseReference('آية الدين');
      expect(matchDayn, isNotNull);
      expect(matchDayn!.surahId, 2);
      expect(matchDayn.ayahNumber, 282);

      final matchKhawateem = await QuranSearchService.instance.parseReference('خواتيم البقرة');
      expect(matchKhawateem, isNotNull);
      expect(matchKhawateem!.surahId, 2);
      expect(matchKhawateem.ayahNumber, 285);
    });

    test('returns null for generic non-reference text', () async {
      final match = await QuranSearchService.instance.parseReference('الصبر جميل');
      expect(match, isNull);
    });

    test('search history add, remove, and clear operations', () async {
      await QuranSearchService.instance.clearHistory();

      await QuranSearchService.instance.addToHistory('الله نور السماوات');
      await QuranSearchService.instance.addToHistory('الرحمن الرحيم');

      var history = await QuranSearchService.instance.getSearchHistory();
      expect(history, contains('الرحمن الرحيم'));
      expect(history, contains('الله نور السماوات'));

      await QuranSearchService.instance.removeFromHistory('الرحمن الرحيم');
      history = await QuranSearchService.instance.getSearchHistory();
      expect(history.contains('الرحمن الرحيم'), isFalse);

      await QuranSearchService.instance.clearHistory();
      // Defaults to fallback list when empty
      history = await QuranSearchService.instance.getSearchHistory();
      expect(history.isNotEmpty, isTrue);
    });

    testWidgets('Renders QuranSearchScreen with search input, chips, and history', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: QuranSearchScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check Appbar and Search field
      expect(find.text('البحث في القرآن الكريم'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Check Scope Chips
      expect(find.text('الكل'), findsOneWidget);
      expect(find.textContaining('الآيات'), findsWidgets);
      expect(find.textContaining('السور'), findsWidgets);

      // Check Suggested searches
      expect(find.text('عمليات بحث مقترحة'), findsOneWidget);
      expect(find.text('آية الكرسي'), findsWidgets);
    });
  });
}
