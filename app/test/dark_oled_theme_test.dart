import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/theme/app_theme.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/app/app.dart';
import 'package:almomin/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  group('Dark & OLED Theme Tokens Tests (FR-THM-001)', () {
    test('AppTheme.oledTheme provides pure black background and AMOLED optimization', () {
      final oled = AppTheme.oledTheme;

      expect(oled.brightness, Brightness.dark);
      expect(oled.scaffoldBackgroundColor, const Color(0xFF000000));
      expect(oled.appBarTheme.backgroundColor, const Color(0xFF000000));
      expect(oled.colorScheme.surface, AppColors.oledSurface);
      expect(oled.cardTheme.color, AppColors.oledCard);
    });

    test('SettingsService manages 4 canonical theme modes and persistence', () async {
      final settings = SettingsService.instance;
      expect(SettingsService.availableThemeModes.length, 4);

      // 1. Light
      await settings.setThemeMode('light');
      expect(settings.themeMode, 'light');
      expect(settings.themeModeName.contains('النهاري'), isTrue);

      // 2. Dark
      await settings.setThemeMode('dark');
      expect(settings.themeMode, 'dark');
      expect(settings.themeModeName.contains('الداكن'), isTrue);

      // 3. OLED
      await settings.setThemeMode('oled');
      expect(settings.themeMode, 'oled');
      expect(settings.themeModeName.contains('OLED'), isTrue);

      // 4. System
      await settings.setThemeMode('system');
      expect(settings.themeMode, 'system');
      expect(settings.themeModeName.contains('تلقائي'), isTrue);
    });
  });

  group('AlMominApp & SettingsScreen Widget Tests', () {
    testWidgets('AlMominApp reacts dynamically to OLED theme selection', (tester) async {
      await SettingsService.instance.setThemeMode('oled');

      await tester.pumpWidget(
        const AlMominApp(),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);
      expect(materialApp.darkTheme?.scaffoldBackgroundColor, const Color(0xFF000000));
    });

    testWidgets('SettingsScreen displays Theme ListTile and opens modal to select OLED mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find theme tile
      final themeTile = find.text('مظهر التطبيق والوضع الليلي (Dark & OLED)');
      expect(themeTile, findsOneWidget);

      // Tap on theme tile
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Modal options should be visible
      expect(find.text('الوضع الليلي الفاخر (OLED أسود نقي)'), findsOneWidget);
      expect(find.text('الوضع الداكن الهادئ'), findsOneWidget);
      expect(find.text('الوضع الفاتح (النهاري)'), findsOneWidget);

      // Select OLED mode
      await tester.tap(find.text('الوضع الليلي الفاخر (OLED أسود نقي)'));
      await tester.pumpAndSettle();

      expect(SettingsService.instance.themeMode, 'oled');
      expect(find.text('تم تفعيل: الوضع الليلي الفاخر (OLED أسود نقي)'), findsOneWidget);
    });
  });
}
