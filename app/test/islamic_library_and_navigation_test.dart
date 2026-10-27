import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/theme/app_theme.dart';
import 'package:almomin/features/library/islamic_library_screen.dart';
import 'package:almomin/features/home/widgets/home_shortcuts_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Islamic Library Hub & Navigation Hub Tests', () {
    testWidgets('Renders IslamicLibraryScreen with tribute, sections, and feature cards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const IslamicLibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar Title
      expect(find.text('رياض العلم والهدي النبوي'), findsOneWidget);

      // Check Tabs
      expect(find.text('رياض المعرفة الشاملة'), findsAtLeastNWidgets(1));
      expect(find.text('مشكاة الحديث النبوي'), findsOneWidget);
      expect(find.text('قصص الوحي والأنبياء'), findsOneWidget);
      expect(find.text('نفحات رمضان والريّان'), findsOneWidget);
      expect(find.text('طُهرة المال والفرائض'), findsOneWidget);
    });

    testWidgets('Renders HomeShortcutsList clean categorized grid with 9 spiritual doors', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: HomeShortcutsList(prayerData: null),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Egyptian heritage banner
      expect(find.textContaining('نسائم القاهرة'), findsOneWidget);

      // Check key spiritual door tiles
      expect(find.textContaining('مجالس العلماء'), findsOneWidget);
      expect(find.textContaining('طِبّ القلوب'), findsOneWidget);
      expect(find.textContaining('رواتب الجنة'), findsOneWidget);
      expect(find.textContaining('بصائر المفسرين'), findsOneWidget);
      expect(find.textContaining('مدارج التدبر'), findsOneWidget);
      expect(find.textContaining('باب الريّان'), findsOneWidget);
      expect(find.textContaining('رحلة الحرمين'), findsOneWidget);
      expect(find.textContaining('مشكاة الحديث'), findsOneWidget);
      expect(find.textContaining('وِرد القرب'), findsOneWidget);

      // Check Daily Spotlight Card
      expect(find.text('قبس من قصص الوحي اليوم'), findsOneWidget);
    });
  });
}
