import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReciterInfo {
  final String id;
  final String nameAr;
  final String style; // 'مرتل', 'مجود', 'المعلم', 'تلاوة خاشعة'
  final String serverUrl; // MP3Quran CDN Base
  final String subfolder; // EveryAyah subfolder

  const ReciterInfo({
    required this.id,
    required this.nameAr,
    required this.style,
    required this.serverUrl,
    required this.subfolder,
  });
}

class SettingsService extends ChangeNotifier {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  /// 35 Canonical Reciters per Appendix B of the Specification
  static const List<ReciterInfo> availableReciters = [
    // كبار قراء مصر والعالم الإسلامي
    ReciterInfo(
      id: 'husary',
      nameAr: 'محمود خليل الحصري (مرتل)',
      style: 'مرتل',
      serverUrl: 'https://server13.mp3quran.net/husr/',
      subfolder: 'Husary_128kbps',
    ),
    ReciterInfo(
      id: 'husary_muallim',
      nameAr: 'محمود خليل الحصري (المعلم)',
      style: 'المعلم',
      serverUrl: 'https://server13.mp3quran.net/husr_mualim/',
      subfolder: 'Husary_Muallim_128kbps',
    ),
    ReciterInfo(
      id: 'husary_mujawwad',
      nameAr: 'محمود خليل الحصري (مجود)',
      style: 'مجود',
      serverUrl: 'https://server13.mp3quran.net/husr_mjwd/',
      subfolder: 'Husary_128kbps_Mujawwad',
    ),
    ReciterInfo(
      id: 'minshawi_murattal',
      nameAr: 'محمد صديق المنشاوي (مرتل)',
      style: 'مرتل',
      serverUrl: 'https://server10.mp3quran.net/minsh/',
      subfolder: 'Minshawy_Murattal_128kbps',
    ),
    ReciterInfo(
      id: 'minshawi_mujawwad',
      nameAr: 'محمد صديق المنشاوي (مجود)',
      style: 'مجود',
      serverUrl: 'https://server10.mp3quran.net/minsh_mjwd/',
      subfolder: 'Minshawy_Mujawwad_192kbps',
    ),
    ReciterInfo(
      id: 'abdulbasit_murattal',
      nameAr: 'عبد الباسط عبد الصمد (مرتل)',
      style: 'مرتل',
      serverUrl: 'https://server7.mp3quran.net/basit/',
      subfolder: 'Abdul_Basit_Murattal_192kbps',
    ),
    ReciterInfo(
      id: 'abdulbasit_mujawwad',
      nameAr: 'عبد الباسط عبد الصمد (مجود)',
      style: 'مجود',
      serverUrl: 'https://server7.mp3quran.net/basit_mjwd/',
      subfolder: 'AbdulSamad_64kbps_QuranExplorer.Com',
    ),
    ReciterInfo(
      id: 'mustafa_ismail',
      nameAr: 'مصطفى إسماعيل (مجود)',
      style: 'مجود',
      serverUrl: 'https://server8.mp3quran.net/mustafa/',
      subfolder: 'Mustafa_Ismail_48kbps',
    ),
    ReciterInfo(
      id: 'banna',
      nameAr: 'محمود علي البنا (مرتل)',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/bna/',
      subfolder: 'Banna_32kbps',
    ),
    ReciterInfo(
      id: 'rifaat',
      nameAr: 'محمد رفعت (تلاوات نادرة)',
      style: 'مجود',
      serverUrl: 'https://server14.mp3quran.net/refat/',
      subfolder: 'Rifat_32kbps',
    ),
    ReciterInfo(
      id: 'tablawi',
      nameAr: 'محمد محمود الطبلاوي',
      style: 'مرتل',
      serverUrl: 'https://server12.mp3quran.net/tblwi/',
      subfolder: 'Mohammad_al_Tablaway_128kbps',
    ),
    ReciterInfo(
      id: 'naina',
      nameAr: 'أحمد نعينع',
      style: 'مجود',
      serverUrl: 'https://server11.mp3quran.net/dr_ahmed/',
      subfolder: 'Ahmed_Neana_128kbps',
    ),
    // أئمة الحرمين الشريفين وكبار القراء المعاصرين
    ReciterInfo(
      id: 'alafasy',
      nameAr: 'مشاري راشد العفاسي',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/afs/',
      subfolder: 'Alafasy_128kbps',
    ),
    ReciterInfo(
      id: 'maher',
      nameAr: 'ماهر المعيقلي',
      style: 'مرتل',
      serverUrl: 'https://server12.mp3quran.net/maher/',
      subfolder: 'MaherAlMuaiqly128kbps',
    ),
    ReciterInfo(
      id: 'sudais',
      nameAr: 'عبد الرحمن السديس',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/sds/',
      subfolder: 'Abdurrahmaan_As-Sudais_192kbps',
    ),
    ReciterInfo(
      id: 'shuraym',
      nameAr: 'سعود الشريم',
      style: 'مرتل',
      serverUrl: 'https://server7.mp3quran.net/shur/',
      subfolder: 'Saood_ash-Shuraym_128kbps',
    ),
    ReciterInfo(
      id: 'ghamadi',
      nameAr: 'سعد الغامدي',
      style: 'مرتل',
      serverUrl: 'https://server7.mp3quran.net/s_gmd/',
      subfolder: 'Ghamadi_40kbps',
    ),
    ReciterInfo(
      id: 'dosari',
      nameAr: 'ياسر الدوسري',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server11.mp3quran.net/yasser/',
      subfolder: 'Yasser_Ad-Dussary_128kbps',
    ),
    ReciterInfo(
      id: 'qatami',
      nameAr: 'ناصر القطامي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server6.mp3quran.net/qtm/',
      subfolder: 'Nasser_Alqatami_128kbps',
    ),
    ReciterInfo(
      id: 'ajamy',
      nameAr: 'أحمد بن علي العجمي',
      style: 'مرتل',
      serverUrl: 'https://server10.mp3quran.net/ajm/',
      subfolder: 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
    ),
    ReciterInfo(
      id: 'rifai',
      nameAr: 'هاني الرفاعي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server8.mp3quran.net/rifai/',
      subfolder: 'Hani_Rifai_192kbps',
    ),
    ReciterInfo(
      id: 'shatri',
      nameAr: 'أبو بكر الشاطري',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/shatri/',
      subfolder: 'Abu_Bakr_Ash-Shaatree_128kbps',
    ),
    ReciterInfo(
      id: 'idris_abkar',
      nameAr: 'إدريس أبكر',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server6.mp3quran.net/abkr/',
      subfolder: 'Idrees_Abkar_128kbps',
    ),
    ReciterInfo(
      id: 'basfar',
      nameAr: 'عبد الله بصفر',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/bsfr/',
      subfolder: 'Abdullah_Basfar_192kbps',
    ),
    ReciterInfo(
      id: 'hudhaify',
      nameAr: 'علي بن عبد الرحمن الحذيفي',
      style: 'مرتل',
      serverUrl: 'https://server9.mp3quran.net/hthfi/',
      subfolder: 'Hudhaify_128kbps',
    ),
    ReciterInfo(
      id: 'juhany',
      nameAr: 'عبد الله عواد الجهني',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/jhn/',
      subfolder: 'Abdullaah_3wwad_Al-Juhaynee_128kbps',
    ),
    ReciterInfo(
      id: 'bukhatir',
      nameAr: 'صلاح بو خاطر',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/bu_khtr/',
      subfolder: 'Salah_Bukhatir_128kbps',
    ),
    ReciterInfo(
      id: 'fares_abbad',
      nameAr: 'فارس عباد',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/frs_a/',
      subfolder: 'Fares_Abbad_128kbps',
    ),
    ReciterInfo(
      id: 'muhammad_ayyoub',
      nameAr: 'محمد أيوب',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/ayyub/',
      subfolder: 'Muhammad_Ayyoub_128kbps',
    ),
    ReciterInfo(
      id: 'thubaity',
      nameAr: 'عبد الباري الثبيتي',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/thubti/',
      subfolder: 'Abdulbari_Ath-Thubaity_128kbps',
    ),
    ReciterInfo(
      id: 'khalid_jalil',
      nameAr: 'خالد الجليل',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server10.mp3quran.net/jleel/',
      subfolder: 'Khalid_Al-Jileel_128kbps',
    ),
    ReciterInfo(
      id: 'akhdar',
      nameAr: 'إبراهيم الأخضر',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/akhdr/',
      subfolder: 'Ibrahim_Akhdar_32kbps',
    ),
    ReciterInfo(
      id: 'ali_jaber',
      nameAr: 'علي جابر (رحمه الله)',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/a_jbr/',
      subfolder: 'Ali_Jaber_64kbps',
    ),
    ReciterInfo(
      id: 'yamani',
      nameAr: 'وديع اليمني',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server6.mp3quran.net/wd3/',
      subfolder: 'Wadee_Al-Yamani_128kbps',
    ),
    ReciterInfo(
      id: 'salimi',
      nameAr: 'منصور السالمي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server16.mp3quran.net/mansor/',
      subfolder: 'Mansoor_Al-Salimi_128kbps',
    ),
    ReciterInfo(
      id: 'kurdi',
      nameAr: 'رعد محمد الكردي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server12.mp3quran.net/raad/',
      subfolder: 'Raad_Al-Kurdi_128kbps',
    ),
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

  // Reading persistence
  int _lastReadSurahId = 1;
  int _lastReadAyahNumber = 1;
  int _lastReadPageNumber = 1;
  String _lastReadSurahName = 'الفاتحة';

  double get mushafFontSize => _mushafFontSize;
  String get selectedReciterId => _selectedReciterId;
  String get calculationMethod => _calculationMethod;
  String get themeMode => _themeMode;
  bool get adhanAlertsEnabled => _adhanAlertsEnabled;
  List<String> get bookmarks => _bookmarks;

  int get lastReadSurahId => _lastReadSurahId;
  int get lastReadAyahNumber => _lastReadAyahNumber;
  int get lastReadPageNumber => _lastReadPageNumber;
  String get lastReadSurahName => _lastReadSurahName;

  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  ReciterInfo get currentReciter {
    return availableReciters.firstWhere(
      (r) => r.id == _selectedReciterId,
      orElse: () => availableReciters.first,
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = _prefs?.getBool('has_completed_onboarding') ?? false;
    _mushafFontSize = _prefs?.getDouble('mushaf_font_size') ?? 24.0;
    _selectedReciterId = _prefs?.getString('selected_reciter_id') ?? 'alafasy';
    _calculationMethod = _prefs?.getString('calculation_method') ?? 'egyptian';
    _themeMode = _prefs?.getString('theme_mode') ?? 'light';
    _adhanAlertsEnabled = _prefs?.getBool('adhan_alerts') ?? true;
    _bookmarks = _prefs?.getStringList('bookmarks') ?? [];

    _lastReadSurahId = _prefs?.getInt('last_read_surah_id') ?? 1;
    _lastReadAyahNumber = _prefs?.getInt('last_read_ayah_number') ?? 1;
    _lastReadPageNumber = _prefs?.getInt('last_read_page_number') ?? 1;
    _lastReadSurahName = _prefs?.getString('last_read_surah_name') ?? 'الفاتحة';

    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _prefs?.setBool('has_completed_onboarding', true);
    notifyListeners();
  }

  Future<void> saveLastRead({
    required int surahId,
    required int ayahNumber,
    required int pageNumber,
    required String surahName,
  }) async {
    _lastReadSurahId = surahId;
    _lastReadAyahNumber = ayahNumber;
    _lastReadPageNumber = pageNumber;
    _lastReadSurahName = surahName;

    await _prefs?.setInt('last_read_surah_id', surahId);
    await _prefs?.setInt('last_read_ayah_number', ayahNumber);
    await _prefs?.setInt('last_read_page_number', pageNumber);
    await _prefs?.setString('last_read_surah_name', surahName);

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

  /// Builds the high-speed CDN MP3Quran streaming URL for an entire Surah
  String getSurahAudioUrl(int surahId, [String? reciterId]) {
    final rid = reciterId ?? _selectedReciterId;
    final reciter = availableReciters.firstWhere(
      (r) => r.id == rid,
      orElse: () => availableReciters.first,
    );
    final sStr = surahId.toString().padLeft(3, '0');
    return '${reciter.serverUrl}$sStr.mp3';
  }
}
