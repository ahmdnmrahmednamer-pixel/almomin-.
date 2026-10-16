import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReciterInfo {
  final String id;
  final String nameAr;
  final String subfolder;

  const ReciterInfo({
    required this.id,
    required this.nameAr,
    required this.subfolder,
  });
}

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  static const List<ReciterInfo> availableReciters = [
    ReciterInfo(id: 'alafasy', nameAr: 'مشاري راشد العفاسي', subfolder: 'Alafasy_128kbps'),
    ReciterInfo(id: 'abdulbasit_murattal', nameAr: 'عبد الباسط عبد الصمد (مرتل)', subfolder: 'Abdul_Basit_Murattal_192kbps'),
    ReciterInfo(id: 'abdulbasit_mujawwad', nameAr: 'عبد الباسط عبد الصمد (مجود)', subfolder: 'AbdulSamad_64kbps_QuranExplorer.Com'),
    ReciterInfo(id: 'minshawi_murattal', nameAr: 'محمد صديق المنشاوي (مرتل)', subfolder: 'Minshawy_Murattal_128kbps'),
    ReciterInfo(id: 'minshawi_mujawwad', nameAr: 'محمد صديق المنشاوي (مجود)', subfolder: 'Minshawy_Mujawwad_192kbps'),
    ReciterInfo(id: 'husary', nameAr: 'محمود خليل الحصري (مرتل)', subfolder: 'Husary_128kbps'),
    ReciterInfo(id: 'husary_mujawwad', nameAr: 'محمود خليل الحصري (مجود)', subfolder: 'Husary_128kbps_Mujawwad'),
    ReciterInfo(id: 'maher', nameAr: 'ماهر المعيقلي', subfolder: 'MaherAlMuaiqly128kbps'),
    ReciterInfo(id: 'sudais', nameAr: 'عبد الرحمن السديس', subfolder: 'Abdurrahmaan_As-Sudais_192kbps'),
    ReciterInfo(id: 'ghamadi', nameAr: 'سعد الغامدي', subfolder: 'Ghamadi_40kbps'),
    ReciterInfo(id: 'ajamy', nameAr: 'أحمد بن علي العجمي', subfolder: 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net'),
    ReciterInfo(id: 'shuraym', nameAr: 'سعود الشريم', subfolder: 'Saood_ash-Shuraym_128kbps'),
    ReciterInfo(id: 'hudhaify', nameAr: 'علي بن عبد الرحمن الحذيفي', subfolder: 'Hudhaify_128kbps'),
  ];

  static const List<Map<String, String>> calculationMethods = [
    {'id': 'egyptian', 'name': 'الهيئة المصرية العامة للمساحة (الفجر 19.5° / العشاء 17.5°)'},
    {'id': 'makkah', 'name': 'أم القرى - مكة المكرمة'},
    {'id': 'mwl', 'name': 'رابطة العالم الإسلامي (MWL)'},
    {'id': 'isna', 'name': 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)'},
    {'id': 'karachi', 'name': 'جامعة العلوم الإسلامية بكراتشي'},
  ];

  SharedPreferences? _prefs;

  // Settings values
  double _mushafFontSize = 24.0;
  String _selectedReciterId = 'alafasy';
  String _calculationMethod = 'egyptian';
  String _themeMode = 'light'; // light, dark, sepia
  bool _adhanAlertsEnabled = true;
  List<String> _bookmarks = [];

  double get mushafFontSize => _mushafFontSize;
  String get selectedReciterId => _selectedReciterId;
  String get calculationMethod => _calculationMethod;
  String get themeMode => _themeMode;
  bool get adhanAlertsEnabled => _adhanAlertsEnabled;
  List<String> get bookmarks => _bookmarks;

  ReciterInfo get currentReciter {
    return availableReciters.firstWhere(
      (r) => r.id == _selectedReciterId,
      orElse: () => availableReciters.first,
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _mushafFontSize = _prefs?.getDouble('mushaf_font_size') ?? 24.0;
    _selectedReciterId = _prefs?.getString('selected_reciter_id') ?? 'alafasy';
    _calculationMethod = _prefs?.getString('calculation_method') ?? 'egyptian';
    _themeMode = _prefs?.getString('theme_mode') ?? 'light';
    _adhanAlertsEnabled = _prefs?.getBool('adhan_alerts') ?? true;
    _bookmarks = _prefs?.getStringList('bookmarks') ?? [];
    notifyListeners();
  }

  Future<void> setMushafFontSize(double size) async {
    _mushafFontSize = size.clamp(16.0, 42.0);
    await _prefs?.setDouble('mushaf_font_size', _mushafFontSize);
    notifyListeners();
  }

  Future<void> setSelectedReciter(String reciterId) async {
    _selectedReciterId = reciterId;
    await _prefs?.setString('selected_reciter_id', _selectedReciterId);
    notifyListeners();
  }

  Future<void> setCalculationMethod(String methodId) async {
    _calculationMethod = methodId;
    await _prefs?.setString('calculation_method', _calculationMethod);
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    await _prefs?.setString('theme_mode', _themeMode);
    notifyListeners();
  }

  Future<void> toggleAdhanAlerts(bool enabled) async {
    _adhanAlertsEnabled = enabled;
    await _prefs?.setBool('adhan_alerts', _adhanAlertsEnabled);
    notifyListeners();
  }

  Future<bool> toggleBookmark(int surahId, int ayahNumber) async {
    final key = '$surahId:$ayahNumber';
    final exists = _bookmarks.contains(key);
    if (exists) {
      _bookmarks.remove(key);
    } else {
      _bookmarks.add(key);
    }
    await _prefs?.setStringList('bookmarks', _bookmarks);
    notifyListeners();
    return !exists;
  }

  bool isBookmarked(int surahId, int ayahNumber) {
    return _bookmarks.contains('$surahId:$ayahNumber');
  }

  /// Builds the EveryAyah URL for an ayah given the current reciter
  String getAyahAudioUrl(int surahId, int ayahNumber) {
    final sub = currentReciter.subfolder;
    final sStr = surahId.toString().padLeft(3, '0');
    final aStr = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$sub/$sStr$aStr.mp3';
  }
}
