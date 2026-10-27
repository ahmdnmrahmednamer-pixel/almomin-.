import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memorization_item.dart';

/// Service managing Quran Memorization, Leitner spaced-repetition and Ayah mastery (FR-MEM-001..003)
class MemorizationService extends ChangeNotifier {
  static final MemorizationService instance = MemorizationService._internal();
  MemorizationService._internal();

  static const String _storageKey = 'memorization_items_v1';

  final Map<String, MemorizationItem> _items = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  int get totalTrackedAyahs => _items.length;

  /// Total count of ayahs considered mastered (Leitner Box >= 3)
  int get totalMasteredCount =>
      _items.values.where((item) => item.leitnerBox >= 3).length;

  /// Count of ayahs that are currently due for review
  int get dueReviewsCount =>
      _items.values.where((item) => item.isDue).length;

  /// Initializes the service from persistent storage
  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = json.decode(jsonStr);
        _items.clear();
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            final memItem = MemorizationItem.fromJson(item);
            _items[memItem.id] = memItem;
          }
        }
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('MemorizationService init error: $e');
      _isInitialized = true;
    }
  }

  /// Checks if an Ayah is being tracked in memorization
  bool hasItem(int surahId, int ayahNumber) {
    return _items.containsKey(MemorizationItem.generateId(surahId, ayahNumber));
  }

  /// Gets the memorization item for an Ayah
  MemorizationItem? getItem(int surahId, int ayahNumber) {
    return _items[MemorizationItem.generateId(surahId, ayahNumber)];
  }

  /// Gets all tracked items for a specific surah
  List<MemorizationItem> getItemsForSurah(int surahId) {
    return _items.values.where((item) => item.surahId == surahId).toList();
  }

  /// Gets all items that are currently due for spaced repetition review
  List<MemorizationItem> getDueItems() {
    return _items.values.where((item) => item.isDue).toList();
  }

  /// Records a self-evaluation review (Easy / Hard / Forgot) for an Ayah
  Future<MemorizationItem> recordReview({
    required int surahId,
    required int ayahNumber,
    required String surahName,
    required MemorizationRating rating,
  }) async {
    await init();
    final id = MemorizationItem.generateId(surahId, ayahNumber);
    final existing = _items[id] ??
        MemorizationItem.createInitial(
          surahId: surahId,
          ayahNumber: ayahNumber,
          surahName: surahName,
        );

    final updated = existing.recordReview(rating);
    _items[id] = updated;

    await _persist();
    notifyListeners();
    return updated;
  }

  /// Removes an Ayah from memorization tracking
  Future<bool> deleteItem(int surahId, int ayahNumber) async {
    await init();
    final id = MemorizationItem.generateId(surahId, ayahNumber);
    if (_items.containsKey(id)) {
      _items.remove(id);
      await _persist();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Exports all items for backup
  List<Map<String, dynamic>> exportData() {
    return _items.values.map((e) => e.toJson()).toList();
  }

  /// Imports items from a backup list
  Future<int> importData(List<dynamic> list, {bool merge = true}) async {
    await init();
    if (!merge) {
      _items.clear();
    }

    int count = 0;
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final parsed = MemorizationItem.fromJson(item);
        if (merge && _items.containsKey(parsed.id)) {
          // If merging, preserve the one with higher timesReviewed or later lastReviewedAt
          final existing = _items[parsed.id]!;
          if (parsed.lastReviewedAt.isAfter(existing.lastReviewedAt)) {
            _items[parsed.id] = parsed;
            count++;
          }
        } else {
          _items[parsed.id] = parsed;
          count++;
        }
      }
    }

    await _persist();
    notifyListeners();
    return count;
  }

  /// Clears all memorization tracking data
  Future<void> clearAll() async {
    _items.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.values.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, json.encode(list));
    } catch (e) {
      debugPrint('MemorizationService persist error: $e');
    }
  }
}
