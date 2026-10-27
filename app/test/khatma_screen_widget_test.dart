import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/khatma_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/khatma/khatma_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
    await KhatmaService.instance.init();
    await KhatmaService.instance.cancelPlan();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: child,
      ),
    );
  }

  testWidgets('KhatmaScreen renders empty state when no plan is active', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestableWidget(const KhatmaScreen()));
    await tester.pumpAndSettle();

    expect(find.text('ابدأ ختمتك القرآنية المباركة'), findsOneWidget);
    expect(find.text('إنشاء خطة ختمة جديدة'), findsOneWidget);
  });

  testWidgets('KhatmaScreen displays active plan, progress, and prayers checklist', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await KhatmaService.instance.createPlan(
      title: 'ختمة الفجر والسكينة',
      targetDays: 30,
      splitByPrayer: true,
      startingPage: 1,
    );

    await tester.pumpWidget(buildTestableWidget(const KhatmaScreen()));
    await tester.pumpAndSettle();

    // Verify Active Plan Card
    expect(find.text('ختمة الفجر والسكينة'), findsOneWidget);
    expect(find.text('ورد اليوم القرآني'), findsOneWidget);
    expect(find.text('صلاة الفجر'), findsOneWidget);
    expect(find.text('صلاة الظهر'), findsOneWidget);
    expect(find.text('صلاة العصر'), findsOneWidget);
    expect(find.text('صلاة المغرب'), findsOneWidget);
    expect(find.text('صلاة العشاء'), findsOneWidget);

    // Verify action buttons
    expect(find.text('ابدأ قراءة ورد اليوم الآن'), findsOneWidget);
    expect(find.text('أتممت الورد'), findsOneWidget);

    // Advance pages by tapping 'أتممت الورد'
    await tester.tap(find.text('أتممت الورد'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify reading progress updated
    expect(KhatmaService.instance.activePlan!.currentPage, greaterThan(1));
  });

  testWidgets('KhatmaScreen displays Duaa Khatm Al-Quran with dedication for Momen Ibrahim', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await KhatmaService.instance.createPlan(
      title: 'ختمة مباركة',
      targetDays: 30,
      splitByPrayer: false,
      startingPage: 604,
    );

    await tester.pumpWidget(buildTestableWidget(const KhatmaScreen()));
    await tester.pumpAndSettle();

    // Find and tap Duaa button in the celebratory banner at top
    final duaaButton = find.text('دعاء الختم');
    expect(duaaButton, findsOneWidget);
    await tester.tap(duaaButton);
    await tester.pumpAndSettle();

    // Verify Duaa Modal Content
    expect(find.text('دعاء ختم القرآن الكريم المأثور'), findsOneWidget);
    expect(find.text('مؤمن إبراهيم رحمهُ الله'), findsOneWidget);
    expect(find.text('دعاء مبارك'), findsOneWidget);
    expect(find.text('آمين يا رب العالمين'), findsOneWidget);

    // Tap Amen button
    await tester.tap(find.text('آمين يا رب العالمين'));
    await tester.pumpAndSettle();

    expect(find.text('جزاكم الله خيراً — آمين'), findsOneWidget);
  });
}
