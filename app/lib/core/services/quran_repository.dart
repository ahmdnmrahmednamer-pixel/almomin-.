import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah.dart';
import '../models/juz.dart';
import '../models/ayah.dart';
import '../text/arabic_normalizer.dart';

class PageMetadata {
  final int pageNumber;
  final int juzNumber;
  final int hizbNumber;
  final int surahId;
  final String surahName;
  final int startAyah;
  final bool hasSurahStart;

  const PageMetadata({
    required this.pageNumber,
    required this.juzNumber,
    required this.hizbNumber,
    required this.surahId,
    required this.surahName,
    required this.startAyah,
    required this.hasSurahStart,
  });
}

class BookmarkDetail {
  final int surahId;
  final int ayahNumber;
  final int pageNumber;
  final String surahName;
  final String textSnippet;

  const BookmarkDetail({
    required this.surahId,
    required this.ayahNumber,
    required this.pageNumber,
    required this.surahName,
    required this.textSnippet,
  });
}

class QuranRepository {
  static List<Surah>? _cachedSurahs;
  static List<Juz>? _cachedJuz;
  static Map<String, List<Ayah>>? _cachedAyahsBySurah;
  static Map<int, List<Ayah>>? _cachedAyahsByPage;
  static Map<int, PageMetadata>? _cachedPageMetadata;

  /// Loads all 114 Surahs from the bundled asset
  static Future<List<Surah>> loadSurahs() async {
    if (_cachedSurahs != null) return _cachedSurahs!;
    final jsonString = await rootBundle.loadString('assets/data/surahs.json');
    final List<dynamic> data = json.decode(jsonString);
    _cachedSurahs = data.map((item) => Surah.fromJson(item)).toList();
    return _cachedSurahs!;
  }

  /// Loads all 30 Juz from the bundled asset
  static Future<List<Juz>> loadJuz() async {
    if (_cachedJuz != null) return _cachedJuz!;
    final jsonString = await rootBundle.loadString('assets/data/juz.json');
    final List<dynamic> data = json.decode(jsonString);
    _cachedJuz = data.map((item) => Juz.fromJson(item)).toList();
    return _cachedJuz!;
  }

  /// Finds surah by ID
  static Future<Surah?> getSurahById(int id) async {
    final surahs = await loadSurahs();
    return surahs.firstWhere((s) => s.id == id, orElse: () => surahs.first);
  }

  /// Loads all ayahs map
  static Future<Map<String, List<Ayah>>> _loadAllAyahsMap() async {
    if (_cachedAyahsBySurah != null) return _cachedAyahsBySurah!;
    final jsonString = await rootBundle.loadString('assets/data/quran_ayahs.json');
    final Map<String, dynamic> rawMap = json.decode(jsonString);
    final Map<String, List<Ayah>> result = {};
    for (final entry in rawMap.entries) {
      final List<dynamic> list = entry.value;
      result[entry.key] = list.map((item) => Ayah.fromRow(item)).toList();
    }
    _cachedAyahsBySurah = result;
    return _cachedAyahsBySurah!;
  }

  static final Map<int, List<Ayah>> _cachedSurahsAyahs = {};

  /// Loads all ayahs for a given surah ID (1..114) instantly
  static Future<List<Ayah>> getAyahsForSurah(int surahId) async {
    if (_cachedSurahsAyahs.containsKey(surahId)) {
      return _cachedSurahsAyahs[surahId]!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/surahs/$surahId.json');
      final List<dynamic> list = json.decode(jsonString);
      final ayahs = list.map((item) => Ayah.fromRow(item)).toList();
      _cachedSurahsAyahs[surahId] = ayahs;
      return ayahs;
    } catch (_) {
      try {
        final allMap = await _loadAllAyahsMap();
        final ayahs = allMap[surahId.toString()] ?? [];
        _cachedSurahsAyahs[surahId] = ayahs;
        return ayahs;
      } catch (_) {
        return [];
      }
    }
  }

