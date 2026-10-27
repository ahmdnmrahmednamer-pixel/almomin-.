import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/tajweed_rule.dart';
import 'package:almomin/core/services/tajweed_service.dart';
import 'package:almomin/features/tajweed/tajweed_screen.dart';
import 'package:almomin/features/tajweed/rule_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await TajweedService.instance.init();
  });

  group('TajweedService Unit Tests (FR-TJW-001)', () {
    test('getAllRules returns comprehensive authentic rules covering all categories', () {
      final rules = TajweedService.instance.getAllRules();
      expect(rules.length, greaterThanOrEqualTo(10));

      for (var rule in rules) {
        expect(rule.id.isNotEmpty, isTrue);
        expect(rule.arabicTitle.isNotEmpty, isTrue);
        expect(rule.summary.isNotEmpty, isTrue);
        expect(rule.definition.isNotEmpty, isTrue);
        expect(rule.letters.isNotEmpty, isTrue);
        expect(rule.examples.isNotEmpty, isTrue);
        expect(rule.howToPronounce.isNotEmpty, isTrue);
        expect(rule.categoryName.isNotEmpty, isTrue);
      }

      // Check coverage across categories
      final categories = rules.map((r) => r.category).toSet();
      expect(categories.contains(TajweedCategory.nunTanween), isTrue);
      expect(categories.contains(TajweedCategory.meemSakinah), isTrue);
      expect(categories.contains(TajweedCategory.madd), isTrue);
      expect(categories.contains(TajweedCategory.qalqalah), isTrue);
      expect(categories.contains(TajweedCategory.waqfMarks), isTrue);
      expect(categories.contains(TajweedCategory.raaLaam), isTrue);
      expect(categories.contains(TajweedCategory.makhaarij), isTrue);
    });

    test('getRulesByCategory filters rules correctly', () {
      final nunRules = TajweedService.instance.getRulesByCategory(TajweedCategory.nunTanween);
      expect(nunRules.length, 5); // Izhar, Idgham Ghunnah, Idgham no Ghunnah, Iqlab, Ikhfa
      for (var r in nunRules) {
        expect(r.category, TajweedCategory.nunTanween);
      }

      final meemRules = TajweedService.instance.getRulesByCategory(TajweedCategory.meemSakinah);
      expect(meemRules.length, 3); // Ikhfa Shafawi, Idgham Shafawi, Izhar Shafawi
      for (var r in meemRules) {
        expect(r.category, TajweedCategory.meemSakinah);
      }
    });

    test('searchRules finds rules by title, letter, and ayah snippet', () {
      final searchByTitle = TajweedService.instance.searchRules('الإظهار الحلقي');
      expect(searchByTitle.any((r) => r.id == 'nun_izhar'), isTrue);

      final searchByLetter = TajweedService.instance.searchRules('قطب جد');
      expect(searchByLetter.any((r) => r.id == 'qalqalah_rules'), isTrue);

      final searchEmpty = TajweedService.instance.searchRules('');
      expect(searchEmpty.length, TajweedService.instance.getAllRules().length);
    });

    test('getColorGuide returns complete color items with valid swatches', () {
      final guide = TajweedService.instance.getColorGuide();
      expect(guide.length, greaterThanOrEqualTo(5));

      for (var item in guide) {
        expect(item.title.isNotEmpty, isTrue);
        expect(item.description.isNotEmpty, isTrue);
        expect(item.durationOrEffect.isNotEmpty, isTrue);
        expect(item.rules.isNotEmpty, isTrue);
      }
    });

    test('toggleFavorite persists and modifies favorite rule IDs', () async {
      final service = TajweedService.instance;
      const testId = 'nun_izhar';

      if (service.isFavorite(testId)) {
        await service.toggleFavorite(testId);
      }
      expect(service.isFavorite(testId), isFalse);

      await service.toggleFavorite(testId);
      expect(service.isFavorite(testId), isTrue);
      expect(service.getFavoriteRules().any((r) => r.id == testId), isTrue);

      await service.toggleFavorite(testId);
      expect(service.isFavorite(testId), isFalse);
    });
  });

  group('Tajweed UI & Widget Tests', () {
    testWidgets('TajweedScreen displays tabs and rules list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TajweedScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & tabs
      expect(find.text('أحكام التجويد وضبط المصحف'), findsOneWidget);
      expect(find.text('أحكام التجويد'), findsOneWidget);
      expect(find.text('دليل الألوان'), findsOneWidget);
      expect(find.text('المحفوظات'), findsOneWidget);

      // Verify rule cards in rules tab
      expect(find.text('الإظهار الحلقي'), findsOneWidget);
      expect(find.text('الإدغام بغنة'), findsOneWidget);

      // Switch to Color Guide tab
      await tester.tap(find.text('دليل الألوان'));
      await tester.pumpAndSettle();
      expect(find.text('الترميز اللوني لمصحف التجويد الملون'), findsOneWidget);

      // Switch to Favorites tab
      await tester.tap(find.text('المحفوظات'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bookmark_border), findsWidgets);
    });

    testWidgets('RuleDetailScreen renders rule info and examples', (WidgetTester tester) async {
      final rule = TajweedService.instance.getRuleById('nun_izhar')!;

      await tester.pumpWidget(
        MaterialApp(
          home: RuleDetailScreen(rule: rule),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الإظهار الحلقي'), findsWidgets);
      expect(find.text('حروف وعلامات الحكم'), findsOneWidget);
      expect(find.text('التعريف والبيان الاصطلاحي'), findsOneWidget);
      expect(find.text('كيفية الأداء والتطبيق العملي'), findsOneWidget);
      expect(find.text('الشاهد من المنظومة'), findsOneWidget);
      expect(find.text('أمثلة من القرآن الكريم'), findsOneWidget);
      expect(find.text('تطبيق نور المؤمن — تعلّم أحكام التجويد وإتقان التلاوة'), findsOneWidget);
    });
  });
}
