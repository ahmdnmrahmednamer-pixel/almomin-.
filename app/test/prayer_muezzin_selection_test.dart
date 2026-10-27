import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/notifications/prayer_notification_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/settings/widgets/settings_adhan_voice_modal.dart';
import 'package:almomin/features/prayer/widgets/prayer_muezzin_selector_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notif_selected_adhan': 'adhan_makkah',
      'notif_selected_fajr_adhan': 'adhan_fajr',
      'notif_prayer_voice_الفجر': 'adhan_fajr',
      'notif_prayer_voice_الظهر': 'adhan_makkah',
      'notif_prayer_voice_العصر': 'adhan_madinah',
      'notif_prayer_voice_المغرب': 'adhan_cairo',
      'notif_prayer_voice_العشاء': 'adhan_aqsa',
    });
    await SettingsService.instance.init();
    await PrayerNotificationService.instance.init();
  });

  group('Per-Prayer Muezzin Selection Tests (لكل صلاة مؤذن)', () {
    test('Initializes distinct Muezzin voices for each of the 5 prayers', () {
      final notif = PrayerNotificationService.instance;

      expect(notif.getPrayerVoice('الفجر'), equals('adhan_fajr'));
      expect(notif.getPrayerVoice('الظهر'), equals('adhan_makkah'));
      expect(notif.getPrayerVoice('العصر'), equals('adhan_madinah'));
      expect(notif.getPrayerVoice('المغرب'), equals('adhan_cairo'));
      expect(notif.getPrayerVoice('العشاء'), equals('adhan_aqsa'));
    });

    test('setPrayerVoice updates and persists voice for specific prayer', () async {
      final notif = PrayerNotificationService.instance;

      // Assign Sheikh Hussary for Asr
      await notif.setPrayerVoice('العصر', 'adhan_hussary');
      expect(notif.getPrayerVoice('العصر'), equals('adhan_hussary'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('notif_prayer_voice_العصر'), equals('adhan_hussary'));

      // Dhuhr remains untouched
      expect(notif.getPrayerVoice('الظهر'), equals('adhan_makkah'));
    });

    test('setAllPrayersVoice updates all 5 prayers to chosen Muezzin', () async {
      final notif = PrayerNotificationService.instance;

      await notif.setAllPrayersVoice('adhan_afasy');

      expect(notif.getPrayerVoice('الفجر'), equals('adhan_afasy'));
      expect(notif.getPrayerVoice('الظهر'), equals('adhan_afasy'));
      expect(notif.getPrayerVoice('العصر'), equals('adhan_afasy'));
      expect(notif.getPrayerVoice('المغرب'), equals('adhan_afasy'));
      expect(notif.getPrayerVoice('العشاء'), equals('adhan_afasy'));
    });

    testWidgets('Renders Per-Prayer Muezzin Manager Sheet with 5 prayers and preview buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showSettingsAdhanVoiceModal(context),
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Open the sheet
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.textContaining('مؤذنو الصلوات الخمس'), findsOneWidget);

      // Verify all 5 prayers are listed
      expect(find.text('صلاة الفجر'), findsOneWidget);
      expect(find.text('صلاة الظهر'), findsOneWidget);
      expect(find.text('صلاة العصر'), findsOneWidget);
      expect(find.text('صلاة المغرب'), findsOneWidget);
      expect(find.text('صلاة العشاء'), findsOneWidget);

      // Verify Preview (استماع للمؤذن) and Dropdown buttons exist
      expect(find.text('استماع للمؤذن 🎧'), findsWidgets);
      expect(find.text('تغيير المؤذن ▾'), findsWidgets);
    });

    testWidgets('PrayerMuezzinSelectorCard renders 5 prayers with dropdown buttons and preview on screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrayerMuezzinSelectorCard(isDark: false),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header
      expect(find.textContaining('اختيار مؤذن لكل صلاة'), findsOneWidget);

      // Verify all 5 prayers exist
      expect(find.text('صلاة الفجر'), findsOneWidget);
      expect(find.text('صلاة الظهر'), findsOneWidget);
      expect(find.text('صلاة العصر'), findsOneWidget);
      expect(find.text('صلاة المغرب'), findsOneWidget);
      expect(find.text('صلاة العشاء'), findsOneWidget);

      // Verify preview and dropdown buttons
      expect(find.text('استماع 🔊'), findsNWidgets(5));
      expect(find.text('قائمة الشيوخ ▾'), findsNWidgets(5));
    });
  });
}
