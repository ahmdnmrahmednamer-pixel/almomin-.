import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import '../models/ramadan_day.dart';
import 'prayer_service.dart';
import 'settings_service.dart';

class RamadanCountdownInfo {
  final String title; // موعد الإفطار المبارك / موعد الإمساك والسحور
  final Duration remaining;
  final String targetTimeFormatted;
  final bool isFasting; // true if between Fajr and Maghrib (waiting for Iftar)

  const RamadanCountdownInfo({
    required this.title,
    required this.remaining,
    required this.targetTimeFormatted,
    required this.isFasting,
  });
}

class RamadanService extends ChangeNotifier {
  static final RamadanService instance = RamadanService._internal();
  RamadanService._internal();

  bool _isInitialized = false;
  final Set<int> _fastedDays = {};
  final Set<int> _taraweehDays = {};
  final Set<int> _quranDays = {};

  Set<int> get fastedDays => Set.unmodifiable(_fastedDays);
  Set<int> get taraweehDays => Set.unmodifiable(_taraweehDays);
  Set<int> get quranDays => Set.unmodifiable(_quranDays);

  int get totalFastedCount => _fastedDays.length;
  int get totalTaraweehCount => _taraweehDays.length;
  int get totalQuranCount => _quranDays.length;
  double get fastingProgress => _fastedDays.isEmpty ? 0.0 : _fastedDays.length / 30.0;

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final fasted = prefs.getStringList('ramadan_fasted_days') ?? [];
      final taraweeh = prefs.getStringList('ramadan_taraweeh_days') ?? [];
      final quran = prefs.getStringList('ramadan_quran_days') ?? [];

