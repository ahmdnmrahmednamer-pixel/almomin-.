import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/settings/widgets/settings_reciter_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  group('Sheikh Al-Minshawi Default Reciter & Dynamic Selection Tests', () {
    test('Default reciter is Sheikh Mohamed Siddiq Al-Minshawi (Murattal)', () {
      final s = SettingsService.instance;
      expect(s.selectedReciterId, equals('minshawi_murattal'));
      expect(s.currentReciter.id, equals('minshawi_murattal'));
      expect(s.currentReciter.nameAr, contains('المنشاوي'));
      expect(s.currentReciter.style, equals('مرتل'));

      // Check first reciter in list is Minshawi
      expect(SettingsService.availableReciters.first.id, equals('minshawi_murattal'));
    });

    test('User can switch reciter to another reciter and persist selection', () async {
      final s = SettingsService.instance;

      // Switch to Husary
      await s.setSelectedReciter('husary');
      expect(s.selectedReciterId, equals('husary'));
      expect(s.currentReciter.nameAr, contains('الحصري'));
      expect(s.getAyahAudioUrl(1, 1), contains('Husary_128kbps'));

      // Switch to Abdulbasit
      await s.setSelectedReciter('abdulbasit_murattal');
      expect(s.selectedReciterId, equals('abdulbasit_murattal'));
      expect(s.currentReciter.nameAr, contains('عبد الباسط'));

      // Switch back to Minshawi
      await s.setSelectedReciter('minshawi_murattal');
      expect(s.selectedReciterId, equals('minshawi_murattal'));
    });

    testWidgets('Reciter selection modal renders with search bar and reciters list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showSettingsReciterModal(context),
                  child: const Text('Open Modal'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal content
      expect(find.text('اختر القارئ الافتراضي للتلاوة'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Search bar
      expect(find.text('محمد صديق المنشاوي (مرتل)'), findsWidgets);
      expect(find.text('الافتراضي ⭐'), findsWidgets);

      // Filter by category
      expect(find.text('مرتل'), findsWidgets);
      expect(find.text('مجود'), findsWidgets);
    });
  });
}
