import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/islamic_libraries_models.dart';

/// خدمة «الورد اليومي الذكي وخطة الطاعات المتكاملة»
class DailyWirdService extends ChangeNotifier {
  static final DailyWirdService instance = DailyWirdService._internal();
  DailyWirdService._internal();

  static const String _prefKey = 'daily_wird_records_v1';
  bool _initialized = false;

  /// Map of YYYY-MM-DD -> List of completed task IDs
  final Map<String, Set<String>> _dailyRecords = {};

  static const List<DailyWirdTaskItem> defaultTasks = [
    DailyWirdTaskItem(
      id: 'wird_fajr_sunnah',
      title: 'ركعتا سنة الفجر وصلاة الفجر في وقتها',
      subtitle: '«ركعتا الفجر خير من الدنيا وما فيها»',
      timeSlot: 'الفجر والصباح',
      rewardPoints: 20,
      icon: Icons.wb_twilight_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_morning_adhkar',
      title: 'أذكار الصباح كاملة مع آية الكرسي والمعوذات',
      subtitle: 'حصن المؤمن وأمانه وطمأنينة قلبه في بداية اليوم',
      timeSlot: 'الفجر والصباح',
      rewardPoints: 15,
      icon: Icons.wb_sunny_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_duha_prayer',
      title: 'صلاة الضحى (صلاة الأوابين)',
      subtitle: 'تجزئ عن ٣٦٠ صدقة على كل سلامى منابن آدم',
      timeSlot: 'الفجر والصباح',
      rewardPoints: 15,
      icon: Icons.light_mode_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_quran_portion',
      title: 'ورد التلاوة اليومي من القرآن الكريم (صفحتان أو حزب)',
      subtitle: 'قراءة بتدبر وترتيل مع متابعة ختمة القرآن',
      timeSlot: 'الظهيرة والعصر',
      rewardPoints: 25,
      icon: Icons.menu_book_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_rawatib_sunnah',
      title: 'السنن الرواتب المؤكدة (١٢ ركعة في اليوم والليلة)',
      subtitle: 'يبني الله لمن واظب عليها بيتاً في الجنة',
      timeSlot: 'الظهيرة والعصر',
      rewardPoints: 20,
      icon: Icons.mosque_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_evening_adhkar',
      title: 'أذكار المساء والاستغفار (١٠٠ مرة) والصلاة على النبي ﷺ',
      subtitle: 'تفريج الهموم وزيادة الإيمان والبركة',
      timeSlot: 'العصر والمساء',
      rewardPoints: 15,
      icon: Icons.nights_stay_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_knowledge_reading',
      title: 'فائدة علمية يومية (حديث نبوي أو مسألة فقهية)',
      subtitle: '«من يرد الله به خيراً يفقهه في الدين»',
      timeSlot: 'العصر والمساء',
      rewardPoints: 15,
      icon: Icons.auto_stories_rounded,
    ),
    DailyWirdTaskItem(
      id: 'wird_witr_mulk_sleep',
      title: 'صلاة الوتر، سورة الملك، وأذكار النوم',
      subtitle: 'ختام اليوم بالوتر والنجاة من عذاب القبر',
      timeSlot: 'الليل والوتر',
      rewardPoints: 20,
      icon: Icons.bedtime_rounded,
    ),
  ];

  String _todayKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> init({bool forceReload = false}) async {
    if (_initialized && !forceReload) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    _dailyRecords.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        decoded.forEach((k, v) {
          if (v is List) {
            _dailyRecords[k] = v.map((e) => e.toString()).toSet();
          }
        });
      } catch (_) {}
    }
    _initialized = true;
    notifyListeners();
  }

  Set<String> getCompletedToday([DateTime? date]) {
    final key = _todayKey(date);
    return Set.unmodifiable(_dailyRecords[key] ?? const <String>{});
  }

  bool isCompleted(String taskId, [DateTime? date]) {
    final key = _todayKey(date);
    return _dailyRecords[key]?.contains(taskId) ?? false;
  }

  double getTodayCompletionRatio([DateTime? date]) {
    if (defaultTasks.isEmpty) return 0.0;
    final done = getCompletedToday(date).length;
    return (done / defaultTasks.length).clamp(0.0, 1.0);
  }

  int getTodayPoints([DateTime? date]) {
    final done = getCompletedToday(date);
    return defaultTasks
        .where((t) => done.contains(t.id))
        .fold(0, (sum, t) => sum + t.rewardPoints);
  }

  int getCurrentStreakDays() {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      final key = _todayKey(d);
      final completed = _dailyRecords[key];
      if (completed != null && completed.isNotEmpty) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  Future<void> toggleTask(String taskId, [DateTime? date]) async {
    final key = _todayKey(date);
    final set = _dailyRecords.putIfAbsent(key, () => <String>{});
    if (set.contains(taskId)) {
      set.remove(taskId);
    } else {
      set.add(taskId);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final serializable = _dailyRecords.map((k, v) => MapEntry(k, v.toList()));
    await prefs.setString(_prefKey, json.encode(serializable));
  }

  Map<String, dynamic> exportData() {
    return _dailyRecords.map((k, v) => MapEntry(k, v.toList()));
  }

  Future<void> importData(Map<String, dynamic> imported, {bool replace = false}) async {
    if (replace) _dailyRecords.clear();
    imported.forEach((k, v) {
      if (v is List) {
        final cur = _dailyRecords.putIfAbsent(k, () => <String>{});
        cur.addAll(v.map((e) => e.toString()));
      }
    });
    await _persist();
    notifyListeners();
  }
}
