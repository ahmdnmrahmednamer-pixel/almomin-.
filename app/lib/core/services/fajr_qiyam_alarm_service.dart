import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'islamic_audio_service.dart';
import 'prayer_service.dart';

/// نموذج نغمة التنبيه لمنبه الفجر وقيام الليل
class WakeUpAlarmTone {
  final String id;
  final String title;
  final String subtitle;
  final String trackId;
  final String rawSoundName;

  const WakeUpAlarmTone({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.trackId,
    required this.rawSoundName,
  });
}

/// خدمة «منبّه الاستعداد لصلاة الفجر ومنبّه قيام الليل الذكي»
class FajrQiyamAlarmService extends ChangeNotifier {
  static final FajrQiyamAlarmService instance = FajrQiyamAlarmService._internal();
  FajrQiyamAlarmService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // 1. Pre-Fajr Wake-Up Alarm Settings
  bool _preFajrEnabled = true;
  int _preFajrMinutesBefore = 25; // Default: 25 mins before Fajr
  String _preFajrToneId = 'adhan_fajr';

  // 2. Qiyam Al-Layl Alarm Settings
  bool _qiyamEnabled = true;
  String _qiyamMode = 'last_third'; // 'last_third', 'before_fajr', 'fixed_time'
  int _qiyamMinutesBeforeFajr = 60;
  int _qiyamFixedHour = 3;
  int _qiyamFixedMinute = 15;
  String _qiyamToneId = 'duaa_sharawi_post_prayer';

  bool get preFajrEnabled => _preFajrEnabled;
  int get preFajrMinutesBefore => _preFajrMinutesBefore;
  String get preFajrToneId => _preFajrToneId;

  bool get qiyamEnabled => _qiyamEnabled;
  String get qiyamMode => _qiyamMode;
  int get qiyamMinutesBeforeFajr => _qiyamMinutesBeforeFajr;
  int get qiyamFixedHour => _qiyamFixedHour;
  int get qiyamFixedMinute => _qiyamFixedMinute;
  String get qiyamToneId => _qiyamToneId;

  static const List<WakeUpAlarmTone> availableTones = [
    WakeUpAlarmTone(
      id: 'adhan_fajr',
      title: 'أذان الفجر (الصلاة خير من النوم - مكة)',
      subtitle: 'نداء الفجر الخاشع من المسجد الحرام بمكة المكرمة',
      trackId: 'adhan_fajr',
      rawSoundName: 'adhan_fajr',
    ),
    WakeUpAlarmTone(
      id: 'adhan_cairo_refaat',
      title: 'أذان الفجر المصري — الشيخ محمد رفعت',
      subtitle: 'نداء الفجر الأصيل من تراث إذاعة القرآن الكريم بالقاهرة',
      trackId: 'adhan_cairo_refaat',
      rawSoundName: 'adhan_cairo',
    ),
    WakeUpAlarmTone(
      id: 'adhan_hussary',
      title: 'نداء الفجر — الشيخ محمود خليل الحصري',
      subtitle: 'أداء هادئ ومتقن بمقام البيات يوقظ القلب بسكينة',
      trackId: 'adhan_hussary',
      rawSoundName: 'adhan_hussary',
    ),
    WakeUpAlarmTone(
      id: 'adhan_madinah',
      title: 'أذان المسجد النبوي الشريف الهادئ',
      subtitle: 'روحانية المدينة المنورة للاستيقاظ الهادئ بدون فزع',
      trackId: 'adhan_madinah',
      rawSoundName: 'adhan_madinah',
    ),
    WakeUpAlarmTone(
      id: 'duaa_sharawi_post_prayer',
      title: 'مناجاة ودعاء الشيخ محمد متولي الشعراوي',
      subtitle: 'ابتهال ودعاء بصوت إمام الدعاة يبعث الهمة لقيام الليل والفجر',
      trackId: 'duaa_sharawi_post_prayer',
      rawSoundName: 'duaa_sharawi_post_prayer',
    ),
    WakeUpAlarmTone(
      id: 'approaching_fajr',
      title: 'التنبيه الصوتي: «اقتربت صلاة الفجر فاستعد»',
      subtitle: 'رسالة صوتية واضحة لتنبيهك باقتراب الفجر والوضوء',
      trackId: 'adhan_fajr',
      rawSoundName: 'approaching_fajr',
    ),
    WakeUpAlarmTone(
      id: 'takbeerat',
      title: 'نغمة تكبيرات الإحرام والفجر السريعة',
      subtitle: 'نغمة قصيرة ومبهجة للاستيقاظ السريع',
      trackId: 'takbeerat',
      rawSoundName: 'takbeerat',
    ),
  ];

