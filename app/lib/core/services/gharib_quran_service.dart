import '../text/arabic_normalizer.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نموذج مفردة من غريب القرآن الكريم
class GharibWordEntry {
  final String id;
  final String word;
  final String root;
  final String meaningAr;
  final String meaningEn;
  final String ayahSnippet;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final int juzNumber;
  final String rhetoricalNote;
  final List<String> quizOptions;
  final int correctOptionIndex;

  const GharibWordEntry({
    required this.id,
    required this.word,
    required this.root,
    required this.meaningAr,
    required this.meaningEn,
    required this.ayahSnippet,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.juzNumber,
    required this.rhetoricalNote,
    required this.quizOptions,
    required this.correctOptionIndex,
  });
}

/// خدمة معجم غريب القرآن والمفردات القرآنية التفاعلي مع اختبار المعاني
class GharibQuranService extends ChangeNotifier {
  static final GharibQuranService instance = GharibQuranService._internal();
  GharibQuranService._internal();

  static List<GharibWordEntry> get allWords => defaultWords;
  int get masteredCount => _masteredWordIds.length;
  bool isMastered(String wordId) => _masteredWordIds.contains(wordId);

  static const List<GharibWordEntry> defaultWords = [
    GharibWordEntry(
      id: 'gh_1_sadaqa',
      word: 'نِحْلَةً',
      root: 'ن - ح - ل',
      meaningAr: 'عطيةً وفريضةً طيبةً بها نفوسكم عن طيب خاطر',
      meaningEn: 'A gracious gift / obligatory dower given willingly',
      ayahSnippet: '﴿وَآتُوا النِّسَاءَ صَدُقَاتِهِنَّ نِحْلَةً﴾',
      surahName: 'النساء',
      surahNumber: 4,
      ayahNumber: 4,
      juzNumber: 4,
      rhetoricalNote:
          'سُمّي المهر نِحلةً تشبيهاً بعطية النحل الخالصة الطيبة التي لا يبتغي معطيها عوضاً.',
      quizOptions: [
        'عطيةً وفريضةً عن طيب نفس',
        'قرضاً مؤجلاً إلى حين',
        'تجارةً مشتركةً بين الزوجين',
        'وصيةً بعد الوفاة',
      ],
      correctOptionIndex: 0,
    ),
    GharibWordEntry(
      id: 'gh_2_sayyib',
      word: 'كَصَيِّبٍ',
      root: 'ص - و - ب',
      meaningAr: 'المطر الغزير النازل من السحاب',
      meaningEn: 'A heavy downpour / rainstorm from the sky',
      ayahSnippet: '﴿أَوْ كَصَيِّبٍ مِّنَ السَّمَاءِ فِيهِ ظُلُمَاتٌ وَرَعْدٌ وَبَرْقٌ﴾',
      surahName: 'البقرة',
      surahNumber: 2,
      ayahNumber: 19,
      juzNumber: 1,
      rhetoricalNote:
          'شبّه الله القرآن بالصيّب (المطر الغزير) لأن به حياة القلوب كما أن بالمطر حياة الأرض.',
      quizOptions: [
        'الريح العاصفة الباردة',
        'المطر الغزير النازل من السحاب',
        'الجبل الشاهق المظلم',
        'الضباب الكثيف فوق البحر',
      ],
      correctOptionIndex: 1,
    ),
    GharibWordEntry(
      id: 'gh_3_furaat',
      word: 'فُرَاتٌ',
      root: 'ف - ر - ت',
      meaningAr: 'الماء العذب الشديد العذوبة الذي يكسر العطش',
      meaningEn: 'Sweet, fresh, palatable water that quenches thirst',
      ayahSnippet: '﴿هَٰذَا عَذْبٌ فُرَاتٌ سَائِغٌ شَرَابُهُ وَهَٰذَا مِلْحٌ أُجَاجٌ﴾',
      surahName: 'فاطر',
      surahNumber: 35,
      ayahNumber: 12,
      juzNumber: 22,
      rhetoricalNote:
          'قُوبل بين «عذب فرات» و«ملح أجاج» (الشديد الملوحة والمرارة) لبيان كمال القدرة الإلهية.',
      quizOptions: [
        'الماء المتجمد في الشتاء',
        'الماء المالح المرّ',
        'الماء الشديد العذوبة السائغ للشرب',
        'النهر السريع الجريان',
      ],
      correctOptionIndex: 2,
    ),
    GharibWordEntry(
      id: 'gh_4_wajila',
      word: 'وَجِلَتْ',
      root: 'و - ج - ل',
      meaningAr: 'خافت وخشعت وفزعت تعظيماً لله وهيبةً لجلاله',
      meaningEn: 'Trembled with awe and reverence before Allah',
      ayahSnippet: '﴿إِنَّمَا الْمُؤْمِنُونَ الَّذِينَ إِذَا ذُكِرَ اللَّهُ وَجِلَتْ قُلُوبُهُمْ﴾',
      surahName: 'الأنفال',
      surahNumber: 8,
      ayahNumber: 2,
      juzNumber: 9,
      rhetoricalNote:
          'وجلُ القلب عند ذكر الله علامة حياة الإيمان واستحضار عظمة الخالق سبحانه.',
      quizOptions: [
        'خافت وخشعت تعظيماً لله',
        'غفلت ونسيت ذكر الله',
        'فرحت بدنياها وأموالها',
        'ترددت في اتخاذ القرار',
      ],
      correctOptionIndex: 0,
    ),
    GharibWordEntry(
      id: 'gh_5_sarmada',
      word: 'سَرْمَدًا',
      root: 'س - ر - م - د',
      meaningAr: 'دائماً متصلاً لا ينقطع أبداً',
      meaningEn: 'Perpetual, continuous, everlasting without interruption',
      ayahSnippet:
          '﴿قُلْ أَرَأَيْتُمْ إِن جَعَلَ اللَّهُ عَلَيْكُمُ اللَّيْلَ سَرْمَدًا إِلَىٰ يَوْمِ الْقِيَامَةِ﴾',
      surahName: 'القصص',
      surahNumber: 28,
      ayahNumber: 71,
      juzNumber: 20,
      rhetoricalNote:
          'لفتة كونية عظيمة لنعمة تعاقب الليل والنهار التي لا يقدر عليها إلا الله.',
      quizOptions: [
        'قصيراً سريع الانقضاء',
        'دائماً متصلاً لا ينقطع',
        'شديد البرودة والظلمة',
        'مضيئاً بنور القمر',
      ],
      correctOptionIndex: 1,
    ),
    GharibWordEntry(
      id: 'gh_6_qaswara',
      word: 'قَسْوَرَةٍ',
      root: 'ق - س - ر',
      meaningAr: 'الأسد المهيب أو الرماة الصيادون',
      meaningEn: 'A roaring lion / mighty hunters',
      ayahSnippet: '﴿كَأَنَّهُمْ حُمُرٌ مُّسْتَنفِرَةٌ ۝ فَرَّتْ مِن قَسْوَرَةٍ﴾',
      surahName: 'المدثر',
      surahNumber: 74,
      ayahNumber: 51,
      juzNumber: 29,
      rhetoricalNote:
          'أخذت من القَسر وهو القهر والغلبة، لأن الأسد يقهر سائر السباع بقوته.',
      quizOptions: [
        'الأسد المهيب أو الرماة الصيادون',
        'البرق الخاطف في السماء',
        'السيل المنحدر من الجبل',
        'الليل المظلم البهيم',
      ],
      correctOptionIndex: 0,
    ),
    GharibWordEntry(
      id: 'gh_7_ghasaq',
      word: 'غَاسِقٍ إِذَا وَقَبَ',
      root: 'غ - س - ق / و - ق - ب',
      meaningAr: 'الليل إذا دخل بظلامه واشتد سواده، أو القمر إذا غاب',
      meaningEn: 'The night when its darkness settles in intensely',
      ayahSnippet: '﴿وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ﴾',
      surahName: 'الفلق',
      surahNumber: 113,
      ayahNumber: 3,
      juzNumber: 30,
      rhetoricalNote:
          'في الليل إذا دخل ظلامه تنتشر الهوامّ والشرور، فشرع الله الاستعاذة به من شر ما يكمن فيه.',
      quizOptions: [
        'النهار إذا أشرق ضياؤه',
        'الليل إذا دخل بظلامه واشتد، أو القمر إذا غاب',
        'المطر إذا نزل من السحاب',
        'البحر إذا هاجت أمواجه',
      ],
      correctOptionIndex: 1,
    ),
    GharibWordEntry(
      id: 'gh_8_samad',
      word: 'الصَّمَدُ',
      root: 'ص - م - د',
      meaningAr: 'السيد الكامل في سؤدده الذي تصمد إليه الخلائق كلها في حوائجها',
      meaningEn: 'The Eternal Refuge upon Whom all creation depends',
      ayahSnippet: '﴿اللَّهُ الصَّمَدُ﴾',
      surahName: 'الإخلاص',
      surahNumber: 112,
      ayahNumber: 2,
      juzNumber: 30,
      rhetoricalNote:
          'قال ابن عباس: الصمد هو السيد الذي قد كمل في علمه وحكمته وغناه وقدرته، ويفتقر إليه كل مخلوق.',
      quizOptions: [
        'السيد الكامل الذي تقصده الخلائق كلها في حوائجها',
        'الشديد العقاب للمعتدين',
        'الخالق للسماوات السبع',
        'الباعث للخلق يوم الحساب',
      ],
      correctOptionIndex: 0,
    ),
    GharibWordEntry(
      id: 'gh_9_ababil',
      word: 'أَبَابِيلَ',
      root: 'أ - ب - ل',
      meaningAr: 'جماعات متتابعة متفرقة يتبع بعضها بعضاً',
      meaningEn: 'Flocks following one after another in waves',
      ayahSnippet: '﴿وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ﴾',
      surahName: 'الفيل',
      surahNumber: 105,
      ayahNumber: 3,
      juzNumber: 30,
      rhetoricalNote:
          'الأبابيل ليست اسم نوع معين من الطير، بل وصف لكونها جماعات وأفواجاً متتابعة من كل جانب.',
      quizOptions: [
        'طيوراً سوداء عملاقة الحجم',
        'جماعات وأفواجاً متتابعة يتبع بعضها بعضاً',
        'رياحاً عاتية محملة بالرمال',
        'ملائكة نازلة من السماء',
      ],
      correctOptionIndex: 1,
    ),
    GharibWordEntry(
      id: 'gh_10_hawiya',
      word: 'هَاوِيَةٌ',
      root: 'ه - و - ي',
      meaningAr: 'نار جهنم العميقة القعر التي يهوي فيها من خفّت موازينه',
      meaningEn: 'The deep abyss / blazing Hellfire into which one plunges',
      ayahSnippet: '﴿فَأُمُّهُ هَاوِيَةٌ ۝ وَمَا أَدْرَاكَ مَا هِيَهْ ۝ نَارٌ حَامِيَةٌ﴾',
      surahName: 'القارعة',
      surahNumber: 101,
      ayahNumber: 9,
      juzNumber: 30,
      rhetoricalNote:
          'سُمّيت أُمّاً له لأنه يأوي إليها كما يأوي الولد إلى أمه، وسُمّيت هاوية لبعد قعرها.',
      quizOptions: [
        'الصحراء القاحلة بلا ماء',
        'الريح الشديدة الهبوب',
        'نار جهنم العميقة القعر التي يهوي فيها',
        'الحفرة المظلمة في القبر',
      ],
      correctOptionIndex: 2,
    ),
  ];

