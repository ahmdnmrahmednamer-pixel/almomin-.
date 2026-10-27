import '../text/arabic_normalizer.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// حالة أداء الفريضة في نموذج محاسبة الصلوات اليومي
enum PrayerPerformanceStatus {
  onTimeCongregation('congregation', 'حاضر في وقتها (جماعة / أول الوقت)'),
  onTimeIndividual('ontime', 'حاضر في وقتها'),
  lateQada('qada', 'قضاء بعد خروج الوقت'),
  missed('missed', 'فاتتني / لم أصلِّها'),
  unrecorded('unrecorded', 'لم تُسجَّل بعد');

  final String id;
  final String labelAr;
  const PrayerPerformanceStatus(this.id, this.labelAr);

  static PrayerPerformanceStatus fromId(String? id) {
    for (final s in PrayerPerformanceStatus.values) {
      if (s.id == id) return s;
    }
    return PrayerPerformanceStatus.unrecorded;
  }
}

/// سجل تشخيصي لفرض فائت أو متأخر مع السبب المكتوب وتاريخه
class MissedPrayerDiagnosticEntry {
  final String dateStr;
  final String prayerName;
  final PrayerPerformanceStatus status;
  final String reasonText;

  const MissedPrayerDiagnosticEntry({
    required this.dateStr,
    required this.prayerName,
    required this.status,
    required this.reasonText,
  });
}

/// التقرير الأسبوعي الشامل لمحاسبة الصلوات وتشخيص أسباب الفوات
class WeeklyPrayerDiagnosticReport {
  final int totalObligatoryInWeek; // 35 (7 days * 5 prayers)
  final int prayedOnTimeCount;
  final int prayedQadaCount;
  final int totalPrayedCount;
  final int missedOrUnprayedCount;
  final int explicitlyMissedCount;
  final Map<String, int> missedCountByPrayer;
  final Map<String, int> reasonFrequency;
  final List<MissedPrayerDiagnosticEntry> diagnosticEntries;
  final List<String> actionableRemedies;

  const WeeklyPrayerDiagnosticReport({
    required this.totalObligatoryInWeek,
    required this.prayedOnTimeCount,
    required this.prayedQadaCount,
    required this.totalPrayedCount,
    required this.missedOrUnprayedCount,
    required this.explicitlyMissedCount,
    required this.missedCountByPrayer,
    required this.reasonFrequency,
    required this.diagnosticEntries,
    required this.actionableRemedies,
  });
}

/// Single day record of prayers, sunnah rawatib, statuses, and missed/delayed reasons
class DailyPrayerRecord {
  final String dateStr; // Format: yyyy-MM-dd

  // 5 Obligatory Prayers
  bool fajr;
  bool dhuhr;
  bool asr;
  bool maghrib;
  bool isha;

  // 12 Sunan Rawatib (Hadith of Umm Habiba)
  bool fajrSunnah;
  bool dhuhrSunnahBefore;
  bool dhuhrSunnahAfter;
  bool maghribSunnah;
  bool ishaSunnah;

  // Voluntary Prayers
  bool duha;
  bool witr;
  bool qiyam;

  /// Detailed status per prayer ('الفجر': 'congregation' | 'ontime' | 'qada' | 'missed' | 'unrecorded')
  final Map<String, String> prayerStatuses;

  /// User-written or selected reason when a prayer was missed or delayed ('الفجر': 'النوم الثقيل...')
  final Map<String, String> missedReasons;

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
    Map<String, String>? prayerStatuses,
    Map<String, String>? missedReasons,
  })  : prayerStatuses = prayerStatuses ?? <String, String>{},
        missedReasons = missedReasons ?? <String, String>{};

  PrayerPerformanceStatus getPrayerStatus(String prayerNameAr) {
    final stored = prayerStatuses[prayerNameAr];
    if (stored != null) {
      return PrayerPerformanceStatus.fromId(stored);
    }
    final isDone = _getBoolByName(prayerNameAr);
    return isDone
        ? PrayerPerformanceStatus.onTimeCongregation
        : PrayerPerformanceStatus.unrecorded;
  }

  String? getReasonForPrayer(String prayerNameAr) {
    final r = missedReasons[prayerNameAr];
    return (r != null && r.trim().isNotEmpty) ? r.trim() : null;
  }

  bool _getBoolByName(String prayerNameAr) {
    switch (prayerNameAr) {
      case 'الفجر':
        return fajr;
      case 'الظهر':
        return dhuhr;
      case 'العصر':
        return asr;
      case 'المغرب':
        return maghrib;
      case 'العشاء':
        return isha;
      default:
        return false;
    }
  }

  void setBoolByName(String prayerNameAr, bool val) {
    switch (prayerNameAr) {
      case 'الفجر':
        fajr = val;
        break;
      case 'الظهر':
        dhuhr = val;
        break;
      case 'العصر':
        asr = val;
        break;
      case 'المغرب':
        maghrib = val;
        break;
      case 'العشاء':
        isha = val;
        break;
    }
  }

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

  /// Count of prayers explicitly marked as missed today
  int get missedObligatoryCount {
    int m = 0;
    for (final p in const ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء']) {
      if (getPrayerStatus(p) == PrayerPerformanceStatus.missed) {
        m++;
      }
    }
    return m;
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
      'prayerStatuses': prayerStatuses,
      'missedReasons': missedReasons,
    };
  }

  factory DailyPrayerRecord.fromJson(Map<String, dynamic> json) {
    final rawStatuses = json['prayerStatuses'] as Map<String, dynamic>?;
    final rawReasons = json['missedReasons'] as Map<String, dynamic>?;

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
      prayerStatuses:
          rawStatuses?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      missedReasons:
          rawReasons?.map((k, v) => MapEntry(k, v.toString())) ?? {},
    );
  }
}

