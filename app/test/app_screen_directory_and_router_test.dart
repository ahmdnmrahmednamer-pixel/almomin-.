import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/theme/app_theme.dart';
import 'package:almomin/features/home/screens/app_screen_directory_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppScreenDirectory & Architecture Tests', () {
    testWidgets('Renders AppScreenDirectoryScreen with search, category chips and items',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AppScreenDirectoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('فهرس ودليل الشاشات الشامل'), findsOneWidget);

      // Verify Search TextField
      expect(find.byType(TextField), findsOneWidget);

      // Verify Category Chips
      expect(find.byType(ChoiceChip), findsAtLeastNWidgets(5));
      expect(find.widgetWithText(ChoiceChip, 'الكل (53)'), findsOneWidget);
      expect(find.textContaining('إشراقة اليوم'), findsAtLeastNWidgets(1));
      expect(find.textContaining('رحاب القرآن'), findsAtLeastNWidgets(1));
      expect(find.textContaining('محراب الصلاة'), findsAtLeastNWidgets(1));
      expect(find.textContaining('أُنس الذاكرين'), findsAtLeastNWidgets(1));
      expect(find.textContaining('رياض العلم'), findsAtLeastNWidgets(1));
    });

    testWidgets('Filters AppScreenDirectory items using search input',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AppScreenDirectoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search term 'مواريث'
      await tester.enterText(find.byType(TextField), 'مواريث');
      await tester.pumpAndSettle();

      // Should find Mawarith item
      expect(find.textContaining('حاسبة المواريث'), findsAtLeastNWidgets(1));

      // Clear search
      await tester.tap(find.byIcon(Icons.clear_rounded));
      await tester.pumpAndSettle();

      // Search for Momen Ibrahim dedication
      await tester.enterText(find.byType(TextField), 'مؤمن');
      await tester.pumpAndSettle();

      expect(find.textContaining('مؤمن إبراهيم'), findsOneWidget);
    });
  });
}