  WakeUpAlarmTone getToneById(String id) {
    return availableTones.firstWhere(
      (t) => t.id == id,
      orElse: () => availableTones.first,
    );
  }

  Future<void> init({bool forceReload = false}) async {
    if (_initialized && !forceReload) return;
    final prefs = await SharedPreferences.getInstance();
    _preFajrEnabled = prefs.getBool('wake_pre_fajr_enabled') ?? true;
    _preFajrMinutesBefore = prefs.getInt('wake_pre_fajr_minutes') ?? 25;
    _preFajrToneId = prefs.getString('wake_pre_fajr_tone') ?? 'adhan_fajr';

    _qiyamEnabled = prefs.getBool('wake_qiyam_enabled') ?? true;
    _qiyamMode = prefs.getString('wake_qiyam_mode') ?? 'last_third';
    _qiyamMinutesBeforeFajr = prefs.getInt('wake_qiyam_minutes_before') ?? 60;
    _qiyamFixedHour = prefs.getInt('wake_qiyam_fixed_hour') ?? 3;
    _qiyamFixedMinute = prefs.getInt('wake_qiyam_fixed_minute') ?? 15;
    _qiyamToneId =
        prefs.getString('wake_qiyam_tone') ?? 'duaa_sharawi_post_prayer';

    _initialized = true;
    await scheduleAlarms();
    notifyListeners();
  }

  /// Calculates the next Fajr DateTime from PrayerService
  DateTime getNextFajrTime([PrayerData? data]) {
    final now = DateTime.now();
    final prayerData = data ?? PrayerService.instance.currentData;
    if (prayerData != null && prayerData.prayers.isNotEmpty) {
      final fajr = prayerData.prayers.firstWhere(
        (p) => p.name.contains('الفجر'),
        orElse: () => prayerData.prayers.first,
      );
      if (fajr.time.isAfter(now)) {
        return fajr.time;
      }
      return fajr.time.add(const Duration(days: 1));
    }
    // Fallback default 04:45 AM
    final candidate = DateTime(now.year, now.month, now.day, 4, 45);
    return candidate.isAfter(now)
        ? candidate
        : candidate.add(const Duration(days: 1));
  }

  /// Calculates the exact Pre-Fajr Wake-Up Alarm DateTime
  DateTime getNextPreFajrWakeTime([PrayerData? data]) {
    final now = DateTime.now();
    final fajr = getNextFajrTime(data);
    final candidate = fajr.subtract(Duration(minutes: _preFajrMinutesBefore));
    if (candidate.isAfter(now)) {
      return candidate;
    }
    return candidate.add(const Duration(days: 1));
  }

  /// Calculates the astronomical start of the Last Third of the Night (الثلث الأخير من الليل)
  DateTime getLastThirdOfNightStart([PrayerData? data]) {
    final now = DateTime.now();
    final prayerData = data ?? PrayerService.instance.currentData;
    DateTime maghribTime;
    DateTime fajrTime = getNextFajrTime(data);

    if (prayerData != null && prayerData.prayers.isNotEmpty) {
      final maghrib = prayerData.prayers.firstWhere(
        (p) => p.name.contains('المغرب'),
        orElse: () => prayerData.prayers.last,
      );
      maghribTime = DateTime(
        fajrTime.year,
        fajrTime.month,
        fajrTime.day,
        maghrib.time.hour,
        maghrib.time.minute,
      ).subtract(const Duration(days: 1));
    } else {
      maghribTime = DateTime(
        fajrTime.year,
        fajrTime.month,
        fajrTime.day,
        18,
        0,
      ).subtract(const Duration(days: 1));
    }

    final nightDurationMinutes = fajrTime.difference(maghribTime).inMinutes;
    final twoThirdsMinutes = (nightDurationMinutes * 2 / 3).round();
    final lastThirdStart = maghribTime.add(Duration(minutes: twoThirdsMinutes));
    if (lastThirdStart.isAfter(now)) {
      return lastThirdStart;
    }
    return lastThirdStart.add(const Duration(days: 1));
  }

