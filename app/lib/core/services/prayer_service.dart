import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';
import '../models/arab_countries.dart';
import '../notifications/prayer_notification_service.dart';

export '../models/arab_countries.dart';

class HijriDateHelper {
  static const List<String> hijriMonths = [
    'المحرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];

  static const List<String> gregorianMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  static const List<String> arabicDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];

  /// Converts Gregorian DateTime to Hijri (year, month, day)
  /// Applies [adjustmentDays] (or persisted SettingsService.hijriAdjustmentDays)
  static Map<String, int> toHijri(DateTime date, {int? adjustmentDays}) {
    final int adj = adjustmentDays ?? SettingsService.instance.hijriAdjustmentDays;
    final DateTime effective = adj == 0 ? date : date.add(Duration(days: adj));

    int y = effective.year;
    int m = effective.month;
    int d = effective.day;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    int a = y ~/ 100;
    int b = 2 - a + (a ~/ 4);
    int jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524;
    int l = jd - 1948440 + 10632;
    int n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    int j = (((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719)) + ((l ~/ 5670) * ((43 * l) ~/ 15238));
    l = l - (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) - ((j ~/ 16) * ((15238 * j) ~/ 43)) + 29;
    int hm = (24 * l) ~/ 709;
    int hd = l - (709 * hm) ~/ 24;
    int hy = 30 * n + j - 30;

    return {'year': hy, 'month': hm.clamp(1, 12), 'day': hd.clamp(1, 30)};
  }

  /// Returns full Hijri text: e.g. "4 جمادى الأولى 1448 هـ"
  static String getHijriDateString([DateTime? date]) {
    final d = date ?? DateTime.now();
    final h = toHijri(d);
    final monthName = hijriMonths[h['month']! - 1];
    return '${h['day']} $monthName ${h['year']} هـ';
  }

  /// Returns full Gregorian text: e.g. "16 أكتوبر 2026 م"
  static String getGregorianDateString([DateTime? date]) {
    final d = date ?? DateTime.now();
    final monthName = gregorianMonths[d.month - 1];
    return '${d.day} $monthName ${d.year} م';
  }

  /// Returns day of the week: e.g. "الجمعة"
  static String getDayOfWeek([DateTime? date]) {
    final d = date ?? DateTime.now();
    return arabicDays[d.weekday - 1];
  }
}

class PrayerInfo {
  final String name;
  final DateTime time;
  final String formattedTime;
  final bool isNext;

  const PrayerInfo({
    required this.name,
    required this.time,
    required this.formattedTime,
    this.isNext = false,
  });
}

class PrayerData {
  final double latitude;
  final double longitude;
  final String locationName;
  final List<PrayerInfo> prayers;
  final PrayerInfo? nextPrayer;
  final Duration timeToNextPrayer;
  final double qiblaDegrees;
  final DateTime lastUpdated;

  const PrayerData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.prayers,
    this.nextPrayer,
    this.timeToNextPrayer = Duration.zero,
    required this.qiblaDegrees,
    required this.lastUpdated,
  });
}

class PrayerService extends ChangeNotifier {
  static final PrayerService instance = PrayerService._internal();
  PrayerService._internal();

  /// Canonical list of all Arab countries and their cities
  static List<CityCoordinate> get famousCities => ArabCountriesData.allCities;

  PrayerData? _currentData;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isManualLocation = false;
  String? _errorMessage;
  Timer? _tickerTimer;
  String _lastCalculationMethod = '';

  /// Lightweight 1-second notifier for countdown badges so the entire HomeScreen
  /// does not rebuild 86,400 times per day (Bug #2 fix).
  final ValueNotifier<Duration> countdownNotifier = ValueNotifier<Duration>(Duration.zero);

  PrayerData? get currentData => _currentData;
  bool get isLoading => _isLoading;
  bool get isManualLocation => _isManualLocation;
  String? get errorMessage => _errorMessage;

  // Default fallback: Cairo, Egypt
  static const double defaultLat = 30.0444;
  static const double defaultLng = 31.2357;
  static const String defaultCity = 'القاهرة، مصر';

