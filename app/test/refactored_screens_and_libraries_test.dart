import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/ui/adaptive_screen_layouts.dart';
import 'package:almomin/core/services/fiqh_library_service.dart';
import 'package:almomin/core/services/quran_sciences_service.dart';
import 'package:almomin/core/services/asma_allah_shamail_service.dart';
import 'package:almomin/core/services/islamic_history_service.dart';
import 'package:almomin/core/services/daily_wird_service.dart';
import 'package:almomin/core/services/unified_library_search_service.dart';
import 'package:almomin/features/library/screens/fiqh_library_screen.dart';
import 'package:almomin/features/library/screens/quran_sciences_screen.dart';
import 'package:almomin/features/library/screens/asma_allah_shamail_screen.dart';
import 'package:almomin/features/library/screens/islamic_history_screen.dart';
import 'package:almomin/features/library/screens/unified_library_search_screen.dart';
import 'package:almomin/features/wird/daily_wird_screen.dart';
import 'package:almomin/features/studio/daawah_card_studio_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await FiqhLibraryService.instance.init(forceReload: true);
    await DailyWirdService.instance.init(forceReload: true);
  });

  group('Expanded Libraries & Unified Search Services Tests', () {
    test('FiqhLibraryService provides 4-Madhhab comparative topics across 6 chapters', () {
      final service = FiqhLibraryService.instance;
      expect(service.chapters.length, equals(7)); // الكل + 6 chapters
      expect(FiqhLibraryService.topics.length, greaterThanOrEqualTo(8));

      final wuduResults = service.searchTopics('الوضوء');
      expect(wuduResults.isNotEmpty, isTrue);
      expect(wuduResults.first.madhahibComparison.length, equals(4));
    });

    test('QuranSciencesService provides Asbab Al-Nuzul, Makki/Madani, and Virtues', () {
      final service = QuranSciencesService.instance;
      expect(QuranSciencesService.entries.length, greaterThanOrEqualTo(8));
      final duha = service.searchEntries('الضحى');
      expect(duha.isNotEmpty, isTrue);
    });

    test('AsmaAllahShamailService provides Names of Allah and Prophetic Shamail', () {
      final service = AsmaAllahShamailService.instance;
      expect(AsmaAllahShamailService.asmaAllahList.length, greaterThanOrEqualTo(8));
      expect(AsmaAllahShamailService.shamailList.length, greaterThanOrEqualTo(4));
      expect(service.searchAsma('الرحمن').isNotEmpty, isTrue);
      expect(service.searchShamail('وجهه').isNotEmpty, isTrue);
    });

    test('IslamicHistoryService provides Seerah, Companions, and Scholars', () {
      final service = IslamicHistoryService.instance;
      expect(IslamicHistoryService.entries.length, greaterThanOrEqualTo(5));
      expect(service.searchEntries('الليث').isNotEmpty, isTrue);
    });

    test('DailyWirdService tracks tasks, completion ratio, and reward points', () async {
      final service = DailyWirdService.instance;
      expect(service.getTodayCompletionRatio(), equals(0.0));
      await service.toggleTask('wird_fajr_sunnah');
      expect(service.isCompleted('wird_fajr_sunnah'), isTrue);
      expect(service.getTodayPoints(), equals(20));
      expect(service.getTodayCompletionRatio(), greaterThan(0.0));
    });

    test('UnifiedLibrarySearchService searches across all 10 libraries simultaneously', () {
      final results = UnifiedLibrarySearchService.instance.searchAllLibraries('الصلاة');
      expect(results.isNotEmpty, isTrue);
      final librariesFound = results.map((r) => r.libraryName).toSet();
      expect(librariesFound.length, greaterThanOrEqualTo(2));
    });
  });

  group('Multi-Mode Adaptive Screen Structure Widget Tests', () {
    testWidgets('AdaptiveStructuredCollectionView switches between Classic, Bento, Magazine, and Compact modes',
        (WidgetTester tester) async {
      final items = [
        StructuredScreenItem(
          id: 'item_1',
          title: 'موسوعة الفقه المقارن',
          subtitle: 'أحكام الطهارة والصلاة',
          badgeText: 'فقه',
          icon: Icons.balance_rounded,
          accentColor: Colors.teal,
          onTap: () {},
        ),
        StructuredScreenItem(
          id: 'item_2',
          title: 'مكتبة علوم القرآن',
          subtitle: 'أسباب النزول والمكي والمدني',
          badgeText: 'قرآن',
          icon: Icons.menu_book_rounded,
          accentColor: Colors.green,
          onTap: () {},
        ),
      ];

      for (final mode in ScreenStructureMode.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdaptiveStructuredCollectionView(
                  mode: mode,
                  items: items,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('موسوعة الفقه المقارن'), findsOneWidget);
        expect(find.text('مكتبة علوم القرآن'), findsOneWidget);
      }
    });

    testWidgets('New library screens and DailyWirdScreen render cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: FiqhLibraryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('موسوعة الفقه الميسر والمذاهب الأربعة'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: QuranSciencesScreen()));
      await tester.pumpAndSettle();
      expect(find.text('مكتبة علوم القرآن وأسباب النزول'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: AsmaAllahShamailScreen()));
      await tester.pumpAndSettle();
      expect(find.text('أسماء الله الحسنى والشمائل المحمدية'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: IslamicHistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('مكتبة التاريخ الإسلامي والسيرة والأعلام'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: UnifiedLibrarySearchScreen()));
      await tester.pumpAndSettle();
      expect(find.text('البحث الموسوعي الشامل في جميع المكتبات'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: DailyWirdScreen()));
      await tester.pumpAndSettle();
      expect(find.text('الورد اليومي الذكي وخطة الطاعات'), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: DaawahCardStudioScreen()));
      await tester.pumpAndSettle();
      expect(find.text('استوديو تصميم البطاقات الدعوية'), findsOneWidget);
    });
  });
}
