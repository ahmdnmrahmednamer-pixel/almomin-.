import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith.dart';
import '../text/arabic_normalizer.dart';
import 'hadith_data.dart';

class HadithService extends ChangeNotifier {
  HadithService._();
  static final HadithService instance = HadithService._();

  static const String _favoritesKey = 'hadith_favorite_ids';
  static const String _lastReadIdKey = 'hadith_last_read_id';

  final List<HadithBook> _books = List.unmodifiable(kHadithBooks);
  final List<HadithItem> _hadiths = List.unmodifiable(kHadithItems);

  Set<int> _favoriteIds = {};
  int? _lastReadHadithId;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  List<HadithBook> get books => _books;
  List<HadithItem> get allHadiths => _hadiths;
  Set<int> get favoriteIds => _favoriteIds;
  int? get lastReadHadithId => _lastReadHadithId;

  Future<void> init({bool forceReload = false}) async {
    if (_initialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList(_favoritesKey) ?? [];
      _favoriteIds = favList.map((e) => int.tryParse(e)).whereType<int>().toSet();
      _lastReadHadithId = prefs.getInt(_lastReadIdKey);
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing HadithService: $e');
      _initialized = true;
    }
  }

  List<HadithItem> getHadithsByBook(String bookId) {
    return _hadiths.where((h) => h.bookId == bookId).toList();
  }

  HadithItem? getHadithById(int id) {
    for (final h in _hadiths) {
      if (h.id == id) return h;
    }
    return null;
  }

  HadithBook? getBookById(String bookId) {
    for (final b in _books) {
      if (b.id == bookId) return b;
    }
    return null;
  }

  List<HadithItem> getFavorites() {
    return _hadiths.where((h) => _favoriteIds.contains(h.id)).toList();
  }

  bool isFavorite(int id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(int hadithId) async {
    if (_favoriteIds.contains(hadithId)) {
      _favoriteIds.remove(hadithId);
    } else {
      _favoriteIds.add(hadithId);
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favoritesKey,
        _favoriteIds.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint('Error saving hadith favorites: $e');
    }
  }

  Future<void> setLastRead(int hadithId) async {
    _lastReadHadithId = hadithId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastReadIdKey, hadithId);
    } catch (e) {
      debugPrint('Error saving last read hadith: $e');
    }
  }

  HadithItem getHadithOfTheDay() {
    if (_hadiths.isEmpty) {
      return const HadithItem(
        id: 1,
        bookId: 'nawawi',
        numberInBook: 1,
        chapter: 'باب الإخلاص وإحضار النية',
        title: 'الأعمال بالنيات',
        matn: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
        narrator: 'عُمَرَ بْنِ الخَطَّابِ رَضِيَ اللَّهُ عَنْهُ',
        source: 'متفق عليه (البخاري ومسلم)',
        grading: 'صحيح',
        explanation: 'أصل عظيم من أصول الإسلام يدور عليه قبول الأعمال وصلاح القلوب.',
      );
    }
    final now = DateTime.now();
    // Deterministic daily rotation based on day of year
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _hadiths.length;
    return _hadiths[index];
  }

  List<HadithItem> searchHadiths(String query, {String? bookId}) {
    final cleanQuery = ArabicNormalizer.normalize(query.trim());
    if (cleanQuery.isEmpty) {
      return bookId != null ? getHadithsByBook(bookId) : _hadiths;
    }

    return _hadiths.where((h) {
      if (bookId != null && h.bookId != bookId) return false;

      final normTitle = ArabicNormalizer.normalize(h.title);
      final normMatn = ArabicNormalizer.normalize(h.matn);
      final normNarrator = ArabicNormalizer.normalize(h.narrator);
      final normChapter = ArabicNormalizer.normalize(h.chapter);
      final normExplanation = ArabicNormalizer.normalize(h.explanation);

      return normMatn.contains(cleanQuery) ||
          normTitle.contains(cleanQuery) ||
          normNarrator.contains(cleanQuery) ||
          normChapter.contains(cleanQuery) ||
          normExplanation.contains(cleanQuery);
    }).toList();
  }

  String formatShareText(HadithItem hadith) {
    return '''✨ قال رسول الله ﷺ:
${hadith.matn}

📖 الراوي: ${hadith.narrator.replaceAll('عَنْ ', '').replaceAll('عَنِ ', '').split('،').first}
🔖 التخريج: ${hadith.source}
🏷️ درجة الصحة: ${hadith.grading}
💡 من فوائد الحديث: ${hadith.explanation}

──────────────
📱 من تطبيق نور المؤمن — رفيق المسلم اليومي''';
  }

  // Backup & Restore Support
  List<int> exportFavorites() => _favoriteIds.toList();

  Future<void> importFavorites(List<int> ids, {bool replace = false}) async {
    if (replace) {
      _favoriteIds.clear();
    }
    _favoriteIds.addAll(ids);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesKey,
      _favoriteIds.map((e) => e.toString()).toList(),
    );
  }
}
