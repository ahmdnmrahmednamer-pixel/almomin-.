import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dhikr.dart';

class AdhkarService extends ChangeNotifier {
  static final AdhkarService instance = AdhkarService._internal();
  AdhkarService._internal();

  SharedPreferences? _prefs;

  // Tasbih state
  int _tasbihCount = 0;
  int _tasbihTarget = 33;
  int _tasbihTotalToday = 0;
  String _selectedTasbihPhrase = 'سُبْحَانَ اللَّهِ';
  bool _hapticEnabled = true;

  int get tasbihCount => _tasbihCount;
  int get tasbihTarget => _tasbihTarget;
  int get tasbihTotalToday => _tasbihTotalToday;
  String get selectedTasbihPhrase => _selectedTasbihPhrase;
  bool get hapticEnabled => _hapticEnabled;

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

  late List<DhikrCategory> _categories;
  List<DhikrCategory> get categories => _categories;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _tasbihCount = _prefs?.getInt('tasbih_count') ?? 0;
    _tasbihTarget = _prefs?.getInt('tasbih_target') ?? 33;
    _tasbihTotalToday = _prefs?.getInt('tasbih_total_today') ?? 0;
    _selectedTasbihPhrase = _prefs?.getString('tasbih_phrase') ?? 'سُبْحَانَ اللَّهِ';
    _hapticEnabled = _prefs?.getBool('tasbih_haptic') ?? true;

    _buildCategories();
    notifyListeners();
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
        ],
      ),
    ];
  }

  // Dhikr Counter Operations
  void incrementDhikr(DhikrItem item) {
    if (!item.isCompleted) {
      item.increment();
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
    notifyListeners();
  }

  void resetCategory(DhikrCategory category) {
    for (final item in category.items) {
      item.reset();
    }
    notifyListeners();
  }

  // Tasbih Operations
  void incrementTasbih() {
    _tasbihCount++;
    _tasbihTotalToday++;

    if (_hapticEnabled) {
      if (_tasbihTarget > 0 && _tasbihCount % _tasbihTarget == 0) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    _prefs?.setInt('tasbih_count', _tasbihCount);
    _prefs?.setInt('tasbih_total_today', _tasbihTotalToday);
    notifyListeners();
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
}
