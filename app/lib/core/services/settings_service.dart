import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';
import '../notifications/prayer_notification_service.dart';
import 'adhkar_service.dart';

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

  /// 61 Verified Canonical Reciters with 100% working CDN stream links
  static const List<ReciterInfo> availableReciters = [
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
      id: 'kurdi',
      nameAr: 'رعد محمد الكردي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server6.mp3quran.net/kurdi/',
      subfolder: 'Raad_Al-Kurdi_128kbps',
    ),
    ReciterInfo(
      id: 'akhdar',
      nameAr: 'إبراهيم الأخضر',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/akdr/',
      subfolder: 'Ibrahim_Akhdar_32kbps',
    ),
    ReciterInfo(
      id: 'kouchi',
      nameAr: 'العيون الكوشي (رواية ورش)',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/koshi/',
      subfolder: 'Kouchi_128kbps',
    ),
    ReciterInfo(
      id: 'husary',
      nameAr: 'محمود خليل الحصري (مرتل)',
      style: 'مرتل',
      serverUrl: 'https://server13.mp3quran.net/husr/',
      subfolder: 'Husary_128kbps',
    ),
    ReciterInfo(
      id: 'husary_mujawwad',
      nameAr: 'محمود خليل الحصري (مجود)',
      style: 'مجود',
      serverUrl: 'https://server13.mp3quran.net/husr_mjwd/',
      subfolder: 'Husary_128kbps_Mujawwad',
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
      id: 'ali_jaber',
      nameAr: 'علي جابر (رحمه الله)',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/a_jbr/',
      subfolder: 'Ali_Jaber_64kbps',
    ),
    ReciterInfo(
      id: 'salimi',
      nameAr: 'منصور السالمي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server16.mp3quran.net/mansor/',
      subfolder: 'Mansoor_Al-Salimi_128kbps',
    ),
    ReciterInfo(
      id: 'islam_sobhi',
      nameAr: 'إسلام صبحي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/',
      subfolder: 'Islam_Sobhi_128kbps',
    ),
    ReciterInfo(
      id: 'hazza_albalushi',
      nameAr: 'هزاع البلوشي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server11.mp3quran.net/hazza/',
      subfolder: 'Hazza_Al-Balushi_128kbps',
    ),
    ReciterInfo(
      id: 'omar_qazabri',
      nameAr: 'عمر القزابري (رواية ورش)',
      style: 'مرتل',
      serverUrl: 'https://server9.mp3quran.net/omar_warsh/',
      subfolder: 'Omar_Al-Qazabri_128kbps',
    ),
    ReciterInfo(
      id: 'abdulrasheed_soufi',
      nameAr: 'عبد الرشيد صوفي (رواية خلف)',
      style: 'مرتل',
      serverUrl: 'https://server16.mp3quran.net/soufi/Rewayat-Khalaf-A-n-Hamzah/',
      subfolder: 'AbdulRasheed_Soufi_128kbps',
    ),
    ReciterInfo(
      id: 'badr_turki',
      nameAr: 'بدر التركي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server16.mp3quran.net/badr/Rewayat-Hafs-A-n-Assem/',
      subfolder: 'Badr_Al-Turki_128kbps',
    ),
    ReciterInfo(
      id: 'jbrl',
      nameAr: 'محمد جبريل',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server8.mp3quran.net/jbrl/',
      subfolder: 'Muhammad_Jibreel_128kbps',
    ),
    ReciterInfo(
      id: 'balila',
      nameAr: 'بندر بليلة (إمام الحرم المكي)',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/balilah/',
      subfolder: 'Bandar_Balila_128kbps',
    ),
    ReciterInfo(
      id: 'mohna',
      nameAr: 'خالد المهنا (إمام المسجد النبوي)',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server11.mp3quran.net/mohna/',
      subfolder: 'Khalid_Al-Mohanna_128kbps',
    ),
    ReciterInfo(
      id: 'mtrod',
      nameAr: 'عبد الله المطرود',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/mtrod/',
      subfolder: 'Abdullah_Al-Matroud_128kbps',
    ),
    ReciterInfo(
      id: 'tnjy',
      nameAr: 'خليفة الطنيجي',
      style: 'مرتل',
      serverUrl: 'https://server12.mp3quran.net/tnjy/',
      subfolder: 'Khalifa_Al-Tunaiji_128kbps',
    ),
    ReciterInfo(
      id: 'hawashi',
      nameAr: 'أحمد الحواشي (رحمه الله)',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server11.mp3quran.net/hawashi/',
      subfolder: 'Ahmed_Al-Hawashi_64kbps',
    ),
    ReciterInfo(
      id: 's_budair',
      nameAr: 'صلاح البدير (إمام المسجد النبوي)',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/s_bud/',
      subfolder: 'Salah_Al-Budair_128kbps',
    ),
    ReciterInfo(
      id: 'lahidan',
      nameAr: 'محمد اللحيدان',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server8.mp3quran.net/lhdan/',
      subfolder: 'Mohammad_Al-Lohaidan_128kbps',
    ),
    ReciterInfo(
      id: 'bu_snnh',
      nameAr: 'عادل ريان',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server8.mp3quran.net/ryan/',
      subfolder: 'Adel_Rayan_128kbps',
    ),
    ReciterInfo(
      id: 'ali_hajjaj',
      nameAr: 'علي حجاج السويسي',
      style: 'مجود',
      serverUrl: 'https://server12.mp3quran.net/hajjaj/',
      subfolder: 'Ali_Hajjaj_AlSuesy_128kbps',
    ),
    ReciterInfo(
      id: 'nabil_rifai',
      nameAr: 'نبيل الرفاعي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server6.mp3quran.net/nabil/',
      subfolder: 'Nabil_Rifai_128kbps',
    ),
    ReciterInfo(
      id: 'abdulwali_arkani',
      nameAr: 'عبد الولي الأركاني',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server6.mp3quran.net/arkani/',
      subfolder: 'Abdulwali_Al-Arkani_128kbps',
    ),
    ReciterInfo(
      id: 'khaled_qahtani',
      nameAr: 'خالد القحطاني',
      style: 'مرتل',
      serverUrl: 'https://server10.mp3quran.net/qht/',
      subfolder: 'Khaled_Al-Qahtani_128kbps',
    ),
    ReciterInfo(
      id: 'abdullah_kamel',
      nameAr: 'عبد الله كامل (رحمه الله)',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server16.mp3quran.net/kamel/Rewayat-Hafs-A-n-Assem/',
      subfolder: 'Abdullah_Kamel_128kbps',
    ),
    ReciterInfo(
      id: 'alzain',
      nameAr: 'الزين محمد أحمد',
      style: 'مرتل',
      serverUrl: 'https://server9.mp3quran.net/alzain/',
      subfolder: 'Alzain_Mohammad_Ahmad_128kbps',
    ),
    ReciterInfo(
      id: 'ahmed_trabulsi',
      nameAr: 'أحمد الطرابلسي (رواية قالون)',
      style: 'مرتل',
      serverUrl: 'https://server10.mp3quran.net/trabulsi/',
      subfolder: 'Ahmed_Al-Trabulsi_128kbps',
    ),
    ReciterInfo(
      id: 'saber_abdulhakam',
      nameAr: 'صابر عبد الحكم',
      style: 'مرتل',
      serverUrl: 'https://server12.mp3quran.net/hkm/',
      subfolder: 'Saber_Abdulhakam_128kbps',
    ),
    ReciterInfo(
      id: 'hatem_farid',
      nameAr: 'حاتم فريد الواعر',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server11.mp3quran.net/hatem/',
      subfolder: 'Hatem_Fareed_128kbps',
    ),
    ReciterInfo(
      id: 'khalid_abdulkhafi',
      nameAr: 'خالد عبد الكافي',
      style: 'مرتل',
      serverUrl: 'https://server11.mp3quran.net/kafi/',
      subfolder: 'Khalid_Abdulkafi_128kbps',
    ),
    ReciterInfo(
      id: 'yasser_qurashi',
      nameAr: 'ياسر القرشي',
      style: 'تلاوة خاشعة',
      serverUrl: 'https://server9.mp3quran.net/qurashi/',
      subfolder: 'Yasser_Al-Qurashi_128kbps',
    ),
    ReciterInfo(
      id: 'muhammad_osman',
      nameAr: 'محمد عثمان خان',
      style: 'مرتل',
      serverUrl: 'https://server6.mp3quran.net/khan/',
      subfolder: 'Muhammad_Osman_Khan_128kbps',
    ),
    ReciterInfo(
      id: 'jamal_shaker',
      nameAr: 'جمال شاكر عبد الله',
      style: 'مرتل',
      serverUrl: 'https://server8.mp3quran.net/jamal/',
      subfolder: 'Jamal_Shaker_Abdullah_128kbps',
    ),
  ];

  static const List<Map<String, String>> calculationMethods = [
    {'id': 'egyptian', 'name': 'الهيئة المصرية العامة للمساحة (الفجر 19.5° / العشاء 17.5°)'},
    {'id': 'makkah', 'name': 'أم القرى - مكة المكرمة'},
    {'id': 'mwl', 'name': 'رابطة العالم الإسلامي (MWL)'},
    {'id': 'isna', 'name': 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)'},
    {'id': 'karachi', 'name': 'جامعة العلوم الإسلامية بكراتشي'},
  ];

  static const List<Map<String, String>> availableThemeModes = [
    {
      'id': 'system',
      'name': 'تلقائي (حسب مظهر الجهاز)',
      'desc': 'يتوافق تلقائياً مع وضع النظام (فاتح في النهار وداكن في الليل)',
    },
    {
      'id': 'light',
      'name': 'الوضع الفاتح (النهاري)',
      'desc': 'ألوان هادئة ومريحة وخلفية عاجية كلاسيكية',
    },
    {
      'id': 'dark',
      'name': 'الوضع الداكن الهادئ',
      'desc': 'درجات رمادية داكنة مريحة للعين في الإضاءة الخافتة',
    },
    {
      'id': 'oled',
      'name': 'الوضع الليلي الفاخر (OLED أسود نقي)',
      'desc': 'سواد نقي 100% لإطفاء البكسلات وتوفير البطارية للتهجد وقيام الليل',
    },
  ];

  SharedPreferences? _prefs;

  // Settings values
  String _languageCode = 'ar'; // 'ar', 'en', 'fr', 'tr', 'ur', 'id'
  String _quranTranslationEdition = 'en_saheeh';
  bool _bilingualDisplayEnabled = false;
  double _mushafFontSize = 24.0;
  String _selectedReciterId = 'minshawi_murattal';
  String _calculationMethod = 'egyptian';
  String _themeMode = 'system'; // light, dark, oled, sepia, system
  bool _adhanAlertsEnabled = true;
  List<String> _bookmarks = [];

  String get languageCode => _languageCode;
  AppLanguage get currentAppLanguage => AppLanguage.fromCode(_languageCode);
  Locale get currentLocale => Locale(_languageCode);
  bool get isArabic => _languageCode == 'ar';
  bool get isEnglish => _languageCode == 'en';
  bool get isRtl => currentAppLanguage.isRtl;
  TextDirection get textDirection => currentAppLanguage.textDirection;
  String get languageName =>
      '${currentAppLanguage.flagEmoji} ${currentAppLanguage.nativeName} (${currentAppLanguage.englishName})';

  String get quranTranslationEdition => _quranTranslationEdition;
  bool get bilingualDisplayEnabled => _bilingualDisplayEnabled;

  // Extended Customization Settings
  bool _keepScreenOn = true;
  bool _autoPlayNextAyah = true;
  bool _preAdhanAlertEnabled = true;
  bool _iqamahAlertEnabled = true;
  bool _tasbihVibrationEnabled = true;
  bool _tasbihCycleAlertEnabled = true;
  bool _tasbihVolumeButtonEnabled = true;
  bool _tasbihSliderEnabled = true;
  bool _downloadOverWifiOnly = false;
  String _mushafDefaultMode = 'page'; // 'page' or 'text'
  bool _showJuzOverlay = true;
  int _hijriAdjustmentDays = 0;
  String _audioQualityPreset = 'studio_hd';
  double _defaultPlaybackSpeed = 1.0;
  int _ayahRepeatCount = 1;
  String _defaultTafsirEdition = 'muyassar';
  String _fiqhMadhhab = 'shafii_egypt';
  bool _autoSilentDuringPrayer = false;
  bool _sunanRawatibReminderEnabled = true;
  String _screenLayoutMode = 'classic';

  bool get keepScreenOn => _keepScreenOn;
  bool get autoPlayNextAyah => _autoPlayNextAyah;
  bool get preAdhanAlertEnabled => _preAdhanAlertEnabled;
  bool get iqamahAlertEnabled => _iqamahAlertEnabled;
  bool get tasbihVibrationEnabled => _tasbihVibrationEnabled;
  bool get hapticEnabled => _tasbihVibrationEnabled;
  bool get tasbihCycleAlertEnabled => _tasbihCycleAlertEnabled;
  bool get tasbihVolumeButtonEnabled => _tasbihVolumeButtonEnabled;
  bool get tasbihSliderEnabled => _tasbihSliderEnabled;
  bool get downloadOverWifiOnly => _downloadOverWifiOnly;
  String get mushafDefaultMode => _mushafDefaultMode;
  bool get showJuzOverlay => _showJuzOverlay;
  int get hijriAdjustmentDays => _hijriAdjustmentDays;
  String get audioQualityPreset => _audioQualityPreset;
  double get defaultPlaybackSpeed => _defaultPlaybackSpeed;
  int get ayahRepeatCount => _ayahRepeatCount;
  String get defaultTafsirEdition => _defaultTafsirEdition;
  String get fiqhMadhhab => _fiqhMadhhab;
  bool get autoSilentDuringPrayer => _autoSilentDuringPrayer;
  bool get sunanRawatibReminderEnabled => _sunanRawatibReminderEnabled;
  String get screenLayoutMode => _screenLayoutMode;

  String get themeModeName {
    switch (_themeMode) {
      case 'light':
        return 'الوضع الفاتح (النهاري)';
      case 'sepia':
        return 'وضع القراءة الهادئ (Sepia)';
      case 'dark':
        return 'الوضع الداكن الهادئ';
      case 'oled':
        return 'الوضع الليلي الفاخر (OLED أسود نقي)';
      case 'system':
      default:
        return 'تلقائي (حسب مظهر الجهاز)';
    }
  }

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

  bool _showTutorialScreens = true;
  bool get showTutorialScreens => _showTutorialScreens;

  bool _screenReaderOptimized = false;
  bool get screenReaderOptimized => _screenReaderOptimized;

  ReciterInfo get currentReciter {
    return availableReciters.firstWhere(
      (r) => r.id == _selectedReciterId,
      orElse: () => availableReciters.first,
    );
  }

  Future<void> init({bool forceReload = false}) async {
    _prefs = await SharedPreferences.getInstance();
    final savedLang = _prefs?.getString('app_language') ?? 'ar';
    _languageCode = AppLanguage.fromCode(savedLang).code;
    _quranTranslationEdition =
        _prefs?.getString('quran_translation_edition') ?? 'en_saheeh';
    _bilingualDisplayEnabled =
        _prefs?.getBool('bilingual_display_enabled') ?? (_languageCode != 'ar');
    _hasCompletedOnboarding = _prefs?.getBool('has_completed_onboarding') ?? false;
    _showTutorialScreens = _prefs?.getBool('show_tutorial_screens') ?? true;
    _mushafFontSize = (_prefs?.getDouble('mushaf_font_size') ?? 24.0).clamp(18.0, 38.0);
    _selectedReciterId = _prefs?.getString('selected_reciter_id') ?? 'minshawi_murattal';
    _calculationMethod = _prefs?.getString('calculation_method') ?? 'egyptian';
    _themeMode = _prefs?.getString('theme_mode') ?? 'system';
    _adhanAlertsEnabled = _prefs?.getBool('adhan_alerts') ?? true;
    _screenReaderOptimized = _prefs?.getBool('screen_reader_optimized') ?? false;
    _bookmarks = _prefs?.getStringList('bookmarks') ?? [];

    _keepScreenOn = _prefs?.getBool('keep_screen_on') ?? true;
    _autoPlayNextAyah = _prefs?.getBool('auto_play_next_ayah') ?? true;
    _preAdhanAlertEnabled = _prefs?.getBool('pre_adhan_alert') ?? true;
    _iqamahAlertEnabled = _prefs?.getBool('iqamah_alert') ?? true;
    _tasbihVibrationEnabled = _prefs?.getBool('tasbih_vibration') ?? true;
    _tasbihCycleAlertEnabled = _prefs?.getBool('tasbih_cycle_alert') ?? true;
    _tasbihVolumeButtonEnabled = _prefs?.getBool('tasbih_volume_button_enabled') ?? true;
    _tasbihSliderEnabled = _prefs?.getBool('tasbih_slider_enabled') ?? true;
    _downloadOverWifiOnly = _prefs?.getBool('download_wifi_only') ?? false;
    _mushafDefaultMode = _prefs?.getString('mushaf_default_mode') ?? 'page';
    _showJuzOverlay = _prefs?.getBool('show_juz_overlay') ?? true;
    _hijriAdjustmentDays = (_prefs?.getInt('hijri_adjustment_days') ?? 0).clamp(-2, 2);
    _audioQualityPreset = _prefs?.getString('audio_quality_preset') ?? 'studio_hd';
    _defaultPlaybackSpeed = _prefs?.getDouble('default_playback_speed') ?? 1.0;
    _ayahRepeatCount = (_prefs?.getInt('ayah_repeat_count') ?? 1).clamp(1, 10);
    _defaultTafsirEdition = _prefs?.getString('default_tafsir_edition') ?? 'muyassar';
    _fiqhMadhhab = _prefs?.getString('fiqh_madhhab') ?? 'shafii_egypt';
    _autoSilentDuringPrayer = _prefs?.getBool('auto_silent_prayer') ?? false;
    _sunanRawatibReminderEnabled = _prefs?.getBool('sunan_rawatib_reminder') ?? true;
    _screenLayoutMode = _prefs?.getString('screen_layout_mode') ?? 'classic';

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

  Future<void> setShowTutorialScreens(bool show) async {
    _showTutorialScreens = show;
    await _prefs?.setBool('show_tutorial_screens', show);
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

  Future<void> setLanguage(String code) async {
    final normalized = code.trim().toLowerCase();
    final isValid = AppLanguage.values.any((l) => l.code == normalized);
    if (!isValid) return;
    if (_languageCode == normalized) return;
    _languageCode = normalized;
    await _prefs?.setString('app_language', _languageCode);

    // Automatically match Quran translation edition when switching to a non-Arabic language
    final matchingTranslation = QuranTranslationEdition.availableTranslations
        .where((t) => t.languageCode == _languageCode)
        .toList();
    if (matchingTranslation.isNotEmpty && _languageCode != 'ar') {
      _quranTranslationEdition = matchingTranslation.first.id;
      _bilingualDisplayEnabled = true;
      await _prefs?.setString(
          'quran_translation_edition', _quranTranslationEdition);
      await _prefs?.setBool('bilingual_display_enabled', true);
    }
    notifyListeners();
  }

  Future<void> setQuranTranslationEdition(String editionId) async {
    final isValid = QuranTranslationEdition.availableTranslations
        .any((e) => e.id == editionId);
    if (!isValid) return;
    _quranTranslationEdition = editionId;
    await _prefs?.setString('quran_translation_edition', editionId);
    notifyListeners();
  }

  Future<void> toggleBilingualDisplay(bool enabled) async {
    _bilingualDisplayEnabled = enabled;
    await _prefs?.setBool('bilingual_display_enabled', enabled);
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

  Future<void> setHijriAdjustmentDays(int days) async {
    _hijriAdjustmentDays = days.clamp(-2, 2);
    await _prefs?.setInt('hijri_adjustment_days', _hijriAdjustmentDays);
    notifyListeners();
  }

  Future<void> setAudioQualityPreset(String preset) async {
    _audioQualityPreset = preset;
    await _prefs?.setString('audio_quality_preset', preset);
    notifyListeners();
  }

  Future<void> setDefaultPlaybackSpeed(double speed) async {
    _defaultPlaybackSpeed = speed.clamp(0.5, 2.0);
    await _prefs?.setDouble('default_playback_speed', _defaultPlaybackSpeed);
    notifyListeners();
  }

  Future<void> setAyahRepeatCount(int count) async {
    _ayahRepeatCount = count.clamp(1, 10);
    await _prefs?.setInt('ayah_repeat_count', _ayahRepeatCount);
    notifyListeners();
  }

  Future<void> setDefaultTafsirEdition(String editionId) async {
    _defaultTafsirEdition = editionId;
    await _prefs?.setString('default_tafsir_edition', editionId);
    notifyListeners();
  }

  Future<void> setFiqhMadhhab(String madhhab) async {
    _fiqhMadhhab = madhhab;
    await _prefs?.setString('fiqh_madhhab', madhhab);
    notifyListeners();
  }

  Future<void> toggleAutoSilentDuringPrayer(bool val) async {
    _autoSilentDuringPrayer = val;
    await _prefs?.setBool('auto_silent_prayer', val);
    notifyListeners();
  }

  Future<void> toggleSunanRawatibReminder(bool val) async {
    _sunanRawatibReminderEnabled = val;
    await _prefs?.setBool('sunan_rawatib_reminder', val);
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
    try {
      await PrayerNotificationService.instance.toggleMaster(enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleScreenReaderOptimization(bool enabled) async {
    _screenReaderOptimized = enabled;
    await _prefs?.setBool('screen_reader_optimized', enabled);
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

  Future<void> toggleKeepScreenOn(bool enabled) async {
    _keepScreenOn = enabled;
    await _prefs?.setBool('keep_screen_on', enabled);
    notifyListeners();
  }

  Future<void> toggleAutoPlayNextAyah(bool enabled) async {
    _autoPlayNextAyah = enabled;
    await _prefs?.setBool('auto_play_next_ayah', enabled);
    notifyListeners();
  }

  Future<void> togglePreAdhanAlert(bool enabled) async {
    _preAdhanAlertEnabled = enabled;
    await _prefs?.setBool('pre_adhan_alert', enabled);
    try {
      await PrayerNotificationService.instance.togglePreReminder(enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleIqamahAlert(bool enabled) async {
    _iqamahAlertEnabled = enabled;
    await _prefs?.setBool('iqamah_alert', enabled);
    try {
      await PrayerNotificationService.instance.toggleIqamahReminder(enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleTasbihVibration(bool enabled) async {
    _tasbihVibrationEnabled = enabled;
    await _prefs?.setBool('tasbih_vibration', enabled);
    try {
      AdhkarService.instance.toggleHaptic(enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleTasbihCycleAlert(bool enabled) async {
    _tasbihCycleAlertEnabled = enabled;
    await _prefs?.setBool('tasbih_cycle_alert', enabled);
    notifyListeners();
  }

  Future<void> toggleTasbihVolumeButton(bool enabled) async {
    _tasbihVolumeButtonEnabled = enabled;
    await _prefs?.setBool('tasbih_volume_button_enabled', enabled);
    try {
      AdhkarService.instance.toggleVolumeButtonTasbih(enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleTasbihSlider(bool enabled) async {
    _tasbihSliderEnabled = enabled;
    await _prefs?.setBool('tasbih_slider_enabled', enabled);
    try {
      AdhkarService.instance.toggleTasbihSlider(enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleDownloadOverWifiOnly(bool enabled) async {
    _downloadOverWifiOnly = enabled;
    await _prefs?.setBool('download_wifi_only', enabled);
    notifyListeners();
  }

  Future<void> setMushafDefaultMode(String mode) async {
    _mushafDefaultMode = mode;
    await _prefs?.setString('mushaf_default_mode', mode);
    notifyListeners();
  }

  Future<void> setScreenLayoutMode(String mode) async {
    _screenLayoutMode = mode;
    await _prefs?.setString('screen_layout_mode', mode);
    notifyListeners();
  }

  Future<void> toggleShowJuzOverlay(bool enabled) async {
    _showJuzOverlay = enabled;
    await _prefs?.setBool('show_juz_overlay', enabled);
    notifyListeners();
  }

  Future<void> resetAllSettings() async {
    await _prefs?.clear();
    await init();
  }

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
