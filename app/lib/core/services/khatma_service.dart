import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class KhatmaPlan {
  final String id;
  final String title;
  int targetDays;
  DateTime startDate;
  final int startingPage;
  int currentPage;
  final bool splitByPrayer;
  List<String> completedPrayersToday;
  DateTime lastReadDate;
  bool isCompleted;
  bool reminderEnabled;
  int reminderHour;
  int reminderMinute;
  int? customDailyPace;

  KhatmaPlan({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    this.startingPage = 1,
    this.currentPage = 1,
    this.splitByPrayer = true,
    List<String>? completedPrayersToday,
    DateTime? lastReadDate,
    this.isCompleted = false,
    this.reminderEnabled = true,
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.customDailyPace,
  })  : completedPrayersToday = completedPrayersToday ?? [],
        lastReadDate = lastReadDate ?? DateTime.now();

  /// Total pages in Madinah Mushaf
  static const int totalMushafPages = 604;

  /// Total pages planned in this Khatma from [startingPage] to 604 (Bug #6 fix)
  int get totalPlannedPages => (totalMushafPages - startingPage + 1).clamp(1, totalMushafPages);

  /// Pages actually completed so far from [startingPage]
  int get pagesReadSoFar {
    if (isCompleted) return totalPlannedPages;
    return (currentPage - startingPage).clamp(0, totalPlannedPages);
  }

  /// Standard pages per day (ceil(totalPlannedPages / days) or custom pace)
  int get pagesPerDay => customDailyPace ?? (totalPlannedPages / targetDays.clamp(1, 365)).ceil();

  /// Standard pages per prayer if split across 5 daily prayers
  int get pagesPerPrayer => (pagesPerDay / 5).ceil();

  /// Total pages remaining to complete the Mushaf
  int get remainingPages {
    if (isCompleted) return 0;
    if (currentPage <= 1 && completedPrayersToday.isEmpty) return totalMushafPages;
    return (totalMushafPages - currentPage).clamp(0, totalMushafPages);
  }

  /// Days elapsed since the start of the Khatma
  int get daysElapsed {
    final now = DateTime.now();
    final diff = now.difference(startDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Days remaining until the target completion date
  int get daysRemaining {
    final rem = targetDays - daysElapsed;
    return rem < 0 ? 0 : rem;
  }

  /// Target page for today based on [startingPage] and elapsed days (Bug #6 fix)
  int get targetPageToday {
    final target = startingPage + ((daysElapsed + 1) * pagesPerDay) - 1;
    return target.clamp(startingPage, totalMushafPages);
  }

  /// Recalculated pace if behind or ahead (Appendix C: ceil(remainingPages / remainingDays))
  int get adjustedPagesPerDay {
    if (daysRemaining <= 0) return remainingPages;
    return (remainingPages / daysRemaining).ceil();
  }

  /// Overall completion percentage (0.0 to 1.0)
  double get progressPercentage {
    if (isCompleted) return 1.0;
    if (currentPage <= startingPage && completedPrayersToday.isEmpty) return 0.0;
    if (startingPage == 1) {
      return (currentPage / totalMushafPages).clamp(0.0, 1.0);
    }
    return (pagesReadSoFar / totalPlannedPages).clamp(0.0, 1.0);
  }

  /// Whether current progress is behind the planned schedule
  bool get isBehindSchedule {
    if (daysElapsed == 0 || isCompleted) return false;
    return currentPage < targetPageToday;
  }

  /// Deficit pages behind schedule
  int get pagesBehind {
    if (isCompleted) return 0;
    final diff = targetPageToday - currentPage;
    return diff < 0 ? 0 : diff;
  }

  /// Smart Catch-up: Resets pace to remaining pages over remaining days smoothly
  void applyCatchUp() {
    final remDays = daysRemaining <= 0 ? 1 : daysRemaining;
    customDailyPace = adjustedPagesPerDay;
    targetDays = remDays;
    startDate = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'startingPage': startingPage,
      'currentPage': currentPage,
      'splitByPrayer': splitByPrayer,
      'completedPrayersToday': completedPrayersToday,
      'lastReadDate': lastReadDate.toIso8601String(),
      'isCompleted': isCompleted,
      'reminderEnabled': reminderEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'customDailyPace': customDailyPace,
    };
  }

  factory KhatmaPlan.fromJson(Map<String, dynamic> json) {
    final parsedCurrent = (json['currentPage'] as int? ?? 1).clamp(1, totalMushafPages);
    final parsedStarting = (json['startingPage'] as int? ?? 1).clamp(1, parsedCurrent);
    return KhatmaPlan(
      id: json['id'] as String? ?? 'khatma_default',
      title: json['title'] as String? ?? 'ختمة القرآن الكريم',
      targetDays: ((json['targetDays'] as num?)?.toInt() ?? 30).clamp(1, 365),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      startingPage: parsedStarting,
      currentPage: parsedCurrent,
      splitByPrayer: json['splitByPrayer'] as bool? ?? true,
      completedPrayersToday: (json['completedPrayersToday'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastReadDate: DateTime.tryParse(json['lastReadDate'] as String? ?? '') ?? DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderHour: json['reminderHour'] as int? ?? 8,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      customDailyPace: json['customDailyPace'] as int?,
    );
  }
}

class KhatmaService extends ChangeNotifier {
  static final KhatmaService instance = KhatmaService._internal();
  KhatmaService._internal();

  static const int khatmaReminderNotificationId = 990;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;
  bool _notificationAvailable = false;

  SharedPreferences? _prefs;
  KhatmaPlan? _activePlan;

  KhatmaPlan? get activePlan => _activePlan;
  bool get hasActivePlan => _activePlan != null && !_activePlan!.isCompleted;

  Future<void> init({bool forceReload = false}) async {
    _prefs = await SharedPreferences.getInstance();
    await _initNotifications();

    final jsonStr = _prefs?.getString('active_khatma_plan');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> data = json.decode(jsonStr);
        _activePlan = KhatmaPlan.fromJson(data);
        _checkDayReset();
      } catch (_) {
        _activePlan = null;
      }
    }
    notifyListeners();
  }

  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;
    _notificationsInitialized = true;
    try {
      const androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initSettings);
      _notificationAvailable = true;
    } catch (e) {
      debugPrint('KhatmaService notification init warning: $e');
      _notificationAvailable = false;
    }
  }

  void _checkDayReset() {
    if (_activePlan == null) return;
    final now = DateTime.now();
    final last = _activePlan!.lastReadDate;
    final isDifferentDay = now.year != last.year || now.month != last.month || now.day != last.day;
    if (isDifferentDay) {
      _activePlan!.completedPrayersToday.clear();
      _savePlan();
    }
  }

  Future<void> createPlan({
    required String title,
    required int targetDays,
    bool splitByPrayer = true,
    int startingPage = 1,
    bool reminderEnabled = true,
    int reminderHour = 8,
    int reminderMinute = 0,
  }) async {
    final start = startingPage.clamp(1, 604);
    _activePlan = KhatmaPlan(
      id: 'khatma_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetDays: targetDays.clamp(1, 365),
      startDate: DateTime.now(),
      startingPage: start,
      currentPage: start,
      splitByPrayer: splitByPrayer,
      completedPrayersToday: [],
      lastReadDate: DateTime.now(),
      isCompleted: start >= 604,
      reminderEnabled: reminderEnabled,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
    );
    await _savePlan();
    await _rescheduleDailyReminder();
    notifyListeners();
  }

  /// Updates progress explicitly (used by manual adjustment or forward progress).
  /// When [allowBackward] is false, browsing earlier Surahs will not overwrite Khatma progress backward (Bug #4 fix).
  Future<void> updateProgress(int pageNumber, {bool allowBackward = true}) async {
    if (_activePlan == null) return;
    final clamped = pageNumber.clamp(1, 604);
    if (!allowBackward && clamped <= _activePlan!.currentPage) {
      return;
    }
    _activePlan!.currentPage = clamped;
    _activePlan!.lastReadDate = DateTime.now();
    _activePlan!.isCompleted = _activePlan!.currentPage >= 604;
    await _savePlan();
    await _rescheduleDailyReminder();
    notifyListeners();
  }

  /// Safe forward-only progress update called when opening Surahs or flipping Mushaf pages (Bug #4 fix).
  Future<void> updateProgressFromReading(int pageNumber) async {
    if (_activePlan == null || _activePlan!.isCompleted) return;
    // Only auto-advance if the user is reading forward within a reasonable window (<= pagesPerDay * 2)
    // so jumping to Surah Al-Kahf or Al-Mulk does not corrupt sequential Khatma tracking.
    final delta = pageNumber - _activePlan!.currentPage;
    final maxAutoJump = (_activePlan!.pagesPerDay * 2).clamp(10, 60);
    if (delta > 0 && delta <= maxAutoJump) {
      await updateProgress(pageNumber, allowBackward: false);
    }
  }

  Future<void> setManualPage(int pageNumber) async {
    await updateProgress(pageNumber, allowBackward: true);
  }

  Future<void> applyCatchUpPace() async {
    if (_activePlan == null) return;
    _activePlan!.applyCatchUp();
    await _savePlan();
    await _rescheduleDailyReminder();
    notifyListeners();
  }

  Future<void> advancePages(int pageCount) async {
    if (_activePlan == null) return;
    final next = (_activePlan!.currentPage + pageCount).clamp(_activePlan!.startingPage, 604);
    await updateProgress(next, allowBackward: true);
  }

  /// Toggles prayer completion for today's Wird and symmetrically advances or rolls back pages (Bug #5 fix).
  Future<void> togglePrayerCompleted(String prayerKey) async {
    if (_activePlan == null) return;
    if (_activePlan!.completedPrayersToday.contains(prayerKey)) {
      _activePlan!.completedPrayersToday.remove(prayerKey);
      // Roll back pagesPerPrayer when unchecking so toggling does not inflate currentPage (Bug #5 fix)
      final rolledBack = (_activePlan!.currentPage - _activePlan!.pagesPerPrayer)
          .clamp(_activePlan!.startingPage, 604);
      _activePlan!.currentPage = rolledBack;
      _activePlan!.isCompleted = false;
      await _savePlan();
      await _rescheduleDailyReminder();
      notifyListeners();
    } else {
      _activePlan!.completedPrayersToday.add(prayerKey);
      // Auto-advance by pagesPerPrayer
      await advancePages(_activePlan!.pagesPerPrayer);
    }
  }

  Future<void> updateReminderSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (_activePlan == null) return;
    _activePlan!.reminderEnabled = enabled;
    _activePlan!.reminderHour = hour;
    _activePlan!.reminderMinute = minute;
    await _savePlan();
    await _rescheduleDailyReminder();
    notifyListeners();
  }

  Future<void> _rescheduleDailyReminder() async {
    if (!_notificationAvailable) return;
    if (_activePlan == null || !_activePlan!.reminderEnabled || _activePlan!.isCompleted) {
      try {
        await _localNotifications.cancel(khatmaReminderNotificationId);
      } catch (_) {}
      return;
    }

    try {
      tz.TZDateTime now;
      try {
        now = tz.TZDateTime.now(tz.local);
      } catch (_) {
        tz.initializeTimeZones();
        now = tz.TZDateTime.now(tz.local);
      }
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        _activePlan!.reminderHour,
        _activePlan!.reminderMinute,
      );
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'khatma_reminder_channel',
        'تذكير الورد القرآني والختمة',
        channelDescription: 'تنبيهات يومية لقراءة الورد القرآني لختمة كتاب الله',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
      );

      final fromPage = _activePlan!.currentPage;
      final toPage = (_activePlan!.currentPage + _activePlan!.pagesPerDay - 1).clamp(fromPage, 604);

      await _localNotifications.zonedSchedule(
        khatmaReminderNotificationId,
        'وردك القرآني لليوم بانتظارك 📖',
        'المستهدف لليوم: صفحة $fromPage إلى $toPage لمواصلة ختمتك المباركة',
        scheduledDate,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Khatma reminder scheduling exception: $e');
    }
  }

  Future<void> cancelPlan() async {
    _activePlan = null;
    await _prefs?.remove('active_khatma_plan');
    try {
      await _localNotifications.cancel(khatmaReminderNotificationId);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _savePlan() async {
    if (_activePlan != null) {
      final jsonStr = json.encode(_activePlan!.toJson());
      await _prefs?.setString('active_khatma_plan', jsonStr);
    } else {
      await _prefs?.remove('active_khatma_plan');
    }
  }
}