  Set<String> _masteredWordIds = {};
  int _quizBestScore = 0;

  Set<String> get masteredWordIds => Set.unmodifiable(_masteredWordIds);
  int get quizBestScore => _quizBestScore;

  Future<void> init({bool forceReload = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _masteredWordIds =
        (prefs.getStringList('gharib_mastered_words') ?? []).toSet();
    _quizBestScore = prefs.getInt('gharib_quiz_best_score') ?? 0;
    notifyListeners();
  }

  Future<void> toggleMastered(String wordId) async {
    if (_masteredWordIds.contains(wordId)) {
      _masteredWordIds.remove(wordId);
    } else {
      _masteredWordIds.add(wordId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'gharib_mastered_words', _masteredWordIds.toList());
    notifyListeners();
  }

  Future<void> recordQuizScore(int score) async {
    if (score > _quizBestScore) {
      _quizBestScore = score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gharib_quiz_best_score', _quizBestScore);
    }
    notifyListeners();
  }

  List<GharibWordEntry> searchWords(String query, {int? juzFilter}) {
    final q = query.trim().toLowerCase();
    final normQ = ArabicNormalizer.normalize(query, loose: true);
    return allWords.where((w) {
      final matchesJuz = juzFilter == null || w.juzNumber == juzFilter;
      if (!matchesJuz) return false;
      if (q.isEmpty) return true;
      return w.word.contains(q) ||
          ArabicNormalizer.normalize(w.word, loose: true).contains(normQ) ||
          w.root.contains(q) ||
          ArabicNormalizer.normalize(w.root, loose: true).contains(normQ) ||
          w.meaningAr.contains(q) ||
          ArabicNormalizer.normalize(w.meaningAr, loose: true).contains(normQ) ||
          w.meaningEn.toLowerCase().contains(q) ||
          w.surahName.contains(q) ||
          ArabicNormalizer.normalize(w.surahName, loose: true).contains(normQ);
    }).toList();
  }
}

extension GharibQuranServiceInstanceExt on GharibQuranService {
  List<GharibWordEntry> get allWords => GharibQuranService.allWords;
}
