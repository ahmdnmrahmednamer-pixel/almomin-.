import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/adhkar_service.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/adhkar/tasbih_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v9.0 — Tasbih Volume-Up (+1) & Interactive Bead Slider Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      IslamicAudioService.instance.disableNativePlayerForTesting = true;
      await SettingsService.instance.init();
      await AdhkarService.instance.init();
      AdhkarService.instance.resetTasbih();
      AdhkarService.instance.resetTasbihTotal();
    });

    test('AdhkarService increments Tasbih by +1 on Volume Up when enabled and respects toggle', () {
      final service = AdhkarService.instance;
      expect(service.volumeButtonTasbihEnabled, isTrue);
      expect(service.tasbihSliderEnabled, isTrue);
      expect(service.tasbihCount, 0);

      // Press Volume Up 3 times while enabled
      service.handleVolumeUpIncrement();
      service.handleVolumeUpIncrement();
      service.handleVolumeUpIncrement();
      expect(service.tasbihCount, 3);
      expect(service.tasbihTotalToday, 3);

      // Disable Volume Up Tasbih option -> should not increment on Volume Up
      service.toggleVolumeButtonTasbih(false);
      expect(service.volumeButtonTasbihEnabled, isFalse);
      service.handleVolumeUpIncrement();
      expect(service.tasbihCount, 3);

      // Re-enable Volume Up Tasbih option -> increments again
      service.toggleVolumeButtonTasbih(true);
      service.handleVolumeUpIncrement();
      expect(service.tasbihCount, 4);
    });

    test('AdhkarService updates Tasbih count accurately via the interactive bead slider', () {
      final service = AdhkarService.instance;
      service.setTasbihTarget(33);
      expect(service.tasbihCount, 0);

      final reachedMid = service.updateTasbihFromSlider(15);
      expect(reachedMid, isFalse);
      expect(service.tasbihCount, 15);
      expect(service.tasbihTotalToday, 15);

      final reachedEnd = service.updateTasbihFromSlider(33);
      expect(reachedEnd, isTrue);
      expect(service.tasbihCount, 33);
    });

    testWidgets('TasbihScreen renders interactive Slider, Volume-Up (+1) toggle, and existing controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TasbihScreen(),
        ),
      );
      await tester.pump();

      // Verify the new Slider and Volume-Up (+1) option are present alongside existing settings
      expect(find.byType(Slider), findsOneWidget);
      expect(find.textContaining('سليدر المسبحة'), findsOneWidget);
      expect(find.text('+١'), findsOneWidget);

      // Simulate pressing hardware Volume Up key
      await tester.sendKeyEvent(LogicalKeyboardKey.audioVolumeUp);
      await tester.pump();
      expect(AdhkarService.instance.tasbihCount, 1);

      // Simulate tapping the +1 Volume Up chip on the slider bar
      await tester.tap(find.text('+١'));
      await tester.pump();
      expect(AdhkarService.instance.tasbihCount, 2);
    });
  });
}
