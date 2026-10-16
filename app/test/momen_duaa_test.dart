import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/home/momen_duaa_screen.dart';
import 'package:almomin/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Momen Ibrahim (رحمهُ الله / الله يرحمه) Launch Duaa & Tutorial Screen Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SettingsService.instance.init();
    });

    test('SettingsService manages showTutorialScreens flag correctly', () async {
      final service = SettingsService.instance;
      expect(service.showTutorialScreens, isTrue);

      await service.setShowTutorialScreens(false);
      expect(service.showTutorialScreens, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('show_tutorial_screens'), isFalse);

      await service.setShowTutorialScreens(true);
      expect(service.showTutorialScreens, isTrue);
      expect(prefs.getBool('show_tutorial_screens'), isTrue);
    });

    testWidgets('MomenDuaaScreen renders with exact name formulation and Amen button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: MomenDuaaScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify exact requested name and mercy formula
      expect(find.text('صَدَقَةٌ جَارِيَةٌ'), findsOneWidget);
      expect(find.text('عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ تَعَالَى'), findsOneWidget);
      expect(find.text('مُؤْمِن إِبْرَاهِيم رحمهُ الله'), findsOneWidget);
      expect(find.textContaining('الله يرحمه'), findsOneWidget);

      // 2. Verify Prophetic Duaa and Hadith
      expect(find.textContaining('اللَّهُمَّ اغْفِرْ لِمُؤْمِن إِبْرَاهِيم وَارْحَمْهُ'), findsOneWidget);
      expect(find.textContaining('دُعَاءٌ لِلْمَيِّتِ مِنَ السُّنَّةِ النَّبَوِيَّةِ'), findsOneWidget);
      expect(find.textContaining('إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ'), findsOneWidget);

      // 3. Verify Bottom Persistent "آمين" Button
      expect(find.text('آمين'), findsOneWidget);
      expect(find.text('اضغط على زر آمين للدخول إلى التطبيق'), findsOneWidget);
    });

    testWidgets('Tapping Amen button in MomenDuaaScreen (from inside app) pops dialog/route', (WidgetTester tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MomenDuaaScreen(isFromInsideApp: true),
                            ),
                          );
                          popped = true;
                        },
                        child: const Text('Open Duaa'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open screen
      await tester.tap(find.text('Open Duaa'));
      await tester.pumpAndSettle();

      expect(find.text('مُؤْمِن إِبْرَاهِيم رحمهُ الله'), findsOneWidget);
      expect(find.text('آمين'), findsOneWidget);

      // Tap Amen
      await tester.tap(find.text('آمين'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
      expect(find.text('Open Duaa'), findsOneWidget);
    });

    testWidgets('SettingsScreen displays Duaa tile and Tutorial switch controls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: SettingsScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('دعاء لمؤمن إبراهيم رحمهُ الله'), findsOneWidget);
      expect(find.textContaining('الله يرحمه'), findsOneWidget);
      expect(find.text('إظهار شاشات شرح البرنامج عند الفتح'), findsOneWidget);
      expect(find.text('عرض شاشات شرح استخدام البرنامج'), findsOneWidget);

      // Toggle tutorial switch
      final switchFinder = find.widgetWithText(SwitchListTile, 'إظهار شاشات شرح البرنامج عند الفتح');
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(SettingsService.instance.showTutorialScreens, isFalse);
    });
  });
}
