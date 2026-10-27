import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/hadith.dart';
import 'package:almomin/core/services/hadith_service.dart';
import 'package:almomin/core/services/hadith_data.dart';
import 'package:almomin/features/hadith/hadith_library_screen.dart';
import 'package:almomin/features/hadith/hadith_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await HadithService.instance.init();
  });

  group('Hadith Model & Catalog Integrity (FR-LIB-005)', () {
    test('Verifies catalog has valid books with required metadata', () {
      final books = HadithService.instance.books;
      expect(books.length, greaterThanOrEqualTo(2));

      final nawawi = books.firstWhere((b) => b.id == 'nawawi40');
      expect(nawawi.title, 'الأربعون النووية');
      expect(nawawi.author, contains('النووي'));
      expect(nawawi.hadithCount, 42);

      final riyadh = books.firstWhere((b) => b.id == 'riyadh');
      expect(riyadh.title, contains('رياض الصالحين'));
      expect(riyadh.hadithCount, greaterThan(0));
    });

    test('Verifies all 42 hadiths of Al-Nawawiyyah are present and complete', () {
      final nawawiHadiths = HadithService.instance.getHadithsByBook('nawawi40');
      expect(nawawiHadiths.length, 42);

      for (int i = 1; i <= 42; i++) {
        final h = nawawiHadiths.firstWhere((item) => item.number == i);
        expect(h.title.isNotEmpty, isTrue, reason: 'Hadith #$i must have title');
        expect(h.narrator.isNotEmpty, isTrue, reason: 'Hadith #$i must have narrator');
        expect(h.matn.isNotEmpty, isTrue, reason: 'Hadith #$i must have matn');
        expect(h.grading.isNotEmpty, isTrue, reason: 'Hadith #$i must have grading');
        expect(h.source.isNotEmpty, isTrue, reason: 'Hadith #$i must have source');
        expect(h.explanation.isNotEmpty, isTrue, reason: 'Hadith #$i must have explanation');
      }
    });

    test('Verifies hadith IDs are globally unique', () {
      final allHadiths = HadithService.instance.allHadiths;
      final ids = allHadiths.map((h) => h.id).toSet();
      expect(ids.length, allHadiths.length);
    });

    test('First Hadith is "الأعمال بالنيات" with full tashkeel and Bukhari/Muslim source', () {
      final h1 = HadithService.instance.getHadithById(1);
      expect(h1, isNotNull);
      expect(h1!.title, 'الأعمال بالنيات');
      expect(h1.matn, contains('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ'));
      expect(h1.grading, 'متفق عليه');
      expect(h1.source, contains('البخاري ومسلم'));
    });
  });

  group('Hadith Search Engine (FR-LIB-003 & Normalization)', () {
    test('Searches by matn ignoring Arabic tashkeel and hamza variants', () {
      // Searching "الاعمال بالنيات" without tashkeel
      final results1 = HadithService.instance.searchHadiths('الاعمال بالنيات');
      expect(results1.isNotEmpty, isTrue);
      expect(results1.first.id, 1);

      // Searching "بني الاسلام على خمس" without tashkeel
      final results2 = HadithService.instance.searchHadiths('بني الاسلام على خمس');
      expect(results2.isNotEmpty, isTrue);
      expect(results2.first.number, 3);
    });

    test('Searches by narrator name', () {
      final results = HadithService.instance.searchHadiths('عمر بن الخطاب');
      expect(results.length, greaterThanOrEqualTo(2));
      expect(results.any((h) => h.id == 1), isTrue);
      expect(results.any((h) => h.id == 2), isTrue);
    });

    test('Searches by topic / chapter keyword', () {
      final results = HadithService.instance.searchHadiths('الزهد');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((h) => h.title.contains('الزهد') || h.chapter.contains('الزهد')), isTrue);
    });

    test('Search filters correctly by bookId', () {
      final riyadhOnly = HadithService.instance.searchHadiths('صدقة', bookId: 'riyadh');
      for (final h in riyadhOnly) {
        expect(h.bookId, 'riyadh');
      }
    });
  });

  group('Hadith of the Day (Deterministic Rotation)', () {
    test('Returns valid hadith deterministically', () {
      final h1 = HadithService.instance.getHadithOfTheDay();
      final h2 = HadithService.instance.getHadithOfTheDay();
      expect(h1.id, h2.id);
      expect(h1.matn.isNotEmpty, isTrue);
    });
  });

  group('Favorites Management & Persistence', () {
    test('Toggles favorites and persists state', () async {
      expect(HadithService.instance.isFavorite(1), isFalse);

      await HadithService.instance.toggleFavorite(1);
      expect(HadithService.instance.isFavorite(1), isTrue);
      expect(HadithService.instance.getFavorites().map((h) => h.id), contains(1));

      // Toggle off
      await HadithService.instance.toggleFavorite(1);
      expect(HadithService.instance.isFavorite(1), isFalse);
    });

    test('Exports and imports favorites for backup & restore round-trip', () async {
      await HadithService.instance.toggleFavorite(2);
      await HadithService.instance.toggleFavorite(3);

      final exported = HadithService.instance.exportFavorites();
      expect(exported, containsAll([2, 3]));

      // Clear
      await HadithService.instance.toggleFavorite(2);
      await HadithService.instance.toggleFavorite(3);
      expect(HadithService.instance.isFavorite(2), isFalse);

      // Import
      await HadithService.instance.importFavorites(exported);
      expect(HadithService.instance.isFavorite(2), isTrue);
      expect(HadithService.instance.isFavorite(3), isTrue);
    });
  });

  group('Share Formatting with Sadaqa Jariya Dedication', () {
    test('Formats share text with full hadith and dedication to مؤمن إبراهيم رحمه الله', () {
      final h = HadithService.instance.getHadithById(1)!;
      final text = HadithService.instance.formatShareText(h);

      expect(text, contains('قال رسول الله ﷺ:'));
      expect(text, contains(h.matn));
      expect(text, contains(h.source));
      expect(text, contains(h.grading));
      expect(text, contains('تطبيق نور المؤمن'));
    });
  });

  group('Hadith UI Widgets Rendering', () {
    testWidgets('Renders HadithLibraryScreen with tabs and search bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HadithLibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مكتبة الأحاديث النبوية الشريفة'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('الأربعون النووية'), findsOneWidget);
      expect(find.textContaining('رياض الصالحين'), findsOneWidget);
      expect(find.textContaining('المفضلة'), findsOneWidget);
      expect(find.text('الأعمال بالنيات'), findsOneWidget);
    });

    testWidgets('Renders HadithDetailScreen with matn, grading, and dedication', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: HadithDetailScreen(hadithId: 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الأعمال بالنيات'), findsOneWidget);
      expect(find.textContaining('إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ'), findsOneWidget);
      expect(find.text('متفق عليه'), findsOneWidget);
      expect(find.text('فوائد وشرح الحديث'), findsOneWidget);
      expect(find.text('مُؤْمِن إِبْرَاهِيم'), findsOneWidget);
    });
  });
}
