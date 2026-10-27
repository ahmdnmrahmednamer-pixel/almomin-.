import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SunnahPrayerItem {
  final String id;
  final String titleAr;
  final String category; // 'rawatib' (السنن الرواتب ١٢ ركعة) أو 'nawafil' (الضحى والوتر والرواتب غير المؤكدة)
  final int rakahs;
  final String timingAr;
  final String hadithVirtue;

  const SunnahPrayerItem({
    required this.id,
    required this.titleAr,
    required this.category,
    required this.rakahs,
    required this.timingAr,
    required this.hadithVirtue,
  });

  bool get isRawatib12 => category == 'rawatib';
}

class SunanRawatibService extends ChangeNotifier {
  static final SunanRawatibService instance = SunanRawatibService._internal();
  SunanRawatibService._internal();

  static const String _storageKey = 'sunan_rawatib_logs_v1';
  bool _isInitialized = false;

  /// Map of dateKey ('yyyy-MM-dd') -> Set of completed Sunnah IDs
  final Map<String, Set<String>> _dailyCompleted = {};

  static const List<SunnahPrayerItem> allSunan = [
    // 1. السنن الرواتب المؤكدة (12 ركعة = بيت في الجنة)
    SunnahPrayerItem(
      id: 'fajr_pre_2',
      titleAr: 'سنة الفجر القبلية (ركعتا الفجر)',
      category: 'rawatib',
      rakahs: 2,
      timingAr: 'بعد أذان الفجر وقبل صلاة الفريضة',
      hadithVirtue: 'قال رسول الله ﷺ: «رَكْعَتَا الْفَجْرِ خَيْرٌ مِنَ الدُّنْيَا وَمَا فِيهَا» [رواه مسلم].',
    ),
    SunnahPrayerItem(
      id: 'dhuhr_pre_2_first',
      titleAr: 'سنة الظهر القبلية الأولى (ركعتان)',
      category: 'rawatib',
      rakahs: 2,
      timingAr: 'بعد أذان الظهر وقبل الفريضة',
      hadithVirtue: 'من الأربع القبلية التي كان النبي ﷺ لا يدعها في الحضر، وتُفتح لها أبواب السماء عند الزوال.',
    ),
    SunnahPrayerItem(
      id: 'dhuhr_pre_2_second',
      titleAr: 'سنة الظهر القبلية الثانية (ركعتان)',
      category: 'rawatib',
      rakahs: 2,
      timingAr: 'بعد الركعتين الأوليين وقبل فريضة الظهر',
      hadithVirtue: 'قال ﷺ: «مَنْ حَافَظَ عَلَى أَرْبَعِ رَكَعَاتٍ قَبْلَ الظُّهْرِ وَأَرْبَعٍ بَعْدَهَا حَرَّمَهُ اللَّهُ عَلَى النَّارِ» [رواه الترمذي وصححه].',
    ),
    SunnahPrayerItem(
      id: 'dhuhr_post_2',
      titleAr: 'سنة الظهر البعدية (ركعتان)',
      category: 'rawatib',
      rakahs: 2,
      timingAr: 'عقب الفراغ من فريضة الظهر والأذكار',
      hadithVirtue: 'من السنن الرواتب الاثنتي عشرة التي يُبنى لصاحبها بيت في الجنة [رواه مسلم].',
    ),
    SunnahPrayerItem(
      id: 'maghrib_post_2',
      titleAr: 'سنة المغرب البعدية (ركعتان)',
      category: 'rawatib',
      rakahs: 2,
      timingAr: 'عقب صلاة المغرب، ويُستحب أداؤها في البيت',
      hadithVirtue: 'من السنن الرواتب المؤكدة، ويُستحب أن يقرأ في الأولى (قل يا أيها الكافرون) وفي الثانية (قل هو الله أحد).',
    ),
    SunnahPrayerItem(
      id: 'isha_post_2',
      titleAr: 'سنة العشاء البعدية (ركعتان)',
      category: 'rawatib',
      rakahs: 2,
      timingAr: 'عقب صلاة العشاء المفروضة',
      hadithVirtue: 'تمام الثنتي عشرة ركعة اليومية التي تكمل بنيان بيت المؤمن في الجنة.',
    ),

    // 2. النوافل اليومية العظيمة (الضحى، الوتر، سنة العصر، سنة الوضوء)
    SunnahPrayerItem(
      id: 'duha_prayer',
      titleAr: 'صلاة الضحى (صلاة الأوابين)',
      category: 'nawafil',
      rakahs: 2,
      timingAr: 'من ارتفاع الشمس قيد رمح إلى قبيل الزوال',
      hadithVirtue: 'قال ﷺ: «يُصْبِحُ عَلَى كُلِّ سُلَامَى مِنْ أَحَدِكُمْ صَدَقَةٌ... وَيُجْزِئُ مِنْ ذَلِكَ رَكْعَتَانِ يَرْكَعُهُمَا مِنَ الضُّحَى» [رواه مسلم].',
    ),
    SunnahPrayerItem(
      id: 'witr_prayer',
      titleAr: 'صلاة الوتر (ختام صلاة الليل)',
      category: 'nawafil',
      rakahs: 3,
      timingAr: 'ما بين صلاة العشاء إلى طلوع الفجر الصادق',
      hadithVirtue: 'قال ﷺ: «إِنَّ اللَّهَ وِتْرٌ يُحِبُّ الْوِتْرَ، فَأَوْتِرُوا يَا أَهْلَ الْقُرْآنِ» [رواه أبو داود والترمذي].',
    ),
    SunnahPrayerItem(
      id: 'asr_pre_4',
      titleAr: 'سنة العصر القبلية (٤ ركعات)',
      category: 'nawafil',
      rakahs: 4,
      timingAr: 'بين أذان العصر وإقامتها',
      hadithVirtue: 'قال رسول الله ﷺ: «رَحِمَ اللَّهُ امْرَأً صَلَّى قَبْلَ الْعَصْرِ أَرْبَعًا» [رواه أبو داود والترمذي وحسنه].',
    ),
    SunnahPrayerItem(
      id: 'wudu_sunnah_2',
      titleAr: 'ركعتا سنة الوضوء (عمل بلال رضي الله عنه)',
      category: 'nawafil',
      rakahs: 2,
      timingAr: 'عقب الوضوء في أي وقت',
      hadithVirtue: 'قال النبي ﷺ لبلال: «بِمَ سَبَقْتَنِي إِلَى الْجَنَّةِ؟» قال: ما أحدثتُ إلا توضأتُ وصليتُ ركعتين [متفق عليه].',
    ),
  ];

