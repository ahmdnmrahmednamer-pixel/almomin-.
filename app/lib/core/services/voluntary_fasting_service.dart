import 'prayer_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نموذج نوع الصيام التطوعي النبوي
class VoluntaryFastType {
  final String id;
  final String title;
  final String scheduleRule;
  final String propheticVirtue;
  final String hadithSource;
  final String category; // 'أسبوعي', 'شهري', 'موسمي'
  final int targetDaysPerPeriod;

  const VoluntaryFastType({
    required this.id,
    required this.title,
    required this.scheduleRule,
    required this.propheticVirtue,
    required this.hadithSource,
    required this.category,
    required this.targetDaysPerPeriod,
  });
}

/// خدمة تخطيط ومتابعة الصيام التطوعي والأيام البيض والسنن الموسمية
class VoluntaryFastingService extends ChangeNotifier {
  static final VoluntaryFastingService instance =
      VoluntaryFastingService._internal();
  VoluntaryFastingService._internal();

  static const List<VoluntaryFastType> fastTypes = [
    VoluntaryFastType(
      id: 'monday_thursday',
      title: 'صيام يومي الإثنين والخميس',
      scheduleRule: 'كل يوم إثنين وخميس من كل أسبوع',
      propheticVirtue:
          'قال رسول الله ﷺ: «تُعْرَضُ الأَعْمَالُ يَوْمَ الاِثْنَيْنِ وَالْخَمِيسِ، فَأُحِبُّ أَنْ يُعْرَضَ عَمَلِي وَأَنَا صَائِمٌ»',
      hadithSource: 'رواه الترمذي وصححه الألباني',
      category: 'أسبوعي',
      targetDaysPerPeriod: 8,
    ),
    VoluntaryFastType(
      id: 'white_days',
      title: 'صيام الأيام البيض (١٣، ١٤، ١٥ هجرياً)',
      scheduleRule: 'اليوم الثالث عشر والرابع عشر والخامس عشر من كل شهر هجري',
      propheticVirtue:
          'قال رسول الله ﷺ لأبي ذر رضي الله عنه: «يَا أَبَا ذَرٍّ إِذَا صُمْتَ مِنَ الشَّهْرِ ثَلاَثَةَ أَيَّامٍ فَصُمْ ثَلاَثَ عَشْرَةَ وَأَرْبَعَ عَشْرَةَ وَخَمْسَ عَشْرَةَ» — وهي كصيام الدهر.',
      hadithSource: 'متفق على أصل صيام ثلاثة أيام من كل شهر',
      category: 'شهري',
      targetDaysPerPeriod: 3,
    ),
    VoluntaryFastType(
      id: 'six_shawwal',
      title: 'صيام الست من شوال',
      scheduleRule: 'ستة أيام من شهر شوال بعد عيد الفطر (متتابعة أو متفرقة)',
      propheticVirtue:
          'قال رسول الله ﷺ: «مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتّاً مِنْ شَوَّالٍ كَانَ كَصِيَامِ الدَّهْرِ»',
      hadithSource: 'صحيح مسلم',
      category: 'موسمي',
      targetDaysPerPeriod: 6,
    ),
    VoluntaryFastType(
      id: 'day_of_arafah',
      title: 'صيام يوم عرفة (٩ ذو الحجة لغير الحاج)',
      scheduleRule: 'اليوم التاسع من شهر ذي الحجة',
      propheticVirtue:
          'قال رسول الله ﷺ: «صِيَامُ يَوْمِ عَرَفَةَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ السَّنَةَ الَّتِي قَبْلَهُ وَالسَّنَةَ الَّتِي بَعْدَهُ»',
      hadithSource: 'صحيح مسلم',
      category: 'موسمي',
      targetDaysPerPeriod: 1,
    ),
    VoluntaryFastType(
      id: 'tasua_ashura',
      title: 'صيام تاسوعاء وعاشوراء (٩ و١٠ محرم)',
      scheduleRule: 'اليوم التاسع والعاشر من شهر الله المحرم',
      propheticVirtue:
          'قال رسول الله ﷺ: «صِيَامُ يَوْمِ عَاشُورَاءَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ السَّنَةَ الَّتِي قَبْلَهُ» وقال: «لَئِنْ بَقِيتُ إِلَى قَابِلٍ لأَصُومَنَّ التَّاسِعَ»',
      hadithSource: 'صحيح مسلم',
      category: 'موسمي',
      targetDaysPerPeriod: 2,
    ),
    VoluntaryFastType(
      id: 'nine_dhul_hijjah',
      title: 'صيام العشر الأوائل من ذي الحجة (١ - ٩ ذو الحجة)',
      scheduleRule: 'الأيام التسعة الأولى من شهر ذي الحجة',
      propheticVirtue:
          'قال رسول الله ﷺ: «مَا مِنْ أَيَّامٍ الْعَمَلُ الصَّالِحُ فِيهِنَّ أَحَبُّ إِلَى اللَّهِ مِنْ هَذِهِ الأَيَّامِ الْعَشْرِ»',
      hadithSource: 'صحيح البخاري',
      category: 'موسمي',
      targetDaysPerPeriod: 9,
    ),
    VoluntaryFastType(
      id: 'shaban_fasting',
      title: 'الإكثار من الصيام في شهر شعبان',
      scheduleRule: 'أغلب أيام شهر شعبان تمهيداً لشهر رمضان',
      propheticVirtue:
          'قالت عائشة رضي الله عنها: «مَا رَأَيْتُ رَسُولَ اللَّهِ ﷺ أَكْثَرَ صِيَاماً مِنْهُ فِي شَعْبَانَ»',
      hadithSource: 'متفق عليه',
      category: 'موسمي',
      targetDaysPerPeriod: 10,
    ),
  ];

