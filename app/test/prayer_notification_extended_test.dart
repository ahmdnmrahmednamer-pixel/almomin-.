import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/notifications/prayer_notification_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
    await PrayerNotificationService.instance.init();
  });

  group('PrayerNotificationService Extended Unit Tests (FR-NOT-006)', () {
    test('Default values are initialized properly', () {
      final notif = PrayerNotificationService.instance;

      expect(notif.preReminderEnabled, isTrue);
      expect(notif.preReminderMinutes, 10);
      expect(notif.qiyamReminderEnabled, isTrue);
      expect(notif.qiyamOffsetMinutes, 60);
      expect(notif.fridayReminderEnabled, isTrue);
      expect(notif.fridayReminderHour, 9);
    });

    test('togglePreReminder updates state and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.togglePreReminder(false);
      expect(notif.preReminderEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_pre_reminder_enabled'), isFalse);

      await notif.togglePreReminder(true);
      expect(notif.preReminderEnabled, isTrue);
      expect(prefs.getBool('notif_pre_reminder_enabled'), isTrue);
    });

    test('setPreReminder updates minutes and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.setPreReminder(15);
      expect(notif.preReminderMinutes, 15);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('notif_pre_reminder'), 15);

      await notif.setPreReminder(10);
      expect(notif.preReminderMinutes, 10);
    });

    test('toggleQiyamReminder updates state and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.toggleQiyamReminder(false);
      expect(notif.qiyamReminderEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_qiyam_enabled'), isFalse);

      await notif.toggleQiyamReminder(true);
      expect(notif.qiyamReminderEnabled, isTrue);
    });

    test('setQiyamOffset updates minutes and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.setQiyamOffset(90);
      expect(notif.qiyamOffsetMinutes, 90);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('notif_qiyam_offset'), 90);

      await notif.setQiyamOffset(60);
      expect(notif.qiyamOffsetMinutes, 60);
    });

    test('toggleFridayReminder updates state and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.toggleFridayReminder(false);
      expect(notif.fridayReminderEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_friday_enabled'), isFalse);

      await notif.toggleFridayReminder(true);
      expect(notif.fridayReminderEnabled, isTrue);
    });

    test('setFridayReminderHour updates hour and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.setFridayReminderHour(8);
      expect(notif.fridayReminderHour, 8);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('notif_friday_hour'), 8);

      await notif.setFridayReminderHour(9);
      expect(notif.fridayReminderHour, 9);
    });

    test('toggleDuhaReminder updates state and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.toggleDuhaReminder(false);
      expect(notif.duhaReminderEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_duha_enabled'), isFalse);

      await notif.toggleDuhaReminder(true);
      expect(notif.duhaReminderEnabled, isTrue);
    });

    test('setDuhaOffset updates minutes and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.setDuhaOffset(40);
      expect(notif.duhaReminderMinutesAfterSunrise, 40);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('notif_duha_offset'), 40);

      await notif.setDuhaOffset(25);
      expect(notif.duhaReminderMinutesAfterSunrise, 25);
    });

    test('togglePostPrayerAdhkar updates state and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.togglePostPrayerAdhkar(false);
      expect(notif.postPrayerAdhkarReminderEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_post_adhkar_enabled'), isFalse);

      await notif.togglePostPrayerAdhkar(true);
      expect(notif.postPrayerAdhkarReminderEnabled, isTrue);
    });

    test('setSoundMode updates mode and persists in SharedPreferences', () async {
      final notif = PrayerNotificationService.instance;
      await notif.setSoundMode(AdhanSoundMode.takbeerat);
      expect(notif.soundMode, AdhanSoundMode.takbeerat);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('notif_sound_mode'), 'takbeerat');

      await notif.setSoundMode(AdhanSoundMode.fullAdhan);
      expect(notif.soundMode, AdhanSoundMode.fullAdhan);
    });

    test('toggleFajrDistinctVoice updates state and persists', () async {
      final notif = PrayerNotificationService.instance;
      await notif.toggleFajrDistinctVoice(false);
      expect(notif.fajrDistinctVoiceEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_fajr_distinct'), isFalse);

      await notif.toggleFajrDistinctVoice(true);
      expect(notif.fajrDistinctVoiceEnabled, isTrue);
    });
  });

  group('SettingsScreen Extended Notifications UI Widget Tests', () {
    testWidgets('Renders Pre-Adhan, Qiyam, and Friday Sunnahs options', (tester) async {
      tester.view.physicalSize = const Size(1080, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find widgets
      expect(find.text('التنبيه المسبق قبل الأذان'), findsOneWidget);
      expect(find.text('تنبيه قيام الليل والتهجد 🌙'), findsOneWidget);
      expect(find.text('تذكير سنن يوم الجمعة المباركة 🕌'), findsOneWidget);

      // Verify Pre-reminder picker opens and changes value
      final prePickerTile = find.text('تعديل دقائق التنبيه المسبق');
      expect(prePickerTile, findsOneWidget);
      await tester.tap(prePickerTile);
      await tester.pumpAndSettle();

      // Tap on 15 minutes
      final option15 = find.text('15 دقائق قبل الأذان');
      expect(option15, findsOneWidget);
      await tester.tap(option15);
      await tester.pumpAndSettle();

      expect(PrayerNotificationService.instance.preReminderMinutes, 15);

      // Verify Qiyam offset picker opens and changes value
      final qiyamPickerTile = find.text('تعديل توقيت تنبيه قيام الليل');
      expect(qiyamPickerTile, findsOneWidget);
      await tester.tap(qiyamPickerTile);
      await tester.pumpAndSettle();

      // Tap on 90 minutes
      final option90 = find.text('قبل أذان الفجر بساعة ونصف (٩٠ دقيقة)');
      expect(option90, findsOneWidget);
      await tester.tap(option90);
      await tester.pumpAndSettle();

      expect(PrayerNotificationService.instance.qiyamOffsetMinutes, 90);
    });
  });
}