  static String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(raw);
        _dailyCompleted.clear();
        decoded.forEach((k, v) {
          if (v is List) {
            _dailyCompleted[k] = v.map((e) => e.toString()).toSet();
          }
        });
      } catch (_) {}
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool isCompleted(String sunnahId, {DateTime? date}) {
    final key = dateKey(date ?? DateTime.now());
    return _dailyCompleted[key]?.contains(sunnahId) ?? false;
  }

  Future<void> toggleSunnah(String sunnahId, {DateTime? date}) async {
    final key = dateKey(date ?? DateTime.now());
    final set = _dailyCompleted.putIfAbsent(key, () => <String>{});
    if (set.contains(sunnahId)) {
      set.remove(sunnahId);
    } else {
      set.add(sunnahId);
    }
    await _save();
    notifyListeners();
  }

  /// Total confirmed Rawatib rak'ahs completed on [date] (out of 12)
  int getCompletedRawatibRakahs({DateTime? date}) {
    final key = dateKey(date ?? DateTime.now());
    final set = _dailyCompleted[key] ?? const <String>{};
    int sum = 0;
    for (final item in allSunan) {
      if (item.isRawatib12 && set.contains(item.id)) {
        sum += item.rakahs;
      }
    }
    return sum;
  }

  /// Total Nawafil + Rawatib rak'ahs completed on [date]
  int getTotalCompletedRakahs({DateTime? date}) {
    final key = dateKey(date ?? DateTime.now());
    final set = _dailyCompleted[key] ?? const <String>{};
    int sum = 0;
    for (final item in allSunan) {
      if (set.contains(item.id)) {
        sum += item.rakahs;
      }
    }
    return sum;
  }

  bool isHouseInParadiseCompleted({DateTime? date}) {
    return getCompletedRawatibRakahs(date: date) >= 12;
  }

  /// Number of days in the last 7 days where all 12 Rawatib rak'ahs were completed
  int getWeeklyParadiseHousesCount([DateTime? anchor]) {
    final base = anchor ?? DateTime.now();
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final d = base.subtract(Duration(days: i));
      if (isHouseInParadiseCompleted(date: d)) {
        count++;
      }
    }
    return count;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, List<String>>{
      for (final entry in _dailyCompleted.entries) entry.key: entry.value.toList(),
    };
    await prefs.setString(_storageKey, json.encode(map));
  }
}