  static const String iftarDua =
      '«ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ» (رواه أبو داود)';

  static const String intentionNote =
      'يجوز في صيام النافلة عقد النية من الليل، ويجوز إنشاؤها من النهار قبل الزوال بشرط ألا يكون قد تناول مفطراً بعد الفجر.';

  final Map<String, int> _completedCounts = {};
  final List<String> _fastedDateLogs = []; // 'YYYY-MM-DD|fastId'
  bool _suhoorReminderEnabled = true;

  Map<String, int> get completedCounts => Map.unmodifiable(_completedCounts);
  List<String> get fastedDateLogs => List.unmodifiable(_fastedDateLogs);
  bool get suhoorReminderEnabled => _suhoorReminderEnabled;

  int get totalFastedDays =>
      _completedCounts.values.fold<int>(0, (sum, val) => sum + val);

  Future<void> init({bool forceReload = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _suhoorReminderEnabled =
        prefs.getBool('voluntary_fast_suhoor_reminder') ?? true;
    for (final f in fastTypes) {
      _completedCounts[f.id] = prefs.getInt('vfast_count_${f.id}') ?? 0;
    }
    _fastedDateLogs
      ..clear()
      ..addAll(prefs.getStringList('vfast_date_logs') ?? []);
    notifyListeners();
  }

  int getCountForType(String fastId) => _completedCounts[fastId] ?? 0;

  Future<void> logFastedDay(String fastId, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final entry = '$dateStr|$fastId';
    if (!_fastedDateLogs.contains(entry)) {
      _fastedDateLogs.insert(0, entry);
    }
    _completedCounts[fastId] = (_completedCounts[fastId] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vfast_count_$fastId', _completedCounts[fastId]!);
    await prefs.setStringList('vfast_date_logs', _fastedDateLogs);
    notifyListeners();
  }

  Future<void> decrementFastCount(String fastId) async {
    final current = _completedCounts[fastId] ?? 0;
    if (current > 0) {
      _completedCounts[fastId] = current - 1;
      final logIdx = _fastedDateLogs.indexWhere((e) => e.endsWith('|$fastId'));
      if (logIdx >= 0) {
        _fastedDateLogs.removeAt(logIdx);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('vfast_count_$fastId', _completedCounts[fastId]!);
      await prefs.setStringList('vfast_date_logs', _fastedDateLogs);
      notifyListeners();
    }
  }

  Future<void> toggleSuhoorReminder(bool val) async {
    _suhoorReminderEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voluntary_fast_suhoor_reminder', val);
    notifyListeners();
  }

  /// Checks if a given Hijri day (1..30) is one of the 3 White Days (13, 14, 15)
  bool isWhiteDay(int hijriDay) =>
      hijriDay == 13 || hijriDay == 14 || hijriDay == 15;

  /// Checks if today (with user's Hijri sighting adjustment) is one of the 3 White Days
  bool isTodayWhiteDay([DateTime? date]) {
    final hijri = HijriDateHelper.toHijri(date ?? DateTime.now());
    return isWhiteDay(hijri['day'] ?? 1);
  }

  /// Returns an automatic recommendation if today matches a Sunnah fast (White Days, Monday/Thursday, Arafah, Ashura)
  String? getTodayHijriFastRecommendation([DateTime? date]) {
    final target = date ?? DateTime.now();
    final hijri = HijriDateHelper.toHijri(target);
    final hMonth = hijri['month'] ?? 1;
    final hDay = hijri['day'] ?? 1;

    if (hMonth == 12 && hDay == 9) {
      return 'اليوم يوم عرفة (٩ ذو الحجة) — صيامه يكفّر السنة الماضية والقادمة';
    }
    if (hMonth == 1 && (hDay == 9 || hDay == 10)) {
      return 'اليوم من أيام تاسوعاء وعاشوراء ($hDay محرم) — صيامه يكفّر السنة الماضية';
    }
    if (isWhiteDay(hDay)) {
      return 'اليوم من الأيام البيض المباركة ($hDay ${HijriDateHelper.hijriMonths[hMonth - 1]}) — صيامها كصيام الدهر';
    }
    if (target.weekday == DateTime.monday || target.weekday == DateTime.thursday) {
      final dayAr = target.weekday == DateTime.monday ? 'الإثنين' : 'الخميس';
      return 'اليوم يوم $dayAr — تعرض فيه الأعمال على الله تعالى';
    }
    return null;
  }
}
