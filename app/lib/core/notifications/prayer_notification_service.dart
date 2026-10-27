import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../app/router.dart';
import '../services/islamic_audio_service.dart';
import '../services/prayer_service.dart';
import '../services/adhan_sensor_gesture_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.actionId == 'stop_adhan') {
    PrayerNotificationService.instance.stopAdhanAudio();
  } else if (notificationResponse.actionId == 'snooze_5') {
    PrayerNotificationService.instance.stopAdhanAudio();
    String prayer = 'الصلاة';
    final payload = notificationResponse.payload;
    if (payload != null && payload.isNotEmpty) {
      try {
        final uri = Uri.parse('app://adhan?$payload');
        prayer = uri.queryParameters['prayer'] ?? 'الصلاة';
      } catch (_) {}
    }
    PrayerNotificationService.instance.snoozeAdhan(5, prayer);
  }
}

enum AdhanSoundMode {
  fullAdhan,
  takbeerat,
  softBeep,
  vibrateOnly,
  silent,
}

class PrayerNotificationService extends ChangeNotifier {
  static final PrayerNotificationService instance = PrayerNotificationService._internal();
  PrayerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static final StreamController<String> _adhanEventStream = StreamController<String>.broadcast();
  static Stream<String> get adhanEventStream => _adhanEventStream.stream;

  bool _masterEnabled = true;
  AdhanSoundMode _soundMode = AdhanSoundMode.fullAdhan;
  bool _vibrateOnStop = true;
  DateTime? _muteUntil;
  String _selectedAdhanVoice = 'adhan_makkah';
  String _selectedFajrVoice = 'adhan_fajr';
  final Map<String, String> _prayerAdhanVoices = {
    'الفجر': 'adhan_fajr',
    'الظهر': 'adhan_makkah',
    'العصر': 'adhan_madinah',
    'المغرب': 'adhan_cairo',
    'العشاء': 'adhan_aqsa',
  };
  String _selectedIqamahVoice = 'iqamah_full';
  bool _iqamahReminderEnabled = true;
  int _iqamahOffsetMinutes = 15;
  bool _preReminderEnabled = true;
  int _preReminderMinutes = 10;
  bool _preReminderVoiceEnabled = true;
  final Map<String, bool> _preReminderPrayerToggles = {
    'الفجر': true,
    'الظهر': true,
    'العصر': true,
    'المغرب': true,
    'العشاء': true,
  };
  bool _qiyamReminderEnabled = true;
  int _qiyamOffsetMinutes = 60;
  bool _fridayReminderEnabled = true;
  int _fridayReminderHour = 9;
  bool _duhaReminderEnabled = true;
  int _duhaReminderMinutesAfterSunrise = 25;
  bool _fajrDistinctVoiceEnabled = true;
  bool _postPrayerAdhkarReminderEnabled = true;
  int _postPrayerAdhkarMinutes = 5;

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
  bool get vibrateOnStop => _vibrateOnStop;
  DateTime? get muteUntil => _muteUntil;
  bool get isTemporarilyMuted => _muteUntil != null && _muteUntil!.isAfter(DateTime.now());
  String get selectedAdhanVoice => _selectedAdhanVoice;
  String get selectedFajrVoice => _selectedFajrVoice;
  Map<String, String> get prayerAdhanVoices => Map.unmodifiable(_prayerAdhanVoices);

  String getPrayerVoice(String prayerName) {
    if (prayerName.contains('فجر') || prayerName.contains('الفجر')) {
      return _prayerAdhanVoices['الفجر'] ?? _selectedFajrVoice;
    }
    return _prayerAdhanVoices[prayerName] ?? _selectedAdhanVoice;
  }
  String get selectedIqamahVoice => _selectedIqamahVoice;
  bool get iqamahReminderEnabled => _iqamahReminderEnabled;
  int get iqamahOffsetMinutes => _iqamahOffsetMinutes;
  bool get preReminderEnabled => _preReminderEnabled;
  int get preReminderMinutes => _preReminderMinutes;
  bool get preReminderVoiceEnabled => _preReminderVoiceEnabled;
  Map<String, bool> get preReminderPrayerToggles => _preReminderPrayerToggles;
  bool isPreReminderPrayerEnabled(String prayerName) => _preReminderPrayerToggles[prayerName] ?? true;
  bool get qiyamReminderEnabled => _qiyamReminderEnabled;
  int get qiyamOffsetMinutes => _qiyamOffsetMinutes;
  bool get fridayReminderEnabled => _fridayReminderEnabled;
  int get fridayReminderHour => _fridayReminderHour;
  bool get duhaReminderEnabled => _duhaReminderEnabled;
  int get duhaReminderMinutesAfterSunrise => _duhaReminderMinutesAfterSunrise;
  bool get fajrDistinctVoiceEnabled => _fajrDistinctVoiceEnabled;
  bool get postPrayerAdhkarReminderEnabled => _postPrayerAdhkarReminderEnabled;
  int get postPrayerAdhkarMinutes => _postPrayerAdhkarMinutes;
  Map<String, bool> get prayerToggles => _prayerToggles;

