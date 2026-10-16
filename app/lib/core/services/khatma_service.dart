import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KhatmaPlan {
  final String id;
  final String title;
  final int targetDays;
  final DateTime startDate;
  int currentPage;
  final bool splitByPrayer;
  List<String> completedPrayersToday;
  DateTime lastReadDate;
  bool isCompleted;

  KhatmaPlan({
    required this.id,
    required this.title,
    required this.targetDays,
    required this.startDate,
    this.currentPage = 1,
    this.splitByPrayer = true,
    List<String>? completedPrayersToday,
    DateTime? lastReadDate,
    this.isCompleted = false,
  })  : completedPrayersToday = completedPrayersToday ?? [],
        lastReadDate = lastReadDate ?? DateTime.now();

  /// Total pages in Madinah Mushaf
  static const int totalMushafPages = 604;

  /// Standard pages per day (Appendix C: ceil(604 / days))
  int get pagesPerDay => (totalMushafPages / targetDays).ceil();

  /// Standard pages per prayer if split across 5 daily prayers
  int get pagesPerPrayer => (pagesPerDay / 5).ceil();

  /// Total pages remaining to complete the Mushaf
  int get remainingPages => (totalMushafPages - currentPage).clamp(0, totalMushafPages);

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

  /// Target page for today based on elapsed days
  int get targetPageToday {
    final target = (daysElapsed + 1) * pagesPerDay;
    return target.clamp(1, totalMushafPages);
  }

  /// Recalculated pace if behind or ahead (Appendix C: ceil(remainingPages / remainingDays))
  int get adjustedPagesPerDay {
    if (daysRemaining <= 0) return remainingPages;
    return (remainingPages / daysRemaining).ceil();
  }

  /// Overall completion percentage (0.0 to 1.0)
  double get progressPercentage {
    return (currentPage / totalMushafPages).clamp(0.0, 1.0);
  }

  /// Whether current progress is behind the planned schedule
  bool get isBehindSchedule {
    return currentPage < targetPageToday;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetDays': targetDays,
      'startDate': startDate.toIso8601String(),
      'currentPage': currentPage,
      'splitByPrayer': splitByPrayer,
      'completedPrayersToday': completedPrayersToday,
      'lastReadDate': lastReadDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory KhatmaPlan.fromJson(Map<String, dynamic> json) {
    return KhatmaPlan(
      id: json['id'] as String? ?? 'khatma_default',
      title: json['title'] as String? ?? 'ختمة القرآن الكريم',
      targetDays: json['targetDays'] as int? ?? 30,
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      currentPage: json['currentPage'] as int? ?? 1,
      splitByPrayer: json['splitByPrayer'] as bool? ?? true,
      completedPrayersToday: (json['completedPrayersToday'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      lastReadDate: DateTime.tryParse(json['lastReadDate'] as String? ?? '') ?? DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class KhatmaService extends ChangeNotifier {
  static final KhatmaService instance = KhatmaService._internal();
  KhatmaService._internal();

  SharedPreferences? _prefs;
  KhatmaPlan? _activePlan;

  KhatmaPlan? get activePlan => _activePlan;
  bool get hasActivePlan => _activePlan != null && !_activePlan!.isCompleted;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
  }) async {
    _activePlan = KhatmaPlan(
      id: 'khatma_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetDays: targetDays.clamp(5, 365),
      startDate: DateTime.now(),
      currentPage: startingPage.clamp(1, 604),
      splitByPrayer: splitByPrayer,
      completedPrayersToday: [],
      lastReadDate: DateTime.now(),
      isCompleted: false,
    );
    await _savePlan();
    notifyListeners();
  }

  Future<void> updateProgress(int pageNumber) async {
    if (_activePlan == null) return;
    _activePlan!.currentPage = pageNumber.clamp(1, 604);
    _activePlan!.lastReadDate = DateTime.now();
    if (_activePlan!.currentPage >= 604) {
      _activePlan!.isCompleted = true;
    }
    await _savePlan();
    notifyListeners();
  }

  Future<void> advancePages(int pageCount) async {
    if (_activePlan == null) return;
    final next = _activePlan!.currentPage + pageCount;
    await updateProgress(next);
  }

  Future<void> togglePrayerCompleted(String prayerKey) async {
    if (_activePlan == null) return;
    if (_activePlan!.completedPrayersToday.contains(prayerKey)) {
      _activePlan!.completedPrayersToday.remove(prayerKey);
    } else {
      _activePlan!.completedPrayersToday.add(prayerKey);
      // Auto-advance by pagesPerPrayer
      await advancePages(_activePlan!.pagesPerPrayer);
    }
    await _savePlan();
    notifyListeners();
  }

  Future<void> cancelPlan() async {
    _activePlan = null;
    await _prefs?.remove('active_khatma_plan');
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
