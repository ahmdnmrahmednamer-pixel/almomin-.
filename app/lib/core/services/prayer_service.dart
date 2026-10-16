import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';

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
  static Map<String, int> toHijri(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;

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

class CityCoordinate {
  final String name;
  final double latitude;
  final double longitude;
  final String method;

  const CityCoordinate(this.name, this.latitude, this.longitude, [this.method = 'egyptian']);
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

  static const List<CityCoordinate> famousCities = [
    CityCoordinate('القاهرة، مصر', 30.0444, 31.2357, 'egyptian'),
    CityCoordinate('الإسكندرية، مصر', 31.2001, 29.9187, 'egyptian'),
    CityCoordinate('الجيزة، مصر', 30.0131, 31.2089, 'egyptian'),
    CityCoordinate('المنصورة، مصر', 31.0409, 31.3785, 'egyptian'),
    CityCoordinate('طنطا، مصر', 30.7865, 31.0004, 'egyptian'),
    CityCoordinate('أسيوط، مصر', 27.1783, 31.1859, 'egyptian'),
    CityCoordinate('سوهاج، مصر', 26.5569, 31.6948, 'egyptian'),
    CityCoordinate('قنا والأقصر، مصر', 25.6872, 32.6396, 'egyptian'),
    CityCoordinate('أسوان، مصر', 24.0889, 32.8998, 'egyptian'),
    CityCoordinate('بورسعيد، مصر', 31.2653, 32.3019, 'egyptian'),
    CityCoordinate('السويس، مصر', 29.9668, 32.5498, 'egyptian'),
    CityCoordinate('الإسماعيلية، مصر', 30.5965, 32.2715, 'egyptian'),
    CityCoordinate('مكة المكرمة، السعودية', 21.3891, 39.8579, 'makkah'),
    CityCoordinate('المدينة المنورة، السعودية', 24.5247, 39.5692, 'makkah'),
    CityCoordinate('الرياض، السعودية', 24.7136, 46.6753, 'makkah'),
    CityCoordinate('جدة، السعودية', 21.4858, 39.1925, 'makkah'),
    CityCoordinate('الدمام والخبر، السعودية', 26.4207, 50.0888, 'makkah'),
    CityCoordinate('القدس الشريف، فلسطين', 31.7683, 35.2137, 'mwl'),
    CityCoordinate('غزة، فلسطين', 31.5017, 34.4668, 'egyptian'),
    CityCoordinate('عمّان، الأردن', 31.9454, 35.9284, 'mwl'),
    CityCoordinate('دمشق، سوريا', 33.5138, 36.2765, 'mwl'),
    CityCoordinate('بيروت، لبنان', 33.8938, 35.5018, 'mwl'),
    CityCoordinate('بغداد، العراق', 33.3152, 44.3661, 'mwl'),
    CityCoordinate('الكويت، الكويت', 29.3759, 47.9774, 'makkah'),
    CityCoordinate('الدوحة، قطر', 25.2854, 51.5310, 'makkah'),
    CityCoordinate('المنامة، البحرين', 26.2285, 50.5860, 'makkah'),
    CityCoordinate('أبوظبي، الإمارات', 24.4539, 54.3773, 'makkah'),
    CityCoordinate('دبي، الإمارات', 25.2048, 55.2708, 'makkah'),
    CityCoordinate('مسقط، عُمان', 23.5880, 58.3829, 'makkah'),
    CityCoordinate('صنعاء، اليمن', 15.3694, 44.1910, 'makkah'),
    CityCoordinate('طرابلس، ليبيا', 32.8872, 13.1913, 'mwl'),
    CityCoordinate('تونس، تونس', 36.8065, 10.1815, 'mwl'),
    CityCoordinate('الجزائر، الجزائر', 36.7538, 3.0588, 'mwl'),
    CityCoordinate('الرباط، المغرب', 34.0209, -6.8416, 'mwl'),
    CityCoordinate('الدار البيضاء، المغرب', 33.5731, -7.5898, 'mwl'),
    CityCoordinate('الخرطوم، السودان', 15.5007, 32.5599, 'egyptian'),
    CityCoordinate('إسطنبول، تركيا', 41.0082, 28.9784, 'mwl'),
  ];

  PrayerData? _currentData;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _tickerTimer;

  PrayerData? get currentData => _currentData;
  bool get isLoading => _isLoading;
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

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLat = prefs.getDouble('last_latitude') ?? defaultLat;
    final savedLng = prefs.getDouble('last_longitude') ?? defaultLng;
    final savedCity = prefs.getString('last_city') ?? defaultCity;

    _calculatePrayers(savedLat, savedLng, savedCity);

    // Setup periodic countdown ticker every 30 seconds
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentData != null) {
        _calculatePrayers(_currentData!.latitude, _currentData!.longitude, _currentData!.locationName);
      }
    });

    // Attempt GPS in background without blocking UI
    requestGpsLocation();
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_latitude', city.latitude);
    await prefs.setDouble('last_longitude', city.longitude);
    await prefs.setString('last_city', city.name);

    if (city.method.isNotEmpty) {
      await SettingsService.instance.setCalculationMethod(city.method);
    }

    _calculatePrayers(city.latitude, city.longitude, city.name);
    notifyListeners();
    return true;
  }

  Future<bool> requestGpsLocation() async {
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
    super.dispose();
  }
}
