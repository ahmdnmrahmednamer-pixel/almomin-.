import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dhikr.dart';

class AdhkarService extends ChangeNotifier {
  static final AdhkarService instance = AdhkarService._internal();
  AdhkarService._internal() {
    _buildCategories();
  }

  SharedPreferences? _prefs;

  // Tasbih state
  int _tasbihCount = 0;
  int _tasbihTarget = 33;
  int _tasbihTotalToday = 0;
  String _tasbihLastDate = '';
  String _selectedTasbihPhrase = 'سُبْحَانَ اللَّهِ';
  bool _hapticEnabled = true;
  bool _volumeButtonTasbihEnabled = true;
  bool _tasbihSliderEnabled = true;
  Timer? _hapticTimer1;
  Timer? _hapticTimer2;

  static String _todayDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get tasbihCount => _tasbihCount;
  int get tasbihTarget => _tasbihTarget;
  int get tasbihTotalToday => _tasbihTotalToday;
  String get selectedTasbihPhrase => _selectedTasbihPhrase;
  bool get hapticEnabled => _hapticEnabled;
  bool get volumeButtonTasbihEnabled => _volumeButtonTasbihEnabled;
  bool get tasbihSliderEnabled => _tasbihSliderEnabled;

  static const List<String> famousTasbihPhrases = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'اللَّهُ أَكْبَرُ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
  ];

  List<DhikrCategory> _categories = [];
  List<DhikrCategory> get categories => _categories;

  Future<void> init({bool forceReload = false}) async {
    _prefs = await SharedPreferences.getInstance();
    final today = _todayDateKey();
    _tasbihLastDate = _prefs?.getString('tasbih_last_date') ?? '';
    _tasbihCount = _prefs?.getInt('tasbih_count') ?? 0;
    _tasbihTarget = _prefs?.getInt('tasbih_target') ?? 33;

    // Reset daily tasbih counter and daily adhkar counts on a new calendar day (Bugs #7 & #8 fix)
    if (_tasbihLastDate != today) {
      _tasbihTotalToday = 0;
      _tasbihLastDate = today;
      await _prefs?.setInt('tasbih_total_today', 0);
      await _prefs?.setString('tasbih_last_date', today);
      await _prefs?.remove('adhkar_daily_counts_v1');
    } else {
      _tasbihTotalToday = _prefs?.getInt('tasbih_total_today') ?? 0;
    }

    _selectedTasbihPhrase = _prefs?.getString('tasbih_phrase') ?? 'سُبْحَانَ اللَّهِ';
    _hapticEnabled = _prefs?.getBool('tasbih_haptic') ?? true;
    _volumeButtonTasbihEnabled = _prefs?.getBool('tasbih_volume_button_enabled') ?? true;
    _tasbihSliderEnabled = _prefs?.getBool('tasbih_slider_enabled') ?? true;

    _buildCategories();
    _restoreDailyDhikrCounts();
    notifyListeners();
  }

  void _ensureTodayDate() {
    final today = _todayDateKey();
    if (_tasbihLastDate.isNotEmpty && _tasbihLastDate != today) {
      _tasbihTotalToday = 0;
      _tasbihLastDate = today;
      _prefs?.setInt('tasbih_total_today', 0);
      _prefs?.setString('tasbih_last_date', today);
      _prefs?.remove('adhkar_daily_counts_v1');
      for (final cat in _categories) {
        for (final item in cat.items) {
          item.reset();
        }
      }
    } else if (_tasbihLastDate.isEmpty) {
      _tasbihLastDate = today;
      _prefs?.setString('tasbih_last_date', today);
    }
  }

  void _restoreDailyDhikrCounts() {
    final raw = _prefs?.getString('adhkar_daily_counts_v1');
    if (raw == null || raw.isEmpty) return;
    try {
      final Map<String, dynamic> map = json.decode(raw);
      for (final cat in _categories) {
        for (final item in cat.items) {
          final saved = map[item.id.toString()];
          if (saved is int && saved > 0) {
            item.currentCount = saved.clamp(0, item.targetCount);
          }
        }
      }
    } catch (_) {}
  }

  void _persistDailyDhikrCounts() {
    final Map<String, int> counts = {};
    for (final cat in _categories) {
      for (final item in cat.items) {
        if (item.currentCount > 0) {
          counts[item.id.toString()] = item.currentCount;
        }
      }
    }
    _prefs?.setString('adhkar_daily_counts_v1', json.encode(counts));
  }

  void _buildCategories() {
    _categories = [
      DhikrCategory(
        id: 'morning',
        title: 'أذكار الصباح',
        subtitle: 'حصن المسلم وبركة اليوم وانشراح الصدر',
        icon: Icons.wb_sunny_rounded,
        primaryColor: const Color(0xFFD4AF37),
        items: [
          DhikrItem(
            id: 101,
            text: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\n﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ﴾',
            targetCount: 1,
            source: 'سورة البقرة: ٢٥٥ (آية الكرسي)',
            virtue: 'من قالها حين يصبح أُجير من الجن حتى يمسي',
          ),
          DhikrItem(
            id: 102,
            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n﴿قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ﴾',
            targetCount: 3,
            source: 'سورة الإخلاص',
            virtue: 'تكفيك من كل شيء حين تقرأها ثلاثاً صباحاً ومساءً',
          ),
          DhikrItem(
            id: 103,
            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n﴿قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ﴾',
            targetCount: 3,
            source: 'سورة الفلق',
            virtue: 'الحفظ والوقاية من كل مكروه وحاسد وسحر',
          ),
          DhikrItem(
            id: 104,
            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n﴿قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ﴾',
            targetCount: 3,
            source: 'سورة الناس',
            virtue: 'الوقاية من وسوسة الشياطين والجن والإنس',
          ),
          DhikrItem(
            id: 105,
            text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
            targetCount: 1,
            source: 'صحيح مسلم',
            virtue: 'شكر الله وإقراره بالملك والاستعاذة من الشرور والكسل',
          ),
          DhikrItem(
            id: 106,
            text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
            targetCount: 1,
            source: 'صحيح البخاري (سيد الاستغفار)',
            virtue: 'من قالها موقناً بها حين يصبح فمات من يومه دخل الجنة',
          ),
          DhikrItem(
            id: 107,
            text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ.',
            targetCount: 1,
            source: 'سنن الترمذي',
            virtue: 'التوكل التام على الله في البدء والمسير والمصير',
          ),
          DhikrItem(
            id: 108,
            text: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَهَ إِلَّا أَنْتَ.',
            targetCount: 3,
            source: 'سنن أبي داود',
            virtue: 'طلب تمام العافية في الجسد والحواس والدين',
          ),
          DhikrItem(
            id: 109,
            text: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
            targetCount: 3,
            source: 'سنن الترمذي وأبي داود',
            virtue: 'لم يضره شيء ولم تفجأه فاجعة بلاء حتى يمسي',
          ),
          DhikrItem(
            id: 110,
            text: 'رَضِيتُ بِاللَّهِ رَبّاً، وَبِالْإِسْلَامِ دِيناً، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيّاً.',
            targetCount: 3,
            source: 'سنن أبي داود والترمذي',
            virtue: 'كان حقاً على الله أن يرضيه يوم القيامة',
          ),
          DhikrItem(
            id: 111,
            text: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.',
            targetCount: 1,
            source: 'المستدرك على الصحيحين',
            virtue: 'صلاح الأحوال وتفويض الأمر لمالك الملك',
          ),
          DhikrItem(
            id: 112,
            text: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ.',
            targetCount: 7,
            source: 'سنن أبي داود',
            virtue: 'من قالها سبع مرات كفاه الله ما أهمه من أمر دنياه وآخرته',
          ),
          DhikrItem(
            id: 113,
            text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ.',
            targetCount: 3,
            source: 'صحيح مسلم',
            virtue: 'تزن في الأجر ساعات طويلة من الذكر والتسبيح',
          ),
          DhikrItem(
            id: 114,
            text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.',
            targetCount: 100,
            source: 'صحيح مسلم',
            virtue: 'حُطت خطاياه وإن كانت مثل زبد البحر، ولم يأتِ أحد بأفضل مما جاء به',
          ),
          DhikrItem(
            id: 115,
            text: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
            targetCount: 10,
            source: 'صحيح البخاري ومسلم',
            virtue: 'كانت له عدل أربع رقاب من ولد إسماعيل وكُتبت له مائة حسنة',
          ),
        ],
      ),
      DhikrCategory(
        id: 'evening',
        title: 'أذكار المساء',
        subtitle: 'حفظ الليل وسكينة الروح والأمان من الشرور',
        icon: Icons.nightlight_round,
        primaryColor: const Color(0xFF1B4332),
        items: [
          DhikrItem(
            id: 201,
            text: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\n﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ﴾',
            targetCount: 1,
            source: 'سورة البقرة: ٢٥٥ (آية الكرسي)',
            virtue: 'من قالها حين يمسي أُجير من الجن حتى يصبح',
          ),
          DhikrItem(
            id: 202,
            text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ. رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ.',
            targetCount: 1,
            source: 'صحيح مسلم',
            virtue: 'إعلان العبودية لله وطلب خير الليلة والاستعاذة من شرها',
          ),
          DhikrItem(
            id: 203,
            text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.',
            targetCount: 1,
            source: 'صحيح البخاري (سيد الاستغفار)',
            virtue: 'من قالها موقناً بها حين يمسي فمات من ليلته دخل الجنة',
          ),
          DhikrItem(
            id: 204,
            text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.',
            targetCount: 3,
            source: 'صحيح مسلم',
            virtue: 'لم يضره شيء في تلك الليلة ولا حمة (لدغة)',
          ),
          DhikrItem(
            id: 205,
            text: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.',
            targetCount: 3,
            source: 'سنن الترمذي وأبي داود',
            virtue: 'حماية وأمان من فواجع الأقدار',
          ),
          DhikrItem(
            id: 206,
            text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ.',
            targetCount: 1,
            source: 'سنن الترمذي',
            virtue: 'استشعار معيّة الله في كل وقت وحين',
          ),
        ],
      ),
      DhikrCategory(
        id: 'post_prayer',
        title: 'أذكار ما بعد الصلاة',
        subtitle: 'المأثور عن النبي ﷺ دبر كل صلاة مكتوبة',
        icon: Icons.mosque_outlined,
        primaryColor: const Color(0xFF2D6A4F),
        items: [
          DhikrItem(
            id: 301,
            text: 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ.\nاللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالإِكْرَامِ.',
            targetCount: 1,
            source: 'صحيح مسلم',
            virtue: 'جبر النقص والتقصير في الصلاة وسؤال السلامة',
          ),
          DhikrItem(
            id: 302,
            text: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ.',
            targetCount: 1,
            source: 'صحيح البخاري ومسلم',
            virtue: 'توحيد الله وإفراده بالرزق والعطاء والمنع',
          ),
          DhikrItem(
            id: 303,
            text: 'سُبْحَانَ اللَّهِ.',
            targetCount: 33,
            source: 'صحيح مسلم',
            virtue: 'تسبيح الله دبر كل صلاة مكتوبة',
          ),
          DhikrItem(
            id: 304,
            text: 'الْحَمْدُ لِلَّهِ.',
            targetCount: 33,
            source: 'صحيح مسلم',
            virtue: 'حمد الله والثناء عليه بعد الصلاة',
          ),
          DhikrItem(
            id: 305,
            text: 'اللَّهُ أَكْبَرُ.',
            targetCount: 33,
            source: 'صحيح مسلم',
            virtue: 'تكبير الله وتعظيمه وإجلاله',
          ),
          DhikrItem(
            id: 306,
            text: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.',
            targetCount: 1,
            source: 'صحيح مسلم (تمام المائة)',
            virtue: 'غُفرت خطاياه وإن كانت مثل زبد البحر',
          ),
          DhikrItem(
            id: 307,
            text: '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...﴾ (آية الكرسي دبر كل صلاة)',
            targetCount: 1,
            source: 'رواه النسائي وصححه الألباني',
            virtue: 'من قرأها دبر كل صلاة مكتوبة لم يمنعه من دخول الجنة إلا أن يموت',
          ),
          DhikrItem(
            id: 308,
            text: '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ سَيِّدَنَا مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَالدَّرَجَةَ الْعَالِيَةَ الرَّفِيعَةَ، وَابْعَثْهُ اللَّهُمَّ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ، إِنَّكَ لَا تُخْلِفُ الْمِيعَادَ.. رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِسَيِّدَنَا مُحَمَّدٍ ﷺ نَبِيًّا وَرَسُولًا»',
            targetCount: 1,
            source: 'دعاء ما بعد الأذان والصلاة — بصوت الشيخ محمد متولي الشعراوي رحمه الله 🎧',
            virtue: 'نيل شفاعة الحبيب المصطفى ﷺ، ورضا الله وتمام بركة الصلاة وإجابة الدعاء',
          ),
          DhikrItem(
            id: 309,
            text: '«اللَّهُمَّ يَا رَبَّنَا، مَا قَصُرَ عَنْهُ عِلْمِي، وَلَمْ تَبْلُغْهُ مَسْأَلَتِي، وَلَمْ تَنَلْهُ نِيَّتِي، مِنْ خَيْرٍ وَعَدْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوْ خَيْرٍ أَنْتَ مُعْطِيهِ أَحَدًا مِنْ عِبَادِكَ؛ فَإِنِّي أَرْغَبُ إِلَيْكَ فِيهِ، وَأَسْأَلُكَ إِيَّاهُ بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ.. اللَّهُمَّ اجْعَلْ ثَوَابَ مَا صَلَّيْنَا، وَنُورَ مَا تَلَوْنَا، وَبَرَكَةَ مَا ذَكَرْنَا، هَدِيَّةً وَاصِلَةً إِلَى رَوْضَةِ سَيِّدِنَا وَمَوْلَانَا مُحَمَّدٍ ﷺ، ثُمَّ إِلَى أَرْوَاحِ آبَائِنَا وَأُمَّهَاتِنَا وَأَمْوَاتِنَا وَمَوْتَى الْمُسْلِمِينَ أَجْمَعِينَ، يَا رَبَّ الْعَالَمِينَ»',
            targetCount: 1,
            source: 'مناجاة ودعاء ختام الصلاة — إمام الدعاة فضيلة الشيخ محمد متولي الشعراوي رحمه الله',
            virtue: 'جامع لخيري الدنيا والآخرة وإهداء ثواب الصلاة والبركة للوالدين والأموات',
          ),
        ],
      ),
      DhikrCategory(
        id: 'sleep',
        title: 'أذكار النوم والاستيقاظ',
        subtitle: 'تحصين النفس وسكينة المضجع وطمأنينة الاستيقاظ',
        icon: Icons.hotel_rounded,
        primaryColor: const Color(0xFF4A6B82),
        items: [
          DhikrItem(
            id: 401,
            text: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ.',
            targetCount: 1,
            source: 'صحيح البخاري ومسلم',
            virtue: 'حفظ النفس أثناء النوم واستيداع الروح عند خالقها',
          ),
          DhikrItem(
            id: 402,
            text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.',
            targetCount: 1,
            source: 'صحيح البخاري',
            virtue: 'ذكر اسم الله عند إغماض العينين والنوم',
          ),
          DhikrItem(
            id: 403,
            text: 'سُبْحَانَ اللَّهِ (٣٣)، وَالْحَمْدُ لِلَّهِ (٣٣)، وَاللَّهُ أَكْبَرُ (٣٤).',
            targetCount: 1,
            source: 'صحيح البخاري (وصية النبي لفاطمة وعلي)',
            virtue: 'خير للعبد من خادم وتعطي قوة في البدن والنشاط',
          ),
          DhikrItem(
            id: 404,
            text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.',
            targetCount: 1,
            source: 'صحيح البخاري (عند الاستيقاظ)',
            virtue: 'شكر نعمة رد الروح والحياة بعد الموتة الصغرى',
          ),
        ],
      ),
      DhikrCategory(
        id: 'duas',
        title: 'جوامع الأدعية المأثورة',
        subtitle: 'أدعية جامعة من القرآن الكريم والسنة النبوية',
        icon: Icons.volunteer_activism_rounded,
        primaryColor: const Color(0xFF8C5E32),
        items: [
          DhikrItem(
            id: 501,
            text: '﴿رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ﴾',
            targetCount: 3,
            source: 'سورة البقرة: ٢٠١ (أكثر دعاء النبي ﷺ)',
            virtue: 'جمع خير الدنيا والآخرة والوقاية من النار',
          ),
          DhikrItem(
            id: 502,
            text: 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ.',
            targetCount: 3,
            source: 'سنن الترمذي',
            virtue: 'سؤال الثبات على الإيمان والتوحيد حتى الممات',
          ),
          DhikrItem(
            id: 503,
            text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى، وَالتُّقَى، وَالْعَفَافَ، وَالْغِنَى.',
            targetCount: 3,
            source: 'صحيح مسلم',
            virtue: 'شامل لكل أسباب صلاح الدين والدنيا وسعة الرزق والعفة',
          ),
          DhikrItem(
            id: 504,
            text: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ.',
            targetCount: 3,
            source: 'سورة الأنبياء: ٨٧ (دعوة ذي النون)',
            virtue: 'ما دعا بها مسلم في شيء قط إلا استجاب الله له وفرّج كربه',
          ),
          DhikrItem(
            id: 505,
            text: 'اللَّهُمَّ أَصْلِحْ لِي دِينِي الَّذِي هُوَ عِصْمَةُ أَمْرِي، وَأَصْلِحْ لِي دُنْيَايَ الَّتِي فِيهَا مَعَاشِي، وَأَصْلِحْ لِي آخِرَتِي الَّتِي فِيهَا مَعَادِي، وَاجْعَلِ الْحَيَاةَ زِيَادَةً لِي فِي كُلِّ خَيْرٍ، وَاجْعَلِ الْمَوْتَ رَاحَةً لِي مِنْ كُلِّ شَرٍّ.',
            targetCount: 1,
            source: 'صحيح مسلم',
            virtue: 'دعاء نبوي جامع لكل مناحي الوجود وصلاح الدين والدنيا',
          ),
          DhikrItem(
            id: 506,
            text: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْماً نَافِعاً، وَرِزْقاً طَيِّباً، وَعَمَلاً مُتَقَبَّلاً.',
            targetCount: 3,
            source: 'سنن ابن ماجه (يقال بعد صلاة الفجر)',
            virtue: 'طلب أركان التوفيق اليومي: العلم والرزق والعمل المقبول',
          ),
          DhikrItem(
            id: 507,
            text: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي.',
            targetCount: 3,
            source: 'سنن الترمذي (وصية النبي لعائشة في ليلة القدر)',
            virtue: 'طلب عفو الله التام ومحو الذنوب والصفح الجميل',
          ),
        ],
      ),

      // 6. أذكار الاستيقاظ من النوم
      DhikrCategory(
        id: 'waking',
        title: 'أذكار الاستيقاظ',
        subtitle: 'شكر نعمة رد الروح وانفتاح أبواب الفضل والإشراق',
        icon: Icons.alarm_on_rounded,
        primaryColor: const Color(0xFFE76F51),
        items: [
          DhikrItem(
            id: 601,
            text: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.',
            targetCount: 1,
            source: 'صحيح البخاري',
            virtue: 'شكر الله على نعمة الاستيقاظ ورد الروح بعد النوم',
          ),
          DhikrItem(
            id: 602,
            text: 'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي فِي جَسَدِي، وَرَدَّ عَلَيَّ رُوحِي، وَأَذِنَ لِي بِذِكْرِهِ.',
            targetCount: 1,
            source: 'سنن الترمذي',
            virtue: 'الاعتراف بفضل العافية وإذن الله بالذكر والطاعة',
          ),
          DhikrItem(
            id: 603,
            text: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ، رَبِّ اغْفِرْ لِي.',
            targetCount: 1,
            source: 'صحيح البخاري (من تعار من الليل)',
            virtue: 'من قالها ثم دعا استجيب له، فإن توضأ وصلى قُبلت صلاته',
          ),
        ],
      ),

      // 7. أدعية القرآن الكريم الجامعة
      DhikrCategory(
        id: 'quran_duas',
        title: 'أدعية القرآن الكريم',
        subtitle: 'أدعية الأنبياء والصالحين المحفوظة في كتاب الله العزيز',
        icon: Icons.auto_stories_rounded,
        primaryColor: const Color(0xFF2A9D8F),
        items: [
          DhikrItem(
            id: 701,
            text: '﴿رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً ۚ إِنَّكَ أَنتَ الْوَهَّابُ﴾',
            targetCount: 3,
            source: 'سورة آل عمران: ٨',
            virtue: 'سؤال الله الهداية المستقيمة والثبات على الحق ونيل الرحمة',
          ),
          DhikrItem(
            id: 702,
            text: '﴿رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ ۝ رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ﴾',
            targetCount: 1,
            source: 'سورة إبراهيم: ٤٠-٤١ (دعاء إبراهيم الخليل عليه السلام)',
            virtue: 'صلاح الأبناء والذرية وبر الوالدين ومغفرة يوم الحساب',
          ),
          DhikrItem(
            id: 703,
            text: '﴿رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي ۝ وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي ۝ يَفْقَهُوا قَوْلِي﴾',
            targetCount: 1,
            source: 'سورة طه: ٢٥-٢٨ (دعاء موسى عليه السلام)',
            virtue: 'انشراح الصدر وتيسير الأمور الصعبة وتوفيق اللسان والبيان',
          ),
          DhikrItem(
            id: 704,
            text: '﴿رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا﴾',
            targetCount: 1,
            source: 'سورة الفرقان: ٧٤ (دعاء عباد الرحمن)',
            virtue: 'سكينة البيت وصلاح الأسرة وريادة التقوى والصلاح',
          ),
          DhikrItem(
            id: 705,
            text: '﴿رَّبِّ أَنزِلْنِي مُنزَلًا مُّبَارَكًا وَأَنتَ خَيْرُ الْمُنزِلِينَ﴾',
            targetCount: 3,
            source: 'سورة المؤمنون: ٢٩',
            virtue: 'بركة المنازل وحلول الخير في السفر والإقامة',
          ),
        ],
      ),

      // 8. أذكار المسجد والمنزل والدخول والخروج
      DhikrCategory(
        id: 'home_mosque',
        title: 'المسجد والمنزل',
        subtitle: 'حصن البيت وبركة الخطى للمساجد وأبواب الرحمة والفضل',
        icon: Icons.roofing_rounded,
        primaryColor: const Color(0xFF386641),
        items: [
          DhikrItem(
            id: 801,
            text: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.',
            targetCount: 1,
            source: 'سنن أبي داود والترمذي (عند الخروج من المنزل)',
            virtue: 'يقال له: هُديت وكُفيت ووُقيت، وتنحى عنه الشيطان',
          ),
          DhikrItem(
            id: 802,
            text: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أَضِلَّ أَوْ أُضَلَّ، أَوْ أَزِلَّ أَوْ أُزَلَّ، أَوْ أَظْلِمَ أَوْ أُظْلَمَ، أَوْ أَجْهَلَ أَوْ يُجْهَلَ عَلَيَّ.',
            targetCount: 1,
            source: 'سنن أبي داود والترمذي',
            virtue: 'حماية المسلم من الضلال والزلل والظلم والجهل في خروجه',
          ),
          DhikrItem(
            id: 803,
            text: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا. (ثم يسلم على أهله)',
            targetCount: 1,
            source: 'سنن أبي داود (عند دخول المنزل)',
            virtue: 'إذا دخل وذكر اسم الله لم يبيت الشيطان في بيته ولا ينال طعامه',
          ),
          DhikrItem(
            id: 804,
            text: 'أَعُوذُ بِاللَّهِ الْعَظِيمِ، وَبِوَجْهِهِ الْكَرِيمِ، وَسُلْطَانِهِ الْقَدِيمِ، مِنَ الشَّيْطَانِ الرَّجِيمِ. بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ.',
            targetCount: 1,
            source: 'سنن أبي داود ومسلم (عند دخول المسجد بالقدم اليمنى)',
            virtue: 'حفظ من الشيطان سائر اليوم وفتح لأبواب الرحمة',
          ),
          DhikrItem(
            id: 805,
            text: 'بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ، اللَّهُمَّ اعْصِمْنِي مِنَ الشَّيْطَانِ الرَّجِيمِ.',
            targetCount: 1,
            source: 'صحيح مسلم وابن ماجه (عند الخروج من المسجد باليسرى)',
            virtue: 'طلب الفضل والرزق والبركة والحصانة من الشيطان',
          ),
        ],
      ),

      // 9. تفريج الكرب والهم والحزن وقضاء الدين
      DhikrCategory(
        id: 'distress_relief',
        title: 'تفريج الكرب والدين',
        subtitle: 'أدعية النجاة والفرج العاجل وجلاء الأحزان والهموم وسداد الديون',
        icon: Icons.healing_rounded,
        primaryColor: const Color(0xFFBC4749),
        items: [
          DhikrItem(
            id: 901,
            text: 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ.',
            targetCount: 1,
            source: 'صحيح البخاري ومسلم (دعاء الكرب)',
            virtue: 'كان النبي ﷺ يدعو به عند الكرب والشدائد العظيمة',
          ),
          DhikrItem(
            id: 902,
            text: 'اللَّهُمَّ إِنِّي عَبْدُكَ، وَابْنُ عَبْدِكَ، وَابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ، سَمَّيْتَ بِهِ نَفْسَكَ، أَوْ أَنْزَلْتَهُ فِي كِتَابِكَ، أَوْ عَلَّمْتَهُ أَحَداً مِنْ خَلْقِكَ، أَوِ اسْتَأْثَرْتَ بِهِ فِي عِلْمِ الْغَيْبِ عِنْدَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجَلَاءَ حُزْنِي، وَذَهَابَ هَمِّي.',
            targetCount: 1,
            source: 'مسند أحمد وصححه الألباني',
            virtue: 'ما قاله أحد أصابه هم أو حزن إلا أذهب الله همه وأبدله مكانه فرجاً',
          ),
          DhikrItem(
            id: 903,
            text: 'اللَّهُمَّ رَحْمَتَكَ أَرْجُو فَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ، وَأَصْلِحْ لِي شَأْنِي كُلَّهُ لَا إِلَهَ إِلَّا أَنْتَ.',
            targetCount: 3,
            source: 'سنن أبي داود وصحيح ابن حبان',
            virtue: 'دعوات المكروب وتفريج الضيق وتيسير العسير',
          ),
          DhikrItem(
            id: 904,
            text: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ.',
            targetCount: 3,
            source: 'سنن الترمذي (لقضاء الدين لو كان مثل جبل)',
            virtue: 'لو كان عليك مثل جبل أُحُدٍ دَيْناً أداه الله عنك',
          ),
          DhikrItem(
            id: 905,
            text: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ.',
            targetCount: 1,
            source: 'صحيح البخاري',
            virtue: 'الاستعاذة من غلبة الديون وقهر الرجال وتراكم الهموم',
          ),
        ],
      ),

      // 10. الرقية الشرعية الشاملة
      DhikrCategory(
        id: 'ruqyah',
        title: 'الرقية الشرعية',
        subtitle: 'آيات الشفاء والتحصين النبوي من العين والحسد والمس والسحر والأمراض',
        icon: Icons.shield_moon_rounded,
        primaryColor: const Color(0xFF1D3557),
        items: [
          DhikrItem(
            id: 1001,
            text: 'قراءة سورة الفاتحة:\n﴿بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ﴾',
            targetCount: 7,
            source: 'سورة الفاتحة (أم الكتاب والشافية والوافية)',
            virtue: 'أعظم رقية في كتاب الله رقى بها الصحابي فبرأ الملدوغ كأنما نَشِطَ من عقال',
          ),
          DhikrItem(
            id: 1002,
            text: '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...﴾ (آية الكرسي)',
            targetCount: 3,
            source: 'سورة البقرة: ٢٥٥',
            virtue: 'أعظم آية في القرآن الكريم، لا يقربك معها شيطان',
          ),
          DhikrItem(
            id: 1003,
            text: '﴿وَإِن يَكَادُ الَّذِينَ كَفَرُوا لَيُزْلِقُونَكَ بِأَبْصَارِهِمْ لَمَّا سَمِعُوا الذِّكْرَ وَيَقُولُونَ إِنَّهُ لَمَجْنُونٌ ۝ وَمَا هُوَ إِلَّا ذِكْرٌ لِّلْعَالَمِينَ﴾',
            targetCount: 3,
            source: 'سورة القلم: ٥١-٥٢',
            virtue: 'رقية نافعة ومجربة لدفع أثر العين الحاسدة ونظرات السوء',
          ),
          DhikrItem(
            id: 1004,
            text: 'بِسْمِ اللَّهِ أَرْقِيكَ، مِنْ كُلِّ شَيْءٍ يُؤْذِيكَ، مِنْ شَرِّ كُلِّ نَفْسٍ أَوْ عَيْنِ حَاسِدٍ، اللَّهُ يَشْفِيكَ، بِسْمِ اللَّهِ أَرْقِيكَ.',
            targetCount: 3,
            source: 'صحيح مسلم (رقية جبريل للنبي ﷺ)',
            virtue: 'الرقية الجبريلية المباركة من كل أذى ونفس وعين',
          ),
          DhikrItem(
            id: 1005,
            text: 'أَذْهِبِ الْبَاسَ رَبَّ النَّاسِ، وَاشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَماً.',
            targetCount: 3,
            source: 'صحيح البخاري ومسلم',
            virtue: 'دعاء النبي ﷺ عند عيادة المريض ومسح الألم باليمين',
          ),
          DhikrItem(
            id: 1006,
            text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّةِ، مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ.',
            targetCount: 3,
            source: 'صحيح البخاري',
            virtue: 'عوذة إبراهيم لإسماعيل وإسحاق وكان النبي ﷺ يعوّذ بها الحسن والحسين',
          ),
        ],
      ),
    ];
  }

  // Dhikr Counter Operations
  void incrementDhikr(DhikrItem item) {
    _ensureTodayDate();
    if (!item.isCompleted) {
      item.increment();
      _persistDailyDhikrCounts();
      if (_hapticEnabled) {
        if (item.isCompleted) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      }
      notifyListeners();
    }
  }

  void resetDhikr(DhikrItem item) {
    item.reset();
    _persistDailyDhikrCounts();
    notifyListeners();
  }

  void resetCategory(DhikrCategory category) {
    for (final item in category.items) {
      item.reset();
    }
    _persistDailyDhikrCounts();
    notifyListeners();
  }

  // Tasbih Operations
  /// Increments Tasbih count and returns true if target was reached
  bool incrementTasbih() {
    _ensureTodayDate();
    _tasbihCount++;
    _tasbihTotalToday++;

    final bool reachedTarget = _tasbihTarget > 0 && (_tasbihCount % _tasbihTarget == 0);

    if (_hapticEnabled) {
      if (reachedTarget) {
        // Cancel any overlapping vibration timers before starting new pulse (Bug #15 fix)
        _hapticTimer1?.cancel();
        _hapticTimer2?.cancel();
        HapticFeedback.heavyImpact();
        _hapticTimer1 = Timer(const Duration(milliseconds: 140), () {
          HapticFeedback.vibrate();
        });
        _hapticTimer2 = Timer(const Duration(milliseconds: 280), () {
          HapticFeedback.heavyImpact();
        });
      } else {
        HapticFeedback.lightImpact();
      }
    }

    _prefs?.setInt('tasbih_count', _tasbihCount);
    _prefs?.setInt('tasbih_total_today', _tasbihTotalToday);
    notifyListeners();

    return reachedTarget;
  }

  void resetTasbih() {
    _tasbihCount = 0;
    _prefs?.setInt('tasbih_count', 0);
    notifyListeners();
  }

  void resetTasbihTotal() {
    _tasbihTotalToday = 0;
    _prefs?.setInt('tasbih_total_today', 0);
    notifyListeners();
  }

  void setTasbihTarget(int target) {
    _tasbihTarget = target;
    _prefs?.setInt('tasbih_target', target);
    notifyListeners();
  }

  void setSelectedTasbihPhrase(String phrase) {
    _selectedTasbihPhrase = phrase;
    _tasbihCount = 0;
    _prefs?.setString('tasbih_phrase', phrase);
    _prefs?.setInt('tasbih_count', 0);
    notifyListeners();
  }

  void toggleHaptic(bool enabled) {
    _hapticEnabled = enabled;
    _prefs?.setBool('tasbih_haptic', enabled);
    notifyListeners();
  }

  void toggleVolumeButtonTasbih(bool enabled) {
    _volumeButtonTasbihEnabled = enabled;
    _prefs?.setBool('tasbih_volume_button_enabled', enabled);
    notifyListeners();
  }

  void toggleTasbihSlider(bool enabled) {
    _tasbihSliderEnabled = enabled;
    _prefs?.setBool('tasbih_slider_enabled', enabled);
    notifyListeners();
  }

  /// Increments Tasbih when hardware Volume Up button is pressed (if enabled)
  bool handleVolumeUpIncrement() {
    if (!_volumeButtonTasbihEnabled) return false;
    return incrementTasbih();
  }

  /// Updates the current cycle count via the interactive Tasbih bead slider
  bool updateTasbihFromSlider(int newInCycleValue) {
    _ensureTodayDate();
    final effectiveTarget = _tasbihTarget > 0 ? _tasbihTarget : 33;
    final clamped = newInCycleValue.clamp(0, effectiveTarget);
    final currentCycles = _tasbihTarget > 0 ? (_tasbihCount ~/ _tasbihTarget) : 0;
    final oldCount = _tasbihCount;
    final int newCount = _tasbihTarget > 0
        ? (currentCycles * _tasbihTarget) + clamped
        : clamped;

    final diff = newCount - oldCount;
    if (diff == 0) return false;

    _tasbihCount = newCount;
    if (diff > 0) {
      _tasbihTotalToday += diff;
    }

    final reachedTarget = _tasbihTarget > 0 && clamped == _tasbihTarget;
    _prefs?.setInt('tasbih_count', _tasbihCount);
    _prefs?.setInt('tasbih_total_today', _tasbihTotalToday);
    notifyListeners();
    return reachedTarget;
  }

  // Canonical Motivational Islamic Quotes & Hadiths for Tasbih Completion
  static const List<TasbihMotivationQuote> motivationalQuotes = [
    TasbihMotivationQuote(
      title: 'طمأنينة وسكينة للقلب 🌿',
      hadithOrAyah: '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
      inspiringMessage: 'هنيئاً لقلبك هذا النور والسكينة.. جعل الله كل تسبيحة شجرة لك في الجنة وظلاً وارفاً يوم القيامة.',
      reference: 'سورة الرعد: ٢٨',
    ),
    TasbihMotivationQuote(
      title: 'ثِقَلٌ عظيم في الميزان ⚖️',
      hadithOrAyah: '«كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ»',
      inspiringMessage: 'ما أعظم أجر هذه الكلمات! لقد ثقُلت موازينك بالحسنات وطابت صحيفتك فاستبشر بفضل الله العظيم.',
      reference: 'صحيح البخاري ومسلم',
    ),
    TasbihMotivationQuote(
      title: 'حفّتك الملائكة وغشيتك الرحمة 🕊️',
      hadithOrAyah: 'قال رسول الله ﷺ: «مَا جَلَسَ قَوْمٌ يَذْكُرُونَ اللَّهَ تَعَالَى إِلَّا حَفَّتْهُمُ الْمَلَائِكَةُ، وَغَشِيَتْهُمُ الرَّحْمَةُ، وَنَزَلَتْ عَلَيْهِمُ السَّكِينَةُ»',
      inspiringMessage: 'تتنزل عليك السكينة الآن ويذكرك ربك في الملأ الأعلى، فطوبى لعبدٍ رطب لسانه بذكره.',
      reference: 'صحيح مسلم',
    ),
    TasbihMotivationQuote(
      title: 'بساتين ونخيل في الفردوس الأعلى 🌴',
      hadithOrAyah: 'قال رسول الله ﷺ: «مَنْ قَالَ: سُبْحَانَ اللَّهِ الْعَظِيمِ وَبِحَمْدِهِ؛ غُرِسَتْ لَهُ نَخْلَةٌ فِي الْجَنَّةِ»',
      inspiringMessage: 'مبارك لك! لقد غرست نخيلاً وبساتين في جنات النعيم، وكل تسبيحة تقربك خطوة إلى الفردوس.',
      reference: 'سنن الترمذي',
    ),
    TasbihMotivationQuote(
      title: 'أحب الكلام إلى الله تعالى 🌟',
      hadithOrAyah: 'قال رسول الله ﷺ: «أَحَبُّ الْكَلَامِ إِلَى اللَّهِ أَرْبَعٌ: سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ»',
      inspiringMessage: 'لقد ذكرت الله بأحب الكلمات إليه ورضيت به رباً وإلهاً، فهنيئاً لمن نال محبة الله ورضوانه.',
      reference: 'صحيح مسلم',
    ),
    TasbihMotivationQuote(
      title: 'حياة القلوب ونور الأرواح 🤍',
      hadithOrAyah: 'قال رسول الله ﷺ: «مَثَلُ الَّذِي يَذْكُرُ رَبَّهُ وَالَّذِي لَا يَذْكُرُ رَبَّهُ مَثَلُ الْحَيِّ وَالْمَيِّتِ»',
      inspiringMessage: 'أحيا الله قلبك بذكره وعمّر أوقاتك بطاعته، فالذكر ربيع القلوب وجلاء الأحزان والهموم.',
      reference: 'صحيح البخاري',
    ),
    TasbihMotivationQuote(
      title: 'بشرى الاستغفار وتفريج الكروب 🌧️',
      hadithOrAyah: 'قال رسول الله ﷺ: «طُوبَى لِمَنْ وَجَدَ فِي صَحِيفَتِهِ اسْتِغْفَارًا كَثِيرًا»',
      inspiringMessage: 'استغفارك محو للذنوب وتفريج للكربات وفتح لأبواب الرزق والتيسير، فداوم تنل الفرج العاجل.',
      reference: 'سنن ابن ماجه',
    ),
    TasbihMotivationQuote(
      title: 'خير من الدنيا وما فيها ✨',
      hadithOrAyah: 'قال رسول الله ﷺ: «لَأَنْ أَقُولَ: سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، أَحَبُّ إِلَيَّ مِمَّا طَلَعَتْ عَلَيْهِ الشَّمْسُ»',
      inspiringMessage: 'أنت الآن أغنى الناس بما ادّخرت في ميزانك، فأجر هذا الذكر خير من كنوز الدنيا وزخرفها الزائل.',
      reference: 'صحيح مسلم',
    ),
  ];

  TasbihMotivationQuote getMotivationQuoteForCycle(int cycle) {
    if (motivationalQuotes.isEmpty) {
      return const TasbihMotivationQuote(
        title: 'أتممت الورد بنجاح ✨',
        hadithOrAyah: '«أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ»',
        inspiringMessage: 'تقبل الله طاعتك وأثابك خيراً كثيراً وكتب لك الأجر.',
        reference: 'القرآن الكريم',
      );
    }
    final index = (cycle > 0 ? (cycle - 1) : 0) % motivationalQuotes.length;
    return motivationalQuotes[index];
  }
}

class TasbihMotivationQuote {
  final String title;
  final String hadithOrAyah;
  final String inspiringMessage;
  final String reference;

  const TasbihMotivationQuote({
    required this.title,
    required this.hadithOrAyah,
    required this.inspiringMessage,
    required this.reference,
  });
}
