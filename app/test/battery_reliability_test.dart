import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/features/prayer/battery_reliability_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BatteryReliabilityScreen & OEM Guides Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('OEM guides cover all 7 major manufacturers in target markets', () {
      final guides = BatteryReliabilityScreen.oemGuides;
      expect(guides.length, 7);

      final ids = guides.map((g) => g.id).toList();
      expect(ids, containsAll([
        'xiaomi',
        'samsung',
        'huawei',
        'oppo_realme',
        'vivo',
        'infinix_tecno',
        'stock_android',
      ]));
    });

    test('Each OEM guide contains valid, comprehensive steps and recommendations', () {
      for (final guide in BatteryReliabilityScreen.oemGuides) {
        expect(guide.name.isNotEmpty, isTrue, reason: 'Name should not be empty for ${guide.id}');
        expect(guide.subTitle.isNotEmpty, isTrue, reason: 'Subtitle should not be empty for ${guide.id}');
        expect(guide.badge.isNotEmpty, isTrue, reason: 'Badge should not be empty for ${guide.id}');
        expect(guide.steps.isNotEmpty, isTrue, reason: 'Steps should not be empty for ${guide.id}');

        for (final step in guide.steps) {
          expect(step.title.isNotEmpty, isTrue);
          expect(step.description.isNotEmpty, isTrue);
          expect(step.recommendedSetting.isNotEmpty, isTrue);
        }
      }
    });

    test('Xiaomi guide has autostart, no restrictions, and lock in recents', () {
      final xiaomi = BatteryReliabilityScreen.oemGuides.firstWhere((g) => g.id == 'xiaomi');
      expect(xiaomi.steps.length, 3);
      expect(xiaomi.steps[0].title, contains('البدء التلقائي'));
      expect(xiaomi.steps[1].title, contains('لا توجد قيود'));
      expect(xiaomi.steps[2].title, contains('التطبيقات الأخيرة'));
    });

    test('Samsung guide has unrestricted battery and never sleeping apps', () {
      final samsung = BatteryReliabilityScreen.oemGuides.firstWhere((g) => g.id == 'samsung');
      expect(samsung.steps.length, 3);
      expect(samsung.steps[0].title, contains('غير مقيد'));
      expect(samsung.steps[1].title, contains('السكون العميق'));
    });

    test('Huawei guide has manual app launch with 3 toggles', () {
      final huawei = BatteryReliabilityScreen.oemGuides.firstWhere((g) => g.id == 'huawei');
      expect(huawei.steps.length, 3);
      expect(huawei.steps[0].title, contains('إدارة بدء التشغيل'));
      expect(huawei.steps[1].title, contains('خيارات التشغيل الثلاثة'));
    });

    testWidgets('Renders BatteryReliabilityScreen correctly with RTL and all sections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BatteryReliabilityScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Check header and cards
      expect(find.text('دليل تثبيت الأذان وإعدادات البطارية'), findsOneWidget);
      expect(find.text('لماذا يحتاج التطبيق لهذه الإعدادات؟'), findsOneWidget);
      expect(find.text('فحص الأذونات الحيوية لنظام الهاتف'), findsOneWidget);
      expect(find.text('دليل ضبط الهاتف حسب الشركة المصنعة'), findsOneWidget);

      // Check live status cards
      expect(find.textContaining('إذن إشعارات الأذان'), findsOneWidget);
      expect(find.textContaining('استثناء من توفير البطارية'), findsOneWidget);
      expect(find.textContaining('إذن المنبه الدقيق بالثانية'), findsOneWidget);

      // Check brand chips and cards
      expect(find.textContaining('شاومي / بوكو / ريدمي'), findsWidgets);
      expect(find.textContaining('سامسونج'), findsWidgets);
    });

    testWidgets('Tapping step checkbox toggles its state and updates progress', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BatteryReliabilityScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Initial progress: 0 of 3
      expect(find.text('0 من 3'), findsOneWidget);

      // Tap on the first step checkbox
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Updated progress: 1 of 3
      expect(find.text('1 من 3'), findsOneWidget);

      // Untap the checkbox
      await tester.tap(firstCheckbox);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Back to 0 of 3
      expect(find.text('0 من 3'), findsOneWidget);
    });
  });
}