  bool isPrayerEnabled(String prayerName) => _prayerToggles[prayerName] ?? true;

  static bool _tzInitialized = false;

  static void _ensureTimeZonesInitialized() {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      _tzInitialized = true;
    }
  }

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;

    _ensureTimeZonesInitialized();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Local timezone detection fallback: $e');
    }

    const androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationResponse(response);
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      final launchDetails = await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchDetails?.notificationResponse != null) {
        final payload = launchDetails!.notificationResponse!.payload;
        if (payload != null && payload.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handlePayloadNavigation(payload);
          });
        }
      }
    } catch (e) {
      debugPrint('Notification init exception: $e');
    }

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      try {
        await androidPlugin.requestNotificationsPermission();
      } catch (e) {
        debugPrint('requestNotificationsPermission error: $e');
      }
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('requestExactAlarmsPermission error: $e');
      }

      await _createNotificationChannels(androidPlugin);
    }

    final prefs = await SharedPreferences.getInstance();
    _masterEnabled = prefs.getBool('notif_master_enabled') ?? true;
    _preReminderEnabled = prefs.getBool('notif_pre_reminder_enabled') ?? true;
    _preReminderMinutes = prefs.getInt('notif_pre_reminder') ?? 10;
    _preReminderVoiceEnabled = prefs.getBool('notif_pre_reminder_voice_enabled') ?? true;
    for (final p in _preReminderPrayerToggles.keys) {
      _preReminderPrayerToggles[p] = prefs.getBool('notif_pre_reminder_prayer_$p') ?? true;
    }
    _selectedAdhanVoice = prefs.getString('notif_selected_adhan') ?? 'adhan_makkah';
    _selectedFajrVoice = prefs.getString('notif_selected_fajr_adhan') ?? 'adhan_fajr';
    for (final p in _prayerAdhanVoices.keys) {
      final defaultVoice = (p == 'الفجر') ? _selectedFajrVoice : _selectedAdhanVoice;
      _prayerAdhanVoices[p] = prefs.getString('notif_prayer_voice_$p') ?? defaultVoice;
    }
    _selectedIqamahVoice = prefs.getString('notif_selected_iqamah') ?? 'iqamah_full';
    _iqamahReminderEnabled = prefs.getBool('notif_iqamah_enabled') ?? true;
    _iqamahOffsetMinutes = prefs.getInt('notif_iqamah_offset') ?? 15;
    _qiyamReminderEnabled = prefs.getBool('notif_qiyam_enabled') ?? true;
    _qiyamOffsetMinutes = prefs.getInt('notif_qiyam_offset') ?? 60;
    _fridayReminderEnabled = prefs.getBool('notif_friday_enabled') ?? true;
    _fridayReminderHour = prefs.getInt('notif_friday_hour') ?? 9;
    _duhaReminderEnabled = prefs.getBool('notif_duha_enabled') ?? true;
    _duhaReminderMinutesAfterSunrise = prefs.getInt('notif_duha_offset') ?? 25;
    _fajrDistinctVoiceEnabled = prefs.getBool('notif_fajr_distinct') ?? true;
    _postPrayerAdhkarReminderEnabled = prefs.getBool('notif_post_adhkar_enabled') ?? true;
    _postPrayerAdhkarMinutes = prefs.getInt('notif_post_adhkar_offset') ?? 5;

    _vibrateOnStop = prefs.getBool('notif_vibrate_on_stop') ?? true;
    final muteStr = prefs.getString('notif_mute_until');
    if (muteStr != null) {
      final parsed = DateTime.tryParse(muteStr);
      if (parsed != null && parsed.isAfter(DateTime.now())) {
        _muteUntil = parsed;
      }
    }

    final soundStr = prefs.getString('notif_sound_mode') ?? 'fullAdhan';
    _soundMode = AdhanSoundMode.values.firstWhere(
      (m) => m.name == soundStr,
      orElse: () => AdhanSoundMode.fullAdhan,
    );

    for (final p in _prayerToggles.keys) {
      _prayerToggles[p] = prefs.getBool('notif_prayer_$p') ?? (p != 'الشروق');
    }

    try {
      await AdhanSensorGestureService.instance.init();
    } catch (_) {}

    _isInitialized = true;
    notifyListeners();
  }

  /// Stops current playing Adhan audio through the audio service
  void stopAdhanAudio() {
    try {
      IslamicAudioService.instance.stop();
    } catch (_) {}
  }

  /// Snoozes Adhan alert for specified minutes and schedules follow-up reminder
  Future<void> snoozeAdhan(int minutes, [String? prayerName]) async {
    _ensureTimeZonesInitialized();
    stopAdhanAudio();
    final now = DateTime.now();
    final snoozeTime = now.add(Duration(minutes: minutes));
    final scheduledTz = tz.TZDateTime.from(snoozeTime, tz.local);
    final prayer = prayerName ?? 'الصلاة';

    const androidDetails = AndroidNotificationDetails(
      'prayer_reminder_channel',
      'تذكير ما بعد الغفوة',
      channelDescription: 'تنبيه الأذان بعد انتهاء فترة الغفوة',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      actions: [
        AndroidNotificationAction(
          'open_interactive',
          'فتح الشاشة التفاعلية 🕌',
          showsUserInterface: true,
        ),
      ],
    );

    try {
      await _localNotifications.zonedSchedule(
        995,
        'تذكير أذان $prayer (غفوة $minutes دقائق) ⏰',
        'انتهت فترة الغفوة — حان وقت أداء الصلاة والتطهر والوقوف بين يدي الله',
        scheduledTz,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'type=adhan&prayer=$prayer',
      );
    } catch (e) {
      debugPrint('Snooze schedule error: $e');
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.actionId == 'stop_adhan') {
      stopAdhanAudio();
      return;
    }
    if (response.actionId == 'snooze_5') {
      stopAdhanAudio();
      String prayer = 'الصلاة';
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        try {
          final uri = Uri.parse('app://adhan?$payload');
          prayer = uri.queryParameters['prayer'] ?? 'الصلاة';
        } catch (_) {}
      }
      snoozeAdhan(5, prayer);
      return;
    }

    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      _adhanEventStream.add(payload);
      _handlePayloadNavigation(payload);
    }
  }

  void _handlePayloadNavigation(String payload) {
    try {
      final uri = Uri.parse('app://adhan?$payload');
      final prayer = uri.queryParameters['prayer'] ?? 'الظهر';
      final isIqamah = uri.queryParameters['type'] == 'iqamah';

      appRouter.push(
        '/adhan-control?prayer=${Uri.encodeComponent(prayer)}&isIqamah=$isIqamah&autoPlay=true',
      );
    } catch (e) {
      debugPrint('Payload navigation error: $e');
    }
  }

  /// Checks whether battery optimization exemption has been granted
  Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Requests battery optimization exemption for uninterrupted background alarms
  Future<bool> requestIgnoreBatteryOptimizations() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<void> _createNotificationChannels(AndroidFlutterLocalNotificationsPlugin androidPlugin) async {
    final List<AndroidNotificationChannel> channels = [
      const AndroidNotificationChannel(
        'prayer_adhan_makkah_channel',
        'أذان المسجد الحرام (مكة المكرمة)',
        description: 'تنبيه نداء الحق بصوت الشيخ علي ملا',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_makkah'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_adhan_madinah_channel',
        'أذان المسجد النبوي (المدينة المنورة)',
        description: 'تنبيه نداء الحق من رحاب المسجد النبوي الشريف',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_madinah'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_adhan_cairo_channel',
        'أذان القاهرة ومصر (الشيخ محمد رفعت)',
        description: 'نداء الحق التاريخي لجامع الأزهر الشريف',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_cairo'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_adhan_aqsa_channel',
        'أذان المسجد الأقصى المبارك',
        description: 'نداء الحق الخالد من مسرى رسول الله ﷺ',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_aqsa'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_adhan_hussary_channel',
        'أذان الشيخ محمود خليل الحصري',
        description: 'أذان خاشع بمقام البيات المتزن',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_hussary'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_adhan_fajr_channel',
        'أذان الفجر المبارك (الصلاة خير من النوم)',
        description: 'نداء الفجر الخاص بدخول وقت الفجر',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('adhan_fajr'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_takbeerat_channel',
        'تكبيرات الأذان والعيدين',
        description: 'تكبيرات سريعة وخفيفة للتنبيه',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('takbeerat'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_softbeep_channel',
        'نغمة إشعار هادئة للتنبيه',
        description: 'إشعار النظام القياسي عند دخول الوقت',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_silent_channel',
        'تنبيه صامت (بدون صوت)',
        description: 'إشعار بصري فقط على شاشة القفل دون رنين',
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
      ),
      const AndroidNotificationChannel(
        'prayer_vibrate_channel',
        'تنبيه اهتزاز فقط (بدون رنين)',
        description: 'اهتزاز قوي عند دخول وقت الصلاة دون تشغيل صوت الأذان',
        importance: Importance.max,
        playSound: false,
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_iqamah_channel',
        'تنبيه إقامة الصلاة',
        description: 'تنبيه بحلول وقت إقامة الصلاة بصوت الإقامة',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('iqamah'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_reminder_channel',
        'تذكير ما قبل الصلاة (افتراضي)',
        description: 'تذكير مسبق قبل حلول الأذان للاستعداد والتطهر',
        importance: Importance.high,
      ),
      const AndroidNotificationChannel(
        'prayer_approaching_fajr_channel',
        'تنبيه اقتراب صلاة الفجر (صوتي)',
        description: 'تنبيه صوتي مسبق: اقتربت صلاة الفجر يرجى الاستعداد والتطهر',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('approaching_fajr'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_approaching_dhuhr_channel',
        'تنبيه اقتراب صلاة الظهر (صوتي)',
        description: 'تنبيه صوتي مسبق: اقتربت صلاة الظهر يرجى الاستعداد والتطهر',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('approaching_dhuhr'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_approaching_asr_channel',
        'تنبيه اقتراب صلاة العصر (صوتي)',
        description: 'تنبيه صوتي مسبق: اقتربت صلاة العصر يرجى الاستعداد والتطهر',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('approaching_asr'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_approaching_maghrib_channel',
        'تنبيه اقتراب صلاة المغرب (صوتي)',
        description: 'تنبيه صوتي مسبق: اقتربت صلاة المغرب يرجى الاستعداد والتطهر',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('approaching_maghrib'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_approaching_isha_channel',
        'تنبيه اقتراب صلاة العشاء (صوتي)',
        description: 'تنبيه صوتي مسبق: اقتربت صلاة العشاء يرجى الاستعداد والتطهر',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('approaching_isha'),
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_qiyam_channel',
        'تنبيه قيام الليل والتهجد',
        description: 'تذكير بالثلث الأخير من الليل لقيام الليل والدعاء',
        importance: Importance.max,
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_friday_channel',
        'تذكير سنن يوم الجمعة',
        description: 'تذكير بقراءة سورة الكهف والصلاة على النبي ﷺ',
        importance: Importance.high,
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_duha_channel',
        'تذكير صلاة الضحى',
        description: 'صلاة الأوابين بعد شروق الشمس بـ ٢٠-٣٠ دقيقة',
        importance: Importance.high,
        enableVibration: true,
      ),
      const AndroidNotificationChannel(
        'prayer_post_adhkar_channel',
        'أذكار ما بعد الصلاة المكتوبة',
        description: 'تذكير بالاستغفار والتسبيح وقراءة آية الكرسي دبر كل صلاة',
        importance: Importance.high,
      ),
    ];

    for (final ch in channels) {
      try {
        await androidPlugin.createNotificationChannel(ch);
      } catch (e) {
        debugPrint('Channel create error for ${ch.id}: $e');
      }
    }
  }

  Future<void> toggleMaster(bool enabled) async {
    _masterEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_master_enabled', enabled);
    if (!enabled) {
      await cancelAll();
    } else {
      rescheduleCurrentPrayers();
    }
    notifyListeners();
  }

  Future<void> togglePrayer(String prayerName, bool enabled) async {
    _prayerToggles[prayerName] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_prayer_$prayerName', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setSoundMode(AdhanSoundMode mode) async {
    _soundMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_sound_mode', mode.name);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> toggleVibrateOnStop(bool enabled) async {
    _vibrateOnStop = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_vibrate_on_stop', enabled);
    notifyListeners();
  }

  Future<void> muteForDuration(Duration duration) async {
    _muteUntil = DateTime.now().add(duration);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_mute_until', _muteUntil!.toIso8601String());
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> cancelTemporaryMute() async {
    _muteUntil = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notif_mute_until');
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setSelectedAdhanVoice(String voiceKey) async {
    _selectedAdhanVoice = voiceKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_selected_adhan', voiceKey);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setPrayerVoice(String prayerName, String voiceKey) async {
    _prayerAdhanVoices[prayerName] = voiceKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_prayer_voice_$prayerName', voiceKey);
    if (prayerName.contains('فجر') || prayerName.contains('الفجر')) {
      _selectedFajrVoice = voiceKey;
      await prefs.setString('notif_selected_fajr_adhan', voiceKey);
    } else {
      _selectedAdhanVoice = voiceKey;
      await prefs.setString('notif_selected_adhan', voiceKey);
    }
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setAllPrayersVoice(String voiceKey) async {
    final prefs = await SharedPreferences.getInstance();
    for (final p in _prayerAdhanVoices.keys) {
      _prayerAdhanVoices[p] = voiceKey;
      await prefs.setString('notif_prayer_voice_$p', voiceKey);
    }
    _selectedAdhanVoice = voiceKey;
    await prefs.setString('notif_selected_adhan', voiceKey);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setSelectedFajrVoice(String voiceKey) async {
    _selectedFajrVoice = voiceKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_selected_fajr_adhan', voiceKey);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setSelectedIqamahVoice(String voiceKey) async {
    _selectedIqamahVoice = voiceKey;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_selected_iqamah', voiceKey);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> toggleIqamahReminder(bool enabled) async {
    _iqamahReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_iqamah_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setPrayerCustomVoice(String prayerName, String voiceKey) => setPrayerVoice(prayerName, voiceKey);
  Future<void> setIqamahVoice(String voiceKey) => setSelectedIqamahVoice(voiceKey);
  Future<void> setPreReminderMinutes(int minutes) => setPreReminder(minutes);
  Future<void> setIqamahOffsetMinutes(int minutes) => setIqamahOffset(minutes);

  Future<void> setIqamahOffset(int minutes) async {
    _iqamahOffsetMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_iqamah_offset', minutes);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> togglePreReminder(bool enabled) async {
    _preReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_pre_reminder_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setPreReminder(int minutes) async {
    _preReminderMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_pre_reminder', minutes);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> togglePreReminderVoice(bool enabled) async {
    _preReminderVoiceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_pre_reminder_voice_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> togglePreReminderPrayer(String prayerName, bool enabled) async {
    _preReminderPrayerToggles[prayerName] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_pre_reminder_prayer_$prayerName', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> toggleQiyamReminder(bool enabled) async {
    _qiyamReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_qiyam_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setQiyamOffset(int minutes) async {
    _qiyamOffsetMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_qiyam_offset', minutes);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> toggleFridayReminder(bool enabled) async {
    _fridayReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_friday_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setFridayReminderHour(int hour) async {
    _fridayReminderHour = hour;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_friday_hour', hour);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> toggleDuhaReminder(bool enabled) async {
    _duhaReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_duha_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setDuhaOffset(int minutes) async {
    _duhaReminderMinutesAfterSunrise = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_duha_offset', minutes);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> toggleFajrDistinctVoice(bool enabled) async {
    _fajrDistinctVoiceEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_fajr_distinct', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> togglePostPrayerAdhkar(bool enabled) async {
    _postPrayerAdhkarReminderEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_post_adhkar_enabled', enabled);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  Future<void> setPostPrayerAdhkarOffset(int minutes) async {
    _postPrayerAdhkarMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_post_adhkar_offset', minutes);
    rescheduleCurrentPrayers();
    notifyListeners();
  }

  void rescheduleCurrentPrayers() {
    final cur = PrayerService.instance.currentData;
    if (cur != null) {
      schedulePrayerNotifications(cur);
    }
  }

  /// Sends an immediate test notification to verify audio & notification display
  Future<void> sendTestNotification({String? customVoice}) async {
    final voice = customVoice ?? _selectedAdhanVoice;
    final channelId = _resolveChannelIdForVoice(voice, isFajr: false);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'تجربة تنبيه الأذان',
      channelDescription: 'فحص فوري لصوت التنبيه وقناة الأذان',
      importance: Importance.max,
      priority: Priority.high,
      playSound: _soundMode != AdhanSoundMode.silent,
      sound: _resolveSoundForVoice(voice, isFajr: false),
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      actions: const [
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف الأذان ⏹️',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze_5',
          'غفوة ٥ دقائق ⏰',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'open_interactive',
          'فتح الشاشة التفاعلية 🕌',
          showsUserInterface: true,
        ),
      ],
    );

    await _localNotifications.show(
      999,
      'تجربة نداء الأذان 🕌 — تطبيق نور المؤمن',
      'الله أكبر، الله أكبر.. خدمة الأذان والتنبيهات تعمل بأعلى كفاءة وجاهزية',
      NotificationDetails(android: androidDetails),
      payload: 'type=adhan&prayer=الظهر',
    );
  }

  /// Sends an immediate test Iqamah notification to verify alert sound
  Future<void> sendTestIqamahNotification({String? customVoice}) async {
    final voiceKey = customVoice ?? _selectedIqamahVoice;
    final rawSoundName = IslamicAudioService.allTracks
            .where((t) => t.id == voiceKey)
            .map((t) => t.rawNotificationSound)
            .firstOrNull ??
        'iqamah';
    final androidDetails = AndroidNotificationDetails(
      'prayer_iqamah_channel',
      'تنبيه إقامة الصلاة',
      channelDescription: 'تنبيه بحلول وقت إقامة الصلاة المكتوبة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: _soundMode != AdhanSoundMode.silent,
      sound: RawResourceAndroidNotificationSound(rawSoundName),
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      actions: const [
        AndroidNotificationAction(
          'stop_adhan',
          'إيقاف ⏹️',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'open_interactive',
          'فتح الشاشة 🕌',
          showsUserInterface: true,
        ),
      ],
    );

    await _localNotifications.show(
      998,
      'تجربة إقامة الصلاة 🕌 — تطبيق نور المؤمن',
      'قد قامت الصلاة، قد قامت الصلاة.. استعد للوقوف بين يدي الله بسكينة وخشوع',
      NotificationDetails(android: androidDetails),
      payload: 'type=iqamah&prayer=الظهر',
    );
  }

  String _resolveChannelIdForVoice(String voiceKey, {required bool isFajr}) {
    if (_soundMode == AdhanSoundMode.silent) {
      return 'prayer_silent_channel';
    }
    if (_soundMode == AdhanSoundMode.vibrateOnly) {
      return 'prayer_vibrate_channel';
    }
    if (_soundMode == AdhanSoundMode.softBeep) {
      return 'prayer_softbeep_channel';
    }
    if (_soundMode == AdhanSoundMode.takbeerat) {
      return 'prayer_takbeerat_channel';
    }

    switch (voiceKey) {
      case 'adhan_madinah':
      case 'adhan_fajr_madinah':
        return 'prayer_adhan_madinah_channel';
      case 'adhan_cairo':
      case 'adhan_cairo_refaat':
        return 'prayer_adhan_cairo_channel';
      case 'adhan_aqsa':
      case 'adhan_fajr_aqsa':
        return 'prayer_adhan_aqsa_channel';
      case 'adhan_hussary':
        return 'prayer_adhan_hussary_channel';
      case 'adhan_fajr':
        return 'prayer_adhan_fajr_channel';
      case 'takbeerat':
        return 'prayer_takbeerat_channel';
      case 'adhan_makkah':
      default:
        return 'prayer_adhan_makkah_channel';
    }
  }

  AndroidNotificationSound? _resolveSoundForVoice(String voiceKey, {required bool isFajr}) {
    if (_soundMode == AdhanSoundMode.silent || _soundMode == AdhanSoundMode.vibrateOnly) {
      return null;
    }
    if (_soundMode == AdhanSoundMode.softBeep) {
      return null; // Uses device default notification sound
    }
    if (_soundMode == AdhanSoundMode.takbeerat) {
      return const RawResourceAndroidNotificationSound('takbeerat');
    }

    switch (voiceKey) {
      case 'adhan_madinah':
      case 'adhan_fajr_madinah':
        return const RawResourceAndroidNotificationSound('adhan_madinah');
      case 'adhan_cairo':
      case 'adhan_cairo_refaat':
        return const RawResourceAndroidNotificationSound('adhan_cairo');
      case 'adhan_aqsa':
      case 'adhan_fajr_aqsa':
        return const RawResourceAndroidNotificationSound('adhan_aqsa');
      case 'adhan_hussary':
        return const RawResourceAndroidNotificationSound('adhan_hussary');
      case 'adhan_fajr':
        return const RawResourceAndroidNotificationSound('adhan_fajr');
      case 'takbeerat':
        return const RawResourceAndroidNotificationSound('takbeerat');
      case 'adhan_makkah':
      default:
        return const RawResourceAndroidNotificationSound('adhan_makkah');
    }
  }

  String _resolveApproachingChannelId(String prayerName) {
    if (!_preReminderVoiceEnabled || _soundMode == AdhanSoundMode.silent) {
      return 'prayer_reminder_channel';
    }
    if (prayerName.contains('فجر') || prayerName.contains('الفجر')) {
      return 'prayer_approaching_fajr_channel';
    } else if (prayerName.contains('ظهر') || prayerName.contains('الظهر')) {
      return 'prayer_approaching_dhuhr_channel';
    } else if (prayerName.contains('عصر') || prayerName.contains('العصر')) {
      return 'prayer_approaching_asr_channel';
    } else if (prayerName.contains('مغرب') || prayerName.contains('المغرب')) {
      return 'prayer_approaching_maghrib_channel';
    } else if (prayerName.contains('عشاء') || prayerName.contains('العشاء')) {
      return 'prayer_approaching_isha_channel';
    }
    return 'prayer_reminder_channel';
  }

  AndroidNotificationSound? _resolveApproachingSound(String prayerName) {
    if (!_preReminderVoiceEnabled ||
        _soundMode == AdhanSoundMode.silent ||
        _soundMode == AdhanSoundMode.vibrateOnly) {
      return null;
    }
    if (prayerName.contains('فجر') || prayerName.contains('الفجر')) {
      return const RawResourceAndroidNotificationSound('approaching_fajr');
    } else if (prayerName.contains('ظهر') || prayerName.contains('الظهر')) {
      return const RawResourceAndroidNotificationSound('approaching_dhuhr');
    } else if (prayerName.contains('عصر') || prayerName.contains('العصر')) {
      return const RawResourceAndroidNotificationSound('approaching_asr');
    } else if (prayerName.contains('مغرب') || prayerName.contains('المغرب')) {
      return const RawResourceAndroidNotificationSound('approaching_maghrib');
    } else if (prayerName.contains('عشاء') || prayerName.contains('العشاء')) {
      return const RawResourceAndroidNotificationSound('approaching_isha');
    }
    return null;
  }

  Future<void> sendTestPreReminderNotification(String prayerName) async {
    final approChannelId = _resolveApproachingChannelId(prayerName);
    final approSound = _resolveApproachingSound(prayerName);

    final androidDetails = AndroidNotificationDetails(
      approChannelId,
      'تنبيه اقتراب الصلاة',
      channelDescription: 'تنبيه صوتي مسبق للاستعداد والتطهر للصلاة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: approSound != null,
      sound: approSound,
      enableVibration: true,
      category: AndroidNotificationCategory.reminder,
      actions: const [
        AndroidNotificationAction(
          'open_interactive',
          'فتح التطبيق 🕌',
          showsUserInterface: true,
        ),
      ],
    );

    await _localNotifications.show(
      996,
      'اقتربت صلاة $prayerName ⏳ (باقي $_preReminderMinutes دقائق)',
      'اقتربت صلاة $prayerName، يرجى الاستعداد والتطهر والتهيؤ للوقوف بين يدي الله',
      NotificationDetails(android: androidDetails),
      payload: 'type=prereminder&prayer=$prayerName',
    );
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
        if (isTemporarilyMuted && prayer.time.isBefore(_muteUntil!)) continue;

        // Schedule Main Adhan / Prayer Time Notification
        final scheduledTz = tz.TZDateTime.from(prayer.time, tz.local);

        final isFajr = prayer.name.contains('الفجر');
        final prayerVoice = getPrayerVoice(prayer.name);
        final channelId = _resolveChannelIdForVoice(prayerVoice, isFajr: isFajr);
        final sound = _resolveSoundForVoice(prayerVoice, isFajr: isFajr);

        final androidDetails = AndroidNotificationDetails(
          channelId,
          isFajr ? 'أذان الفجر المبارك' : 'مواقيت الصلاة والأذان',
          channelDescription: 'تنبيهات دخول أوقات الصلوات المفروضة ونداء الحق',
          importance: Importance.max,
          priority: Priority.high,
          playSound: _soundMode != AdhanSoundMode.silent && _soundMode != AdhanSoundMode.vibrateOnly,
          sound: sound,
          enableVibration: _soundMode != AdhanSoundMode.silent,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          actions: const [
            AndroidNotificationAction(
              'stop_adhan',
              'إيقاف الأذان ⏹️',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'snooze_5',
              'غفوة ٥ دقائق ⏰',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'open_interactive',
              'فتح الشاشة التفاعلية 🕌',
              showsUserInterface: true,
            ),
          ],
        );

        await _localNotifications.zonedSchedule(
          notificationId++,
          'حان الآن موعد صلاة ${prayer.name} 🕌',
          'الله أكبر الله أكبر — حي على الصلاة، حي على الفلاح (${data.locationName})',
          scheduledTz,
          NotificationDetails(android: androidDetails),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'type=adhan&prayer=${prayer.name}',
        );

        // Schedule Pre-reminder if enabled
        if (_preReminderEnabled && _preReminderMinutes > 0 && isPreReminderPrayerEnabled(prayer.name) && prayer.name != 'الشروق') {
          final preTime = prayer.time.subtract(Duration(minutes: _preReminderMinutes));
          if (preTime.isAfter(now)) {
            final preTz = tz.TZDateTime.from(preTime, tz.local);
            final approChannelId = _resolveApproachingChannelId(prayer.name);
            final approSound = _resolveApproachingSound(prayer.name);

            await _localNotifications.zonedSchedule(
              notificationId++,
              'اقتربت صلاة ${prayer.name} ⏳ (متبقي $_preReminderMinutes دقيقة)',
              'اقتربت صلاة ${prayer.name}، يرجى الاستعداد والتطهر والتهيؤ للوقوف بين يدي الله',
              preTz,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  approChannelId,
                  'تذكير اقتراب الصلاة',
                  channelDescription: 'تنبيه مسبق قبل حلول الأذان للاستعداد والتطهر',
                  importance: Importance.max,
                  priority: Priority.high,
                  playSound: approSound != null,
                  sound: approSound,
                  enableVibration: true,
                  category: AndroidNotificationCategory.reminder,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: 'type=prereminder&prayer=${prayer.name}',
            );
          }
        }

        // Schedule Iqamah Alert if enabled (and not Shurouq)
        if (_iqamahReminderEnabled && prayer.name != 'الشروق') {
          final iqamahTime = prayer.time.add(Duration(minutes: _iqamahOffsetMinutes));
          if (iqamahTime.isAfter(now)) {
            final iqamahTz = tz.TZDateTime.from(iqamahTime, tz.local);
            final iqamahRawSound = _selectedIqamahVoice == 'iqamah_short' ? 'takbeerat' : 'iqamah';
            final iqamahDetails = AndroidNotificationDetails(
              'prayer_iqamah_channel',
              'تنبيه إقامة الصلاة',
              channelDescription: 'تنبيه بحلول وقت إقامة الصلاة المكتوبة',
              importance: Importance.max,
              priority: Priority.high,
              playSound: _soundMode != AdhanSoundMode.silent && _soundMode != AdhanSoundMode.vibrateOnly,
              sound: RawResourceAndroidNotificationSound(iqamahRawSound),
              enableVibration: true,
              fullScreenIntent: true,
              category: AndroidNotificationCategory.alarm,
              actions: [
                AndroidNotificationAction(
                  'stop_adhan',
                  'إيقاف ⏹️',
                  showsUserInterface: false,
                  cancelNotification: true,
                ),
                AndroidNotificationAction(
                  'open_interactive',
                  'فتح الشاشة 🕌',
                  showsUserInterface: true,
                ),
              ],
            );

            await _localNotifications.zonedSchedule(
              notificationId++,
              'حان الآن موعد إقامة صلاة ${prayer.name} 🕌',
              'قد قامت الصلاة، أقبل على ربك بسكينة وخشوع (${data.locationName})',
              iqamahTz,
              NotificationDetails(android: iqamahDetails),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              payload: 'type=iqamah&prayer=${prayer.name}',
            );
          }
        }

        // Schedule Post-Prayer Adhkar Reminder (سنن وأذكار ما بعد الصلاة)
        if (_postPrayerAdhkarReminderEnabled && prayer.name != 'الشروق') {
          final adhkarTime = prayer.time.add(Duration(minutes: _iqamahOffsetMinutes + _postPrayerAdhkarMinutes));
          if (adhkarTime.isAfter(now)) {
            final adhkarTz = tz.TZDateTime.from(adhkarTime, tz.local);
            const adhkarDetails = AndroidNotificationDetails(
              'prayer_post_adhkar_channel',
              'أذكار ما بعد الصلاة المكتوبة',
              channelDescription: 'تذكير بالاستغفار والتسبيح وقراءة آية الكرسي دبر كل صلاة',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
            );

            await _localNotifications.zonedSchedule(
              notificationId++,
              'أذكار ما بعد صلاة ${prayer.name} 📿',
              'أستغفر الله، أستغفر الله، أستغفر الله.. اللهم أنت السلام ومنك السلام تباركت يا ذا الجلال والإكرام',
              adhkarTz,
              const NotificationDetails(android: adhkarDetails),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          }
        }
      }

      // Schedule Duha Prayer Reminder (صلاة الضحى والأوابين بعد الشروق)
      if (_duhaReminderEnabled) {
        final shurouqPrayer = data.prayers.firstWhere(
          (p) => p.name.contains('الشروق'),
          orElse: () => data.prayers.first,
        );
        final duhaTime = shurouqPrayer.time.add(Duration(minutes: _duhaReminderMinutesAfterSunrise));
        if (duhaTime.isAfter(now)) {
          final duhaTz = tz.TZDateTime.from(duhaTime, tz.local);
          const duhaDetails = AndroidNotificationDetails(
            'prayer_duha_channel',
            'تذكير صلاة الضحى',
            channelDescription: 'صلاة الأوابين بعد شروق الشمس بـ ٢٥ دقيقة',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
          );

          await _localNotifications.zonedSchedule(
            notificationId++,
            'صلاة الضحى (صلاة الأوابين) ☀️',
            'يصبح على كل سلامى من أحدكم صدقة.. وتجزئ من ذلك ركعتان يركعهما من الضحى',
            duhaTz,
            const NotificationDetails(android: duhaDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }

      // Schedule Qiyam Al-Layl & Tahajjud Reminder (قبل الفجر)
      if (_qiyamReminderEnabled) {
        final fajrPrayer = data.prayers.firstWhere(
          (p) => p.name.contains('الفجر'),
          orElse: () => data.prayers.first,
        );
        final qiyamTime = fajrPrayer.time.subtract(Duration(minutes: _qiyamOffsetMinutes));
        if (qiyamTime.isAfter(now)) {
          final qiyamTz = tz.TZDateTime.from(qiyamTime, tz.local);
          const qiyamDetails = AndroidNotificationDetails(
            'prayer_qiyam_channel',
            'تنبيه قيام الليل والتهجد',
            channelDescription: 'تذكير إيماني بالثلث الأخير من الليل لقيام الليل والوتر والدعاء',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
          );

          await _localNotifications.zonedSchedule(
            notificationId++,
            'قيام الليل والتهجد 🌙',
            'ركعتان في جوف الليل خير من الدنيا وما فيها — ثلث الليل الآخر وقت النزول الإلهي واستجابة الدعاء',
            qiyamTz,
            const NotificationDetails(android: qiyamDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }

      // Schedule Friday Sunnahs & Kahf Reminder (يوم الجمعة)
      if (_fridayReminderEnabled) {
        final daysUntilFriday = (DateTime.friday - now.weekday) % 7;
        final targetDate = now.add(Duration(days: daysUntilFriday));
        final fridayTime = DateTime(targetDate.year, targetDate.month, targetDate.day, _fridayReminderHour, 0);

        if (fridayTime.isAfter(now)) {
          final fridayTz = tz.TZDateTime.from(fridayTime, tz.local);
          const fridayDetails = AndroidNotificationDetails(
            'prayer_friday_channel',
            'تذكير سنن يوم الجمعة',
            channelDescription: 'تذكير بقراءة سورة الكهف، الصلاة على النبي ﷺ، وساعة الاستجابة',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
          );

          await _localNotifications.zonedSchedule(
            notificationId++,
            'سنن يوم الجمعة المباركة 🕌',
            'نور ما بين الجمعتين: قراءة سورة الكهف، الإكثار من الصلاة على النبي ﷺ، والدعاء في ساعة الاستجابة',
            fridayTz,
            const NotificationDetails(android: fridayDetails),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
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
