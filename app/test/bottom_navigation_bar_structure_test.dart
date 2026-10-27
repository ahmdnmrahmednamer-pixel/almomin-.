import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/app/router.dart';
import 'package:almomin/app/widgets/app_navigation_drawer.dart';
import 'package:almomin/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bottom Navigation Bar & Drawer Settings Separation Tests', () {
    testWidgets('MainScaffold contains exactly 5 primary religious destinations without Settings', (tester) async {
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
      // Verify exactly 5 destinations
      expect(navBar.destinations.length, equals(5));

      // Check all 5 primary destinations are present
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('القرآن'), findsOneWidget);
      expect(find.text('الصلاة'), findsOneWidget);
      expect(find.text('الأذكار'), findsOneWidget);
      expect(find.text('المكتبة'), findsOneWidget);

      // Verify that 'الإعدادات' is NOT a destination in the bottom navigation bar
      expect(find.widgetWithText(NavigationDestination, 'الإعدادات'), findsNothing);
    });

    testWidgets('AppNavigationDrawer includes dedicated button for Settings & Support', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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

      // Check Drawer elements
      expect(find.text('الإعدادات والتخصيص'), findsOneWidget);
      expect(find.text('تواصل معنا والدعم'), findsOneWidget);
      expect(find.text('عن التطبيق'), findsOneWidget);
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
      expect(find.text('الإعدادات والتخصيص'), findsOneWidget);
      // Check Home action button
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });
  });
}
