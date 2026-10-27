import '../text/arabic_normalizer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tajweed_rule.dart';

class TajweedService extends ChangeNotifier {
  static final TajweedService instance = TajweedService._internal();
  TajweedService._internal();

  bool _isInitialized = false;
  final Set<String> _favoriteRuleIds = {};

  Set<String> get favoriteRuleIds => Set.unmodifiable(_favoriteRuleIds);

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('tajweed_favorites') ?? [];
      _favoriteRuleIds
        ..clear()
        ..addAll(favs);
    } catch (e) {
      debugPrint('TajweedService init error: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool isFavorite(String ruleId) => _favoriteRuleIds.contains(ruleId);

  Future<void> toggleFavorite(String ruleId) async {
    if (_favoriteRuleIds.contains(ruleId)) {
      _favoriteRuleIds.remove(ruleId);
    } else {
      _favoriteRuleIds.add(ruleId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tajweed_favorites', _favoriteRuleIds.toList());
    } catch (e) {
      debugPrint('Error saving tajweed favorites: $e');
    }
  }

  List<TajweedRule> getAllRules() => _allRules;

  List<TajweedRule> getRulesByCategory(TajweedCategory category) {
    return _allRules.where((r) => r.category == category).toList();
  }

  List<TajweedRule> getFavoriteRules() {
    return _allRules.where((r) => _favoriteRuleIds.contains(r.id)).toList();
  }

  TajweedRule? getRuleById(String id) {
    for (final r in _allRules) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<TajweedRule> searchRules(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return _allRules;
    final normQ = ArabicNormalizer.normalize(query, loose: true);

    return _allRules.where((r) {
      return r.arabicTitle.toLowerCase().contains(cleanQuery) ||
          ArabicNormalizer.normalize(r.arabicTitle, loose: true).contains(normQ) ||
          r.title.toLowerCase().contains(cleanQuery) ||
          ArabicNormalizer.normalize(r.title, loose: true).contains(normQ) ||
          r.summary.toLowerCase().contains(cleanQuery) ||
          ArabicNormalizer.normalize(r.summary, loose: true).contains(normQ) ||
          r.definition.toLowerCase().contains(cleanQuery) ||
          ArabicNormalizer.normalize(r.definition, loose: true).contains(normQ) ||
          r.letters.any((l) => l.contains(cleanQuery) || ArabicNormalizer.normalize(l, loose: true).contains(normQ)) ||
          r.categoryName.toLowerCase().contains(cleanQuery) ||
          ArabicNormalizer.normalize(r.categoryName, loose: true).contains(normQ) ||
          r.examples.any((e) =>
              e.targetWord.contains(cleanQuery) ||
              ArabicNormalizer.normalize(e.targetWord, loose: true).contains(normQ) ||
              e.ayahSnippet.contains(cleanQuery) ||
              ArabicNormalizer.normalize(e.ayahSnippet, loose: true).contains(normQ) ||
              e.surahName.contains(cleanQuery) ||
              ArabicNormalizer.normalize(e.surahName, loose: true).contains(normQ));
    }).toList();
  }

  // دليل ألوان المصحف الشريف الملون المعتمد
  List<TajweedColorGuideItem> getColorGuide() => _colorGuide;

  // قواعد التجويد الشاملة والمعتمدة
  static final List<TajweedRule> _allRules = [
    // -------------------------------------------------------------
    // 1. أحكام النون الساكنة والتنوين
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'nun_izhar',
      title: 'الإظهار الحلقي',
      arabicTitle: 'الإظهار الحلقي',
      category: TajweedCategory.nunTanween,
      summary: 'إخراج النون الساكنة أو التنوين من مخرجها بغير غنة ظاهرة عند ملاقاة أحد حروف الحلق الستة.',
      definition: 'الإظهار لغةً هو البيان، واصطلاحاً: إخراج كل حرف من مخرجه بغير غنة كاملة في الحرف المظهر. وحروفه ستة مجموعة في أوائل الكلمات: (أخي هاك علماً حازه غير خاسر) وهي: الهمزة والهاء والعين والحاء والغين والخاء.',
      letters: ['ء', 'هـ', 'ع', 'ح', 'غ', 'خ'],
      ruleColor: Color(0xFF1B5E20),
      poeticVerse: 'فَالْأَوَّلُ الْإِظْهَارُ قَبْلَ أَحْرُفِ *** لِلْحَلْقِ سِتٌّ رُتِّبَتْ فَلْتَعْرِفِ\nهَمْزٌ فَهَاءٌ ثُمَّ عَيْنٌ حَاءُ *** مُهْمَلَتَانِ ثُمَّ غَيْنٌ خَاءُ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يُنطق بالنون الساكنة أو التنوين واضحة ومستقرة في طرف اللسان دون سكت ولا تمطيط ولا تشديد ولا غنة زائدة، ثم يُنطق بالحرف الحلقي مستقلاً.',
      examples: [
        TajweedExample(
          ayahSnippet: 'مَنْ ءَامَنَ بِاللَّهِ وَالْيَوْمِ الْآخِرِ',
          targetWord: 'مَنْ ءَامَنَ',
          surahName: 'البقرة',
          ayahNumber: 62,
          explanation: 'نون ساكنة بعدها همزة في كلمتين حكمها الإظهار الحلقي.',
        ),
        TajweedExample(
          ayahSnippet: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          targetWord: 'وَانْحَرْ',
          surahName: 'الكوثر',
          ayahNumber: 2,
          explanation: 'نون ساكنة بعدها حاء في كلمة واحدة حكمها الإظهار الحلقي.',
        ),
        TajweedExample(
          ayahSnippet: 'وَاللَّهُ عَلِيمٌ حَكِيمٌ',
          targetWord: 'عَلِيمٌ حَكِيمٌ',
          surahName: 'النساء',
          ayahNumber: 26,
          explanation: 'تنوين ضمة بعده حاء حكمه الإظهار الحلقي.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'nun_idgham_ghunnah',
      title: 'الإدغام بغنة (ناقص)',
      arabicTitle: 'الإدغام بغنة',
      category: TajweedCategory.nunTanween,
      summary: 'إدخال النون الساكنة أو التنوين في الحرف التالي مع بقاء الغنة بمقدار حركتين عند حروف (ينمو).',
      definition: 'الإدغام لغةً هو الإدخال، واصطلاحاً: التقاء حرف ساكن بحرف متحرك بحيث يصيران حرفاً واحداً مشدداً كالثاني. ويكون بغنة مع أربعة أحرف يجمعها لفظ (يَنْمُو). ويشترط أن يكون من كلمتين، فإن جاء في كلمة واحدة وجب الإظهار المطلق مثل (دُنْيَا، قِنْوَان، صِنْوَان، بُنْيَان).',
      letters: ['ي', 'ن', 'م', 'و'],
      ruleColor: Color(0xFF2E7D32),
      poeticVerse: 'لَكِنَّهَا قِسْمَانِ قِسْمٌ يُدْغَمَا *** فِيهِ بِغُنَّةٍ بِيَنْمُو عُلِمَا\nإِلَّا إِذَا كَانَا بِكِلْمَةٍ فَلَا *** تُدْغِمْ كَدُنْيَا ثُمَّ صِنْوَانٍ تَلَا',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يُدمج صوت النون في الحرف التالي مع حبس الصوت وإخراجه من الخيشوم برنين الغنة بمقدار حركتين دون استعجال.',
      examples: [
        TajweedExample(
          ayahSnippet: 'فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
          targetWord: 'فَمَن يَعْمَلْ',
          surahName: 'الزلزلة',
          ayahNumber: 7,
          explanation: 'نون ساكنة بعدها ياء في كلمتين حكمها إدغام بغنة ناقص.',
        ),
        TajweedExample(
          ayahSnippet: 'مِن مَّالِ اللَّهِ الَّذِي آتَاكُمْ',
          targetWord: 'مِن مَّالِ',
          surahName: 'النور',
          ayahNumber: 33,
          explanation: 'نون ساكنة بعدها ميم حكمها إدغام كامل بغنة.',
        ),
        TajweedExample(
          ayahSnippet: 'وَرَحْمَةٌ وَبَرَكَاتٌ عَلَيْكُمْ أَهْلَ الْبَيْتِ',
          targetWord: 'وَرَحْمَةٌ وَبَرَكَاتٌ',
          surahName: 'هود',
          ayahNumber: 73,
          explanation: 'تنوين بعده واو حكمه إدغام ناقص بغنة.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'nun_idgham_no_ghunnah',
      title: 'الإدغام بغير غنة (كامل)',
      arabicTitle: 'الإدغام بغير غنة',
      category: TajweedCategory.nunTanween,
      summary: 'إدخال النون الساكنة أو التنوين في اللام أو الراء إدخالاً تاماً دون بقاء أي أثر للغنة.',
      definition: 'هو ذوبان النون الساكنة أو التنوين تماماً في حرف اللام أو الراء بحيث يُنطق بحرف مشدد تام التشديد دون أي صوت يخرج من الخيشوم.',
      letters: ['ل', 'ر'],
      ruleColor: Color(0xFF388E3C),
      poeticVerse: 'وَالثَّانِ إِدْغَامٌ بِغَيْرِ غُنَّهْ *** فِي اللَّامِ وَالرَّا ثُمَّ كَرِّرَنَّهْ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'ينتقل القارئ من الحرف الذي قبل النون مباشرة إلى اللام أو الراء المشددة دون إخراج أي غنة من الأنف.',
      examples: [
        TajweedExample(
          ayahSnippet: 'وَيْلٌ لِّكُلِّ هُمَزَةٍ لُّمَزَةٍ',
          targetWord: 'وَيْلٌ لِّكُلِّ',
          surahName: 'الهمزة',
          ayahNumber: 1,
          explanation: 'تنوين بعده لام حكمه إدغام كامل بغير غنة.',
        ),
        TajweedExample(
          ayahSnippet: 'مِّن رَّبِّهِمْ إِنَّهُ الْحَقُّ',
          targetWord: 'مِّن رَّبِّهِمْ',
          surahName: 'البقرة',
          ayahNumber: 26,
          explanation: 'نون ساكنة بعدها راء حكمها إدغام كامل بغير غنة وتكرير الراء مخفف.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'nun_iqlab',
      title: 'الإقلاب',
      arabicTitle: 'الإقلاب (القلب)',
      category: TajweedCategory.nunTanween,
      summary: 'قلب النون الساكنة أو التنوين ميماً مخفاة بغنة حركتين عند حرف الباء (يُرمز له بميم صغيرة قائمة ۘ م).',
      definition: 'الإقلاب لغةً: تحويل الشيء عن وجهه، واصطلاحاً: قلب النون الساكنة أو التنوين ميماً قبل الباء مع مراعاة الغنة وعدم كز الشفتين (تلامس لطيف للشفتين مع غنة بمقدار حركتين).',
      letters: ['ب'],
      ruleColor: Color(0xFF00796B),
      poeticVerse: 'وَالثَّالِثُ الْإِقْلَابُ عِنْدَ الْبَاءِ *** مِيمًا بِغُنَّةٍ مَعَ الْإِخْفَاءِ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'تُنطق النون ميماً ساكنة مع إطباق الشفتين إطباقاً خفيفاً بلا كز ولا فرجة مبالغ فيها، مع إطالة الغنة حركتين قبل النطق بالباء.',
      examples: [
        TajweedExample(
          ayahSnippet: 'كَلَّا لَيُنبَذَنَّ فِي الْحُطَمَةِ',
          targetWord: 'لَيُنبَذَنَّ',
          surahName: 'الهمزة',
          ayahNumber: 4,
          explanation: 'نون ساكنة بعدها باء في كلمة واحدة قُلبت ميماً مخفاة بغنة.',
        ),
        TajweedExample(
          ayahSnippet: 'وَاللَّهُ عَلِيمٌ بِذَاتِ الصُّدُورِ',
          targetWord: 'عَلِيمٌ بِذَاتِ',
          surahName: 'آل عمران',
          ayahNumber: 119,
          explanation: 'تنوين ضمة بعده باء حكمه الإقلاب إلى ميم بغنة.',
        ),
        TajweedExample(
          ayahSnippet: 'مِن بَعْدِ مَا جَاءَتْهُمُ الْبَيِّنَاتُ',
          targetWord: 'مِن بَعْدِ',
          surahName: 'البقرة',
          ayahNumber: 213,
          explanation: 'نون ساكنة بعدها باء في كلمتين حكمها الإقلاب.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'nun_ikhfa',
      title: 'الإخفاء الحقيقي',
      arabicTitle: 'الإخفاء الحقيقي',
      category: TajweedCategory.nunTanween,
      summary: 'ستر النون الساكنة أو التنوين بين الإظهار والإدغام مع بقاء الغنة بمقدار حركتين عند حروفه الـ 15.',
      definition: 'الإخفاء لغةً الستر، واصطلاحاً: نطق النون الساكنة أو التنوين بصفة بين الإظهار والإدغام عارٍ عن التشديد مع بقاء الغنة. وتفخم الغنة إذا كان بعدها حرف مفخم (ص، ض، ط، ظ، ق) وترقق مع بقية الحروف المستفلة.',
      letters: ['ص', 'ذ', 'ث', 'ك', 'ج', 'ش', 'ق', 'س', 'د', 'ط', 'ز', 'ف', 'ت', 'ض', 'ظ'],
      ruleColor: Color(0xFF43A047),
      poeticVerse: 'وَالرَّابِعُ الْإِخْفَاءُ عِنْدَ الْفَاضِلِ *** مِنَ الْحُرُوفِ وَاجِبٌ لِلْفَاضِلِ\nفِي خَمْسَةٍ مِنْ بَعْدِ عَشْرٍ رَمْزُهَا *** فِي كِلْمِ هَذَا البَيْتِ قَدْ ضَمَّنْتُهَا\nصِفْ ذَا ثَنَا كَمْ جَادَ شَخْصٌ قَدْ سَمَا *** دُمْ طَيِّبًا زِدْ فِي تُقًى ضَعْ ظَالِمَا',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يوضع اللسان قريباً من مخرج الحرف الآتي دون إلصاقه بمخرج النون تماماً، مع إخراج غنة رنانة من الخيشوم حركتين مفخمة أو مرققة بحسب الحرف التالي.',
      examples: [
        TajweedExample(
          ayahSnippet: 'مِن قَبْلِكُمْ وَلَعَلَّكُمْ تَتَّقُونَ',
          targetWord: 'مِن قَبْلِكُمْ',
          surahName: 'البقرة',
          ayahNumber: 21,
          explanation: 'نون ساكنة بعدها قاف، حكمها إخفاء حقيقي مع تفخيم الغنة لأن القاف حرف استعلاء.',
        ),
        TajweedExample(
          ayahSnippet: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ',
          targetWord: 'الْإِنسَانَ',
          surahName: 'العصر',
          ayahNumber: 2,
          explanation: 'نون ساكنة بعدها سين في كلمة واحدة، حكمها إخفاء حقيقي بغنة مرققة.',
        ),
        TajweedExample(
          ayahSnippet: 'شَرَابًا طَهُورًا',
          targetWord: 'شَرَابًا طَهُورًا',
          surahName: 'الإنسان',
          ayahNumber: 21,
          explanation: 'تنوين فتح بعده طاء حكمه إخفاء حقيقي بغنة مفخمة.',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 2. أحكام الميم الساكنة
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'meem_ikhfa_shafawi',
      title: 'الإخفاء الشفوي',
      arabicTitle: 'الإخفاء الشفوي',
      category: TajweedCategory.meemSakinah,
      summary: 'إخفاء الميم الساكنة مع الغنة حركتين إذا جاء بعدها حرف الباء فقط.',
      definition: 'إذا وقع بعد الميم الساكنة حرف الباء (ولا يكون إلا من كلمتين)، تُخفى الميم مع غنة بمقدار حركتين ويسمى إخفاءً شفوياً لأن الميم والباء يخرجان من الشفتين.',
      letters: ['ب'],
      ruleColor: Color(0xFF00897B),
      poeticVerse: 'فَالْأَوَّلُ الْإِخْفَاءُ عِنْدَ الْبَاءِ *** وَسَمِّهِ الشَّفْوِيَّ لِلْقُرَّاءِ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'تتلاقى الشفتان بلطف دون ضغط شديد مع مد الصوت بالغنة من الخيشوم بمقدار حركتين ثم فتح الشفتين بنطق الباء.',
      examples: [
        TajweedExample(
          ayahSnippet: 'تَرْمِيهِم بِحِجَارَةٍ مِّن سِجِّيلٍ',
          targetWord: 'تَرْمِيهِم بِحِجَارَةٍ',
          surahName: 'الفيل',
          ayahNumber: 4,
          explanation: 'ميم ساكنة بعدها باء حكمها إخفاء شفوي بغنة حركتين.',
        ),
        TajweedExample(
          ayahSnippet: 'وَمَن يَعْتَصِم بِاللَّهِ فَقَدْ هُدِيَ',
          targetWord: 'يَعْتَصِم بِاللَّهِ',
          surahName: 'آل عمران',
          ayahNumber: 101,
          explanation: 'ميم ساكنة بعدها باء حكمها إخفاء شفوي.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'meem_idgham_shafawi',
      title: 'إدغام المتماثلين الصغير',
      arabicTitle: 'إدغام المتماثلين (الشفوي)',
      category: TajweedCategory.meemSakinah,
      summary: 'إدغام الميم الساكنة في ميم متحركة تليها لتصبحا ميماً واحدة مشددة بغنة حركتين.',
      definition: 'إذا جاء بعد الميم الساكنة ميم متحركة تدغم الأولى في الثانية فتصيران ميماً واحدة مشددة مع كمال الغنة حركتين.',
      letters: ['م'],
      ruleColor: Color(0xFF00695C),
      poeticVerse: 'وَالثَّانِ إِدْغَامٌ بِمِثْلِهَا أَتَى *** وَسَمِّ إِدْغَامًا صَغِيرًا يَا فَتَى',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'تنطبق الشفتان انطباقاً تاماً مع الغنة بمقدار حركتين تخرج من الخيشوم.',
      examples: [
        TajweedExample(
          ayahSnippet: 'الَّذِي أَطْعَمَهُم مِّن جُوعٍ وَآمَنَهُم مِّنْ خَوْفٍ',
          targetWord: 'أَطْعَمَهُم مِّن',
          surahName: 'قريش',
          ayahNumber: 4,
          explanation: 'ميم ساكنة أدغمت في ميم متحركة إدغاماً شفوياً بغنة كاملة.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'meem_izhar_shafawi',
      title: 'الإظهار الشفوي',
      arabicTitle: 'الإظهار الشفوي',
      category: TajweedCategory.meemSakinah,
      summary: 'إظهار الميم الساكنة ناصعة واضحة دون غنة عند باقي الحروف الهجائية، وأشد ما يكون عند الواو والفاء.',
      definition: 'نطق الميم الساكنة واضحة ومستقرة دون غنة زائدة عند جميع الحروف ما عدا الباء والميم. ويجب الحذر من إخفائها عند حرفي الواو والفاء لقرب المخرج مع الفاء واتحاد المخرج مع الواو.',
      letters: ['كل الحروف عدا الباء والميم'],
      ruleColor: Color(0xFF2E7D32),
      poeticVerse: 'وَالثَّالِثُ الْإِظْهَارُ فِي الْبَقِيَّهْ *** مِنْ أَحْرُفٍ وَسَمِّهَا شَفْوِيَّهْ\nوَاحْذَرْ لَدَى وَاوٍ وَفَا أَن تَخْتَفِي *** لِقُرْبِهَا وَالاتِّحَادِ فَاعْرِفِ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'تطبق الشفتان على الميم إطباقاً معتدلاً زمناً قصيراً دون غنة زائدة ثم الانتقال المباشر للحرف التالي.',
      examples: [
        TajweedExample(
          ayahSnippet: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          targetWord: 'عَلَيْهِمْ غَيْرِ',
          surahName: 'الفاتحة',
          ayahNumber: 7,
          explanation: 'ميم ساكنة بعدها غين حكمها إظهار شفوي.',
        ),
        TajweedExample(
          ayahSnippet: 'عَلَيْهِمْ وَلَا الضَّالِّينَ',
          targetWord: 'عَلَيْهِمْ وَلَا',
          surahName: 'الفاتحة',
          ayahNumber: 7,
          explanation: 'ميم ساكنة بعدها واو وجب إظهارها بشدة لاجتماعهما في مخرج الشفتين.',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 3. أحكام المدود
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'madd_tabiee',
      title: 'المد الطبيعي (الأصلي)',
      arabicTitle: 'المد الطبيعي (الأصلي)',
      category: TajweedCategory.madd,
      summary: 'المد الذي لا تقوم ذات حرف المد إلا به ولا يتوقف على سبب من همز أو سكون ومقداره حركتان.',
      definition: 'حروف المد الثلاثة (الألف الساكنة المفتوح ما قبلها، الواو الساكنة المضموم ما قبلها، الياء الساكنة المكسور ما قبلها والمجموعة في نُوحِيهَا). يمَد بمقدار حركتين (بسط الإصبع أو قبضه بحركة معتدلة).',
      letters: ['ا', 'و', 'ي'],
      ruleColor: Color(0xFFFB8C00),
      poeticVerse: 'مَا لَا تَوَقُّفٌ لَهُ عَلَى سَبَبْ *** وَلَا بِدُونِهِ الحُرُوفُ تُجْتَلَبْ\nبَلْ أَيُّ حَرْفٍ غَيْرِ هَمْزٍ أَوْ سُكُونْ *** جَا بَعْدَ مَدٍّ فَالطَّبِيعِيَّ يَكُونْ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يمتد الصوت بحرف المد بمقدار حركتين متساويتين دون زيادة ولا نقصان.',
      examples: [
        TajweedExample(
          ayahSnippet: 'تِلْكَ مِنْ أَنبَاءِ الْغَيْبِ نُوحِيهَا إِلَيْكَ',
          targetWord: 'نُوحِيهَا',
          surahName: 'هود',
          ayahNumber: 49,
          explanation: 'جمعت أحرف المد الثلاثة بشروطها: واو قبلها ضم، ياء قبلها كسر، ألف قبلها فتح.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'madd_muttasil',
      title: 'المد المتصل (الواجب)',
      arabicTitle: 'المد المتصل',
      category: TajweedCategory.madd,
      summary: 'أن يأتي حرف المد وتليه همزة في كلمة واحدة ومقداره 4 أو 5 حركات وجوباً (6 عند الوقف المتطرف).',
      definition: 'سمي متصلاً لاتصال حرف المد والهمز في كلمة واحدة، وحكمه الوجوب لإجماع القراء على مده أكثر من الطبيعي. مقداره 4 إلى 5 حركات وصلاً ووقفاً، ويزاد إلى 6 حركات إذا كانت الهمزة متطرفة وموقوفاً عليها.',
      letters: ['حرف مد + همزة في كلمة واحدة'],
      ruleColor: Color(0xFFD32F2F),
      poeticVerse: 'فَوَاجِبٌ إِنْ جَاءَ هَمْزٌ بَعْدَ مَدّْ *** فِي كِلْمَةٍ وَذَا بِمُتَّصِلٍ يُعَدّْ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يمتد الصوت بحرف المد بمقدار 4 أو 5 حركات (ضعف الطبيعي مرتين ونصف) قبل نطق الهمزة المحققة.',
      examples: [
        TajweedExample(
          ayahSnippet: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          targetWord: 'جَاءَ',
          surahName: 'النصر',
          ayahNumber: 1,
          explanation: 'ألف مد بعدها همزة في كلمة واحدة حكمها مد متصل واجب 4 أو 5 حركات.',
        ),
        TajweedExample(
          ayahSnippet: 'وَالسَّمَاءِ وَالطَّارِقِ',
          targetWord: 'وَالسَّمَاءِ',
          surahName: 'الطارق',
          ayahNumber: 1,
          explanation: 'مد متصل 4 أو 5 حركات، ويجوز مده 6 حركات عند الوقف عليها.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'madd_munfasil',
      title: 'المد المنفصل (الجائز)',
      arabicTitle: 'المد المنفصل',
      category: TajweedCategory.madd,
      summary: 'أن يأتي حرف المد في آخر الكلمة والهمزة في أول الكلمة التي تليها ومقداره 4 أو 5 حركات لحفص.',
      definition: 'سمي منفصلاً لانفصال حرف المد عن الهمزة في كلمتين، وحكمه الجواز لجواز قصره حركتين عند بعض القراء وطريق طيبة النشر، ويمد 4 أو 5 حركات من طريق الشاطبية لحفص عن عاصم. ويسقط المد وصلاً إذا وقف على الكلمة الأولى فيعود طبيعياً.',
      letters: ['حرف مد نهاية كلمة + همزة بداية كلمة ثانية'],
      ruleColor: Color(0xFFE65100),
      poeticVerse: 'وَجَائِزٌ مَدٌّ وَقَصْرٌ إِنْ فُصِلْ *** كُلٌّ بِكِلْمَةٍ وَهَذَا المُنْفَصِلْ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يمتد الصوت 4 أو 5 حركات وصلاً، أما عند الوقف على الكلمة الأولى فيُمَد حركتين فقط كمد طبيعي.',
      examples: [
        TajweedExample(
          ayahSnippet: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          targetWord: 'إِنَّا أَعْطَيْنَاكَ',
          surahName: 'الكوثر',
          ayahNumber: 1,
          explanation: 'ألف المد في (إنا) والهمزة في أول (أعطيناك) مد جائز منفصل 4-5 حركات.',
        ),
        TajweedExample(
          ayahSnippet: 'يَا أَيُّهَا الَّذِينَ آمَنُوا',
          targetWord: 'يَا أَيُّهَا',
          surahName: 'البقرة',
          ayahNumber: 183,
          explanation: 'مد منفصل حكمي لاتصال ياء النداء رسماً في المصحف.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'madd_lazim',
      title: 'المد اللازم (الكلمي والحرفي)',
      arabicTitle: 'المد اللازم (6 حركات لزوماً)',
      category: TajweedCategory.madd,
      summary: 'أن يأتي بعد حرف المد سكون أصلي ثابت وصلاً ووقفاً ويمد 6 حركات مشبعاً باتفاق القراء.',
      definition: 'المد اللازم ينقسم إلى كلمي وحرفي، وكل منهما مثقل (إذا أدغم الساكن فيما بعده وكان مشدداً) أو مخفف (إذا لم يدغم). مقداره 6 حركات لزوماً لجميع القراء دون استثناء.',
      letters: ['حرف مد + حرف ساكن سكوناً أصلياً وصلاً ووقفاً'],
      ruleColor: Color(0xFFB71C1C),
      poeticVerse: 'أَقْسَامُ لَازِمٍ لَدَيْهِمْ أَرْبَعَهْ *** وَتِلْكَ كِلْمِيٌّ وَحَرْفِيٌّ مَعَهْ\nكِلَاهُمَا مُخَفَّفٌ مُثَقَّلُ *** فَهَذِهِ أَرْبَعَةٌ تُفَصَّلُ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يمد الصوت 6 حركات كاملة دون تهاون مع نبر الحرف المشدد الذي يليه لإبرازه.',
      examples: [
        TajweedExample(
          ayahSnippet: 'غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          targetWord: 'الضَّالِّينَ',
          surahName: 'الفاتحة',
          ayahNumber: 7,
          explanation: 'مد لازم كلمي مثقل لوقوع لام مشددة بعد حرف الألف، مقداره 6 حركات لزوماً.',
        ),
        TajweedExample(
          ayahSnippet: 'آلْآنَ وَقَدْ كُنتُم بِهِ تَسْتَعْجِلُونَ',
          targetWord: 'آلْآنَ',
          surahName: 'يونس',
          ayahNumber: 51,
          explanation: 'مد لازم كلمي مخفف لأن اللام ساكنة غير مدغمة، مقداره 6 حركات.',
        ),
        TajweedExample(
          ayahSnippet: 'الم ۚ ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ',
          targetWord: 'الم',
          surahName: 'البقرة',
          ayahNumber: 1,
          explanation: 'اللام مد لازم حرفي مثقل (6 حركات) والميم مد لازم حرفي مخفف (6 حركات).',
        ),
      ],
    ),
    const TajweedRule(
      id: 'madd_arid_sukoon',
      title: 'المد العارض للسكون',
      arabicTitle: 'المد العارض للسكون',
      category: TajweedCategory.madd,
      summary: 'أن يأتي بعد حرف المد حرف متحرك سكن لأجل الوقف ومقداره 2 أو 4 أو 6 حركات.',
      definition: 'إذا سكن الحرف الأخير في الكلمة بسبب الوقف وكان قبله حرف مد، جاز في المد ثلاثة أوجه: القصر (حركتان)، والتوسط (أربع حركات)، والإشباع (ست حركات). أما في حالة الوصل فيعود مداً طبيعياً حركتين.',
      letters: ['حرف مد + حرف سكن عارضاً للوقف'],
      ruleColor: Color(0xFFF57C00),
      poeticVerse: 'وَمِثْلُ ذَا إِنْ عَرَضَ السُّكُونُ *** وَقْفًا كَتَعْلَمُونَ نَسْتَعِينُ',
      poeticSource: 'تحفة الأطفال - الشيخ سليمان الجمزوري',
      howToPronounce: 'يجوز للقارئ أن يقف بحركتين أو بأربع أو بست حركات، والأولى التوسط (4 حركات) مع توحيد الوجه في التلاوة الواحدة.',
      examples: [
        TajweedExample(
          ayahSnippet: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          targetWord: 'الْعَالَمِينَ',
          surahName: 'الفاتحة',
          ayahNumber: 2,
          explanation: 'الياء مد عارض للسكون عند الوقف على النون بالسكون: يمد 2 أو 4 أو 6 حركات.',
        ),
        TajweedExample(
          ayahSnippet: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          targetWord: 'نَسْتَعِينُ',
          surahName: 'الفاتحة',
          ayahNumber: 5,
          explanation: 'مد عارض للسكون 2-4-6 حركات وقفا، وحركتان وصلا.',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 4. أحكام القلقلة
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'qalqalah_rules',
      title: 'أحكام القلقلة ومراتبها',
      arabicTitle: 'القلقلة (قطب جد)',
      category: TajweedCategory.qalqalah,
      summary: 'اضطراب المخرج عند النطق بالحرف الساكن حتى يسمع له نبرة قوية. حروفها خمسة: (ق، ط، ب، ج، د).',
      definition: 'القلقلة لغةً التحريك والاضطراب، واصطلاحاً: صوت زائد يحدث في مخرج الحرف عند النطق به ساكناً نتيجة انحباس الصوت والنفس ثم انفراجهما دفعة واحدة. ولها 3 مراتب:\n1. كبرى: الحرف المشدد الموقوف عليه (أشد ما تكون).\n2. وسطى: الحرف المخفف الموقوف عليه.\n3. صغرى: الحرف الساكن في وسط الكلمة أو وصلاً.',
      letters: ['ق', 'ط', 'ب', 'ج', 'د'],
      ruleColor: Color(0xFF1976D2),
      poeticVerse: 'قَلْقَلَةٌ قُطْبُ جَدٍّ وَإِنْ يَكُنْ *** صَحَّتْ فَفِي الوَقْفِ كَانَتْ أَبْيَنَا',
      poeticSource: 'المقدمة الجزرية - الإمام ابن الجزري',
      howToPronounce: 'ينطق بالحرف دون خلطه بحركة (لا فتحة ولا ضمة ولا كسرة) باضطراب سريع في المخرج يعيد الحرف لنصابه بوضوح.',
      examples: [
        TajweedExample(
          ayahSnippet: 'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ',
          targetWord: 'وَتَبَّ',
          surahName: 'المسد',
          ayahNumber: 1,
          explanation: 'قلقلة كبرى لوقوع الباء مشددة وموقوفاً عليها.',
        ),
        TajweedExample(
          ayahSnippet: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          targetWord: 'الْفَلَقِ',
          surahName: 'الفلق',
          ayahNumber: 1,
          explanation: 'قلقلة وسطى لوقوع القاف مخففة موقوفاً عليها بالسكون العارض.',
        ),
        TajweedExample(
          ayahSnippet: 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِي تَضْلِيلٍ',
          targetWord: 'يَجْعَلْ',
          surahName: 'الفيل',
          ayahNumber: 2,
          explanation: 'قلقلة صغرى لوقوع الجيم ساكنة في وسط الكلمة.',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 5. علامات الوقف والضبط بالمصحف الشريف
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'waqf_lazim',
      title: 'علامة الوقف اللازم (مـ)',
      arabicTitle: 'الوقف اللازم (مـ)',
      category: TajweedCategory.waqfMarks,
      summary: 'لزوم الوقف على الكلمة والابتداء بما بعدها حتى لا يختل أو ينقلب المعنى المراد.',
      definition: 'يُرمز له بميم صغيرة أفقية (مـ)، ويدل على وجوب الوقف، لأن وصل الكلام يوهم معنى باطلاً غير مقصود من الآية الكريمة.',
      letters: ['مـ'],
      ruleColor: Color(0xFF5D4037),
      poeticVerse: 'وَبَعْدَ تَجْوِيدِكَ لِلْحُرُوفِ *** لَا بُدَّ مِنْ مَعْرِفَةِ الْوُقُوفِ\nوَالِابْتِدَاءِ وَهْيَ تُقْسَمُ إِذَنْ *** ثَلَاثَةً لَازِمٌ وَجَائِزٌ وَامْتَنَعْ',
      poeticSource: 'المقدمة الجزرية - الإمام ابن الجزري',
      howToPronounce: 'يقف القارئ ويقطع الصوت ويتنفس ثم يبتدئ بالكلمة التي تليها مباشرة.',
      examples: [
        TajweedExample(
          ayahSnippet: 'إِنَّمَا يَسْتَجِيبُ الَّذِينَ يَسْمَعُونَ ۘ وَالْمَوْتَىٰ يَبْعَثُهُمُ اللَّهُ',
          targetWord: 'يَسْمَعُونَ ۘ',
          surahName: 'الأنعام',
          ayahNumber: 36,
          explanation: 'وقف لازم، فلو وُصل لأوهم أن الموتى يشتركون مع الأحياء في الاستجابة.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'waqf_mumtani',
      title: 'علامة الوقف الممنوع (لا)',
      arabicTitle: 'الوقف الممنوع (لا)',
      category: TajweedCategory.waqfMarks,
      summary: 'النهي عن الوقف أو الابتداء بما بعدها لشدة تعلق الكلام معنىً وإعراباً بما بعده.',
      definition: 'تدل علامة (لا) على عدم جواز الوقف، فإن وقف القارئ لضرورة انقطاع النفس وجب عليه إعادة الكلمة والوصل بما بعدها لسلامة المعنى.',
      letters: ['لا'],
      ruleColor: Color(0xFFC62828),
      poeticVerse: 'وَلَيْسَ فِي القُرْآنِ مِنْ وَقْفٍ يَجِبْ *** وَلَا حَرَامٌ غَيْرَ مَا لَهُ سَبَبْ',
      poeticSource: 'المقدمة الجزرية - الإمام ابن الجزري',
      howToPronounce: 'يستمر القارئ في القراءة وصلاً دون توقف عند هذه العلامة.',
      examples: [
        TajweedExample(
          ayahSnippet: 'الَّذِينَ تَتَوَفَّاهُمُ الْمَلَائِكَةُ طَيِّبِينَ ۙ يَقُولُونَ سَلَامٌ عَلَيْكُمُ',
          targetWord: 'طَيِّبِينَ ۙ',
          surahName: 'النحل',
          ayahNumber: 32,
          explanation: 'لا يجوز الوقف على (طيبين) لأن جملة (يقولون سلام عليكم) حال من الملائكة متعلقة بها.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'waqf_jaiz',
      title: 'علامة الوقف الجائز (ج)',
      arabicTitle: 'الوقف الجائز (ج)',
      category: TajweedCategory.waqfMarks,
      summary: 'جواز الوقف والوصل على حد سواء لتكافؤ المعنى بين الوقف والاستمرار.',
      definition: 'علامة الوقف الجائز جوازاً مستوي الطرفين، أي لا رجحان لأحدهما على الآخر، فيجوز للقارئ الوقف ويجوز له الوصل.',
      letters: ['ج'],
      ruleColor: Color(0xFF00695C),
      poeticVerse: 'وَجَائِزٌ لِاسْتِوَاءِ الطَّرَفَيْنْ *** فَقِفْ أَوِ اصِلْ لَا حَرَجَ فِي الاثْنَيْنْ',
      poeticSource: 'أصول الضبط والوقف في التلاوة',
      howToPronounce: 'للقارئ كامل الخيار بين الوقف وأخذ النفس أو المتابعة والوصل.',
      examples: [
        TajweedExample(
          ayahSnippet: 'نَحْنُ نَقُصُّ عَلَيْكَ نَبَأَهُم بِالْحَقِّ ۚ إِنَّهُمْ فِتْيَةٌ آمَنُوا بِرَبِّهِمْ',
          targetWord: 'بِالْحَقِّ ۚ',
          surahName: 'الكهف',
          ayahNumber: 13,
          explanation: 'وقف جائز، يحسن الوقف ويحسن الوصل دون تفضيل.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'waqf_sila_qila',
      title: 'علامتا (صلى) و (قلى)',
      arabicTitle: 'أولوية الوصل (صلى) وأولوية الوقف (قلى)',
      category: TajweedCategory.waqfMarks,
      summary: '(صلى): الوصل أولى مع جواز الوقف، و (قلى): الوقف أولى مع جواز الوصل.',
      definition: 'علامة (صلى) اختصار لـ (الوصل أولى)، أي أن الوصل أتم للمعنى ولكن الوقف مباح. وعلامة (قلى) اختصار لـ (الوقف أولى)، أي أن التوقف هنا أكمل في أداء المعنى الشريف وإن كان الوصل جائزاً.',
      letters: ['صلى', 'قلى'],
      ruleColor: Color(0xFF4527A0),
      poeticVerse: 'صِلْ أَوْلَى بِصِلَى وَقِفْ أَوْلَى بِقَلَى *** وَكُلُّ ذَا فِي مُصْحَفِ الرَّسْمِ انْجَلَى',
      poeticSource: 'قواعد التجويد والرسم العثماني',
      howToPronounce: 'عند (صلى) يفضل المتابعة دون وقوف، وعند (قلى) يفضل الوقف وأخذ النفس مع جواز العكس.',
      examples: [
        TajweedExample(
          ayahSnippet: 'وَإِن يَمْسَسْكَ اللَّهُ بِضُرٍّ فَلَا كَاشِفَ لَهُ إِلَّا هُوَ ۖ وَإِن يَمْسَسْكَ بِخَيْرٍ',
          targetWord: 'إِلَّا هُوَ ۖ',
          surahName: 'الأنعام',
          ayahNumber: 17,
          explanation: 'علامة (صلى): الوصل أولى لارتباط الجملة المعطوفة بالشرط السابق.',
        ),
        TajweedExample(
          ayahSnippet: 'قُل رَّبِّي أَعْلَمُ بِعِدَّتِهِم مَّا يَعْلَمُهُمْ إِلَّا قَلِيلٌ ۗ فَلَا تُمَارِ فِيهِمْ',
          targetWord: 'قَلِيلٌ ۗ',
          surahName: 'الكهف',
          ayahNumber: 22,
          explanation: 'علامة (قلى): الوقف أولى لتمام المعنى قبل استئناف النهي.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'waqf_taanuq',
      title: 'علامة تعانق الوقف (ۛ ۛ)',
      arabicTitle: 'تعانق الوقف (المراقبة)',
      category: TajweedCategory.waqfMarks,
      summary: 'ثلاث نقاط هرمية متكررة: إذا وقف القارئ على الموضع الأول امتنع عن الثاني وعكسه.',
      definition: 'تسمى نقط المراقبة أو تعانق الوقف، تدل على أن الوقف يصح على أحدهما فقط، فإن وقف القارئ على الموضع الأول وجب عليه وصل الثاني دون وقف، وإن لم يقف على الأول جاز له الوقف على الثاني.',
      letters: ['ۛ ۛ'],
      ruleColor: Color(0xFF6A1B9A),
      poeticVerse: 'إِذَا رَأَيْتَ نُقَطَ التَّعَانُقِ *** فَقِفْ عَلَى إِحْدَاهُمَا فِي السَّبْقِ',
      poeticSource: 'إرشاد القراء إلى علامات المصحف',
      howToPronounce: 'اختر أحد الموضعين للوقف عليه فقط واقرأ الآخر موصولاً بحركة تامة.',
      examples: [
        TajweedExample(
          ayahSnippet: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
          targetWord: 'لَا رَيْبَ ۛ فِيهِ ۛ',
          surahName: 'البقرة',
          ayahNumber: 2,
          explanation: 'إن وقفت على (لا ريب) تقرأ (فيه هدى للمتقين)، وإن وقفت على (فيه) تقرأ (ذلك الكتاب لا ريب فيه) ثم (هدى للمتقين).',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 6. أحكام الراء واللام (التفخيم والترقيق)
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'raa_tafkheem_tarqeeq',
      title: 'أحكام الراء (تفخيماً وترقيقاً)',
      arabicTitle: 'تفخيم الراء وترقيقها',
      category: TajweedCategory.raaLaam,
      summary: 'تفخم الراء إذا كانت مفتوحة أو مضمومة أو ساكنة بعد فتح/ضم، وترقق إذا كانت مكسورة أو ساكنة بعد كسر أصلي.',
      definition: 'التفخيم لغة التسمين، واصطلاحاً: سمن يدخل على صوت الحرف يمتلئ الفم بصداه. وتفخم الراء في 8 حالات وترقق في 4 حالات ويجوز الوجهان في حالات خاصة كـ (فِرْقٍ ومِصْرَ وقِطْرَ).',
      letters: ['ر'],
      ruleColor: Color(0xFF1565C0),
      poeticVerse: 'وَرَقِّقِ الرَّاءَ إِذَا مَا كُسِرَتْ *** كَذَاكَ بَعْدَ الْكَسْرِ حَيْثُ سَكَنَتْ\nإِنْ لَمْ تَكُنْ مِنْ قَبْلِ حَرْفِ اسْتِعْلَا *** أَوْ كَانَتِ الكَسْرَةُ لَيْسَتْ أَصْلَا',
      poeticSource: 'المقدمة الجزرية - الإمام ابن الجزري',
      howToPronounce: 'يرتفع أقصى اللسان وتقعر وسطه عند تفخيم الراء، وينخفض اللسان عند ترقيقها بصوت لطيف رقيق.',
      examples: [
        TajweedExample(
          ayahSnippet: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
          targetWord: 'رَبَّنَا',
          surahName: 'البقرة',
          ayahNumber: 201,
          explanation: 'راء مفتوحة حكمها التفخيم وجوباً.',
        ),
        TajweedExample(
          ayahSnippet: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          targetWord: 'الرَّحِيمِ',
          surahName: 'الفاتحة',
          ayahNumber: 1,
          explanation: 'الراء الأولى مفخمة والراء في الرحيم مفخمة وصلاً وترقق إذا كُسرت مثل (رِزْقاً).',
        ),
        TajweedExample(
          ayahSnippet: 'وَفِرْعَوْنَ ذِي الْأَوْتَادِ',
          targetWord: 'وَفِرْعَوْنَ',
          surahName: 'الفجر',
          ayahNumber: 10,
          explanation: 'راء ساكنة قبلها كسر أصلي وليس بعدها حرف استعلاء، حكمها الترقيق قولا واحدا.',
        ),
      ],
    ),
    const TajweedRule(
      id: 'laam_jalalah',
      title: 'لام لفظ الجلالة (اللَّه)',
      arabicTitle: 'لام لفظ الجلالة',
      category: TajweedCategory.raaLaam,
      summary: 'تفخم لام لفظ الجلالة إذا سبقت بفتح أو ضم، وترقق إذا سبقت بكسر.',
      definition: 'الأصل في اللام الترقيق دائماً، لكنها تفخم حصراً في اسم الجلالة (اللَّه) وما يشتق منه (اللهم) إن سبقها فتح أو ضم، وتبقى على أصل ترقيقها إن سبقها كسر.',
      letters: ['ل (في اسم الجلالة)'],
      ruleColor: Color(0xFF0D47A1),
      poeticVerse: 'وَفَخِّمِ اللَّامَ مِنِ اسْمِ اللَّهِ *** عَنْ فَتْحٍ اوْ ضَمٍّ كَعَبْدُ اللَّهِ',
      poeticSource: 'المقدمة الجزرية - الإمام ابن الجزري',
      howToPronounce: 'يمتلئ الفم بصدى اللام المفخمة بعد الفتح والضم (قَالَ اللَّهُ)، ويستفل اللسان عند ترقيقها بعد الكسر (بِاسْمِ اللَّهِ).',
      examples: [
        TajweedExample(
          ayahSnippet: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          targetWord: 'هُوَ اللَّهُ',
          surahName: 'الإخلاص',
          ayahNumber: 1,
          explanation: 'سبقت لام لفظ الجلالة بفتحة على الواو فتفخم اللام وجوباً.',
        ),
        TajweedExample(
          ayahSnippet: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          targetWord: 'بِسْمِ اللَّهِ',
          surahName: 'الفاتحة',
          ayahNumber: 1,
          explanation: 'سبقت لام لفظ الجلالة بكسرة على الميم فترقق اللام رقيقة.',
        ),
      ],
    ),

    // -------------------------------------------------------------
    // 7. مخارج الحروف وصفاتها
    // -------------------------------------------------------------
    const TajweedRule(
      id: 'makhaarij_general',
      title: 'مخارج الحروف العامة الخمسة',
      arabicTitle: 'المخارج العامة للحروف',
      category: TajweedCategory.makhaarij,
      summary: 'المخارج العامة خمسة: الجوف، والحلق، واللسان، والشفتان، والخيشوم، ويتفرع منها 17 مخرجاً خاصاً.',
      definition: 'المخرج هو موضع خروج الحرف وتميزه عن غيره. المخارج الكبرى الخمسة:\n1. الجوف: خلاء الفم والحلق وتخرج منه حروف المد الثلاثة.\n2. الحلق: وفيه أقصى الحلق (ء هـ)، وسط الحلق (ع ح)، أدنى الحلق (غ خ).\n3. اللسان: وفيه 10 مخارج لـ 18 حرفاً.\n4. الشفتان: وفيهما مخرجان لـ 4 أحرف (الفاء، والباء والميم والواو غير المدية).\n5. الخيشوم: التجويف الأنفي ومخرج الغنة.',
      letters: ['جميع الحروف الهجائية'],
      ruleColor: Color(0xFF4A148C),
      poeticVerse: 'مَخَارِجُ الحُرُوفِ سَبْعَةَ عَشَرْ *** عَلَى الَّذِي يَخْتَارُهُ مَنِ اخْتَبَرْ\nفَفَأَلِفُ الجَوْفِ وَأُخْتَاهَا وَهِي *** حُرُوفُ مَدٍّ لِلْهَوَاءِ تَنْتَهِي',
      poeticSource: 'المقدمة الجزرية - الإمام ابن الجزري',
      howToPronounce: 'لمعرفة مخرج أي حرف: سكن الحرف أو شدده وأدخل عليه همزة وصل مصحوبة بحركة واصغِ إليه، فحيث انقطع الصوت فهو مخرجه المحقق.',
      examples: [
        TajweedExample(
          ayahSnippet: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
          targetWord: 'اقْرَأْ',
          surahName: 'العلق',
          ayahNumber: 1,
          explanation: 'القاف من أقصى اللسان مع ما يحاذيه من الحنك الأعلى الرخو.',
        ),
      ],
    ),
  ];

  static final List<TajweedColorGuideItem> _colorGuide = [
    const TajweedColorGuideItem(
      title: 'المد اللازم والمتصل (أحمر داكن / قرمزي)',
      description: 'يمد بمقدار 4 إلى 6 حركات وجوباً ولزوماً.',
      color: Color(0xFFD32F2F),
      durationOrEffect: '4 - 6 حركات',
      rules: ['المد المتصل الواجب', 'المد اللازم الكلمي والحرفي', 'المد العارض عند الإشباع'],
    ),
    const TajweedColorGuideItem(
      title: 'المد الجائز والمنفصل والصلة (برتقالي)',
      description: 'يمد بمقدار حركتين أو 4 أو 5 حركات جوازاً.',
      color: Color(0xFFFB8C00),
      durationOrEffect: '2 - 4 - 5 حركات',
      rules: ['المد المنفصل', 'مد البدل', 'مد الصلة الكبرى', 'مد اللين'],
    ),
    const TajweedColorGuideItem(
      title: 'الغنة والإخفاء والإدغام (أخضر)',
      description: 'إخراج صوت رنان من الخيشوم بمقدار حركتين.',
      color: Color(0xFF2E7D32),
      durationOrEffect: 'حركتان (غنة)',
      rules: ['الإخفاء الحقيقي', 'الإخفاء الشفوي', 'الإدغام بغنة', 'إدغام المتماثلين', 'النون والميم المشددتان'],
    ),
    const TajweedColorGuideItem(
      title: 'الإقلاب (تركواز / أخضر مزرق)',
      description: 'قلب النون الساكنة أو التنوين ميماً مخفاة بغنة حركتين.',
      color: Color(0xFF00796B),
      durationOrEffect: 'حركتان ميم مخفاة',
      rules: ['الإقلاب عند الباء'],
    ),
    const TajweedColorGuideItem(
      title: 'القلقلة (أزرق سماوي)',
      description: 'اضطراب المخرج عند النطق بالحرف الساكن ليسمع له نبرة قوية.',
      color: Color(0xFF1976D2),
      durationOrEffect: 'اضطراب المخرج',
      rules: ['قلقلة قطب جد (كبرى، وسطى، صغرى)'],
    ),
    const TajweedColorGuideItem(
      title: 'التفخيم والراء واللام (كحلي / نيلي)',
      description: 'امتلاء الفم بصدى الحرف المفخم المستعلي.',
      color: Color(0xFF0D47A1),
      durationOrEffect: 'تسمين الحرف',
      rules: ['تفخيم الراء', 'لام لفظ الجلالة المفخمة', 'حروف الاستعلاء (خص ضغط قظ)'],
    ),
    const TajweedColorGuideItem(
      title: 'الحروف الساقطة أو غير المنطوقة (رمادي)',
      description: 'حروف تُكتب في الرسم العثماني ولا تنطق وصلاً أو وقفاً.',
      color: Color(0xFF757575),
      durationOrEffect: 'لا يُلفظ',
      rules: ['همزة الوصل الساقطة', 'اللام الشمسية المدغمة', 'ألفات الصفر المستدير'],
    ),
  ];
}
