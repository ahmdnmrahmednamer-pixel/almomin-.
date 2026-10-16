import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single day record of prayers and sunnah rawatib (FR-PRY-009)
class DailyPrayerRecord {
  final String dateStr; // Format: yyyy-MM-dd

  // 5 Obligatory Prayers
  bool fajr;
  bool dhuhr;
  bool asr;
  bool maghrib;
  bool isha;

  // 12 Sunan Rawatib (Hadith of Umm Habiba)
  bool fajrSunnah; // 2 rak'ahs before Fajr
  bool dhuhrSunnahBefore; // 4 rak'ahs before Dhuhr
  bool dhuhrSunnahAfter; // 2 rak'ahs after Dhuhr
  bool maghribSunnah; // 2 rak'ahs after Maghrib
  bool ishaSunnah; // 2 rak'ahs after Isha

  // Voluntary Prayers
  bool duha; // صلاة الضحى
  bool witr; // صلاة الوتر
  bool qiyam; // قيام الليل

  DailyPrayerRecord({
    required this.dateStr,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.fajrSunnah = false,
    this.dhuhrSunnahBefore = false,
    this.dhuhrSunnahAfter = false,
    this.maghribSunnah = false,
    this.ishaSunnah = false,
    this.duha = false,
    this.witr = false,
    this.qiyam = false,
  });

  /// Count of completed obligatory prayers (0..5)
  int get completedObligatoryCount {
    int c = 0;
    if (fajr) c++;
    if (dhuhr) c++;
    if (asr) c++;
    if (maghrib) c++;
    if (isha) c++;
    return c;
  }

  /// Total completed Sunnah Rawatib rak'ahs (0..12)
  int get completedRawatibRakats {
    int r = 0;
    if (fajrSunnah) r += 2;
    if (dhuhrSunnahBefore) r += 4;
    if (dhuhrSunnahAfter) r += 2;
    if (maghribSunnah) r += 2;
    if (ishaSunnah) r += 2;
    return r;
  }

  bool get isAllObligatoryCompleted => completedObligatoryCount == 5;
  bool get isAllRawatibCompleted => completedRawatibRakats == 12;

  Map<String, dynamic> toJson() {
    return {
      'dateStr': dateStr,
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'fajrSunnah': fajrSunnah,
      'dhuhrSunnahBefore': dhuhrSunnahBefore,
      'dhuhrSunnahAfter': dhuhrSunnahAfter,
      'maghribSunnah': maghribSunnah,
      'ishaSunnah': ishaSunnah,
      'duha': duha,
      'witr': witr,
      'qiyam': qiyam,
    };
  }

  factory DailyPrayerRecord.fromJson(Map<String, dynamic> json) {
    return DailyPrayerRecord(
      dateStr: json['dateStr'] as String? ?? '',
      fajr: json['fajr'] as bool? ?? false,
      dhuhr: json['dhuhr'] as bool? ?? false,
      asr: json['asr'] as bool? ?? false,
      maghrib: json['maghrib'] as bool? ?? false,
      isha: json['isha'] as bool? ?? false,
      fajrSunnah: json['fajrSunnah'] as bool? ?? false,
      dhuhrSunnahBefore: json['dhuhrSunnahBefore'] as bool? ?? false,
      dhuhrSunnahAfter: json['dhuhrSunnahAfter'] as bool? ?? false,
      maghribSunnah: json['maghribSunnah'] as bool? ?? false,
      ishaSunnah: json['ishaSunnah'] as bool? ?? false,
      duha: json['duha'] as bool? ?? false,
      witr: json['witr'] as bool? ?? false,
      qiyam: json['qiyam'] as bool? ?? false,
    );
  }
}

/// Service managing persistent prayer and sunnah tracking (FR-PRY-009)
class PrayerTrackerService extends ChangeNotifier {
  static final PrayerTrackerService instance = PrayerTrackerService._internal();
  PrayerTrackerService._internal();