      _fastedDays
        ..clear()
        ..addAll(fasted.map((s) => int.tryParse(s) ?? 0).where((n) => n > 0));
      _taraweehDays
        ..clear()
        ..addAll(taraweeh.map((s) => int.tryParse(s) ?? 0).where((n) => n > 0));
      _quranDays
        ..clear()
        ..addAll(quran.map((s) => int.tryParse(s) ?? 0).where((n) => n > 0));
    } catch (e) {
      debugPrint('RamadanService init error: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool isDayFasted(int day) => _fastedDays.contains(day);
  bool isTaraweehCompleted(int day) => _taraweehDays.contains(day);
  bool isQuranCompleted(int day) => _quranDays.contains(day);

  Future<void> toggleFasted(int day) async {
    if (_fastedDays.contains(day)) {
      _fastedDays.remove(day);
    } else {
      _fastedDays.add(day);
    }
    notifyListeners();
    _saveTracker('ramadan_fasted_days', _fastedDays);
  }

  Future<void> toggleTaraweeh(int day) async {
    if (_taraweehDays.contains(day)) {
      _taraweehDays.remove(day);
    } else {
      _taraweehDays.add(day);
    }
    notifyListeners();
    _saveTracker('ramadan_taraweeh_days', _taraweehDays);
  }

  Future<void> toggleQuran(int day) async {
    if (_quranDays.contains(day)) {
      _quranDays.remove(day);
    } else {
      _quranDays.add(day);
    }
    notifyListeners();
    _saveTracker('ramadan_quran_days', _quranDays);
  }

  Future<void> _saveTracker(String key, Set<int> set) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, set.map((n) => n.toString()).toList());
    } catch (e) {
      debugPrint('Error saving ramadan tracker: $e');
    }
  }

  CalculationParameters _getParams() {
    final method = SettingsService.instance.calculationMethod;
    switch (method) {
      case 'makkah':
        return CalculationMethodParameters.ummAlQura();
      case 'mwl':
        return CalculationMethodParameters.muslimWorldLeague();
      case 'isna':
        return CalculationMethodParameters.northAmerica();
      case 'karachi':
        return CalculationMethodParameters.karachi();
      case 'egyptian':
      default:
        return CalculationMethodParameters.egyptian();
    }
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final hStr = hour.toString().padLeft(2, '0');
    return '$hStr:$minute $period';
  }

  List<RamadanDay> generateImsakiyyah({
    double? latitude,
    double? longitude,
    DateTime? startDate,
  }) {
    final lat = latitude ?? PrayerService.instance.currentData?.latitude ?? 30.0444; // Default Cairo
    final lng = longitude ?? PrayerService.instance.currentData?.longitude ?? 31.2357;
    final coords = Coordinates(lat, lng);
    final params = _getParams();

    // Default to upcoming Ramadan 1448 H (approx Feb 8, 2027) or provided date
    final start = startDate ?? DateTime(2027, 2, 8);

    final days = <RamadanDay>[];
    for (int i = 0; i < 30; i++) {
      final date = start.add(Duration(days: i));
      final pt = PrayerTimes(
        coordinates: coords,
        date: date,
        calculationParameters: params,
      );

      final fajr = pt.fajr.toLocal();
      final sunrise = pt.sunrise.toLocal();
      final dhuhr = pt.dhuhr.toLocal();
      final asr = pt.asr.toLocal();
      final maghrib = pt.maghrib.toLocal();
      final isha = pt.isha.toLocal();
      final imsak = fajr.subtract(const Duration(minutes: 10));

      days.add(RamadanDay(
        dayNumber: i + 1,
        gregorianDate: date,
        dayName: HijriDateHelper.getDayOfWeek(date),
        imsakTime: _formatTime(imsak),
        fajrTime: _formatTime(fajr),
        sunriseTime: _formatTime(sunrise),
        dhuhrTime: _formatTime(dhuhr),
        asrTime: _formatTime(asr),
        maghribTime: _formatTime(maghrib),
        ishaTime: _formatTime(isha),
        dailyDuaa: _dailyDuaas[i % _dailyDuaas.length],
      ));
    }
    return days;
  }

  RamadanCountdownInfo getCountdown([DateTime? customNow]) {
    final now = customNow ?? DateTime.now();
    final data = PrayerService.instance.currentData;

    if (data == null || data.prayers.isEmpty) {
      return const RamadanCountdownInfo(
        title: 'موعد الإفطار المبارك',
        remaining: Duration(hours: 4),
        targetTimeFormatted: '06:00 م',
        isFasting: true,
      );
    }

    final fajr = data.prayers.firstWhere((p) => p.name.contains('الفجر'), orElse: () => data.prayers.first).time;
    final maghrib = data.prayers.firstWhere((p) => p.name.contains('المغرب'), orElse: () => data.prayers.last).time;
    final imsak = fajr.subtract(const Duration(minutes: 10));

    if (now.isAfter(fajr) && now.isBefore(maghrib)) {
      // Fasting time -> waiting for Iftar (Maghrib)
      final diff = maghrib.difference(now);
      return RamadanCountdownInfo(
        title: 'المتبقي حتى أذان المغرب (الإفطار المبارك)',
        remaining: diff.isNegative ? Duration.zero : diff,
        targetTimeFormatted: _formatTime(maghrib),
        isFasting: true,
      );
    } else {
      // Night time -> waiting for Imsak / Fajr (Suhur)
      DateTime nextImsak = imsak;
      if (now.isAfter(imsak)) {
        nextImsak = imsak.add(const Duration(days: 1));
      }
      final diff = nextImsak.difference(now);
      return RamadanCountdownInfo(
        title: 'المتبقي حتى وقت الإمساك والسحور',
        remaining: diff.isNegative ? Duration.zero : diff,
        targetTimeFormatted: _formatTime(nextImsak),
        isFasting: false,
      );
    }
  }

  static const List<String> _dailyDuaas = [
    'اللَّهُمَّ بَلِّغْنَا رَمَضَانَ وَأَعِنَّا فِيهِ عَلَى الصِّيَامِ وَالْقِيَامِ وَتِلَاوَةِ الْقُرْآنِ.',
    'اللَّهُمَّ اجْعَلْنَا فِيهِ مِنَ الْمُتَوَكِّلِينَ عَلَيْكَ، وَالفَائِزِينَ لَدَيْكَ.',
    'اللَّهُمَّ قَوِّنِي فِيهِ عَلَى إِقَامَةِ أَمْرِكَ، وَأَوْزِعْنِي فِيهِ لِأَدَاءِ شُكْرِكَ بِكَرَمِكَ.',
    'اللَّهُمَّ اجْعَلْنِي فِيهِ مِنَ الْمُسْتَغْفِرِينَ، وَاجْعَلْنِي فِيهِ مِنْ عِبَادِكَ الصَّالِحِينَ.',
    'اللَّهُمَّ لَا تَخْذُلْنِي فِيهِ لِتَعَرُّضِ مَعْصِيَتِكَ، وَأَعِذْنِي مِنْ مُوجِبَاتِ سَخَطِكَ.',
    'اللَّهُمَّ أَعِنِّي فِيهِ عَلَى صِيَامِهِ وَقِيَامِهِ، وَجَنِّبْنِي فِيهِ مِنْ هَفَوَاتِهِ وَآثَامِهِ.',
    'اللَّهُمَّ ارْزُقْنِي فِيهِ رَحْمَةَ الْأَيْتَامِ، وَإِطْعَامَ الطَّعَامِ، وَإِفْشَاءَ السَّلَامِ.',
    'اللَّهُمَّ اجْعَلْ لِي فِيهِ نَصِيبًا مِنْ رَحْمَتِكَ الْوَاسِعَةِ، وَاهْدِنِي فِيهِ لِبَرَاهِينِكَ السَّاطِعَةِ.',
    'اللَّهُمَّ اجْعَلْنِي فِيهِ مِنَ الْمُحْسِنِينَ، وَأَعِنِّي عَلَى كَظْمِ الْغَيْظِ وَالعَفْوِ عَنِ النَّاسِ.',
    'اللَّهُمَّ حَبِّبْ إِلَيَّ فِيهِ الْإِحْسَانَ، وَكَرِّهْ إِلَيَّ فِيهِ الْفُسُوقَ وَالْعِصْيَانَ.',
  ];

  static const List<RamadanDuaa> supplications = [
    RamadanDuaa(
      title: 'دعاء النبي ﷺ عند الإفطار',
      arabicText: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الأَجْرُ إِنْ شَاءَ اللَّهُ.',
      category: 'عند الإفطار',
      source: 'سنن أبي داود والدارقطني (صحيح)',
    ),
    RamadanDuaa(
      title: 'دعاء استجابة الصائم المأثور',
      arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ أَنْ تَغْفِرَ لِي.',
      category: 'عند الإفطار',
      source: 'سنن ابن ماجه عن عبد الله بن عمرو (حسن)',
    ),
    RamadanDuaa(
      title: 'دعاء الصائم إذا أفطر عند قوم',
      arabicText: 'أَفْطَرَ عِنْدَكُمُ الصَّائِمُونَ، وَأَكَلَ طَعَامَكُمُ الأَبْرَارُ، وَصَلَّتْ عَلَيْكُمُ الْمَلائِكَةُ.',
      category: 'آداب الطعام',
      source: 'سنن أبي داود والنسائي (صحيح)',
    ),
    RamadanDuaa(
      title: 'دعاء ليلة القدر الذي علمه النبي لعائشة',
      arabicText: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي.',
      category: 'ليلة القدر والعشر الأواخر',
      source: 'جامع الترمذي وصحيح ابن ماجه (صحيح)',
    ),
    RamadanDuaa(
      title: 'دعاء رؤية هلال شهر رمضان المبارك',
      arabicText: 'اللَّهُ أَكْبَرُ، اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالأَمْنِ وَالإِيمَانِ، وَالسَّلامَةِ وَالإِسْلامِ، وَالتَّوْفِيقِ لِمَا تُحِبُّ وَتَرْضَى، رَبُّنَا وَرَبُّكَ اللَّهُ.',
      category: 'رؤية الهلال',
      source: 'سنن الترمذي ومسند أحمد (صحيح)',
    ),
    RamadanDuaa(
      title: 'ذكر ودعاء وقت السحر والاستغفار',
      arabicText: 'وَبِالْأَسْحَارِ هُمْ يَسْتَغْفِرُونَ · رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ.',
      category: 'وقت السحر',
      source: 'القرآن الكريم — آل عمران والذاريات',
    ),
  ];
}
