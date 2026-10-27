import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/app/router.dart';
import 'package:almomin/app/widgets/app_navigation_drawer.dart';
import 'package:almomin/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bottom Navigation Bar & Drawer Settings Tests', () {
    testWidgets('MainScaffold contains 6 destinations including dedicated Settings', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: MainScaffold(
            child: Scaffold(
              body: Center(child: Text('محتوى الصفحة')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navBarFinder = find.byType(NavigationBar);
      expect(navBarFinder, findsOneWidget);

      final navBar = tester.widget<NavigationBar>(navBarFinder);
      // Verify exactly 6 destinations
      expect(navBar.destinations.length, equals(6));

      // Check all 6 destinations are present
      expect(find.text('إشراقة اليوم'), findsOneWidget);
      expect(find.text('رحاب القرآن'), findsOneWidget);
      expect(find.text('محراب الصلاة'), findsOneWidget);
      expect(find.text('أُنس الذاكرين'), findsOneWidget);
      expect(find.text('رياض العلم'), findsOneWidget);
      expect(find.text('الإعدادات'), findsOneWidget);

      // Verify that 'الإعدادات' is a dedicated destination in the bottom navigation bar
      expect(find.widgetWithText(NavigationDestination, 'الإعدادات'), findsOneWidget);
    });

    testWidgets('AppNavigationDrawer includes dedicated button for Settings & Support', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            drawer: AppNavigationDrawer(),
            body: Center(child: Text('الرئيسية')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('تهيئة الخشوع وإعدادات التطبيق'),
        200,
        scrollable: find.byType(Scrollable).last,
      );

      // Check Drawer elements
      expect(find.text('تهيئة الخشوع وإعدادات التطبيق'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('التواصل والمقترحات'),
        100,
        scrollable: find.byType(Scrollable).last,
      );

      expect(find.text('التواصل والمقترحات'), findsOneWidget);
      expect(find.text('رسالة التطبيق'), findsOneWidget);
      expect(find.textContaining('الدعاء للمرحوم مؤمن'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders clean header with navigation options', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar Title
      expect(find.text('تهيئة الخشوع وإعدادات التطبيق'), findsOneWidget);
      // Check Home action button
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });
  });
}