  static const String _storageKey = 'prayer_tracker_records_v1';
  SharedPreferences? _prefs;
  final Map<String, DailyPrayerRecord> _records = {};

  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final rawJson = _prefs?.getString(_storageKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(rawJson);
        _records.clear();
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            _records[entry.key] = DailyPrayerRecord.fromJson(entry.value);
          }
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  DailyPrayerRecord getRecordForDate(DateTime date) {
    final key = formatDateKey(date);
    if (!_records.containsKey(key)) {
      _records[key] = DailyPrayerRecord(dateStr: key);
    }
    return _records[key]!;
  }

  DailyPrayerRecord get todayRecord => getRecordForDate(DateTime.now());

  Future<void> _saveRecords() async {
    if (_prefs == null) return;
    final Map<String, dynamic> data = {};
    for (final entry in _records.entries) {
      data[entry.key] = entry.value.toJson();
    }
    await _prefs!.setString(_storageKey, json.encode(data));
  }

  Future<bool> toggleObligatory(String prayerNameAr, [DateTime? date]) async {
    final record = getRecordForDate(date ?? DateTime.now());
    bool state = false;

    switch (prayerNameAr) {
      case 'الفجر':
        record.fajr = !record.fajr;
        state = record.fajr;
        break;
      case 'الظهر':
        record.dhuhr = !record.dhuhr;
        state = record.dhuhr;
        break;
      case 'العصر':
        record.asr = !record.asr;
        state = record.asr;
        break;
      case 'المغرب':
        record.maghrib = !record.maghrib;
        state = record.maghrib;
        break;
      case 'العشاء':
        record.isha = !record.isha;
        state = record.isha;
        break;
    }

    await _saveRecords();
    notifyListeners();
    return state;
  }

  Future<bool> toggleSunnah(String sunnahKey, [DateTime? date]) async {
    final record = getRecordForDate(date ?? DateTime.now());
    bool state = false;

    switch (sunnahKey) {
      case 'fajr_sunnah':
        record.fajrSunnah = !record.fajrSunnah;
        state = record.fajrSunnah;
        break;
      case 'dhuhr_sunnah_before':
        record.dhuhrSunnahBefore = !record.dhuhrSunnahBefore;
        state = record.dhuhrSunnahBefore;
        break;
      case 'dhuhr_sunnah_after':
        record.dhuhrSunnahAfter = !record.dhuhrSunnahAfter;
        state = record.dhuhrSunnahAfter;
        break;
      case 'maghrib_sunnah':
        record.maghribSunnah = !record.maghribSunnah;
        state = record.maghribSunnah;
        break;
      case 'isha_sunnah':
        record.ishaSunnah = !record.ishaSunnah;
        state = record.ishaSunnah;
        break;
      case 'duha':
        record.duha = !record.duha;
        state = record.duha;
        break;
      case 'witr':
        record.witr = !record.witr;
        state = record.witr;
        break;
      case 'qiyam':
        record.qiyam = !record.qiyam;
        state = record.qiyam;
        break;
    }

    await _saveRecords();
    notifyListeners();
    return state;
  }

  /// Returns records for the last 7 days (including today)
  List<DailyPrayerRecord> getRecent7Days() {
    final now = DateTime.now();
    final List<DailyPrayerRecord> list = [];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      list.add(getRecordForDate(d));
    }
    return list;
  }

  /// Gentle, non-punitive encouraging message based on today's progress
  String getGentleEncouragement() {
    final r = todayRecord;
    if (r.isAllObligatoryCompleted && r.isAllRawatibCompleted) {
      return 'هنيئاً لك! أتممت الصلوات الخمس والسنن الرواتب الـ 12 ركعة، لك بيت في الجنة بإذن الله 🕌✨';
    }
    if (r.isAllObligatoryCompleted) {
      return 'ما شاء الله! أتممت الصلوات الخمس اليوم كاملة، تقبل الله طاعتك ورزقك القبول والبركة 🌿';
    }
    if (r.completedObligatoryCount > 0) {
      return 'أحسنت! حافظ على صلواتك في وقتها، فالصلاة نور للمؤمن وانشراح للصدر ✨';
    }
    return '«إن الصلاة كانت على المؤمنين كتاباً موقوتاً» · اجعل يومك عامراً بذكر الله وطاعته 🌿';
  }
}