  /// Calculates the next Qiyam Al-Layl Wake-Up Alarm DateTime based on selected mode
  DateTime getNextQiyamWakeTime([PrayerData? data]) {
    final now = DateTime.now();
    if (_qiyamMode == 'last_third') {
      return getLastThirdOfNightStart(data);
    } else if (_qiyamMode == 'before_fajr') {
      final fajr = getNextFajrTime(data);
      final candidate =
          fajr.subtract(Duration(minutes: _qiyamMinutesBeforeFajr));
      return candidate.isAfter(now)
          ? candidate
          : candidate.add(const Duration(days: 1));
    } else {
      final candidate = DateTime(
        now.year,
        now.month,
        now.day,
        _qiyamFixedHour,
        _qiyamFixedMinute,
      );
      return candidate.isAfter(now)
          ? candidate
          : candidate.add(const Duration(days: 1));
    }
  }

  String formatTimeAr(DateTime dt) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'صباحاً' : 'مساءً';
    final minStr = dt.minute.toString().padLeft(2, '0');
    return '${hour12.toString().padLeft(2, '0')}:$minStr $period';
  }

  Future<void> setPreFajrEnabled(bool enabled) async {
    _preFajrEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wake_pre_fajr_enabled', enabled);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setPreFajrMinutesBefore(int minutes) async {
    _preFajrMinutesBefore = minutes.clamp(5, 120);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wake_pre_fajr_minutes', _preFajrMinutesBefore);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setPreFajrTone(String toneId) async {
    _preFajrToneId = toneId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wake_pre_fajr_tone', toneId);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setQiyamEnabled(bool enabled) async {
    _qiyamEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wake_qiyam_enabled', enabled);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setQiyamMode(String mode) async {
    _qiyamMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wake_qiyam_mode', mode);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setQiyamMinutesBeforeFajr(int minutes) async {
    _qiyamMinutesBeforeFajr = minutes.clamp(20, 180);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wake_qiyam_minutes_before', _qiyamMinutesBeforeFajr);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setQiyamFixedTime(int hour, int minute) async {
    _qiyamFixedHour = hour.clamp(0, 23);
    _qiyamFixedMinute = minute.clamp(0, 59);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wake_qiyam_fixed_hour', _qiyamFixedHour);
    await prefs.setInt('wake_qiyam_fixed_minute', _qiyamFixedMinute);
    await scheduleAlarms();
    notifyListeners();
  }

  Future<void> setQiyamTone(String toneId) async {
    _qiyamToneId = toneId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wake_qiyam_tone', toneId);
    await scheduleAlarms();
    notifyListeners();
  }

  /// Previews the selected wake-up tone immediately using IslamicAudioService
  Future<void> previewTone(String toneId) async {
    final tone = getToneById(toneId);
    if (toneId == 'approaching_fajr') {
      await IslamicAudioService.instance.stop();
      await IslamicAudioService.instance.playApproachingPrayerAudio('الفجر');
      return;
    }
    await IslamicAudioService.instance.playTrackById(tone.trackId);
  }

  /// Schedules the actual OS alarm notifications for Pre-Fajr and Qiyam Al-Layl
  Future<void> scheduleAlarms([PrayerData? data]) async {
    try {
      try {
        tz_data.initializeTimeZones();
      } catch (_) {}
      // Cancel previous IDs 880 (Pre-Fajr) and 881 (Qiyam)
      await _notifications.cancel(880);
      await _notifications.cancel(881);

      if (_preFajrEnabled) {
        final wakeTime = getNextPreFajrWakeTime(data);
        final tzWake = tz.TZDateTime.from(wakeTime, tz.local);
        final tone = getToneById(_preFajrToneId);

        final androidDetails = AndroidNotificationDetails(
          'fajr_wakeup_alarm_${tone.rawSoundName}',
          'منبه الاستيقاظ والاستعداد لصلاة الفجر',
          channelDescription: 'منبه صوتي لإيقاظك قبل أذان الفجر بالوقت والنغمة المحددين',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(tone.rawSoundName),
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );

        await _notifications.zonedSchedule(
          880,
          'منبّه الاستعداد لصلاة الفجر 🌅 (باقي $_preFajrMinutesBefore دقيقة)',
          'قم فتوضأ واستعد لصلاة الفجر — «ركعتا الفجر خير من الدنيا وما فيها» (${tone.title})',
          tzWake,
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'type=adhan&prayer=الفجر',
        );
      }

      if (_qiyamEnabled) {
        final qiyamTime = getNextQiyamWakeTime(data);
        final tzQiyam = tz.TZDateTime.from(qiyamTime, tz.local);
        final tone = getToneById(_qiyamToneId);

        final androidDetails = AndroidNotificationDetails(
          'qiyam_wakeup_alarm_${tone.rawSoundName}',
          'منبه قيام الليل والتهجد الذكي',
          channelDescription: 'منبه صوتي لإيقاظك لقيام الليل والثلث الأخير',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(tone.rawSoundName),
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );

        await _notifications.zonedSchedule(
          881,
          'منبّه قيام الليل والثلث الأخير 🌙',
          'حان وقت الخلوة بالله في الثلث الأخير من الليل — وقت النزول الإلهي واستجابة الدعاء',
          tzQiyam,
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'type=adhan&prayer=الفجر',
        );
      }
    } catch (e) {
      debugPrint('FajrQiyamAlarmService schedule error: $e');
    }
  }

  /// Fires an immediate test of the Pre-Fajr or Qiyam alarm with audio & notification
  Future<void> triggerImmediateTestAlarm({required bool isQiyam}) async {
    final toneId = isQiyam ? _qiyamToneId : _preFajrToneId;
    await previewTone(toneId);
    try {
      final tone = getToneById(toneId);
      final androidDetails = AndroidNotificationDetails(
        'test_wakeup_alarm_${tone.rawSoundName}',
        isQiyam ? 'تجربة منبه قيام الليل' : 'تجربة منبه الاستعداد للفجر',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(tone.rawSoundName),
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
      await _notifications.show(
        isQiyam ? 883 : 882,
        isQiyam
            ? 'تجربة منبّه قيام الليل والثلث الأخير 🌙'
            : 'تجربة منبّه الاستعداد لصلاة الفجر 🌅 (قبل الفجر بـ $_preFajrMinutesBefore د)',
        'النغمة المختارة: ${tone.title}',
        NotificationDetails(android: androidDetails),
      );
    } catch (_) {}
  }

  Map<String, dynamic> exportData() => {
        'pre_fajr_enabled': _preFajrEnabled,
        'pre_fajr_minutes': _preFajrMinutesBefore,
        'pre_fajr_tone': _preFajrToneId,
        'qiyam_enabled': _qiyamEnabled,
        'qiyam_mode': _qiyamMode,
        'qiyam_minutes_before': _qiyamMinutesBeforeFajr,
        'qiyam_fixed_hour': _qiyamFixedHour,
        'qiyam_fixed_minute': _qiyamFixedMinute,
        'qiyam_tone': _qiyamToneId,
      };

  Future<void> importData(Map<String, dynamic> data) async {
    if (data['pre_fajr_enabled'] is bool) {
      await setPreFajrEnabled(data['pre_fajr_enabled'] as bool);
    }
    if (data['pre_fajr_minutes'] is int) {
      await setPreFajrMinutesBefore(data['pre_fajr_minutes'] as int);
    }
    if (data['pre_fajr_tone'] is String) {
      await setPreFajrTone(data['pre_fajr_tone'] as String);
    }
    if (data['qiyam_enabled'] is bool) {
      await setQiyamEnabled(data['qiyam_enabled'] as bool);
    }
    if (data['qiyam_mode'] is String) {
      await setQiyamMode(data['qiyam_mode'] as String);
    }
    if (data['qiyam_minutes_before'] is int) {
      await setQiyamMinutesBeforeFajr(data['qiyam_minutes_before'] as int);
    }
    if (data['qiyam_fixed_hour'] is int && data['qiyam_fixed_minute'] is int) {
      await setQiyamFixedTime(
        data['qiyam_fixed_hour'] as int,
        data['qiyam_fixed_minute'] as int,
      );
    }
    if (data['qiyam_tone'] is String) {
      await setQiyamTone(data['qiyam_tone'] as String);
    }
  }
}