  /// Loads all ayahs indexed by page number (1..604)
  static Future<Map<int, List<Ayah>>> loadAllPages() async {
    if (_cachedAyahsByPage != null) return _cachedAyahsByPage!;
    final allMap = await _loadAllAyahsMap();
    final Map<int, List<Ayah>> pages = {};
    for (int p = 1; p <= 604; p++) {
      pages[p] = [];
    }
    for (final ayahs in allMap.values) {
      for (final ayah in ayahs) {
        if (ayah.page >= 1 && ayah.page <= 604) {
          pages[ayah.page]?.add(ayah);
        }
      }
    }
    _cachedAyahsByPage = pages;
    return _cachedAyahsByPage!;
  }

  /// Gets all ayahs on a given page (1..604)
  static Future<List<Ayah>> getAyahsForPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return [];
    final pagesMap = await loadAllPages();
    return pagesMap[pageNumber] ?? [];
  }

  /// Retrieves metadata for a given page (surah name, juz, start ayah, etc.)
  static Future<PageMetadata?> getPageMetadata(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) return null;
    if (_cachedPageMetadata != null && _cachedPageMetadata!.containsKey(pageNumber)) {
      return _cachedPageMetadata![pageNumber];
    }

    final ayahs = await getAyahsForPage(pageNumber);
    if (ayahs.isEmpty) return null;

    final firstAyah = ayahs.first;
    final surahs = await loadSurahs();
    final surah = surahs.firstWhere((s) => s.id == firstAyah.surahId, orElse: () => surahs.first);
    final hasStart = ayahs.any((a) => a.ayahNumber == 1);

    final meta = PageMetadata(
      pageNumber: pageNumber,
      juzNumber: firstAyah.juz,
      hizbNumber: firstAyah.hizb,
      surahId: firstAyah.surahId,
      surahName: surah.nameAr,
      startAyah: firstAyah.ayahNumber,
      hasSurahStart: hasStart,
    );

    _cachedPageMetadata ??= {};
    _cachedPageMetadata![pageNumber] = meta;
    return meta;
  }

  /// Gets a single ayah by surah ID and ayah number
  static Future<Ayah?> getAyah(int surahId, int ayahNumber) async {
    final ayahs = await getAyahsForSurah(surahId);
    try {
      return ayahs.firstWhere((a) => a.ayahNumber == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  /// In-memory search helper matching ArabicNormalizer specification
  static Future<List<Surah>> searchSurahs(String query) async {
    final surahs = await loadSurahs();
    if (query.trim().isEmpty) return surahs;
    final normalizedQuery = ArabicNormalizer.normalize(query, loose: true);
    return surahs.where((s) {
      final nameNorm = ArabicNormalizer.normalize(s.nameAr, loose: true);
      final simpleNorm = s.nameSimple.toLowerCase();
      final idStr = s.id.toString();
      return nameNorm.contains(normalizedQuery) ||
             simpleNorm.contains(query.toLowerCase()) ||
             idStr == query.trim();
    }).toList();
  }

  /// Full-text search across all 6,236 Ayahs
  static Future<List<Ayah>> searchAyahs(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];
    final allMap = await _loadAllAyahsMap();
    final normalizedQuery = ArabicNormalizer.normalize(query, loose: true);
    final List<Ayah> matches = [];

    for (final ayahs in allMap.values) {
      for (final ayah in ayahs) {
        final norm = ArabicNormalizer.normalize(ayah.textUthmani, loose: true);
        if (norm.contains(normalizedQuery)) {
          matches.add(ayah);
          if (matches.length >= limit) return matches;
        }
      }
    }
    return matches;
  }

  /// Resolves rich details for a list of bookmark keys (e.g. ['2:255', '1:1'])
  static Future<List<BookmarkDetail>> getBookmarksDetails(List<String> bookmarkKeys) async {
    final List<BookmarkDetail> result = [];
    final surahs = await loadSurahs();

    for (final key in bookmarkKeys) {
      final parts = key.split(':');
      if (parts.length == 2) {
        final surahId = int.tryParse(parts[0]);
        final ayahNum = int.tryParse(parts[1]);
        if (surahId != null && ayahNum != null) {
          final ayah = await getAyah(surahId, ayahNum);
          final surah = surahs.firstWhere((s) => s.id == surahId, orElse: () => surahs.first);
          if (ayah != null) {
            result.add(BookmarkDetail(
              surahId: surahId,
              ayahNumber: ayahNum,
              pageNumber: ayah.page,
              surahName: surah.nameAr,
              textSnippet: ayah.textUthmani,
            ));
          }
        }
      }
    }
    return result;
  }
}
