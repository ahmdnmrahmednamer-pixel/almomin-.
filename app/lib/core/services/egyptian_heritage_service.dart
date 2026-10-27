import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/egyptian_heritage.dart';
import '../text/arabic_normalizer.dart';

/// Comprehensive Service for Egyptian Islamic Heritage, Cairo Quran Radio,
/// Ibtihalat, Sheikh Al-Sha'rawi Reflections, Historic Mosques, and Dar Al-Ifta Rulings.
class EgyptianHeritageService extends ChangeNotifier {
  static final EgyptianHeritageService instance = EgyptianHeritageService._internal();
  EgyptianHeritageService._internal();

  bool _isInitialized = false;
  final Set<String> _favoriteIds = {};
  String _selectedGoldKarat = '21';

  bool get isInitialized => _isInitialized;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  String get selectedGoldKarat => _selectedGoldKarat;

  List<EgyptianRadioStation> get radioStations => defaultRadioStations;
  List<ShaarawiReflectionItem> get shaarawiReflections => defaultShaarawiReflections;
  List<EgyptianHistoricMosque> get historicMosques => defaultHistoricMosques;
  List<String> get mubtahileenList => ['الكل', ...ibtihalatCatalog.map((e) => e.mubtahilName).toSet()];
  List<EgyptianIbtihalItem> getIbtihalatByMubtahil(String m) =>
      m == 'الكل' ? ibtihalatCatalog : ibtihalatCatalog.where((e) => e.mubtahilName == m).toList();
  List<String> get fatwaCategories => ['الكل', ...darAlIftaFatwas.map((e) => e.category).toSet()];
  List<EgyptianIbtihalItem> get ibtihalat => ibtihalatCatalog;
  List<EgyptianFatwaItem> get darAlIftaRulings => darAlIftaFatwas;

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('egyptian_heritage_favorites') ?? [];
      _favoriteIds
        ..clear()
        ..addAll(favs);
      _selectedGoldKarat = prefs.getString('egyptian_preferred_gold_karat') ?? '21';
    } catch (e) {
      debugPrint('EgyptianHeritageService init error: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('egyptian_heritage_favorites', _favoriteIds.toList());
    } catch (_) {}
    notifyListeners();
  }

  List<String> exportFavorites() => _favoriteIds.toList();

  Future<void> importFavorites(List<String> ids, {bool replace = true}) async {
    if (replace) {
      _favoriteIds.clear();
    }
    _favoriteIds.addAll(ids);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('egyptian_heritage_favorites', _favoriteIds.toList());
    } catch (_) {}
    notifyListeners();
  }

  /// Calculates Haversine distance in kilometers between two coordinates.
  double calculateDistanceKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = (toLat - fromLat) * (pi / 180.0);
    final dLon = (toLng - fromLng) * (pi / 180.0);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(fromLat * (pi / 180.0)) *
            cos(toLat * (pi / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Searches across Ibtihalat, Mosques, Shaarawi Reflections, and Dar Al-Ifta Fatwas.
  List<EgyptianFatwaItem> searchFatwas(String query, {String? category}) {
    final clean = query.trim();
    final normQuery = ArabicNormalizer.normalize(clean, loose: true);
    return darAlIftaFatwas.where((item) {
      if (category != null && category != 'الكل' && item.category != category) {
        return false;
      }
      if (clean.isEmpty) return true;
      final hay = ArabicNormalizer.normalize(
        '${item.title} ${item.questionSummary} ${item.rulingSummary} ${item.detailedEvidence}',
        loose: true,
      );
      return hay.contains(normQuery);
    }).toList();
  }

  List<EgyptianHistoricMosque> searchMosques(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return historicMosques;
    final normQuery = ArabicNormalizer.normalize(clean, loose: true);
    return historicMosques.where((m) {
      final hay = ArabicNormalizer.normalize(
        '${m.name} ${m.cityAndDistrict} ${m.era} ${m.historicalStory} ${m.famousReciters.join(" ")}',
        loose: true,
      );
      return hay.contains(normQuery);
    }).toList();
  }

  List<EgyptianIbtihalItem> searchIbtihalat(String query, {String? mubtahilFilter}) {
    final clean = query.trim();
    final normQuery = ArabicNormalizer.normalize(clean, loose: true);
    return ibtihalatCatalog.where((item) {
      if (mubtahilFilter != null &&
          mubtahilFilter != 'الكل' &&
          !item.mubtahilName.contains(mubtahilFilter) && !ArabicNormalizer.normalize(item.mubtahilName, loose: true).contains(ArabicNormalizer.normalize(mubtahilFilter, loose: true))) {
        return false;
      }
      if (clean.isEmpty) return true;
      final hay = ArabicNormalizer.normalize(
        '${item.title} ${item.mubtahilName} ${item.lyricsExcerpt} ${item.occasionOrMaqam}',
        loose: true,
      );
      return hay.contains(normQuery);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // 1. إذاعة القرآن الكريم من القاهرة والإذاعات المصرية الأصيلة
  // ---------------------------------------------------------------------------
  static const List<EgyptianRadioStation> defaultRadioStations = [
    EgyptianRadioStation(
      id: 'eqr_cairo_main',
      name: 'إذاعة القرآن الكريم من القاهرة',
      subtitle: 'البث المباشر لأعرق إذاعة قرآنية في العالم (تأسست ٢٥ مارس ١٩٦٤م)',
      frequencyOrBadge: '98.2 FM القاهرة',
      streamUrl: 'https://stream.radiojar.com/8s5u5tpdtwzuv',
      fallbackUrls: [
        'https://server13.mp3quran.net/husr/001.mp3',
        'https://server10.mp3quran.net/minsh/001.mp3',
      ],
      icon: Icons.radio_rounded,
      accentColor: Color(0xFF0F5B45),
      dailyScheduleHighlights: [
        '٠٤:٠٠ ص — تواشيح الفجر وتلاوة قرآنية مباركة وأذان الفجر بتوقيت القاهرة',
        '٠٦:١٥ ص — برنامج «طريق الهداية» وحديث الصباح من الأزهر الشريف',
        '٠٧:٠٠ ص — المصحف المرتل لكبار قراء دولة التلاوة المصرية',
        '٠٩:٣٠ ص — برنامج «بريد الإسلام» للإجابة عن فتاوى المستمعين',
        '٠١:٠٠ م — خواطر فضيلة الإمام محمد متولي الشعراوي حول آيات الذكر الحكيم',
        '٠٥:٠٠ م — برنامج «المصحف المعلم» للشيخ محمود خليل الحصري',
        '٠٨:٣٠ م — برنامج «في ظلال الهدي النبوي» و«قطوف من حدائق الإيمان»',
        '١١:٠٠ م — سهرة قرآنية خاشعة من التسجيلات الخارجية النادرة بمساجد مصر',
      ],
    ),
    EgyptianRadioStation(
      id: 'radio_egypt_minshawi',
      name: 'أثير الشيخ محمد صديق المنشاوي',
      subtitle: 'الصوت الباكي الخاشع — تلاوات مرتلة ومجودة من تراث الإذاعة المصرية',
      frequencyOrBadge: 'تراث الإذاعة',
      streamUrl: 'https://server10.mp3quran.net/minsh/018.mp3',
      fallbackUrls: ['https://server10.mp3quran.net/minsh/036.mp3'],
      icon: Icons.podcasts_rounded,
      accentColor: Color(0xFFB8893A),
      dailyScheduleHighlights: [
        'تلاوات المصحف المرتل كاملًا برواية حفص عن عاصم',
        'روائع التلاوات المجودة من مساجد القاهرة وسوهاج والمسجد الأقصى',
      ],
    ),
    EgyptianRadioStation(
      id: 'radio_egypt_husary',
      name: 'أثير الشيخ محمود خليل الحصري',
      subtitle: 'شيخ عموم المقارئ المصرية وأول من سجل المصحف المرتل في التاريخ',
      frequencyOrBadge: 'المصحف المعلم',
      streamUrl: 'https://server13.mp3quran.net/husr/002.mp3',
      fallbackUrls: ['https://server13.mp3quran.net/husr/001.mp3'],
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF1E6F5C),
      dailyScheduleHighlights: [
        'الضبط التجويدي الدقيق والوقف والابتداء المعتمد بالأزهر الشريف',
      ],
    ),
    EgyptianRadioStation(
      id: 'radio_egypt_abdulbasit',
      name: 'أثير الشيخ عبد الباسط عبد الصمد',
      subtitle: 'صوت مكة والحنجرة الذهبية — روائع التلاوات المصرية الخالدة',
      frequencyOrBadge: 'الحنجرة الذهبية',
      streamUrl: 'https://server7.mp3quran.net/basit/019.mp3',
      fallbackUrls: ['https://server7.mp3quran.net/basit/001.mp3'],
      icon: Icons.mic_external_on_rounded,
      accentColor: Color(0xFF8B6508),
      dailyScheduleHighlights: [
        'تلاوات المسجد الحرام ومسجد الإمام الشافعي ومسجد الحسين بالقاهرة',
      ],
    ),
    EgyptianRadioStation(
      id: 'radio_egypt_mustafa_ismail',
      name: 'أثير الشيخ مصطفى إسماعيل',
      subtitle: 'عبقري النغم القرآني وقارئ القصر والجامع الأزهر الشريف',
      frequencyOrBadge: 'مدرسة المقامات',
      streamUrl: 'https://server8.mp3quran.net/mustafa/019.mp3',
      fallbackUrls: ['https://server8.mp3quran.net/mustafa/001.mp3'],
      icon: Icons.graphic_eq_rounded,
      accentColor: Color(0xFF2C5E43),
      dailyScheduleHighlights: [
        'تلاوات خالدة تجمع بين جلال المعنى وإعجاز التصوير الصوتي للآيات',
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // 2. ديوان الابتهالات والتواشيح المصرية الأصيلة (النقشبندي، طوبار، عمران، الفشني)
  // ---------------------------------------------------------------------------
  static const List<EgyptianIbtihalItem> ibtihalatCatalog = [
    EgyptianIbtihalItem(
      id: 'ibtihal_naqshbandi_mawlay',
      title: 'مولاي إني ببابك قد بسطت يدي',
      mubtahilName: 'الشيخ سيد النقشبندي',
      mubtahilTitle: 'إمام المداحين وأستاذ الابتهالات (١٩٢٠ - ١٩٧٦م)',
      occasionOrMaqam: 'ابتهال السحر ورمضان • مقام بياتي وصبا',
      duration: '٠٧:١٥',
      audioUrl: 'https://archive.org/download/Athan_Mawsoa_mp3/034.mp3',
      fallbackUrls: ['https://server10.mp3quran.net/minsh/001.mp3'],
      lyricsExcerpt:
          'مَوْلَايَ إِنِّي بِبَابِكَ قَدْ بَسَطْتُ يَدِي * مَنْ لِي أَلُوذُ بِهِ إِلَّاكَ يَا سَنَدِي\n'
          'أَقُومُ بِاللَّيْلِ وَالأَسْحَارُ سَاجِيَةٌ * أَدْعُو وَهَمْسُ دُعَائِي بِالدُّمُوعِ نَدِي\n'
          'بِنُورِ وَجْهِكَ إِنِّي عَائِذٌ وَجِلٌ * وَمِنْ يَعُذْ بِكَ لَنْ يَشْقَى إِلَى الأَبَدِ',
      spiritualNote:
          'من أشهر الابتهالات المصرية التي ارتبطت بوجدان المصريين قبل أذان المغرب وأذان الفجر في شهر رمضان المبارك.',
    ),
    EgyptianIbtihalItem(
      id: 'ibtihal_tobar_ya_malik_almulk',
      title: 'يا مالك الملك يا من في البرية متصرف',
      mubtahilName: 'الشيخ نصر الدين طوبار',
      mubtahilTitle: 'كروان الإنشاد الديني وقائد فرقة الإنشاد بالأزهر (١٩٢٠ - ١٩٨٦م)',
      occasionOrMaqam: 'مناجاة الفجر والأسحار • مقام راست وحجاز',
      duration: '٠٦:٤٠',
      audioUrl: 'https://archive.org/download/Athan_Mawsoa_mp3/036.mp3',
      fallbackUrls: ['https://server13.mp3quran.net/husr/001.mp3'],
      lyricsExcerpt:
          'يَا مَالِكَ المُلْكِ يَا مَنْ فِي البَرِيَّةِ مُتَصَرِّفٌ * يَا عَالِمَ السِّرِّ وَالنَّجْوَى لِمَنْ يَقِفُ\n'
          'إِلَيْكَ يَا رَبِّ مَدَّ العَبْدُ رَاحَتَهُ * يَرْجُو رِضَاكَ وَدَمْعُ العَيْنِ يَنْذَرِفُ',
      spiritualNote:
          'تُعد مدرسة الشيخ نصر الدين طوبار (ابن محافظة الدقهلية) قمة في الخشوع والتضرع الصادق بإذاعة القرآن الكريم.',
    ),
    EgyptianIbtihalItem(
      id: 'ibtihal_tobar_jalla_almunadi',
      title: 'جلّ المنادي ينادي يا عبادي',
      mubtahilName: 'الشيخ نصر الدين طوبار',
      mubtahilTitle: 'كروان الإنشاد الديني ومبتهل مسجد الخازندار بشبرا',
      occasionOrMaqam: 'ابتهال الثلث الأخير من الليل • مقام صبا شجي',
      duration: '٠٨:١٠',
      audioUrl: 'https://archive.org/download/Athan_Mawsoa_mp3/007.mp3',
      fallbackUrls: ['https://server10.mp3quran.net/minsh/001.mp3'],
      lyricsExcerpt:
          'جَلَّ المُنَادِي يُنَادِي: يَا عِبَادِي أَنَا الغَفُورُ الرَّحِيمُ * هَلْ مِنْ تَائِبٍ فَأَتُوبَ عَلَيْهِ؟\n'
          'وَقَفْتُ بِبَابِكَ يَا خَالِقِي * أُقِرُّ بِذَنْبِي وَأَرْجُو الهُدَى',
      spiritualNote:
          'يجسّد هذا الابتهال حديث التنزل الإلهي في الثلث الأخير من الليل بأداء مصري خاشع يمس شغاف القلوب.',
    ),
    EgyptianIbtihalItem(
      id: 'ibtihal_omran_ya_sayyid_alkawnayn',
      title: 'ابتهالات السحر وأسماء الله الحسنى',
      mubtahilName: 'الشيخ محمد عمران',
      mubtahilTitle: 'سلطان المبتهلين وعبقري النغم الديني المصري (١٩٤٤ - ١٩٩٤م)',
      occasionOrMaqam: 'تواشيح الفجر بإذاعة القاهرة • مقام نهاوند وبياتي',
      duration: '٠٥:٥٠',
      audioUrl: 'https://archive.org/download/Athan_Mawsoa_mp3/035.mp3',
      fallbackUrls: ['https://server13.mp3quran.net/husr/001.mp3'],
      lyricsExcerpt:
          'يَا رَبِّ إِنْ عَظُمَتْ ذُنُوبِي كَثْرَةً * فَلَقَدْ عَلِمْتُ بِأَنَّ عَفْوَكَ أَعْظَمُ\n'
          'إِنْ كَانَ لَا يَرْجُوكَ إِلَّا مُحْسِنٌ * فَبِمَنْ يَلُوذُ وَيَسْتَجِيرُ المُجْرِمُ',
      spiritualNote:
          'جمع الشيخ محمد عمران بين إتقان القراءات القرآنية وبراعة الابتهال والمدائح النبوية الأصيلة.',
    ),
    EgyptianIbtihalItem(
      id: 'ibtihal_fashni_ya_ayyuha_almukhtar',
      title: 'يا أيها المختار من خير الورى',
      mubtahilName: 'الشيخ طه الفشني',
      mubtahilTitle: 'عميد المنشدين وقارئ جامع الإمام الحسين (١٩٠٠ - ١٩٧١م)',
      occasionOrMaqam: 'المديح النبوي الشريف • مدرسة الصعيد والفيوم وبني سويف',
      duration: '٠٦:٢٥',
      audioUrl: 'https://archive.org/download/Athan_Mawsoa_mp3/012.mp3',
      fallbackUrls: ['https://server10.mp3quran.net/minsh/001.mp3'],
      lyricsExcerpt:
          'يَا أَيُّهَا المُخْتَارُ مِنْ خَيْرِ الوَرَى * خُلُقاً وَخَلْقاً فِي الكَمَالِ تَوَحَّدَا\n'
          'مَاذَا أَقُولُ فِي مَدْحِ طَهَ المُجْتَبَى * وَاللَّهُ فِي القُرْآنِ عَظَّمَ أَحْمَدَا',
      spiritualNote:
          'من روائع مدرسة الفشن بمحافظة بني سويف التي أرست دعائم التواشيح الدينية في الإذاعة المصرية.',
    ),
    EgyptianIbtihalItem(
      id: 'ibtihal_naqshbandi_aghibu',
      title: 'أغيب وذو اللطف لا يغيب',
      mubtahilName: 'الشيخ سيد النقشبندي',
      mubtahilTitle: 'قيثارة السماء ومبتهل مسجد السيد البدوي بطنطا',
      occasionOrMaqam: 'ابتهال التوكل واليقين • مقام سيكاه وحجاز',
      duration: '٠٥:٤٥',
      audioUrl: 'https://archive.org/download/Athan_Mawsoa_mp3/001.mp3',
      fallbackUrls: ['https://server13.mp3quran.net/husr/001.mp3'],
      lyricsExcerpt:
          'أَغِيبُ وَذُو اللُّطْفِ لَا يَغِيبُ * وَأَرْجُوهُ رَجَاءً لَا يَخِيبُ\n'
          'وَأَسْأَلُهُ السَّلَامَةَ مِنْ زَمَانٍ * بُلِيتُ بِهِ نَوَائِبُهُ تَشِيبُ',
      spiritualNote:
          'من أروع ابتهالات اليقين والرضا بقضاء الله التي سُجلت في استوديوهات ماسبيرو بالقاهرة.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // 3. واحة إمام الدعاة الشيخ محمد متولي الشعراوي رحمه الله (أدعية وخواطر إيمانية)
  // ---------------------------------------------------------------------------
  static const List<ShaarawiReflectionItem> defaultShaarawiReflections = [
    ShaarawiReflectionItem(
      id: 'shaarawi_duaa_adhan',
      title: 'دعاء الشيخ الشعراوي الشهير عقب الأذان والصلاة',
      category: 'أدعية مأثورة',
      surahOrTopic: 'دعاء الوسيلة والشفاء والقبول',
      arabicText:
          '«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ سَيِّدَنَا مُحَمَّدًا الوَسِيلَةَ وَالفَضِيلَةَ، وَالدَّرَجَةَ الرَّفِيعَةَ العَالِيَةَ، وَابْعَثْهُ اللَّهُمَّ المَقَامَ المَحْمُودَ الَّذِي وَعَدْتَهُ، إِنَّكَ لَا تُخْلِفُ المِيعَادَ.. وَصَلِّ اللَّهُمَّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ وَصَحْبِهِ وَسَلِّمْ»',
      summaryInsight:
          'الدعاء التاريخي الذي يذاع يومياً في إذاعة القرآن الكريم والتلفزيون المصري عقب كل أذان بصوت إمام الدعاة.',
      audioTrackId: 'duaa_sharawi_post_prayer',
    ),
    ShaarawiReflectionItem(
      id: 'shaarawi_duaa_khatm_salat',
      title: 'مناجاة الشيخ الشعراوي: «اللهم إني أعلم أني عاصيك...»',
      category: 'مناجاة وابتهال',
      surahOrTopic: 'مناجاة العبودية والافتقار إلى الله',
      arabicText:
          '«اللَّهُمَّ إِنَّكَ تَعْلَمُ أَنِّي عَلَى إِسَاءَتِي وَظُلْمِي وَإِسْرَافِي عَلَى نَفْسِي لَمْ أَجْعَلْ لَكَ وَلَداً وَلَا نِدّاً وَلَا صَاحِبَةً وَلَا كُفُواً أَحَداً؛ فَإِنْ تُعَذِّبْ فَعَبْدُكَ، وَإِنْ تَغْفِرْ فَإِنَّكَ أَنْتَ العَزِيزُ الحَكِيمُ.\n'
          'اللَّهُمَّ إِنِّي أَطَعْتُكَ فِي أَحَبِّ الأَشْيَاءِ إِلَيْكَ وَهُوَ التَّوْحِيدُ، وَلَمْ أَعْصِكَ فِي أَبْغَضِ الأَشْيَاءِ إِلَيْكَ وَهُوَ الكُفْرُ؛ فَاغْفِرْ لِي مَا بَيْنَهُمَا يَا أَرْحَمَ الرَّاحِمِينَ»',
      summaryInsight:
          'من أعمق أدعية الشيخ الشعراوي التي تجمع بين التوسل بتوحيد الله والاعتراف بالتقصير البشري.',
      audioTrackId: 'duaa_sharawi_post_prayer',
    ),
    ShaarawiReflectionItem(
      id: 'shaarawi_khawatir_fatihah',
      title: 'خاطرة في أسرار (الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ)',
      category: 'خواطر قرآنية',
      surahOrTopic: 'سورة الفاتحة • أم الكتاب',
      arabicText:
          '«الحق سبحانه وتعالى حين علّمنا كيف نحمده قال: (الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ)؛ فجعل صيغة الحمد بالجملة الاسمية الدالة على الثبات والدوام، فالحمد ثابت لله أزلاً وأبداً قبل أن يخلق الحامدين، والربوبية عطاء إيجادٍ وعطاء إمدادٍ لا ينقطع لحظة واحدة»',
      summaryInsight:
          'الفرق بين نعمة الإيجاد (الخلق من العدم) ونعمة الإمداد (استمرار القيومية والرزق والحفظ) في تفسير الفاتحة.',
      remoteAudioUrl:
          'https://archive.org/download/Khwater.El-Sharawy.Fi.Tafsir.EL-Quran-Karim-Up-By-mUSLEm/001_Al-Fatihah.mp3',
    ),
    ShaarawiReflectionItem(
      id: 'shaarawi_khawatir_rizq',
      title: 'خاطرة حول الرزق واليقين: (وَفِي السَّمَاءِ رِزْقُكُمْ)',
      category: 'خواطر قرآنية',
      surahOrTopic: 'سورة الذاريات • آية ٢٢',
      arabicText:
          '«لا تشغل بالك بما ضُمِن لك، ولكن اشغل بالك بما طُلِب منك؛ فالرزق مضمونٌ ومقسومٌ بأمر الله، والسعي حركةٌ في الحياة طاعةً لله لاجلباً للرزق بذاته، ومن رضي بقسمة الله بارك الله له في القليل حتى يفيض»',
      summaryInsight:
          'قاعدة إيمانية راسخة قررها الشيخ الشعراوي لطمأنينة القلب في طلب المعاش مع الأخذ بالأسباب المشروعة.',
    ),
    ShaarawiReflectionItem(
      id: 'shaarawi_khawatir_egypt',
      title: 'مكانة مصر في القرآن الكريم: (ادْخُلُوا مِصْرَ إِن شَاءَ اللَّهُ آمِنِينَ)',
      category: 'لطائف قرآنية',
      surahOrTopic: 'سورة يوسف: ٩٩ • سورة الزخرف: ٥١',
      arabicText:
          '«ذُكرت مصر في القرآن الكريم تصريحاً وتلويحاً في عشرات المواضع، واقترن اسمها بالأمن والأمان والخزائن والكرم؛ فهي كنانة الله في أرضه، وموئل الأزهر الشريف الذي حفظ الله به علوم العربية والقرآن على مر القرون»',
      summaryInsight:
          'استنباط قرآني بديع حول اقتران ذكر مصر بالأمان والرحمة والبركة في كتاب الله العزيز.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // 4. دليل المساجد التاريخية الكبرى والمعالم الإسلامية في مصر
  // ---------------------------------------------------------------------------
  static const List<EgyptianHistoricMosque> defaultHistoricMosques = [
    EgyptianHistoricMosque(
      id: 'mosque_al_azhar',
      name: 'الجامع الأزهر الشريف',
      cityAndDistrict: 'القاهرة التاريخية — الدراسة',
      foundedYear: '٣٥٩ هـ / ٩٧٠ م (أكثر من ١٠٥٠ عاماً)',
      era: 'العصر الفاطمي والأيوبي والمملوكي والحديث',
      latitude: 30.0457,
      longitude: 31.2627,
      architecturalHighlight: 'الصحن الرخامي الفسيح والمآذن الخمس التاريخية والأروقة العلمية الـ ٢٨',
      historicalStory:
          'أعرق جامعة إسلامية في العالم ومنارة العلم الوسطي وحافظ التراث القرآني واللغوي. تخرّج في أروقته كبار أئمة التفسير والحديث والقراءات في العالم الإسلامي.',
      famousReciters: ['الشيخ مصطفى إسماعيل', 'الشيخ محمود خليل الحصري', 'الشيخ عبد الفتاح الشعشاعي', 'د. أحمد نعينع'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_amr_ibn_alaas',
      name: 'جامع عمرو بن العاص (تاج الجوامع)',
      cityAndDistrict: 'مصر القديمة — الفسطاط، القاهرة',
      foundedYear: '٢١ هـ / ٦٤١ م',
      era: 'عصر الفتح الإسلامي الراشدي',
      latitude: 30.0101,
      longitude: 31.2331,
      architecturalHighlight: 'أول مسجد بُني في مصر وقارة أفريقيا بأكملها، وأصل المدرسة المصرية في الإقراء',
      historicalStory:
          'أسسه الصحابي الجليل عمرو بن العاص رضي الله عنه بمشاركة جمع من الصحابة الكرام، وفيه درّس الإمام الشافعي والليث بن سعد رحمهما الله.',
      famousReciters: ['الشيخ محمد جبريل', 'الشيخ محمد صديق المنشاوي', 'الشيخ كامل يوسف البهتيمي'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_al_hussein',
      name: 'مسجد الإمام الحسين بن علي رضي الله عنه',
      cityAndDistrict: 'حي الجمالية وخان الخليلي — القاهرة',
      foundedYear: '٥٤٩ هـ / ١١٥٤ م',
      era: 'العصر الفاطمي والعباسي والحديث',
      latitude: 30.0478,
      longitude: 31.2630,
      architecturalHighlight: 'الأبواب الرخامية والمئذنة المملوكية الدقيقة وقاعة الآثار النبوية الشريفة',
      historicalStory:
          'قلب القاهرة الروحاني ومقصد المصلين وطلاب العلم، شهد أعظم المحافل القرآنية وتلاوات الفجر والجمعة لكبار قراء مصر.',
      famousReciters: ['الشيخ محمود علي البنا', 'الشيخ طه الفشني', 'الشيخ عبد الباسط عبد الصمد', 'الشيخ أحمد نعينع'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_sayyida_zainab',
      name: 'مسجد السيدة زينب رضي الله عنها',
      cityAndDistrict: 'ميدان السيدة زينب — القاهرة',
      foundedYear: '٢٤٠ هـ / ٨٥٤ م (وتجدد عبر العصور)',
      era: 'العصر العباسي والمملوكي والحديث',
      latitude: 30.0318,
      longitude: 31.2422,
      architecturalHighlight: 'الواجهة الحجرية المزخرفة بالخط الكوفي والثلث والقباب الرشيقة',
      historicalStory:
          'من أشهر مساجد القاهرة التي ارتبطت بمدرسة التلاوة المصرية الأصيلة؛ حيث كان الشيخ محمد رفعت والشيخ مصطفى إسماعيل يقرآن فيه سورة الكهف يوم الجمعة.',
      famousReciters: ['الشيخ محمد رفعت', 'الشيخ أبو العينين شعيشع', 'الشيخ محمد الصيفي'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_misr_new_capital',
      name: 'مسجد مصر الكبير ومركز مصر الثقافي الإسلامي',
      cityAndDistrict: 'العاصمة الإدارية الجديدة — شرق القاهرة',
      foundedYear: '١٤٤٤ هـ / ٢٠٢٣ م',
      era: 'العمارة الإسلامية المصرية المعاصرة',
      latitude: 30.0119,
      longitude: 31.7458,
      architecturalHighlight: 'أحد أكبر المساجد في العالم (يسع أكثر من ١٠٠ ألف مصلٍ) ومئذنتان بارتفاع ١٤٠ متراً',
      historicalStory:
          'صرح معماري وإيماني عظيم يقع على هضبة العاصمة الإدارية الجديدة، يضم داراً للقرآن الكريم تحتوي على ٣٠ قاعة لتحفيظ القرآن الكريم.',
      famousReciters: ['كبار قراء الإذاعة والتلفزيون المصري'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_sultan_hassan',
      name: 'مسجد ومدرسة السلطان حسن',
      cityAndDistrict: 'ميدان صلاح الدين بالقلعة — القاهرة',
      foundedYear: '٧٥٧ هـ / ١٣٥٦ م',
      era: 'العصر المملوكي البحري',
      latitude: 30.0317,
      longitude: 31.2564,
      architecturalHighlight: 'درة العمارة الإسلامية في العالم؛ يضم ٤ إيوانات كبرى لمدارس الفقه الأربعة',
      historicalStory:
          'وصفه المؤرخ المقريزي بأنه «لا يُعرف في بلاد الإسلام معبد من معابد المسلمين يحاكي هذا الجامع» لعظمة بنائه وارتفاع إيوان القبلة فيه.',
      famousReciters: ['الشيخ محمد عمران', 'الشيخ راغب مصطفى غلوش'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_al_rifai',
      name: 'مسجد الرفاعي العامر',
      cityAndDistrict: 'ميدان القلعة — القاهرة',
      foundedYear: '١٣٢٩ هـ / ١٩١٢ م',
      era: 'العصر الحديث (القرن العشرين)',
      latitude: 30.0326,
      longitude: 31.2570,
      architecturalHighlight: 'الأسقف المذهبة والأعمدة الرخامية الشاهقة والمقرنصات الملونة الدقيقة',
      historicalStory:
          'شقيق مسجد السلطان حسن المقابل له، وارتبطت به تلاوات الجمعة الخالدة للشيخ أبي العينين شعيشع وأذان الشيخ محمود الطوخي.',
      famousReciters: ['الشيخ أبو العينين شعيشع', 'الشيخ محمود الطوخي'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_ibn_tulun',
      name: 'مسجد أحمد بن طولون',
      cityAndDistrict: 'جبل يشكر — السيدة زينب، القاهرة',
      foundedYear: '٢٦٥ هـ / ٨٧٩ م',
      era: 'العصر الطولوني',
      latitude: 30.0287,
      longitude: 31.2494,
      architecturalHighlight: 'المئذنة الملوية الفريدة ذات السلم الحجري الخارجي وثالث أكبر مسجد تاريخي بمصر',
      historicalStory:
          'أقدم مسجد في مصر احتفظ بتخطيطه وزخارفه الجصية الأصلية كاملة منذ أكثر من ١١٥٠ عاماً دون تغيير.',
      famousReciters: ['الشيخ علي محمود', 'الشيخ كامل يوسف البهتيمي'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_imam_shafii',
      name: 'مسجد الإمام الشافعي رضي الله عنه',
      cityAndDistrict: 'حي الإمام الشافعي — القاهرة',
      foundedYear: '٦٠٨ هـ / ١٢١١ م',
      era: 'العصر الأيوبي والحديث',
      latitude: 30.0114,
      longitude: 31.2536,
      architecturalHighlight: 'القبة الخشبية الأيوبية الفريدة والمنبر المطعم بالعاج والأبنوس',
      historicalStory:
          'يحتضن مرقد فقيه الأمة وناصر السنة الإمام محمد بن إدريس الشافعي رضي الله عنه الذي أرسى مذهبه الجديد في مصر، وكان الشيخ عبد الباسط عبد الصمد قارئاً للسورة فيه.',
      famousReciters: ['الشيخ عبد الباسط عبد الصمد', 'الشيخ محمد رفعت'],
    ),
    EgyptianHistoricMosque(
      id: 'mosque_morsi_abu_el_abbas',
      name: 'مسجد المرسي أبو العباس',
      cityAndDistrict: 'حي الجمرك (بحري) — الإسكندرية',
      foundedYear: '٧٠٦ هـ / ١٣٠٧ م (وتجدد ١٩٤٣ م)',
      era: 'العصر المملوكي والحديث',
      latitude: 31.2056,
      longitude: 29.8825,
      architecturalHighlight: 'الأضلاع الثمانية والقباب الأربع الشامخة والمئذنة المطلة على الميناء الشرقي',
      historicalStory:
          'أشهر وأكبر مساجد محافظة الإسكندرية وعروس البحر المتوسط، ومعلم معماري إسلامي فريد على ساحل البحر الأبيض المتوسط.',
      famousReciters: ['الشيخ عبد الفتاح الشعشاعي', 'الشيخ الشحات محمد أنور'],
    ),
  ];

  // ---------------------------------------------------------------------------
  // 5. ركن فتاوى دار الإفتاء المصرية والأزهر الشريف (للمستخدم المصري)
  // ---------------------------------------------------------------------------
  static const List<EgyptianFatwaItem> darAlIftaFatwas = [
    EgyptianFatwaItem(
      id: 'fatwa_bank_certificates_zakat',
      title: 'حكم أرباح شهادات الاستثمار والودائع البنكية في مصر وكيفية زكاتها',
      category: 'الزكاة والمعاملات',
      questionSummary: 'ما حكم أرباح شهادات الاستثمار وحسابات التوفير في البنوك المصرية، وكيف تُخرج زكاتها؟',
      rulingSummary:
          'قررت دار الإفتاء المصرية ومجمع البحوث الإسلامية بالأزهر الشريف أن معاملات البنوك وشهادات الاستثمار من عقود التمويل المستحدثة الجائزة شرعاً وأرباحها حلال.',
      detailedEvidence:
          '• بالنسبة للزكاة: إذا كانت الشهادة أو الوديعة يُتعيش من عائدها الشهري للنفقة الضرورية، فتُخرج الزكاة بنسبة ١٠٪ من العائد (الصافي) فور قبضه قياساً على الأراضي الزراعية، أو ٢.٥٪ من أصل المال وعائده كل حول هجري إن كان المال فائضاً عن الحاجة وبلغ نصاب ٨٥ جراماً من الذهب عيار ٢١.',
      issuingAuthority: 'دار الإفتاء المصرية ومجمع البحوث الإسلامية بالأزهر الشريف',
    ),
    EgyptianFatwaItem(
      id: 'fatwa_gold_jewelry_shabka',
      title: 'حكم زكاة الذهب الملبوس للزينة (الشبكة والحلي) للمرأة المصرية',
      category: 'الزكاة والمعاملات',
      questionSummary: 'هل تجب الزكاة في الذهب الذي تقتنيه المرأة المصرية للزينة المعتادة (الشبكة والمصوغات)؟',
      rulingSummary:
          'الفتوى المعتمدة في دار الإفتاء المصرية ومذهب الشافعية والمالكية والحنابلة أنه لا زكاة في حلي المرأة المتخذ للزينة المباحة ما دام في حدود المعتاد عرفاً.',
      detailedEvidence:
          '• أما إذا كان الذهب (سواء سبائك عيار ٢٤ أو جنيهات ذهب عيار ٢١ أو كسر ذهب) مُقتنى بقصد الادخار وحفظ القيمة أو التجارة، وبلغ وزنه الصافي ما يعادل ٨٥ جراماً وحال عليه الحول الهجري، فتجب فيه الزكاة بنسبة ٢.٥٪ (ربع العشر).',
      issuingAuthority: 'دار الإفتاء المصرية — أمانة الفتوى',
    ),
    EgyptianFatwaItem(
      id: 'fatwa_egypt_prayer_angles',
      title: 'اعتماد مواقيت الهيئة المصرية العامة للمساحة (الفجر 19.5° والعشاء 17.5°)',
      category: 'الصلاة والمواقيت',
      questionSummary: 'ما مدى دقة مواقيت الفجر والعشاء في النتيجة المصرية الرسمية المعمول بها في مساجد مصر؟',
      rulingSummary:
          'أكدت دار الإفتاء المصرية وهيئة كبار العلماء بالأزهر أن مواقيت الهيئة المصرية العامة للمساحة (زاوية الفجر ١٩.٥° تحت الأفق وزاوية العشاء ١٧.٥°) هي المواقيت الشرعية الصحيحة المستقرة علمياً وفلكياً في مصر.',
      detailedEvidence:
          '• هذه المواقيت مبنية على أرصاد فلكية وبصرية دقيقة في صحراء مصر ووادي النيل منذ أكثر من قرن، ولا يجوز الالتفات إلى التشكيك في وقت أذان الفجر في مساجد مصر.',
      issuingAuthority: 'دار الإفتاء المصرية والهيئة المصرية العامة للمساحة',
    ),
    EgyptianFatwaItem(
      id: 'fatwa_egypt_travel_qasr',
      title: 'مسافة القصر والجمع في السفر بين محافظات مصر',
      category: 'الصلاة والمواقيت',
      questionSummary: 'متى يجوز للمسافر بين محافظات مصر (مثل القاهرة والإسكندرية أو الصعيد) قصر وجمع الصلاة؟',
      rulingSummary:
          'يجوز قصر الصلاة الرباعية (الظهر والعصر والعشاء) ركعتين وجمعها إذا بلغت مسافة السفر نحو ٨٣.٥ كيلومتراً فأكثر بعد مجاوزة عمران المدينة أو المحافظة.',
      detailedEvidence:
          '• السفر من القاهرة إلى الإسكندرية (٢٢٠ كم)، أو السخنة (١٢٠ كم)، أو المنصورة (١٢٥ كم)، أو محافظات الصعيد يبيح القصر والجمع بمجرد الخروج من البنيان العمراني ما لم ينوِ الإقامة أربعة أيام فأكثر غير يومي الدخول والخروج.',
      issuingAuthority: 'لجنة الفتوى بالأزهر الشريف ودار الإفتاء المصرية',
    ),
    EgyptianFatwaItem(
      id: 'fatwa_zakat_alfitr_egypt',
      title: 'إخراج زكاة الفطر نقداً بالجنيه المصري ومصارفها',
      category: 'الصيام ورمضان',
      questionSummary: 'هل يجوز إخراج زكاة الفطر وفدية الصيام نقداً بالجنيه المصري بدلاً من الحبوب؟',
      rulingSummary:
          'تفتي دار الإفتاء المصرية بجواز وأفضلية إخراج زكاة الفطر نقداً بالجنيه المصري؛ لأنه أنفع للفقير وأيسر لقضاء حاجاته في العصر الحاضر، وهو مذهب الإمام أبي حنيفة وجمع من الصحابة والتابعين.',
      detailedEvidence:
          '• تحدد دار الإفتاء المصرية ومجمع البحوث الإسلامية كل عام الحد الأدنى لزكاة الفطر وفدية الصيام عن كل فرد بمراعاة سعر القمح السائد في مصر، مع استحباب الزيادة لمن وسّع الله عليه.',
      issuingAuthority: 'دار الإفتاء المصرية',
    ),
  ];
}
