import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../services/prayer_service.dart';

enum AdhanSoundMode {
  fullAdhan,
  takbeerat,
  softBeep,
  silent,
}

class PrayerNotificationService extends ChangeNotifier {
  static final PrayerNotificationService instance = PrayerNotificationService._internal();
  PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool _masterEnabled = true;
  AdhanSoundMode _soundMode = AdhanSoundMode.fullAdhan;
  int _preReminderMinutes = 10;

  final Map<String, bool> _prayerToggles = {
    'الفجر': true,
    'الشروق': false,
    'الظهر': true,
    'العصر': true,
    'المغرب': true,
    'العشاء': true,
  };

  bool get masterEnabled => _masterEnabled;
  AdhanSoundMode get soundMode => _soundMode;
  int get preReminderMinutes => _preReminderMinutes;
  Map<String, bool> get prayerToggles => _prayerToggles;

  bool isPrayerEnabled(String prayerName) => _prayerToggles[prayerName] ?? true;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _localNotifications.initialize(initSettings);
    } catch (e) {
      debugPrint('Notification init exception: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    _masterEnabled = prefs.getBool('notif_master_enabled') ?? true;
    _preReminderMinutes = prefs.getInt('notif_pre_reminder') ?? 10;
    final soundStr = prefs.getString('notif_sound_mode') ?? 'fullAdhan';
    _soundMode = AdhanSoundMode.values.firstWhere(
      (m) => m.name == soundStr,
      orElse: () => AdhanSoundMode.fullAdhan,
    );

    for (final p in _prayerToggles.keys) {
      _prayerToggles[p] = prefs.getBool('notif_prayer_$p') ?? (p != 'الشروق');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleMaster(bool enabled) async {
    _masterEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_master_enabled', enabled);
    if (!enabled) {
      await cancelAll();
    }
    notifyListeners();
  }

  Future<void> togglePrayer(String prayerName, bool enabled) async {
    _prayerToggles[prayerName] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_prayer_$prayerName', enabled);
    notifyListeners();
  }

  Future<void> setSoundMode(AdhanSoundMode mode) async {
    _soundMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_sound_mode', mode.name);
    notifyListeners();
  }

  Future<void> setPreReminder(int minutes) async {
    _preReminderMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_pre_reminder', minutes);
    notifyListeners();
  }

  Future<void> schedulePrayerNotifications(PrayerData data) async {
    if (!_masterEnabled || !_isInitialized) return;

    try {
      await _localNotifications.cancelAll();
      final now = DateTime.now();

      int notificationId = 100;
      for (final prayer in data.prayers) {
        if (!isPrayerEnabled(prayer.name)) continue;
        if (prayer.time.isBefore(now)) continue;

        // Schedule Main Adhan / Prayer Time Notification
        final scheduledTz = tz.TZDateTime.from(prayer.time, tz.local);

        const androidDetails = AndroidNotificationDetails(
          'prayer_adhan_channel',
          'مواقيت الصلاة والأذان',
          channelDescription: 'تنبيهات دخول أوقات الصلوات المفروضة والأذان',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

        await _localNotifications.zonedSchedule(
          notificationId++,
          'حان الآن موعد صلاة ${prayer.name}',
          'الله أكبر الله أكبر — حي على الصلاة، حي على الفلاح (${data.locationName})',
          scheduledTz,
          const NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        // Schedule Pre-reminder if enabled
        if (_preReminderMinutes > 0) {
          final preTime = prayer.time.subtract(Duration(minutes: _preReminderMinutes));
          if (preTime.isAfter(now)) {
            final preTz = tz.TZDateTime.from(preTime, tz.local);
            await _localNotifications.zonedSchedule(
              notificationId++,
              'اقترب موعد صلاة ${prayer.name}',
              'متبقي $_preReminderMinutes دقائق على أذان ${prayer.name}',
              preTz,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'prayer_reminder_channel',
                  'تذكير ما قبل الصلاة',
                  importance: Importance.defaultImportance,
                  priority: Priority.defaultPriority,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error scheduling prayer notifications: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _localNotifications.cancelAll();
    } catch (_) {}
  }
}