  String identifyCity(double lat, double lng) {
    double minDistance = double.infinity;
    String closest = 'موقعك الفعلي (${lat.toStringAsFixed(2)}°, ${lng.toStringAsFixed(2)}°)';

    for (final c in famousCities) {
      final dLat = (lat - c.latitude) * 111.0;
      final dLng = (lng - c.longitude) * 111.0 * cos(lat * pi / 180.0);
      final distKm = sqrt(dLat * dLat + dLng * dLng);
      if (distKm < minDistance) {
        minDistance = distKm;
        if (distKm <= 90.0) {
          closest = '${c.name} (GPS)';
        }
      }
    }
    return closest;
  }

  Future<void> init({bool forceRefresh = false, bool forceReload = false}) async {
    if (_isInitialized && !forceRefresh && !forceReload && _currentData != null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedLat = prefs.getDouble('last_latitude') ?? defaultLat;
    final savedLng = prefs.getDouble('last_longitude') ?? defaultLng;
    final savedCity = prefs.getString('last_city') ?? defaultCity;
    _isManualLocation = prefs.getBool('is_manual_location') ?? false;
    _lastCalculationMethod = SettingsService.instance.calculationMethod;

    SettingsService.instance.removeListener(_onSettingsChanged);
    SettingsService.instance.addListener(_onSettingsChanged);

    _calculatePrayers(savedLat, savedLng, savedCity);

    // Setup continuous live ticking every 1 second to update countdown and prayers dynamically
    _startLiveTicker();
    _isInitialized = true;

    // Only attempt automatic GPS lookup if the user has NOT explicitly chosen a manual city (Bug #1 fix)
    if (!_isManualLocation) {
      unawaited(requestGpsLocation(isAutoInit: true));
    }
  }

  void _onSettingsChanged() {
    final currentMethod = SettingsService.instance.calculationMethod;
    if (currentMethod != _lastCalculationMethod) {
      _lastCalculationMethod = currentMethod;
      recalculateWithCurrentSettings();
    }
  }

  /// Recalculates prayer times immediately when calculation method or settings change (Bug #3 fix)
  void recalculateWithCurrentSettings() {
    if (_currentData == null) return;
    _calculatePrayers(
      _currentData!.latitude,
      _currentData!.longitude,
      _currentData!.locationName,
    );
  }

  void _startLiveTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentData != null) {
        _tickContinuousCountdown();
      }
    });
  }

  void _tickContinuousCountdown() {
    if (_currentData == null) return;
    final now = DateTime.now();

    // If date rolled over past midnight, recalculate entire day
    if (now.day != _currentData!.lastUpdated.day) {
      _calculatePrayers(_currentData!.latitude, _currentData!.longitude, _currentData!.locationName);
      return;
    }

    if (_currentData!.nextPrayer != null) {
      final pTime = _currentData!.nextPrayer!.time;
      final diff = pTime.difference(now);

      // When the countdown reaches zero or prayer time arrives, recalculate immediately to shift to next prayer
      if (diff.isNegative || diff.inSeconds <= 0) {
        _calculatePrayers(_currentData!.latitude, _currentData!.longitude, _currentData!.locationName);
        return;
      }

      // Update timeToNextPrayer and lightweight countdownNotifier second-by-second
      _currentData = PrayerData(
        latitude: _currentData!.latitude,
        longitude: _currentData!.longitude,
        locationName: _currentData!.locationName,
        prayers: _currentData!.prayers,
        nextPrayer: _currentData!.nextPrayer,
        timeToNextPrayer: diff,
        qiblaDegrees: _currentData!.qiblaDegrees,
        lastUpdated: _currentData!.lastUpdated,
      );
      countdownNotifier.value = diff;

      // Only trigger global ChangeNotifier listeners once per minute instead of every second (Bug #2 fix)
      if (diff.inSeconds % 60 == 0) {
        notifyListeners();
      }
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

  Future<bool> setManualCity(CityCoordinate city) async {
    _isManualLocation = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_manual_location', true);
    await prefs.setDouble('last_latitude', city.latitude);
    await prefs.setDouble('last_longitude', city.longitude);
    await prefs.setString('last_city', city.name);
    if (city.country.isNotEmpty) {
      await prefs.setString('last_country', city.country);
    }

    if (city.method.isNotEmpty) {
      _lastCalculationMethod = city.method;
      await SettingsService.instance.setCalculationMethod(city.method);
    }

    _calculatePrayers(city.latitude, city.longitude, city.name);
    notifyListeners();
    return true;
  }

  Future<bool> requestGpsLocation({bool isAutoInit = false}) async {
    if (isAutoInit && _isManualLocation) {
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _errorMessage = 'خدمات تحديد الموقع (GPS) غير مفعلة على الهاتف';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _errorMessage = 'تم رفض إذن الوصول إلى الموقع الجغرافي';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _errorMessage = 'إذن الموقع مرفوض نهائياً. يمكنك اختيار مدينتك يدوياً';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // First check fast cached position
      Position? position = await Geolocator.getLastKnownPosition();

      // If no cached position or stale, fetch current with fallback
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 12),
      );

      if (position == null) {
        throw Exception('لم نتمكن من الحصول على الإحداثيات');
      }

      final locName = identifyCity(position.latitude, position.longitude);

      final prefs = await SharedPreferences.getInstance();
      if (!isAutoInit) {
        _isManualLocation = false;
        await prefs.setBool('is_manual_location', false);
      }
      await prefs.setDouble('last_latitude', position.latitude);
      await prefs.setDouble('last_longitude', position.longitude);
      await prefs.setString('last_city', locName);

      _calculatePrayers(position.latitude, position.longitude, locName);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'تعذر تثبيت إشارة GPS. تم الاحتفاظ بالموقع الحالي.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void _calculatePrayers(double lat, double lng, String locName) {
    final now = DateTime.now();
    final coords = Coordinates(lat, lng);
    final params = _getParams();
    final pt = PrayerTimes(
      coordinates: coords,
      date: now,
      calculationParameters: params,
    );

    // CRITICAL: Convert all adhan_dart UTC times to the device's local timezone
    final rawList = [
      {'name': 'الفجر', 'time': pt.fajr.toLocal()},
      {'name': 'الشروق', 'time': pt.sunrise.toLocal()},
      {'name': 'الظهر', 'time': pt.dhuhr.toLocal()},
      {'name': 'العصر', 'time': pt.asr.toLocal()},
      {'name': 'المغرب', 'time': pt.maghrib.toLocal()},
      {'name': 'العشاء', 'time': pt.isha.toLocal()},
    ];

    // Find next prayer based on local time
    PrayerInfo? nextP;
    Duration minDiff = const Duration(days: 1);

    for (final item in rawList) {
      final pTime = item['time'] as DateTime?;
      if (pTime != null && pTime.isAfter(now)) {
        final diff = pTime.difference(now);
        if (diff < minDiff) {
          minDiff = diff;
          nextP = PrayerInfo(
            name: item['name'] as String,
            time: pTime,
            formattedTime: _formatTime(pTime),
            isNext: true,
          );
        }
      }
    }

    // If all prayers today passed, next is tomorrow's Fajr
    if (nextP == null) {
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowPt = PrayerTimes(
        coordinates: coords,
        date: tomorrow,
        calculationParameters: params,
      );
      final tFajr = tomorrowPt.fajr.toLocal();
      minDiff = tFajr.difference(now);
      nextP = PrayerInfo(
        name: 'الفجر (غداً)',
        time: tFajr,
        formattedTime: _formatTime(tFajr),
        isNext: true,
      );
    }

    final List<PrayerInfo> resultList = [];
    for (final item in rawList) {
      final pTime = item['time'] as DateTime?;
      final name = item['name'] as String;
      if (pTime != null) {
        resultList.add(PrayerInfo(
          name: name,
          time: pTime,
          formattedTime: _formatTime(pTime),
          isNext: nextP?.name == name,
        ));
      }
    }

    double qiblaDeg = 136.0;
    try {
      qiblaDeg = Qibla.qibla(coords);
    } catch (_) {}

    _currentData = PrayerData(
      latitude: lat,
      longitude: lng,
      locationName: locName,
      prayers: resultList,
      nextPrayer: nextP,
      timeToNextPrayer: minDiff,
      qiblaDegrees: qiblaDeg,
      lastUpdated: now,
    );
    countdownNotifier.value = minDiff;
    try {
      PrayerNotificationService.instance.schedulePrayerNotifications(_currentData!);
    } catch (_) {}
    notifyListeners();
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

  String formatCountdown(Duration d) {
    if (d.isNegative) return 'حان الآن';
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    SettingsService.instance.removeListener(_onSettingsChanged);
    countdownNotifier.dispose();
    super.dispose();
  }
}
