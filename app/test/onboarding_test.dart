import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/onboarding/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Onboarding & Momin Ibrahim Dedication Tests (T-501 / FR-SET-001)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('SettingsService onboarding completion flag persists correctly', () async {
      SharedPreferences.setMockInitialValues({'has_completed_onboarding': false});
      final service = SettingsService.instance;
      await service.init();

      expect(service.hasCompletedOnboarding, isFalse);

      await service.completeOnboarding();
      expect(service.hasCompletedOnboarding, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_completed_onboarding'), isTrue);
    });

    testWidgets('Renders OnboardingScreen with Momin Ibrahim dedication and controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      SharedPreferences.setMockInitialValues({'has_completed_onboarding': false});
      await SettingsService.instance.init();

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: OnboardingScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify App Title and Noble Dedication
      expect(find.text('نور المؤمن'), findsOneWidget);
      expect(find.text('مرحباً بك في تطبيق نور المؤمن'), findsOneWidget);
      expect(find.textContaining('مؤمن إبراهيم رحمهُ الله'), findsOneWidget);
      expect(find.textContaining('إهداء ودعاء مبارك'), findsOneWidget);

      // Verify Don't Show Again Checkbox
      expect(find.text('عدم إظهار شاشات شرح البرنامج مرة أخرى'), findsOneWidget);

      // 2. Verify Navigation Controls
      expect(find.text('تخطي'), findsOneWidget);
      expect(find.text('التالي'), findsOneWidget);

      // 3. Move to Page 2 (Personalization)
      await tester.tap(find.text('التالي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('تخصيص تجربتك في التطبيق'), findsOneWidget);
      expect(find.text('المدينة لمواقيت الصلاة'), findsOneWidget);
      expect(find.text('القارئ الافتراضي للتلاوة'), findsOneWidget);

      // 4. Move to Page 3 (Notifications & Readiness)
      await tester.tap(find.text('التالي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('تنبيهات الأذان والجاهزية'), findsOneWidget);
      expect(find.textContaining('تثبيت الأذان على هاتفك'), findsOneWidget);
      expect(find.text('ابدأ الآن 🕌'), findsOneWidget);

      // 5. Tap Finish
      await tester.tap(find.text('ابدأ الآن 🕌'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(SettingsService.instance.hasCompletedOnboarding, isTrue);
      expect(SettingsService.instance.showTutorialScreens, isFalse);
    });
  });
}
