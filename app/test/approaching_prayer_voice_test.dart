import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/notifications/prayer_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Approaching Prayer Voice Alerts & Pre-reminder Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'notif_pre_reminder_enabled': true,
        'notif_pre_reminder': 15,
        'notif_pre_reminder_voice_enabled': true,
        'notif_pre_reminder_prayer_الفجر': true,
        'notif_pre_reminder_prayer_الظهر': true,
        'notif_pre_reminder_prayer_العصر': true,
        'notif_pre_reminder_prayer_المغرب': true,
        'notif_pre_reminder_prayer_العشاء': false,
      });
    });

    test('Initializes pre-reminder lead time and voice toggles correctly', () async {
      final service = PrayerNotificationService.instance;
      await service.init();

      expect(service.preReminderEnabled, isTrue);
      expect(service.preReminderMinutes, equals(15));
      expect(service.preReminderVoiceEnabled, isTrue);
      expect(service.isPreReminderPrayerEnabled('الفجر'), isTrue);
      expect(service.isPreReminderPrayerEnabled('الظهر'), isTrue);
      expect(service.isPreReminderPrayerEnabled('العصر'), isTrue);
      expect(service.isPreReminderPrayerEnabled('المغرب'), isTrue);
      expect(service.isPreReminderPrayerEnabled('العشاء'), isFalse);
    });

    test('Toggles lead time and updates listeners', () async {
      final service = PrayerNotificationService.instance;
      await service.init();

      await service.setPreReminder(20);
      expect(service.preReminderMinutes, equals(20));

      await service.setPreReminder(5);
      expect(service.preReminderMinutes, equals(5));
    });

    test('Toggles per-prayer approaching voice alert correctly', () async {
      final service = PrayerNotificationService.instance;
      await service.init();

      await service.togglePreReminderPrayer('العشاء', true);
      expect(service.isPreReminderPrayerEnabled('العشاء'), isTrue);

      await service.togglePreReminderPrayer('الفجر', false);
      expect(service.isPreReminderPrayerEnabled('الفجر'), isFalse);
    });

    test('Toggles master pre-reminder voice toggle', () async {
      final service = PrayerNotificationService.instance;
      await service.init();

      await service.togglePreReminderVoice(false);
      expect(service.preReminderVoiceEnabled, isFalse);

      await service.togglePreReminderVoice(true);
      expect(service.preReminderVoiceEnabled, isTrue);
    });
  });
}
