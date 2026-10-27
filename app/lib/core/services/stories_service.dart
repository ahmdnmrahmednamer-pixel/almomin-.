import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prophet_story.dart';
import '../text/arabic_normalizer.dart';

/// Comprehensive Audio Service for Prophet Stories (قصص الأنبياء الصوتية)
/// Manages streaming audio links, local downloads, offline playback, and favorites.
class StoriesService extends ChangeNotifier {
  static final StoriesService instance = StoriesService._internal();
  StoriesService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(minutes: 15),
  ));

  bool _isInitialized = false;
  final Set<String> _favoriteIds = {};
  final Map<String, String> _downloadedLocalPaths = {};
  final Map<String, int> _downloadedFileSizes = {};
  final Map<String, double> _activeProgress = {};
  final Map<String, CancelToken> _cancelTokens = {};
  String? _lastReadStoryId;
  String? _storageDirPath;

  bool get isInitialized => _isInitialized;
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  String? get lastReadStoryId => _lastReadStoryId;
  int get totalStoriesCount => _storiesData.length;

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('stories_favorites') ?? [];
      _favoriteIds..clear()..addAll(favList);
      _lastReadStoryId = prefs.getString('stories_last_read');

      final dir = await _getStoriesDirectory();
      _storageDirPath = dir.path;
      await _scanStorageDirectory(dir);
    } catch (e) {
      debugPrint('StoriesService init error: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<Directory> _getStoriesDirectory() async {
    if (kIsWeb) {
      return Directory('/web_stories');
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final storiesDir = Directory('${appDocDir.path}/prophet_stories');
    if (!await storiesDir.exists()) {
      await storiesDir.create(recursive: true);
    }
    return storiesDir;
  }

  Future<void> _scanStorageDirectory(Directory dir) async {
    _downloadedLocalPaths.clear();
    _downloadedFileSizes.clear();
    if (!await dir.exists()) return;

    final entities = dir.listSync();
    for (final entity in entities) {
      if (entity is File && (entity.path.endsWith('.tmp') || entity.path.endsWith('.part'))) {
        try {
          entity.deleteSync();
        } catch (_) {}
        continue;
      }
      if (entity is File && entity.path.endsWith('.mp3')) {
        final nonEmptySegs = entity.uri.pathSegments.where((s) => s.isNotEmpty);
          if (nonEmptySegs.isEmpty) continue;
          final filename = nonEmptySegs.last;
        final id = filename.replaceAll('.mp3', '');
        if (_storiesData.any((s) => s.id == id)) {
          final size = entity.lengthSync();
          if (size > 1000) {
            _downloadedLocalPaths[id] = entity.path;
            _downloadedFileSizes[id] = size;
          }
        }
      }
    }
  }

  // --- Offline & Download Status ---

  bool isDownloaded(String id) {
    final path = _downloadedLocalPaths[id];
    if (path == null) return false;
    final f = File(path);
    return f.existsSync() && f.lengthSync() > 1000;
  }

  String? getLocalAudioPath(String id) {
    if (isDownloaded(id)) {
      return _downloadedLocalPaths[id];
    }
    return null;
  }

  bool isDownloading(String id) => _activeProgress.containsKey(id);

  double getDownloadProgress(String id) => _activeProgress[id] ?? 0.0;

  Future<bool> downloadStory(String id) async {
    final story = _storiesData.firstWhere((s) => s.id == id, orElse: () => _storiesData.first);
    if (isDownloading(id)) return false;

    await init();
    final dirPath = _storageDirPath;
    if (dirPath == null) return false;

    final filePath = '$dirPath/$id.mp3';
    final tempFilePath = '$filePath.tmp';

    final cancelToken = CancelToken();
    _cancelTokens[id] = cancelToken;
    _activeProgress[id] = 0.01;
    notifyListeners();

    try {
      final tempFile = File(tempFilePath);
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }

      int lastEmitMs = 0;

      await _dio.download(
        story.audioUrl,
        tempFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final progress = (received / total).clamp(0.0, 1.0);
            _activeProgress[id] = progress;
            if (now - lastEmitMs > 250 || progress >= 1.0) {
              lastEmitMs = now;
              notifyListeners();
            }
          }
        },
      );

      final finalFile = File(filePath);
      if (finalFile.existsSync()) finalFile.deleteSync();
      await File(tempFilePath).rename(filePath);

      _downloadedLocalPaths[id] = filePath;
      _downloadedFileSizes[id] = finalFile.lengthSync();
      _activeProgress.remove(id);
      _cancelTokens.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Story download error for $id: $e');
      _activeProgress.remove(id);
      _cancelTokens.remove(id);
      final tempFile = File(tempFilePath);
      if (tempFile.existsSync()) {
        try {
          tempFile.deleteSync();
        } catch (_) {}
      }
      notifyListeners();
      return false;
    }
  }

  void cancelDownload(String id) {
    final token = _cancelTokens[id];
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled by user');
    }
    _activeProgress.remove(id);
    _cancelTokens.remove(id);
    notifyListeners();
  }

  Future<bool> deleteDownloadedStory(String id) async {
    final path = _downloadedLocalPaths[id];
    if (path == null) return false;

    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _downloadedLocalPaths.remove(id);
      _downloadedFileSizes.remove(id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete story audio error: $e');
      return false;
    }
  }

  Future<void> deleteAllDownloadedStories() async {
    for (final path in _downloadedLocalPaths.values.toList()) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    _downloadedLocalPaths.clear();
    _downloadedFileSizes.clear();
    notifyListeners();
  }

  List<ProphetAudioStory> getDownloadedStories() {
    return _storiesData.where((s) => isDownloaded(s.id)).toList();
  }

  int get totalDownloadedStoriesBytes {
    int total = 0;
    for (final size in _downloadedFileSizes.values) {
      total += size;
    }
    return total;
  }

  String get formattedTotalDownloadedStorage {
    final bytes = totalDownloadedStoriesBytes;
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    if (mb < 0.1) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    if (mb >= 1024) {
      final gb = mb / 1024;
      return '${gb.toStringAsFixed(2)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  // --- Favorites & Last Read ---

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('stories_favorites', _favoriteIds.toList());
    } catch (e) {
      debugPrint('Error saving favorite: $e');
    }
  }

  Future<void> setLastReadStory(String id) async {
    _lastReadStoryId = id;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('stories_last_read', id);
    } catch (e) {
      debugPrint('Error saving last read story: $e');
    }
  }

  // --- Catalog, Query & Search ---

  List<ProphetAudioStory> getAllStories() => List.unmodifiable(_storiesData);

  List<ProphetAudioStory> getStoriesByCategory(StoryCategory? category) {
    if (category == null) return getAllStories();
    return _storiesData.where((s) => s.category == category).toList();
  }

  List<ProphetAudioStory> getUluAlAzmStories() {
    return _storiesData.where((s) => s.isUluAlAzm).toList();
  }

  List<ProphetAudioStory> getStoriesByScholar(String scholarId) {
    if (scholarId.isEmpty || scholarId == 'all') return getAllStories();
    return _storiesData.where((s) => s.scholarId == scholarId).toList();
  }

  List<Map<String, String>> getAvailableScholars() {
    return const [
      {'id': 'all', 'name': 'جميع الشيوخ والعلماء'},
      {'id': 'al_awadi', 'name': 'الشيخ نبيل العوضي'},
      {'id': 'suwaidan', 'name': 'د. طارق السويدان'},
      {'id': 'shaarawi', 'name': 'الشيخ محمد متولي الشعراوي'},
      {'id': 'abdelkafy', 'name': 'د. عمر عبد الكافي'},
      {'id': 'othman_khamis', 'name': 'الشيخ عثمان الخميس'},
      {'id': 'ratib_nabulsi', 'name': 'د. محمد راتب النابلسي'},
    ];
  }

  List<ProphetAudioStory> getFavoriteStories() {
    return _storiesData.where((s) => _favoriteIds.contains(s.id)).toList();
  }

  List<ProphetAudioStory> searchStories(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return getAllStories();
    final normQuery = ArabicNormalizer.normalize(cleanQuery, loose: true);

    bool matchesField(String text) {
      if (text.toLowerCase().contains(cleanQuery)) return true;
      if (normQuery.isNotEmpty) {
        return ArabicNormalizer.normalize(text, loose: true).contains(normQuery);
      }
      return false;
    }

    return _storiesData.where((s) {
      final inTitle = matchesField(s.title);
      final inName = matchesField(s.characterName);
      final inSummary = matchesField(s.summary);
      final inEra = matchesField(s.era);
      final inSurah = s.surahsMentioned.any(matchesField);
      final inLessons = s.keyLessons.any(matchesField);
      return inTitle || inName || inSummary || inEra || inSurah || inLessons;
    }).toList();
  }

  ProphetAudioStory getStoryOfTheDay([DateTime? date]) {
    final now = date ?? DateTime.now();
    final dayOfYear = int.tryParse("${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}") ?? 1;
    final index = dayOfYear % _storiesData.length;
    return _storiesData[index];
  }

  // --- Authentic Prophet Audio Catalog ---
  static const List<ProphetAudioStory> _storiesData = [
    // 1. آدم عليه السلام
    ProphetAudioStory(
      id: 'adam',
      title: 'قصة أبي البشر آدم عليه السلام وحواء',
      characterName: 'آدم عليه السلام',
      subtitle: 'بداية الخلق وسجود الملائكة وخلافة الأرض والتوبة الصادقة',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٧ دقيقة',
      durationSeconds: 2877,
      fileSizeBytes: 23022866,
      audioUrl: 'https://archive.org/download/qasas-anbiya/01.mp3',
      era: 'بداية الوجود البشري',
      surahsMentioned: ['البقرة', 'الأعراف', 'طه', 'الحجر', 'الإسراء', 'ص'],
      summary: 'خلق الله آدم من طين ونفخ فيه من روحه، وأمر الملائكة بالسجود له إكراماً، وأسكنه وزوجه الجنة، فلما وسوس لهما الشيطان أكلا من الشجرة فتابا إلى الله فغفر لهما وأهبطهما لخلافة الأرض.',
      keyLessons: [
        'طبيعة الإنسان خطّاء، وباب التوبة والاستغفار مفتوح دائماً.',
        'عداوة إبليس للإنسان أبدية قائمة على الحسد والكبر.',
        'العلم والبيان شرف كرّم الله به بني آدم على سائر خلقه.',
        'التواضع والانقياد لأمر الله نجاة، والكبر أصل كل شقاء.',
      ],
      propheticDuaa: 'رَبَّنَا ظَلَمْنَا أَنفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      duaaReference: 'سورة الأعراف: ٢٣',
      isUluAlAzm: false,
    ),

    // 2. نوح عليه السلام
    ProphetAudioStory(
      id: 'nuh',
      title: 'قصة نوح عليه السلام وشيخ المرسلين',
      characterName: 'نوح عليه السلام',
      subtitle: 'ألف سنة إلا خمسين عاماً من الدعوة وبناء الفلك والطوفان العظيم',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٧ دقيقة',
      durationSeconds: 2830,
      fileSizeBytes: 22647122,
      audioUrl: 'https://archive.org/download/qasas-anbiya/02.mp3',
      era: 'أوائل عصور البشرية بعد آدم بعشرة قرون',
      surahsMentioned: ['نوح', 'هود', 'الأعراف', 'المؤمنون', 'الشعراء', 'العنكبوت'],
      summary: 'أول رسول أرسله الله إلى أهل الأرض بعد انتشار عبادة الأصنام، دعا قومه ليلاً ونهاراً وسراً وجهاراً ٩٥٠ عاماً، فلما أصروا على الكفر أمره الله ببناء السفينة فأهلك الله الكافرين بالطوفان ونجّى المؤمنين.',
      keyLessons: [
        'الصبر والمثابرة في الدعوة إلى الحق مهما طال الزمن.',
        'رابطة العقيدة والإيمان أسمى وأوثق من رابطة النسب والدم.',
        'عاقبة الاستكبار والظلم الهلاك ولو طال أمد الإمهال.',
        'الاستغفار مفتاح للبركات ونزول الأمطار وزيادة الأموال والبنين.',
      ],
      propheticDuaa: 'رَبِّ إِنِّي مَغْلُوبٌ فَانتَصِرْ',
      duaaReference: 'سورة القمر: ١٠',
      isUluAlAzm: true,
    ),

    // 3. هود وصالح عليهما السلام
    ProphetAudioStory(
      id: 'hud_salih',
      title: 'قصة هود وصالح عليهما السلام (عاد وثمود)',
      characterName: 'هود وصالح عليهما السلام',
      subtitle: 'إرم ذات العماد والرياح الصرصر وناقة الله ومعجزة الصخرة',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٨ دقيقة',
      durationSeconds: 2885,
      fileSizeBytes: 23087789,
      audioUrl: 'https://archive.org/download/qasas-anbiya/03.mp3',
      era: 'الجزيرة العربية القديمة (الأحقاف والحِجر)',
      surahsMentioned: ['هود', 'الأعراف', 'الشعراء', 'فصلت', 'الحاقة', 'الشمس'],
      summary: 'أرسل الله هوداً إلى عاد الأقوياء الذين بنوا في كل ريع آية، فلما استكبروا أهلكهم بريح صرصر عاتية، وأرسل صالحاً إلى ثمود الذين ينحتون من الجبال بيوتاً فطلبوا معجزة الناقة فعقروها فأخذتهم الصيحة والرجفة.',
      keyLessons: [
        'القوة الجسدية والعمران لا تغني شيئاً أمام بطش الله.',
        'طلب المعجزات تعنتاً سبب لنزول العذاب الفوري عند التكذيب.',
        'الاعتزاز بنعم الله يقتضي الشكر وليس التكبر والفساد.',
      ],
      propheticDuaa: 'إِنِّي تَوَكَّلْتُ عَلَى اللَّهِ رَبِّي وَرَبِّكُم ۚ مَّا مِن دَابَّةٍ إِلَّا هُوَ آخِذٌ بِنَاصِيَتِهَا',
      duaaReference: 'سورة هود: ٥٦',
      isUluAlAzm: false,
    ),

    // 4. إبراهيم عليه السلام
    ProphetAudioStory(
      id: 'ibrahim',
      title: 'قصة خليل الرحمن إبراهيم عليه السلام',
      characterName: 'إبراهيم عليه السلام',
      subtitle: 'تحطيم الأصنام والنار الباردة وذبح إسماعيل وبناء الكعبة المشرفة',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٦ دقيقة',
      durationSeconds: 2815,
      fileSizeBytes: 22520798,
      audioUrl: 'https://archive.org/download/qasas-anbiya/04.mp3',
      era: 'بابل والشام والحجاز (حوالي ١٩٠٠ ق.م)',
      surahsMentioned: ['البقرة', 'إبراهيم', 'الأنبياء', 'الشعراء', 'الصافات', 'النجم', 'الممتحنة'],
      summary: 'إمام الحنفاء وخليل الرحمن الذي حاجّ النمرود وحطم أصنام قومه فألقوه في النار فجعلها الله برداً وسلاماً، وهاجر بأهله وابتلاه الله بذبح ابنه ففداه بذبح عظيم ورفع مع إسماعيل قواعد البيت العتيق.',
      keyLessons: [
        'التوحيد الخالص هو أساس النجاة وعماد كل ملّة نبوية.',
        'اليقين التام والتسليم المطلق لأمر الله تعالى يقلب النار برداً.',
        'برّ الوالدين بالدعوة بالحسنى والحرص على هدايتهم.',
        'الدعاء للذرية والوطن بالأمن والبركة والاستقامة.',
      ],
      propheticDuaa: 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِن ذُرِّيَّتِي ۚ رَبَّنَا وَتَقَبَّلْ دُعَاءِ',
      duaaReference: 'سورة إبراهيم: ٤٠',
      isUluAlAzm: true,
    ),

    // 5. لوط وشعيب وإسماعيل وإسحاق عليهم السلام
    ProphetAudioStory(
      id: 'lut_shuaib',
      title: 'قصة لوط وشعيب وإسماعيل وإسحاق عليهم السلام',
      characterName: 'لوط وشعيب والذبيح إسماعيل',
      subtitle: 'عفاف الفطرة ونزول الحجارة والوفاء بالمكيال وبئر زمزم المبارك',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٩ دقيقة',
      durationSeconds: 2939,
      fileSizeBytes: 23519663,
      audioUrl: 'https://archive.org/download/qasas-anbiya/05.mp3',
      era: 'أرض سدوم ومدين ومكة المكرمة القديمة',
      surahsMentioned: ['هود', 'الأعراف', 'الحجر', 'الشعراء', 'العنكبوت', 'الصافات'],
      summary: 'حارب لوط عليه السلام الفاحشة التي لم يسبق إليها أحد فأهلك الله قريته بحجارة من سجيل، ودعا شعيب قومه في مدين لإقامة العدل وإيفاء الكيل والميزان، وجسّد إسماعيل أعظم درجات الطاعة والاستسلام لأمر والده.',
      keyLessons: [
        'حماية الفطرة الإنسانية والانتصار للفضيلة ونبذ الرذائل.',
        'الأمانة في التجارة وإيفاء المكيال والميزان من شعب الإيمان.',
        'طاعة الوالدين في البر والتسليم لقضاء الله وقدره.',
      ],
      propheticDuaa: 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ۚ عَلَيْهِ تَوَكَّلْتُ وَإِلَيْهِ أُنِيبُ',
      duaaReference: 'سورة هود: ٨٨',
      isUluAlAzm: false,
    ),

    // 6. يوسف عليه السلام
    ProphetAudioStory(
      id: 'yusuf',
      title: 'قصة يوسف الصديق عليه السلام',
      characterName: 'يوسف عليه السلام',
      subtitle: 'أحسن القصص: من غيابات الجب وفتنة القصر وسنوات السجن إلى خزائن مصر',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٨ دقيقة',
      durationSeconds: 2897,
      fileSizeBytes: 23178773,
      audioUrl: 'https://archive.org/download/qasas-anbiya/06.mp3',
      era: 'أرض كنعان ومصر القديمة (حوالي ١٧٠٠ ق.م)',
      surahsMentioned: ['يوسف', 'الأنعام', 'غافر'],
      summary: 'رأى أحد عشر كوكباً والشمس والقمر له ساجدين، فحسده إخوته وألقوه في البئر، وبيع بثمن بخس في مصر، وراودته امرأة العزيز فاستعصم وسُجن صابراً، ثم فسّر رؤيا الملك فتولى خزائن الأرض وعفا عن إخوته وجمع الله شمله بأبويه.',
      keyLessons: [
        'العفة ومراقبة الله في الخلوات مفتاح العز والتمكين.',
        'حسن الظن بالله والصبر الجميل يعقبهما دائماً الفرج والتمكين.',
        'العفو عند المقدرة ومقابلة الإساءة بالإحسان من شيم الصديقين.',
        'كتمان النعم والستر خشية الحسد من الحكمة.',
      ],
      propheticDuaa: 'رَبِّ السِّجْنُ أَحَبُّ إِلَيَّ مِمَّا يَدْعُونَنِي إِلَيْهِ ۖ وَإِلَّا تَصْرِفْ عَنِّي كَيْدَهُنَّ أَصْبُ إِلَيْهِنَّ وَأَكُن مِّنَ الْجَاهِلِينَ',
      duaaReference: 'سورة يوسف: ٣٣',
      isUluAlAzm: false,
    ),

    // 7. أيوب ويونس وموسى عليهم السلام
    ProphetAudioStory(
      id: 'ayyub_yunus_musa',
      title: 'قصة أيوب ويونس وبداية رسالة موسى عليهم السلام',
      characterName: 'أيوب ويونس وموسى عليهم السلام',
      subtitle: 'صبر أيوب العظيم ونداء ذي النون في ظلمات الحوت ومولد كليم الله في اليم',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٥١ دقيقة',
      durationSeconds: 3059,
      fileSizeBytes: 24475388,
      audioUrl: 'https://archive.org/download/qasas-anbiya/07.mp3',
      era: 'بلاد الشام ونينوى ومصر القديمة',
      surahsMentioned: ['الأنبياء', 'ص', 'الصافات', 'القصص', 'طه'],
      summary: 'ابتُلي أيوب في جسده وماله وولده فصبر صبراً صار به مثلاً، ونادى يونس ربه من ظلمات بطن الحوت فنجاه الله، وألقي موسى رضيعاً في تابوت باليم فالتقطه آل فرعون ليكون لهم عدواً وحزناً وتولاه الله برعايته.',
      keyLessons: [
        'الصبر على البلاء مع الرضا التام بقضاء الله كنز لا يفنى.',
        'دعاء ذي النون في الكرب يفرّج كل هم ويجيب كل مضطر.',
        'تدبير الله ولطفه الخفي يحفظ الإنسان في أشد المواقف خطورة.',
      ],
      propheticDuaa: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      duaaReference: 'سورة الأنبياء: ٨٧',
      isUluAlAzm: false,
    ),

    // 8. بقية قصة موسى عليه السلام
    ProphetAudioStory(
      id: 'musa_pharaoh',
      title: 'بقية قصة موسى عليه السلام مع فرعون وبني إسرائيل',
      characterName: 'موسى عليه السلام (كليم الله)',
      subtitle: 'مواجهة السحرة والآيات التسع وانفلاق البحر وغرق فرعون وسنوات التيه',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٥١ دقيقة',
      durationSeconds: 3096,
      fileSizeBytes: 24772388,
      audioUrl: 'https://archive.org/download/qasas-anbiya/08.mp3',
      era: 'مصر وسيناء (حوالي ١٣٠٠ ق.م)',
      surahsMentioned: ['البقرة', 'الأعراف', 'طه', 'القصص', 'الشعراء', 'يونس', 'الإسراء'],
      summary: 'واجه موسى كبرياء فرعون بآيات العصا واليد البيضاء، فآمن السحرة سجداً، ولما لاحق فرعون وجنوده بني إسرائيل أوحى الله لموسى أن يضرب بعصاه البحر فانفلق اثني عشر فرقاً فعبر المؤمنون وغرق فرعون وجنده.',
      keyLessons: [
        'الحق ينتصر على الباطل مهما تجبر الطغاة وامتلكوا من سحر وقوة.',
        'الثقة التامة بالله: (كَلَّا ۖ إِنَّ مَعِيَ رَبِّي سَيَهْدِينِ).',
        'شؤم التمرد والجبن عن الجهاد يورث التيه والذلة.',
      ],
      propheticDuaa: 'رَبِّ اشْرَحْ لِي صَدْرِي * وَيَسِّرْ لِي أَمْرِي * وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي * يَفْقَهُوا قَوْلِي',
      duaaReference: 'سورة طه: ٢٥-٢٨',
      isUluAlAzm: true,
    ),

    // 9. داود وسليمان وزكريا ويحيى عليهم السلام
    ProphetAudioStory(
      id: 'dawud_sulaiman',
      title: 'قصة داود وسليمان وزكريا ويحيى عليهم السلام',
      characterName: 'داود وسليمان وزكريا ويحيى',
      subtitle: 'تسبيح الجبال مع الزبور ومنطق الطير والريح وجنود الجن ودعاء المحراب',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٥١ دقيقة',
      durationSeconds: 3061,
      fileSizeBytes: 24492704,
      audioUrl: 'https://archive.org/download/qasas-anbiya/09.mp3',
      era: 'بيت المقدس وفلسطين (حوالي ١٠٠٠ - ٨٠٠ ق.م)',
      surahsMentioned: ['البقرة', 'الأنبياء', 'النمل', 'سبأ', 'ص', 'مريم', 'آل عمران'],
      summary: 'آتى الله داود الملك والزبور وليّن له الحديد وسخّر معه الجبال يسبحن والطير، وورثه سليمان وسخّر الله له الريح والجن وعلمه منطق الطير، ودعا زكريا ربه في المحراب فهب له يحيى سيداً وحصوراً ونبياً من الصالحين.',
      keyLessons: [
        'تسخير النعم والسلطان في عبادة الله وخدمة الحق شكر للمنعم.',
        'الحكمة وفصل الخطاب أعظم من القوة المادية المجردة.',
        'الدعاء بالذرية الصالحة لا ينقطع ولو مع كبر السن وعقم الأسباب.',
      ],
      propheticDuaa: 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ',
      duaaReference: 'سورة النمل: ١٩',
      isUluAlAzm: false,
    ),

    // 10. عيسى عليه السلام
    ProphetAudioStory(
      id: 'isa',
      title: 'قصة عيسى المسيح ابن مريم عليه السلام',
      characterName: 'عيسى عليه السلام',
      subtitle: 'معجزة الميلاد العذري والتكلم في المهد وإبراء الأكمه والأبرص والرفع للسماء',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٩ دقيقة',
      durationSeconds: 2955,
      fileSizeBytes: 23645927,
      audioUrl: 'https://archive.org/download/qasas-anbiya/10.mp3',
      era: 'القدس والناصرة بفلسطين (القرن الأول الميلادي)',
      surahsMentioned: ['آل عمران', 'النساء', 'المائدة', 'مريم', 'الأنبياء', 'الزخرف', 'الصف'],
      summary: 'كلمة الله ألقاها إلى مريم البتول وروح منه، تكلّم في المهد صبياً مبشراً بنبوته، وأيَّده الله بروح القدس فأبرأ الأكمه والأبرص وأحيى الموتى بإذن الله، وتآمروا لقتله فشبّه لهم وما قتلوه وما صلبوه بل رفعه الله إليه وسينزل في آخر الزمان حكماً عدلاً.',
      keyLessons: [
        'قدرة الله مطلقة يخلق ما يشاء بأمره كن فيكون دون أسباب.',
        'عظمة مريم الصديقة وطهارتها واصطفاؤها على نساء العالمين.',
        'التوحيد الخالص هو دين جميع الأنبياء من آدم إلى محمد.',
      ],
      propheticDuaa: 'رَبَّنَا أَنزِلْ عَلَيْنَا مَائِدَةً مِّنَ السَّمَاءِ تَكُونُ لَنَا عِيدًا لِّأَوَّلِنَا وَآخِرِنَا وَآيَةً مِّنكَ ۖ وَارْزُقْنَا وَأَنتَ خَيْرُ الرَّازِقِينَ',
      duaaReference: 'سورة المائدة: ١١٤',
      isUluAlAzm: true,
    ),

    // 11. خاتم الأنبياء محمد ﷺ
    ProphetAudioStory(
      id: 'muhammad_saw',
      title: 'سيرة خاتم النبيين وإمام المرسلين محمد ﷺ',
      characterName: 'محمد رسول الله ﷺ',
      subtitle: 'المولد النبوي المبارك وغار حراء والهجرة الشريفة وفتح مكة وإتمام الدين',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٥٢ دقيقة',
      durationSeconds: 3120,
      fileSizeBytes: 24800000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/29.mp3',
      era: 'مكة المكرمة والمدينة المنورة (٥٧١ - ٦٣٢ م)',
      surahsMentioned: ['آل عمران', 'الأحزاب', 'الفتح', 'محمد', 'النجم', 'التوبة', 'الضحى', 'الشرح'],
      summary: 'أرسله الله رحمة للعالمين بالهدى ودين الحق ليظهره على الدين كله، وُلد يتيماً فنشأ صادقاً أميناً، نزل عليه الوحي في غار حراء فأضاءت رسالته ظلمات الجاهلية، وهاجر للمدينة وأسس الدولة الإسلامية على العدل والأخلاق، وفتح مكة عفواً ورحمة وأتم البلاغ المبين.',
      keyLessons: [
        'خُلق النبي ﷺ كان القرآن، وهو القدوة والأسوة الحسنة في كل جوانب الحياة.',
        'الصبر والرحمة ولين الجانب أعظم دعائم نجاح الدعوة والقيادة.',
        'التوحيد ونبذ الجاهلية وتحرير العقول والقلوب من عبودية الخلق إلى عبودية الخالق.',
      ],
      propheticDuaa: 'اللَّهُمَّ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      duaaReference: 'صحيح البخاري ومسلم',
      isUluAlAzm: true,
    ),

    // 12. أصحاب الكهف وذو القرنين
    ProphetAudioStory(
      id: 'ashab_alkahf',
      title: 'قصة أصحاب الكهف والملك الصالح ذي القرنين',
      characterName: 'فتية الكهف وذو القرنين',
      subtitle: 'الثبات على الإيمان ونوم ٣٠٩ سنوات والرحلة العظيمة وبناء السد المنيع',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٥ دقيقة',
      durationSeconds: 2700,
      fileSizeBytes: 22100000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/05.mp3',
      era: 'عصور تاريخية قديمة ما بين الشام ومشارق الأرض ومغاربها',
      surahsMentioned: ['الكهف'],
      summary: 'فتية آمنوا بربهم فزادهم هدى، فرّوا بدينهم من الملك الظالم إلى الكهف فضرب الله على آذانهم ثلاثمائة سنين وازدادوا تسعاً ليكونوا آية للناس، وملك صالح طاف الأرض ناشراً للعدل وبنى سداً من زبر الحديد لمنع يأجوج ومأجوج.',
      keyLessons: [
        'الفرار بالدين والثبات على التوحيد عند اشتداد الفتن.',
        'حفظ الله لأوليائه وتدبيره المعجز فوق مدارك البشر.',
        'استعمال القوة والسلطة في نصرة المستضعفين وإقامة العدل.',
      ],
      propheticDuaa: 'رَبَّنَا آتِنَا مِن لَّدُنكَ رَحْمَةً وَهَيِّئْ لَنَا مِنْ أَمْرِنَا رَشَدًا',
      duaaReference: 'سورة الكهف: ١٠',
      isUluAlAzm: false,
    ),

    // 13. إدريس عليه السلام
    ProphetAudioStory(
      id: 'idris',
      title: 'قصة نبي الله إدريس عليه السلام (ورفعناه مكاناً علياً)',
      characterName: 'إدريس عليه السلام',
      subtitle: 'أول من خط بالقلم وخاط الثياب والرفع في المكان العلي',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٢ دقيقة',
      durationSeconds: 1920,
      fileSizeBytes: 15400000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/01.mp3',
      era: 'بين آدم ونوح عليهما السلام في بابل ومصر',
      surahsMentioned: ['مريم', 'الأنبياء'],
      summary: 'كان صديقاً نبياً، أول من أعطي النبوة بعد آدم وشيث، عُرف بالحكمة والعلم والزهد، وأثنى الله عليه في محكم التنزيل ورفعه مكاناً علياً في السماء الرابعة.',
      keyLessons: [
        'فضل العلم والكتابة والاجتهاد في خدمة الإنسانية.',
        'الصدق والوفاء بالعهد يرفع صاحبه إلى أعلى المراتب.',
      ],
      propheticDuaa: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ',
      duaaReference: 'أذكار الصديقين المأثورة',
      isUluAlAzm: false,
    ),

    // 14. شعيب عليه السلام
    ProphetAudioStory(
      id: 'shuayb',
      title: 'قصة شعيب عليه السلام وخطيب الأنبياء (أصحاب مدين والأيكة)',
      characterName: 'شعيب عليه السلام',
      subtitle: 'الأمانة في الميزان والنهي عن بخس الناس أشياءهم وعذاب يوم الظلة',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤٠ دقيقة',
      durationSeconds: 2400,
      fileSizeBytes: 19200000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/04.mp3',
      era: 'أرض مدين بالقرب من معان بالأردن',
      surahsMentioned: ['الأعراف', 'هود', 'الشعراء', 'العنكبوت'],
      summary: 'أرسله الله إلى قوم مدين وكانوا يطففون المكيال والميزان ويقطعون السبيل، فدعاهم بالحكمة والموعظة الحسنة، فلما عاندوا وكذبوه أخذتهم الرجفة وعذاب يوم الظلة فأصبحوا في دارهم جاثمين.',
      keyLessons: [
        'العدل في المعاملات المالية والتجارية عبادة شرعية عظيمة.',
        'فساد الأخلاق الاقتصادية سبب لهلاك الأمم.',
      ],
      propheticDuaa: 'عَلَى اللَّهِ تَوَكَّلْنَا ۚ رَبَّنَا افْتَحْ بَيْنَنَا وَبَيْنَ قَوْمِنَا بِالْحَقِّ وَأَنتَ خَيْرُ الْفَاتِحِينَ',
      duaaReference: 'سورة الأعراف: ٨٩',
      isUluAlAzm: false,
    ),

    // 15. أيوب عليه السلام
    ProphetAudioStory(
      id: 'ayyub',
      title: 'قصة نبي الله أيوب عليه السلام ومضرب المثل في الصبر',
      characterName: 'أيوب عليه السلام',
      subtitle: 'البلاء العظيم وثبات الإيمان ونبع الماء البارد والشفاء التام',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٨ دقيقة',
      durationSeconds: 2280,
      fileSizeBytes: 18200000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/06.mp3',
      era: 'أرض حوران بالشام',
      surahsMentioned: ['الأنبياء', 'ص'],
      summary: 'ابتلي في ماله وأولاده وجسده ١٨ عاماً فلم يزده ذلك إلا صبراً وشكراً وحمداً، فنادى ربه نداء المضطر فأمره الله أن يركض برجله فنبع له مغتسل بارد وشراب وشفاه الله وردّ عليه أهله ومثلهم معهم رحمة منه وذكرى للعابدين.',
      keyLessons: [
        'الصبر الجميل عند نزول البلاء والرضا بقضاء الله.',
        'حسن الظن بالله والدعاء بأدب وتذلل يفتح أبواب الفرج.',
      ],
      propheticDuaa: 'أَنِّي مَسَّنِيَ الضُّرُّ وَأَنتَ أَرْحَمُ الرَّاحِمِينَ',
      duaaReference: 'سورة الأنبياء: ٨٣',
      isUluAlAzm: false,
    ),

    // 16. يونس عليه السلام
    ProphetAudioStory(
      id: 'yunus',
      title: 'قصة يونس عليه السلام وذي النون في بطن الحوت',
      characterName: 'يونس عليه السلام',
      subtitle: 'الظلمات الثلاث والنداء الخالد الذي لا إله إلا أنت سبحانك وإيمان أهل نينوى',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٦ دقيقة',
      durationSeconds: 2160,
      fileSizeBytes: 17300000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/06.mp3',
      era: 'مدينة نينوى بالموصل شمال العراق',
      surahsMentioned: ['يونس', 'الأنبياء', 'الصافات', 'القلم'],
      summary: 'غضب من إعراض قومه فركب السفينة فاستهموا فوقعت عليه القرعة فألقي في البحر فالتقمه الحوت وهو مليم، فنادى في ظلمات الليل والبحر وبطن الحوت فنبذه الله بالعراء وأنبت عليه شجرة من يقطين ونجاه من الغم وتاب قومه فآمنوا أجمعين.',
      keyLessons: [
        'دعوة ذي النون ما دعا بها مسلم في كربة إلا فرج الله عنه.',
        'عدم التعجل واليأس في البلاغ والاستمرار في التوجيه.',
      ],
      propheticDuaa: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      duaaReference: 'سورة الأنبياء: ٨٧',
      isUluAlAzm: false,
    ),

    // 17. داود وسليمان عليهما السلام
    ProphetAudioStory(
      id: 'dawud_sulayman',
      title: 'قصة داود وسليمان عليهما السلام (الملك والنبوة وتسخير الريح والجن)',
      characterName: 'داود وسليمان عليهما السلام',
      subtitle: 'تسبيح الجبال والحديد اللين ومنطق الطير وهدهد سبأ وعرش بلقيس',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٥٠ دقيقة',
      durationSeconds: 3000,
      fileSizeBytes: 24000000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/07.mp3',
      era: 'بيت المقدس وفلسطين (القرن العاشر قبل الميلاد)',
      surahsMentioned: ['البقرة', 'الأنبياء', 'النمل', 'سبأ', 'ص'],
      summary: 'آتى الله داود الزبور وألان له الحديد وسخر معه الجبال يسبحن والطير، وآتى ابنه سليمان ملكاً لا ينبغي لأحد من بعده فسخر له الريح تجري بأمره والجن يعملون بين يديه وعلمه منطق الطير والحيوان فكان عبداً شكوراً.',
      keyLessons: [
        'شكر النعم هو الحافظ الحقيقي للتمكين والسلطان.',
        'الجمع بين خشوع النبوة والعدل في إدارة شؤون الرعية.',
      ],
      propheticDuaa: 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَىٰ وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ',
      duaaReference: 'سورة النمل: ١٩',
      isUluAlAzm: false,
    ),

    // 18. زكريا ويحيى عليهما السلام
    ProphetAudioStory(
      id: 'zakariyya_yahya',
      title: 'قصة زكريا ويحيى عليهما السلام (دعاء الخفاء والمعجزة)',
      characterName: 'زكريا ويحيى عليهما السلام',
      subtitle: 'واشتعل الرأس شيباً ومحراب العبادة وسيداً وحصوراً ونبياً من الصالحين',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٥ دقيقة',
      durationSeconds: 2100,
      fileSizeBytes: 16800000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/09.mp3',
      era: 'فلسطين والقدس قبل بعثة عيسى عليه السلام',
      surahsMentioned: ['آل عمران', 'مريم', 'الأنبياء'],
      summary: 'كفل زكريا مريم في المحراب فرأى عندها رزقاً ربانياً، فدعا ربه في كبر سنه وعقم زوجته بالذرية الطيبة، فبشرته الملائكة بيحيى مصدقاً بكلمة من الله وحكمه الصبي وعفته وبره بوالديه.',
      keyLessons: [
        'الدعاء في الخفاء والتذلل لله لا يخيب أبداً حتى مع انقطاع الأسباب الدنيوية.',
        'بر الوالدين والعفة والتقوى صفات الأنبياء المخلَصين.',
      ],
      propheticDuaa: 'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ',
      duaaReference: 'سورة الأنبياء: ٨٩',
      isUluAlAzm: false,
    ),

    // --- روائع القصص النبوي: الدكتور طارق السويدان ---
    ProphetAudioStory(
      id: 'suwaidan_yusuf',
      title: 'دروس القيادة والعفة في سيرة يوسف عليه السلام',
      characterName: 'يوسف الصديق عليه السلام',
      subtitle: 'تحليل قيادي واجتماعي لأحسن القصص مع د. طارق السويدان',
      category: StoryCategory.prophet,
      narrator: 'د. طارق السويدان',
      seriesName: 'سلسلة روائع القصص النبوي',
      scholarId: 'suwaidan',
      duration: '٤٤ دقيقة',
      durationSeconds: 2640,
      fileSizeBytes: 21200000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/05.mp3',
      era: 'مصر القديمة وكنعان',
      surahsMentioned: ['يوسف'],
      summary: 'قراءة استراتيجية وإيمانية عميقة لسورة يوسف، واستخلاص مهارات إدارة الأزمات الاقتصادية، والعفة في مواجهة الفتن، والعفو عند المقدرة من منظور تربوي قيادي.',
      keyLessons: [
        'التخطيط المستقبلي وإدارة مخزون الغذاء والأزمات الاقتصادية.',
        'حسن التوكل على الله يحول المحنة في الجب والسجن إلى تمكين في الأرض.',
      ],
      propheticDuaa: 'أَنتَ وَلِيِّي فِي الدُّنْيَا وَالْآخِرَةِ ۖ تَوَفَّنِي مُسْلِمًا وَأَلْحِقْنِي بِالصَّالِحِينَ',
      duaaReference: 'سورة يوسف: ١٠١',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'suwaidan_musa',
      title: 'بناء الأمم ومواجهة الطغيان: قصة كليم الله موسى',
      characterName: 'موسى عليه السلام',
      subtitle: 'تحليل د. طارق السويدان لمراحل نشأة وتربية ومواجهة النبي موسى لفرعون',
      category: StoryCategory.prophet,
      narrator: 'د. طارق السويدان',
      seriesName: 'سلسلة روائع القصص النبوي',
      scholarId: 'suwaidan',
      duration: '٤٨ دقيقة',
      durationSeconds: 2880,
      fileSizeBytes: 23100000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/08.mp3',
      era: 'مصر وسيناء وفلسطين',
      surahsMentioned: ['طه', 'القصص', 'الشعراء'],
      summary: 'إلقاء الضوء على بناء شخصية موسى عليه السلام، والصراع بين الحق والباطل، وكيف تصنع الأقدار العجيبة نصر المستضعفين.',
      keyLessons: [
        'سقوط عروش الظلم حتمي إذا تحرك أهل الإيمان باليقين والصبر.',
        'أهمية القيادة الشجاعة الواثقة بربها عند انقطاع السبل.',
      ],
      propheticDuaa: 'كَلَّا ۖ إِنَّ مَعِيَ رَبِّي سَيَهْدِينِ',
      duaaReference: 'سورة الشعراء: ٦٢',
      isUluAlAzm: true,
    ),

    // --- خواطر وتدبر قصص الأنبياء: فضيلة الإمام محمد متولي الشعراوي ---
    ProphetAudioStory(
      id: 'shaarawi_ibrahim',
      title: 'خواطر إيمانية في فداء إسماعيل وبناء الكعبة (الشيخ الشعراوي)',
      characterName: 'إبراهيم وإسماعيل عليهما السلام',
      subtitle: 'البيان اللغوي والإيماني المعجز لفضيلة الإمام الشعراوي',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ محمد متولي الشعراوي',
      seriesName: 'خواطر وتدبر قصص الأنبياء',
      scholarId: 'shaarawi',
      duration: '٣٩ دقيقة',
      durationSeconds: 2340,
      fileSizeBytes: 18700000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/04.mp3',
      era: 'مكة المكرمة وبابل',
      surahsMentioned: ['البقرة', 'إبراهيم', 'الصافات'],
      summary: 'شرح فذ ولطائف لغوية عميقة حول حكمة الله في امتحان خليل الرحمن إبراهيم، وفداء إسماعيل بذبح عظيم، ومقام التوحيد عند بناء البيت الحرام.',
      keyLessons: [
        'الانقياد التام لأمر الله يثمر الفرج والعطاء العظيم.',
        'بر الوالدين والتسليم المطلق حكمة تنجي صاحبها في الدارين.',
      ],
      propheticDuaa: 'رَبَّنَا تَقَبَّلْ مِنَّا ۖ إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
      duaaReference: 'سورة البقرة: ١٢٧',
      isUluAlAzm: true,
    ),
    ProphetAudioStory(
      id: 'shaarawi_sulayman',
      title: 'عجائب النمل والهدهد وتسخير الكون لسليمان (الشيخ الشعراوي)',
      characterName: 'سليمان عليه السلام',
      subtitle: 'تأملات لغوية وبيانية ساحرة لفضيلة الشيخ الشعراوي',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ محمد متولي الشعراوي',
      seriesName: 'خواطر وتدبر قصص الأنبياء',
      scholarId: 'shaarawi',
      duration: '٤٢ دقيقة',
      durationSeconds: 2520,
      fileSizeBytes: 20100000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/07.mp3',
      era: 'فلسطين والشام واليمن',
      surahsMentioned: ['النمل', 'سبأ'],
      summary: 'تدبر بديع في مقال النملة وهدهد سليمان ومشاعر الحيوان، واستخلاص عظمة التواضع الإيماني لمن ملك الدنيا بأسره.',
      keyLessons: [
        'عظمة التواضع عند قمة التمكين والملك.',
        'كل كائن في الوجود له رسالة ووعي وتسبيح لله.',
      ],
      propheticDuaa: 'رَبِّ اغْفِرْ لِي وَهَبْ لِي مُلْكًا لَّا يَنبَغِي لِأَحَدٍ مِّن بَعْدِي',
      duaaReference: 'سورة ص: ٣٥',
      isUluAlAzm: false,
    ),

    // --- تكملة سلسلة الشيخ نبيل العوضي الشاملة ---
    ProphetAudioStory(
      id: 'ilyas_alyasa',
      title: 'قصة إلياس واليسع عليهما السلام وصنم بعل',
      characterName: 'إلياس واليسع عليهما السلام',
      subtitle: 'مواجهة الشرك في بعلبك ودعوة التوحيد بعد انحراف بني إسرائيل',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٢ دقيقة',
      durationSeconds: 1920,
      fileSizeBytes: 15300000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/06.mp3',
      era: 'الشام وبعلبك بعد عهد سليمان',
      surahsMentioned: ['الصافات', 'الأنعام', 'ص'],
      summary: 'أرسل الله إلياس إلى أهل بعلبك الذين عبدوا صنم بعل، فدعاهم إلى عبادة الله الواحد القهار، ثم خلفه اليسع عليه السلام نبياً صالحاً هادياً بالحق.',
      keyLessons: [
        'الثبات على التوحيد في وجه الانحراف المجتمعي العام.',
        'استمرار رسالة الحق بتعاقب الأنبياء والدعاة المخلصين.',
      ],
      propheticDuaa: 'سَلَامٌ عَلَىٰ إِلْ يَاسِينَ ۗ إِنَّا كَذَٰلِكَ نَجْزِي الْمُحْسِنِينَ',
      duaaReference: 'سورة الصافات: ١٣٠-١٣١',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'yusha_bin_nun',
      title: 'قصة فتى موسى يوشع بن نون وفتح بيت المقدس',
      characterName: 'يوشع بن نون عليه السلام',
      subtitle: 'حبس الشمس ودخول الأرض المقدسة سجداً وظهور راية النصر',
      category: StoryCategory.prophet,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٨ دقيقة',
      durationSeconds: 2280,
      fileSizeBytes: 18200000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/08.mp3',
      era: 'صحراء التيه وأرض فلسطين المباركة',
      surahsMentioned: ['المائدة', 'الكهف'],
      summary: 'قاد يوشع بن نون الجيل المؤمن بعد سنوات التيه الأربعين، وفتح الله على يديه بيت المقدس بعد أن حبس الله له الشمس حتى تم الفتح المبين.',
      keyLessons: [
        'النصر يأتي بإعداد الجيل المؤمن الصابر المطيع لربه.',
        'تأييد الله لأوليائه بالكرامات والمعجزات عند صدق التوجه.',
      ],
      propheticDuaa: 'ادْخُلُوا عَلَيْهِمُ الْبَابَ فَإِذَا دَخَلْتُمُوهُ فَإِنَّكُمْ غَالِبُونَ',
      duaaReference: 'سورة المائدة: ٢٣',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'luqman',
      title: 'قصة لقمان الحكيم ووصاياه الخالدة لابنه',
      characterName: 'لقمان الحكيم',
      subtitle: 'منهج التربية النبوية الحكيمة، بر الوالدين، ومراقبة الله في السر والعلن',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٤ دقيقة',
      durationSeconds: 2040,
      fileSizeBytes: 16300000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/03.mp3',
      era: 'بلاد النوبة ومصر القديمة',
      surahsMentioned: ['لقمان'],
      summary: 'آتاه الله الحكمة فكان شاكراً لربه، وسطر القرآن وصاياه الأبوية البليغة في التوحيد، وإقامة الصلاة، والتواضع، والصبر على المكاره.',
      keyLessons: [
        'الشكر أساس دوام النعم والحكمة.',
        'مراقبة الله حتى في مثقال حبة من خردل داخل الصخرة.',
      ],
      propheticDuaa: 'يَا بُنَيَّ أَقِمِ الصَّلَاةَ وَأْمُرْ بِالْمَعْرُوفِ وَانْهَ عَنِ الْمُنكَرِ وَاصْبِرْ عَلَىٰ مَا أَصَابَكَ',
      duaaReference: 'سورة لقمان: ١٧',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'qarun',
      title: 'قصة قارون والغرور بالثروة وخسف الأرض',
      characterName: 'قارون',
      subtitle: 'مفاتيح الكنوز التي تنوء بالعصبة أولي القوة وعاقبة البغي والاستعلاء',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٣ دقيقة',
      durationSeconds: 1980,
      fileSizeBytes: 15800000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/05.mp3',
      era: 'مصر الفرعونية في عهد موسى عليه السلام',
      surahsMentioned: ['القصص', 'العنكبوت', 'غافر'],
      summary: 'كان قارون من قوم موسى فبغى عليهم بكنوزه وأمواله الطائلة، وقال إنما أوتيته على علم عندي، فخسف الله به وبداره الأرض فما كان له من فئة ينصرونه.',
      keyLessons: [
        'المال فتنة ونعمة مستودعة يجب شكرها وتسخيرها لابتغاء الدار الآخرة.',
        'الغرور بالعلم والذكاء البشري بداية الهلاك والسقوط.',
      ],
      propheticDuaa: 'وَابْتَغِ فِيمَا آتَاكَ اللَّهُ الدَّارَ الْآخِرَةَ ۖ وَلَا تَنسَ نَصِيبَكَ مِنَ الدُّنْيَا',
      duaaReference: 'سورة القصص: ٧٧',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'ashab_ukhdood',
      title: 'قصة الغلام والراهب والساحر وأصحاب الأخدود',
      characterName: 'الغلام المؤمن وأهل نجران',
      subtitle: 'أعظم ملاحم الثبات على العقيدة والتضحية في سبيل التوحيد الخالص',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٦ دقيقة',
      durationSeconds: 2160,
      fileSizeBytes: 17200000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/09.mp3',
      era: 'نجران وجنوب الجزيرة العربية قبل الإسلام',
      surahsMentioned: ['البروج'],
      summary: 'قصة الغلام الذكي الذي علم الحق من الراهب وأبطل سحر الساحر، وضحى بنفسه ليؤمن قومه جميعاً برب الغلام، فخد الملك الظالم لهم الأخاديد وأحرقهم بالنار.',
      keyLessons: [
        'الانتصار الحقيقي هو انتصار المبدأ والإيمان على الطغيان.',
        'صدق النية يحول موت الفرد إلى حياة أمة كاملة بالإيمان.',
      ],
      propheticDuaa: 'إِنَّ الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ لَهُمْ جَنَّاتٌ تَجْرِي مِن تَحْتِهَا الْأَنْهَارُ ۚ ذَٰلِكَ الْفَوْزُ الْكَبِيرُ',
      duaaReference: 'سورة البروج: ١١',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'habib_alnajjar',
      title: 'قصة حبيب النجار (مؤمن آل ياسين)',
      characterName: 'حبيب النجار',
      subtitle: 'وجاء من أقصى المدينة رجل يسعى — النصح الصادق حتى آخر أنفاس الشهادة',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣١ دقيقة',
      durationSeconds: 1860,
      fileSizeBytes: 14800000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/02.mp3',
      era: 'أنطاكية في بلاد الشام',
      surahsMentioned: ['يس'],
      summary: 'جاء مسرعاً ينصح قومه باتباع المرسلين الذين لا يسألونهم أجراً وهم مهتدون، فقتلوه ظلماً، فقيل له ادخل الجنة، فتمنى لو يعلم قومه بما غفر له ربه وجعله من المكرمين.',
      keyLessons: [
        'الإيجابية وتحمل مسؤولية نصرة الحق دون تردد.',
        'سلامة الصدر ورجاء الهداية حتى للأعداء عند دخول الجنة.',
      ],
      propheticDuaa: 'قِيلَ ادْخُلِ الْجَنَّةَ ۖ قَالَ يَا لَيْتَ قَوْمِي يَعْلَمُونَ * بِمَا غَفَرَ لِي رَبِّي وَجَعَلَنِي مِنَ الْمُكْرَمِينَ',
      duaaReference: 'سورة يس: ٢٦-٢٧',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'samiri',
      title: 'قصة السامري وصناعة عجل الذهب',
      characterName: 'السامري وبنو إسرائيل',
      subtitle: 'فتنة الشبهات والانحراف العقائدي بعد معجزة شق البحر ونجاة بني إسرائيل',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٥ دقيقة',
      durationSeconds: 2100,
      fileSizeBytes: 16800000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/08.mp3',
      era: 'صحراء سيناء عقب غرق فرعون',
      surahsMentioned: ['طه', 'الأعراف'],
      summary: 'استغل السامري غياب موسى لميقات ربه فصنع من حلي القوم عجلاً جسداً له خوار، وأضل كثيراً من بني إسرائيل حتى عاد كليم الله موسى غضبان أسفاً وحرق العجل ونسفه في اليم.',
      keyLessons: [
        'خطورة علماء السوء ومثيري الشبهات على العقيدة.',
        'الجهل والتعلق بالماديات سبب الانتكاس بعد الهداية.',
      ],
      propheticDuaa: 'إِنَّمَا إِلَٰهُكُمُ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ ۚ وَسِعَ كُلَّ شَيْءٍ عِلْمًا',
      duaaReference: 'سورة طه: ٩٨',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'bilaam',
      title: 'قصة بلعام بن باعوراء (الذي آتيناه آياتنا فانسلخ منها)',
      characterName: 'بلعام بن باعوراء',
      subtitle: 'تحذير قرآني مدوٍّ من حب الدنيا والاتباع للهوى بعد معرفة العلم الإلهي',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٣٠ دقيقة',
      durationSeconds: 1800,
      fileSizeBytes: 14400000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/01.mp3',
      era: 'أرض كنعان والأردن',
      surahsMentioned: ['الأعراف'],
      summary: 'عالم آتاه الله الاسم الأعظم ومعرفة آياته، فلما أخلد إلى الأرض واتبع هواه انسلخ من الدين ومثله كمثل الكلب إن تحمل عليه يلهث أو تتركه يلهث.',
      keyLessons: [
        'العلم بلا عمل وتقوى وبال على صاحبه.',
        'الحذر من حب الدنيا ومجاملة أهل الباطل على حساب العقيدة.',
      ],
      propheticDuaa: 'وَاتْلُ عَلَيْهِمْ نَبَأَ الَّذِي آتَيْنَاهُ آيَاتِنَا فَانسَلَخَ مِنْهَا فَأَتْبَعَهُ الشَّيْطَانُ فَكَانَ مِنَ الْغَاوِينَ',
      duaaReference: 'سورة الأعراف: ١٧٥',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'dhul_qarnayn',
      title: 'قصة الملك الصالح ذي القرنين وسد يأجوج ومأجوج',
      characterName: 'ذو القرنين',
      subtitle: 'التمكين العادل في الأرض وبناء السدود الحديدية وحماية الضعفاء',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٤١ دقيقة',
      durationSeconds: 2460,
      fileSizeBytes: 19600000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/10.mp3',
      era: 'مشارق الأرض ومغاربها في العصور القديمة',
      surahsMentioned: ['الكهف'],
      summary: 'ملك مكن الله له في الأرض فأتبع سبباً، طاف مشارق الأرض ومغاربها ناشراً للعدل، وبلغ بين السدين فبنى ردماً عظيماً من زبر الحديد والقطر حماية لأهل الضعف.',
      keyLessons: [
        'تسخير القوة والتكنولوجيا الهندسية لخدمة البشرية ودفع المفاسد.',
        'رد الفضل دائماً لله: هذا رحمة من ربي.',
      ],
      propheticDuaa: 'قَالَ هَٰذَا رَحْمَةٌ مِّن رَّبِّي ۖ فَإِذَا جَاءَ وَعْدُ رَبِّي جَعَلَهُ دَكَّاءَ',
      duaaReference: 'سورة الكهف: ٩٨',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'ashab_jannah',
      title: 'قصة أصحاب الجنة وبلاء حرمان الفقراء',
      characterName: 'أصحاب البستان والجنة',
      subtitle: 'إذ أقسموا ليصرمنها مصبحين ولا يستثنون فطاف عليها طائف من ربك وهم نائمون',
      category: StoryCategory.quranStory,
      narrator: 'فضيلة الشيخ نبيل العوضي',
      duration: '٢٩ دقيقة',
      durationSeconds: 1740,
      fileSizeBytes: 13900000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/07.mp3',
      era: 'اليمن (ضروان قرب صنعاء)',
      surahsMentioned: ['القلم'],
      summary: 'ورث أبناء بستاناً صالحاً كان أبوهم يتصدق منه، فعزموا على قطف ثماره فجراً خفية لمنع المساكين، فأرسل الله ناراً أحرقت الجنة كالصريم، فتابوا وأنابوا بعد نزول البلاء.',
      keyLessons: [
        'النية السيئة في منع الصدقة سبب لهلاك المال ومحق البركة.',
        'الاعتراف بالخطأ والتوبة الجماعية تفتح باب رحمة الله وعوضه.',
      ],
      propheticDuaa: 'قَالُوا سُبْحَانَ رَبِّنَا إِنَّا كُنَّا ظَالِمِينَ * عَسَىٰ رَبُّنَا أَن يُبْدِلَنَا خَيْرًا مِّنْهَا',
      duaaReference: 'سورة القلم: ٢٩-٣٢',
      isUluAlAzm: false,
    ),

    // --- روائع كبار العلماء: د. عمر عبد الكافي ---
    ProphetAudioStory(
      id: 'abdelkafy_adam',
      title: 'وسوسة إبليس وحقيقة الستر والتوبة (د. عمر عبد الكافي)',
      characterName: 'آدم وحواء عليهما السلام',
      subtitle: 'تحليل بياني رائع لمداخل الشيطان وسيكولوجية التوبة الصادقة',
      category: StoryCategory.prophet,
      narrator: 'د. عمر عبد الكافي',
      seriesName: 'صفوة الصفوة والوعد الحق',
      scholarId: 'abdelkafy',
      duration: '٤٣ دقيقة',
      durationSeconds: 2580,
      fileSizeBytes: 20600000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/01.mp3',
      era: 'بداية الخلق',
      surahsMentioned: ['الأعراف', 'طه'],
      summary: 'تحليل دقيق لكيفية خداع إبليس لآدم وحواء بالقسم بالله كذباً، واستخلاص العبر في معركة الستر والعفاف والتوبة السريعة بعد الوقوع في الزلل.',
      keyLessons: [
        'مكر الشيطان يستهدف دائماً نزع لباس التقوى والستر.',
        'سرعة اللجوء إلى الله بالاعتراف بالذنب تمحو أثر المعصية.',
      ],
      propheticDuaa: 'فَتَلَقَّىٰ آدَمُ مِن رَّبِّهِ كَلِمَاتٍ فَتَابَ عَلَيْهِ ۚ إِنَّهُ هُوَ التَّوَّابُ الرَّحِيمُ',
      duaaReference: 'سورة البقرة: ٣٧',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'abdelkafy_musa_khidr',
      title: 'موسى والخضر: أسرار القدر واليقين وحكمة الابتلاء (د. عمر عبد الكافي)',
      characterName: 'موسى والخضر عليهما السلام',
      subtitle: 'رحلة البحث عن العلم الإلهي وفهم ألطاف الله الخفية في أقدار العباد',
      category: StoryCategory.prophet,
      narrator: 'د. عمر عبد الكافي',
      seriesName: 'صفوة الصفوة والوعد الحق',
      scholarId: 'abdelkafy',
      duration: '٤٦ دقيقة',
      durationSeconds: 2760,
      fileSizeBytes: 22100000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/06.mp3',
      era: 'مجمع البحرين وسيناء',
      surahsMentioned: ['الكهف'],
      summary: 'رحلة الكليم موسى مع العبد الصالح الخضر لكشف أسرار خرق السفينة وقتل الغلام وبناء الجدار، والبرهان على أن ما نكرهه في ظاهره قد يكون عين الرحمة والنجاة.',
      keyLessons: [
        'التواضع في طلب العلم مهما بلغت منزلة العالم.',
        'أقدار الله كلها خير وإن خفيت حكمتها على مدارك العقول القاصرة.',
      ],
      propheticDuaa: 'وَمَا فَعَلْتُهُ عَنْ أَمْرِي ۚ ذَٰلِكَ تَأْوِيلُ مَا لَمْ تَسْطِع عَّلَيْهِ صَبْرًا',
      duaaReference: 'سورة الكهف: ٨٢',
      isUluAlAzm: false,
    ),

    // --- روائع كبار العلماء: فضيلة الشيخ عثمان الخميس ---
    ProphetAudioStory(
      id: 'othman_khamis_yusuf',
      title: 'قصة يوسف الصديق والعفة في زمن الفتن (الشيخ عثمان الخميس)',
      characterName: 'يوسف الصديق عليه السلام',
      subtitle: 'شرح تحليلي فقهي وتربوي لمعالم قصة الصديق مع فضيلة الشيخ عثمان الخميس',
      category: StoryCategory.prophet,
      narrator: 'الشيخ عثمان الخميس',
      seriesName: 'سلسلة القصص القرآني والأنبياء',
      scholarId: 'othman_khamis',
      duration: '٤٩ دقيقة',
      durationSeconds: 2940,
      fileSizeBytes: 23500000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/05.mp3',
      era: 'مصر القديمة',
      surahsMentioned: ['يوسف'],
      summary: 'استعراض أصيل ومتقن لمحطات سيرة يوسف عليه السلام من كيد الإخوة والجب، إلى فتنة امرأة العزيز والسجن، ووصولاً للتمكين والتسامح مع المعتدين.',
      keyLessons: [
        'معاذ الله: كلمة النجاة عند هجوم الفتن والشهوات.',
        'الصبر الجميل مفتاح العز في الدنيا والآخرة.',
      ],
      propheticDuaa: 'إِنَّهُ مَن يَتَّقِ وَيَصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ',
      duaaReference: 'سورة يوسف: ٩٠',
      isUluAlAzm: false,
    ),
    ProphetAudioStory(
      id: 'othman_khamis_muhammad',
      title: 'معالم النبوة وشمائل الحبيب المصطفى ﷺ (الشيخ عثمان الخميس)',
      characterName: 'محمد رسول الله ﷺ',
      subtitle: 'السيرة العطرة وأخلاق النبوة التي أضاءت الدنيا بالرحمة والهدى',
      category: StoryCategory.prophet,
      narrator: 'الشيخ عثمان الخميس',
      seriesName: 'سلسلة القصص القرآني والأنبياء',
      scholarId: 'othman_khamis',
      duration: '٥٢ دقيقة',
      durationSeconds: 3120,
      fileSizeBytes: 24900000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/11.mp3',
      era: 'مكة المكرمة والمدينة المنورة',
      surahsMentioned: ['الأحزاب', 'محمد', 'الفتح', 'التوبة'],
      summary: 'بيان شافي لخصائص وشمائل نبي الرحمة محمد ﷺ، وكيف قاد الأمة من ظلمات الجاهلية إلى نور الإسلام بالأخلاق الرفيعة والرحمة المهداة.',
      keyLessons: [
        'رحمته ﷺ شملت الأعداء والأطفال والحيوان والجماد.',
        'اتباع سنته الشريفة هو المقياس الأوحد لمحبة الله.',
      ],
      propheticDuaa: 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍ',
      duaaReference: 'سورة القلم: ٤',
      isUluAlAzm: true,
    ),

    // --- روائع كبار العلماء: فضيلة الدكتور محمد راتب النابلسي ---
    ProphetAudioStory(
      id: 'nabulsi_ibrahim',
      title: 'إبراهيم الخليل واليقين والتوحيد الخالص (د. محمد راتب النابلسي)',
      characterName: 'إبراهيم عليه السلام',
      subtitle: 'بصائر إيمانية وفكرية في مقام الخلة والاستسلام الكامل لله رب العالمين',
      category: StoryCategory.prophet,
      narrator: 'د. محمد راتب النابلسي',
      seriesName: 'أبطال العقيدة والتوحيد',
      scholarId: 'ratib_nabulsi',
      duration: '٤٠ دقيقة',
      durationSeconds: 2400,
      fileSizeBytes: 19200000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/04.mp3',
      era: 'بابل والشام والحجاز',
      surahsMentioned: ['الأنعام', 'إبراهيم', 'الصافات'],
      summary: 'تحليل دقيق لأدلة إبراهيم العقلية في مواجهة النمرود وقومه عبدة الكواكب، وبيان كيف تجعل قوة العقيدة واليقين النيران برداً وسلاماً.',
      keyLessons: [
        'التوحيد الخالص يحرر العقل والنفس من كل عبودية لسوى الله.',
        'اليقين بالله يحيل المحن المهلكة إلى أمان ونصر.',
      ],
      propheticDuaa: 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      duaaReference: 'صحيح البخاري: ٤٥٦٣',
      isUluAlAzm: true,
    ),
    ProphetAudioStory(
      id: 'nabulsi_yunus',
      title: 'يونس عليه السلام ودعوة ذي النون في الظلمات (د. محمد راتب النابلسي)',
      characterName: 'يونس عليه السلام',
      subtitle: 'قانون تفريج الكربات ولحظات النجاة بالاعتراف بالتقصير والتوحيد',
      category: StoryCategory.prophet,
      narrator: 'د. محمد راتب النابلسي',
      seriesName: 'أبطال العقيدة والتوحيد',
      scholarId: 'ratib_nabulsi',
      duration: '٣٧ دقيقة',
      durationSeconds: 2220,
      fileSizeBytes: 17700000,
      audioUrl: 'https://archive.org/download/qasas-anbiya/07.mp3',
      era: 'نينوى (العراق) والبحر الأبيض المتوسط',
      surahsMentioned: ['الأنبياء', 'الصافات', 'القلم'],
      summary: 'بيان أسرار دعاء ذي النون: لا إله إلا أنت سبحانك إني كنت من الظالمين، وكيف يمثل هذا الدعاء طوق نجاة لكل مكروب ومهموم في الدنيا والآخرة.',
      keyLessons: [
        'لا يأس من رحمة الله حتى في أحلك الظلمات.',
        'الاعتراف بالخطأ وتنزيه الله مفتاح الفرج الإلهي العاجل.',
      ],
      propheticDuaa: 'لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      duaaReference: 'سورة الأنبياء: ٨٧',
      isUluAlAzm: false,
    ),
  ];
}