/// Service managing persistent daily prayer form, weekly analytics, and missed-prayer root-cause diagnostics
class PrayerTrackerService extends ChangeNotifier {
  static final PrayerTrackerService instance = PrayerTrackerService._internal();
  PrayerTrackerService._internal();

  static const String _storageKey = 'prayer_tracker_records_v1';
  static const List<String> fivePrayers = [
    'الفجر',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  static const List<String> commonMissedReasons = [
    'النوم الثقيل / السهر المتأخر',
    'الانشغال بالعمل أو الدراسة',
    'التسويف وتأجيل الصلاة لآخر الوقت',
    'التواجد خارج المنزل أو في المواصلات',
    'التعب والإرهاق الجسدي',
    'نسيان ضبط المنبه أو كتم صوت الهاتف',
  ];

  SharedPreferences? _prefs;
  final Map<String, DailyPrayerRecord> _records = {};

  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> init({bool forceReload = false}) async {
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
    _prefs ??= await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};
    for (final entry in _records.entries) {
      data[entry.key] = entry.value.toJson();
    }
    await _prefs!.setString(_storageKey, json.encode(data));
  }

  /// Sets the detailed form status and optional missed/delayed reason for a specific prayer
  Future<void> setPrayerFormStatus({
    required String prayerNameAr,
    required PrayerPerformanceStatus status,
    String? reasonText,
    DateTime? date,
  }) async {
    final record = getRecordForDate(date ?? DateTime.now());
    record.prayerStatuses[prayerNameAr] = status.id;

    final isPrayed = status == PrayerPerformanceStatus.onTimeCongregation ||
        status == PrayerPerformanceStatus.onTimeIndividual ||
        status == PrayerPerformanceStatus.lateQada;
    record.setBoolByName(prayerNameAr, isPrayed);

    if (reasonText != null && reasonText.trim().isNotEmpty) {
      record.missedReasons[prayerNameAr] = reasonText.trim();
    } else if (status == PrayerPerformanceStatus.onTimeCongregation ||
        status == PrayerPerformanceStatus.onTimeIndividual) {
      record.missedReasons.remove(prayerNameAr);
    }

    await _saveRecords();
    notifyListeners();
  }

  Future<bool> toggleObligatory(String prayerNameAr, [DateTime? date]) async {
    final record = getRecordForDate(date ?? DateTime.now());
    final newVal = !record._getBoolByName(prayerNameAr);
    record.setBoolByName(prayerNameAr, newVal);
    record.prayerStatuses[prayerNameAr] = newVal
        ? PrayerPerformanceStatus.onTimeCongregation.id
        : PrayerPerformanceStatus.unrecorded.id;
    if (newVal) {
      record.missedReasons.remove(prayerNameAr);
    }

    await _saveRecords();
    notifyListeners();
    return newVal;
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
  List<DailyPrayerRecord> getRecent7Days([DateTime? anchorDate]) {
    final now = anchorDate ?? DateTime.now();
    final List<DailyPrayerRecord> list = [];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      list.add(getRecordForDate(d));
    }
    return list;
  }

