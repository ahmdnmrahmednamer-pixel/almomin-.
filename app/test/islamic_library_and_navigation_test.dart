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
      expect(find.text('المكتبة الإسلامية والسنّة والعلوم'), findsOneWidget);

      // Check Tabs
      expect(find.text('الحديث النبوي'), findsOneWidget);
      expect(find.text('قصص الأنبياء'), findsOneWidget);
      expect(find.text('واحة رمضان'), findsOneWidget);
      expect(find.text('حاسبة الزكاة'), findsOneWidget);

      // Check Hadith search box
      expect(find.text('ابحث في نصوص الأحاديث النبوية الشريفة...'), findsOneWidget);
    });

    testWidgets('Renders HomeShortcutsList clean categorized grid with 12 services', (tester) async {
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

      // Check grid header
      expect(find.text('الخدمات والأقسام السريعة'), findsOneWidget);
      expect(find.text('١٢ خدمة إسلامية'), findsOneWidget);

      // Check key service tiles
      expect(find.text('البحث القرآني'), findsOneWidget);
      expect(find.text('محفّظ القرآن'), findsOneWidget);
      expect(find.text('محراب رمضان'), findsOneWidget);
      expect(find.text('موسوعة الحديث'), findsOneWidget);
      expect(find.text('قصص الأنبياء'), findsOneWidget);
      expect(find.text('أحكام التجويد'), findsOneWidget);
      expect(find.text('اتجاه القبلة'), findsOneWidget);
      expect(find.text('حاسبة الزكاة'), findsOneWidget);
      expect(find.text('مواضيع القرآن'), findsOneWidget);
      expect(find.text('خواطر الآيات'), findsOneWidget);
      expect(find.text('المشغل الصوتي'), findsOneWidget);
      expect(find.text('دليل الأذان'), findsOneWidget);

      // Check Daily Spotlight Card
      expect(find.text('عِبرة وقصة اليوم'), findsOneWidget);
    });
  });
}
