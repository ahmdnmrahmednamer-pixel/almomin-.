import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/adhkar_service.dart';
import 'package:almomin/core/localization/app_localizations.dart';
import 'package:almomin/features/adhkar/tasbih_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AdhkarService.instance.init();
    AdhkarService.instance.resetTasbih();
    AdhkarService.instance.resetTasbihTotal();
    AdhkarService.instance.setSelectedTasbihPhrase('سُبْحَانَ اللَّهِ');
  });

  Widget buildTestableWidget() {
    return const MaterialApp(
      home: TasbihScreen(),
    );
  }

  group('TasbihScreen Vibration & Motivation Widget Tests', () {
    testWidgets('Renders TasbihScreen with vibration and sound controls in AppBar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify AppBar title
      expect(find.text(AppLocalizations(const Locale('ar')).tr('electronic_tasbih')), findsOneWidget);

      // Verify Sound & Vibration action icons
      expect(find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.volume_up_rounded)), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);

      // Verify initial Dhikr pill
      expect(find.text('سُبْحَانَ اللَّهِ'), findsAtLeastNWidgets(1));

      // Verify tactile tasbih counter display
      expect(find.text('0'), findsAtLeastNWidgets(1));
    });

    testWidgets('Tapping vibration icon in AppBar toggles haptic feedback mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(AdhkarService.instance.hapticEnabled, isTrue);

      // Tap vibration toggle
      await tester.tap(find.byIcon(Icons.vibration));
      await tester.pumpAndSettle();

      // State is now disabled
      expect(AdhkarService.instance.hapticEnabled, isFalse);
      expect(find.text('تم تعطيل الاهتزاز 📴'), findsOneWidget);

      // Tap again to enable
      await tester.tap(find.byIcon(Icons.smartphone_outlined));
      await tester.pumpAndSettle();

      expect(AdhkarService.instance.hapticEnabled, isTrue);
      expect(find.text('تم تفعيل الاهتزاز في المسبحة 📳'), findsOneWidget);
    });

    testWidgets('Reaching target count triggers motivational celebration dialog with Momen Ibrahim dedication', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Set small target of 2 to trigger quickly in test
      AdhkarService.instance.setTasbihTarget(2);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Find the circular tasbih button by key
      final tasbihButtonFinder = find.byKey(const Key('tasbih_main_button'));
      expect(tasbihButtonFinder, findsOneWidget);

      // Tap 1
      await tester.tap(tasbihButtonFinder);
      await tester.pump();
      expect(AdhkarService.instance.tasbihCount, 1);
      expect(find.text('مبارك! أتممت الورد بنجاح ✨'), findsNothing);

      // Tap 2 -> Reaches target (2 % 2 == 0)
      await tester.tap(tasbihButtonFinder);
      await tester.pumpAndSettle();

      expect(AdhkarService.instance.tasbihCount, 2);

      // Verify motivational celebration dialog is displayed
      expect(find.text('مبارك! أتممت الورد بنجاح ✨'), findsOneWidget);
      expect(find.text('تقبّل الله طاعتك وأجزل لك المثوبة والأجر 🌸'), findsOneWidget);
      expect(find.text('2 تسبيحة'), findsOneWidget);

      // Verify motivational Hadith
      expect(find.textContaining('مَنْ دَلَّ عَلَى خَيْرٍ'), findsAtLeastNWidgets(1));

      // Verify buttons
      expect(find.text('متابعة الذكر (دورة جديدة)'), findsOneWidget);
      expect(find.text('تصفير العداد'), findsOneWidget);
      expect(find.text('مشاركة الأجر'), findsOneWidget);

      // Tap Continue button to close dialog
      await tester.tap(find.text('متابعة الذكر (دورة جديدة)'));
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.text('مبارك! أتممت الورد بنجاح ✨'), findsNothing);
    });
  });
}