  /// Generates a comprehensive 7-day weekly report and root-cause diagnostic analysis
  WeeklyPrayerDiagnosticReport getWeeklyDiagnosticReport([DateTime? anchorDate]) {
    final days = getRecent7Days(anchorDate);
    int onTime = 0;
    int qada = 0;
    int explicitlyMissed = 0;
    final Map<String, int> missedByPrayer = {
      for (final p in fivePrayers) p: 0,
    };
    final Map<String, int> reasonFreq = {};
    final List<MissedPrayerDiagnosticEntry> entries = [];

    for (final day in days) {
      for (final p in fivePrayers) {
        final status = day.getPrayerStatus(p);
        final reason = day.getReasonForPrayer(p);

        if (status == PrayerPerformanceStatus.onTimeCongregation ||
            status == PrayerPerformanceStatus.onTimeIndividual) {
          onTime++;
        } else if (status == PrayerPerformanceStatus.lateQada) {
          qada++;
          if (reason != null) {
            entries.add(
              MissedPrayerDiagnosticEntry(
                dateStr: day.dateStr,
                prayerName: p,
                status: status,
                reasonText: reason,
              ),
            );
            reasonFreq[reason] = (reasonFreq[reason] ?? 0) + 1;
          }
        } else if (status == PrayerPerformanceStatus.missed) {
          explicitlyMissed++;
          missedByPrayer[p] = (missedByPrayer[p] ?? 0) + 1;
          final effectiveReason = reason ?? 'لم يُكتب سبب محدد';
          entries.add(
            MissedPrayerDiagnosticEntry(
              dateStr: day.dateStr,
              prayerName: p,
              status: status,
              reasonText: effectiveReason,
            ),
          );
          reasonFreq[effectiveReason] = (reasonFreq[effectiveReason] ?? 0) + 1;
        } else {
          // unrecorded counts toward missed/unprayed in the 35-prayer weekly total
          missedByPrayer[p] = (missedByPrayer[p] ?? 0) + 1;
        }
      }
    }

    final totalPrayed = onTime + qada;
    final missedOrUnprayed = (35 - totalPrayed).clamp(0, 35);

    // Build personalized remedies based on recorded reasons
    final List<String> remedies = [];
    final allReasonsText = ArabicNormalizer.normalize(reasonFreq.keys.join(' '), loose: true);
    if (allReasonsText.contains('النوم') ||
        allReasonsText.contains('السهر') ||
        (missedByPrayer['الفجر'] ?? 0) > 0) {
      remedies.add(
        '🌅 علاج فوات الفجر بسبب النوم: فعِّل «منبّه الاستعداد قبل الفجر» في التطبيق قبل الأذان بـ ٢٥ دقيقة مع النوم المبكر على طهارة.',
      );
    }
    if (allReasonsText.contains('العمل') ||
        allReasonsText.contains(ArabicNormalizer.normalize('الدراسة', loose: true)) ||
        allReasonsText.contains('الانشغال')) {
      remedies.add(
        '⏳ علاج الانشغال بالعمل أو الدراسة: فعِّل تنبيه اقتراب الصلاة قبل ١٠ دقائق، واجعل وقت الصلاة موعداً ثابتاً لا يُؤجَّل (١٠ دقائق فقط تبارك في يومك كله).',
      );
    }
    if (allReasonsText.contains('التسويف') ||
        allReasonsText.contains(ArabicNormalizer.normalize('تأجيل', loose: true))) {
      remedies.add(
        '🕌 علاج التسويف والتأجيل: بادر بالوضوء فور سماع نداء «حي على الصلاة» قبل البدء بأي مهمة جديدة.',
      );
    }
    if (allReasonsText.contains('المواصلات') ||
        allReasonsText.contains('خارج المنزل')) {
      remedies.add(
        '🧭 علاج التواجد خارج المنزل: اخرج من بيتك على وضوء دائماً، واستخدم بوصلة القبلة في التطبيق لأداء الصلاة في أقرب مسجد أو مصلى.',
      );
    }
    if (remedies.isEmpty) {
      remedies.add(
        '✨ واظب على تسجيل الفورم اليومي فور كل صلاة، وإذا فاتك فرض دوّن السبب بصدق لتكتشف العائق الحقيقي وتعالجه.',
      );
    }

    return WeeklyPrayerDiagnosticReport(
      totalObligatoryInWeek: 35,
      prayedOnTimeCount: onTime,
      prayedQadaCount: qada,
      totalPrayedCount: totalPrayed,
      missedOrUnprayedCount: missedOrUnprayed,
      explicitlyMissedCount: explicitlyMissed,
      missedCountByPrayer: missedByPrayer,
      reasonFrequency: reasonFreq,
      diagnosticEntries: entries.reversed.toList(),
      actionableRemedies: remedies,
    );
  }

  /// Gentle, non-punitive encouraging message based on today's progress
  String getGentleEncouragement() {
    final r = todayRecord;
    if (r.isAllObligatoryCompleted && r.isAllRawatibCompleted) {
      return 'هنيئاً لك! أتممت الصلوات الخمس والسنن الرواتب الـ 12 ركعة، لك بيت في الجنة بإذن الله 🕌✨';
    }
    if (r.isAllObligatoryCompleted) {
      return 'بارك الله فيك! أتممت الفرائض الخمس اليوم، ويمكنك إتمام السنن الرواتب لزيادة الأجر 🌟';
    }
    final remaining = 5 - r.completedObligatoryCount;
    return 'أنجزت ${r.completedObligatoryCount} من 5 صلوات اليوم (متبقي $remaining فروض) — سجل حالة كل صلاة أو سبب التأخير لمعالجته 🤲';
  }
}
