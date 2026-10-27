import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../text/arabic_normalizer.dart';
import 'quran_repository.dart';

class QuranReferenceMatch {
  final int surahId;
  final int ayahNumber;
  final String title;
  final String? aliasNote;

  const QuranReferenceMatch({
    required this.surahId,
    required this.ayahNumber,
    required this.title,
    this.aliasNote,
  });
}

class AyahSearchResult {
  final Ayah ayah;
  final Surah surah;
  final String query;

  const AyahSearchResult({
    required this.ayah,
    required this.surah,
    required this.query,
  });
}

class QuranSearchService {
  static final QuranSearchService instance = QuranSearchService._internal();
  QuranSearchService._internal();

  static const String _historyKey = 'quran_search_history_v1';

  static const Map<String, String> _rawAliases = {
    'آية الكرسي': '2:255',
    'الكرسي': '2:255',
    'آية الدين': '2:282',
    'الدين': '2:282',
    'خواتيم البقرة': '2:285',
    'أواخر البقرة': '2:285',
    'آية النور': '24:35',
    'الله نور السماوات': '24:35',
    'آية السيف': '9:5',
    'آية المباهلة': '3:61',
    'آية التطهير': '33:33',
    'آية المودة': '42:23',
    'آية الحجاب': '33:59',
    'آية العرش': '9:129',
    'آية الصيام': '2:183',
    'كتب عليكم الصيام': '2:183',
    'آية البر': '2:177',
    'آية الوضوء': '5:6',
    'آية التيمم': '4:43',
    'آية القبلة': '2:144',
    'تحويل القبلة': '2:144',
    'آية الربا': '2:275',
    'آية الأمانة': '33:72',
    'إنا عرضنا الأمانة': '33:72',
    'آية الخلافة': '2:30',
    'إني جاعل في الأرض خليفة': '2:30',
    'آية الاسترجاع': '2:156',
    'إنا لله وإنا إليه راجعون': '2:156',
  };

  static Map<String, String>? _normalizedAliasesCache;
  static Map<String, String> get _normalizedAliases {
    _normalizedAliasesCache ??= {
      for (final entry in _rawAliases.entries)
        ArabicNormalizer.normalize(entry.key, loose: true): entry.value
    };
    return _normalizedAliasesCache!;
  }

  /// Cached pre-normalized Ayah index per Surah ID so searchAyahs does not re-normalize
  /// all 6,236 Ayahs from scratch on every keystroke (Bug #16 fix).
  static Map<int, List<MapEntry<Ayah, String>>>? _normalizedSurahAyahsCache;

  Future<Map<int, List<MapEntry<Ayah, String>>>> _ensureNormalizedIndex() async {
    if (_normalizedSurahAyahsCache != null) {
      return _normalizedSurahAyahsCache!;
    }
    final pagesMap = await QuranRepository.loadAllPages();
    final Map<int, List<MapEntry<Ayah, String>>> index = {};
    for (int page = 1; page <= 604; page++) {
      final ayahs = pagesMap[page] ?? [];
      for (final ayah in ayahs) {
        final norm = ArabicNormalizer.normalize(ayah.textUthmani, loose: true);
        index.putIfAbsent(ayah.surahId, () => []).add(MapEntry(ayah, norm));
      }
    }
    _normalizedSurahAyahsCache = index;
    return index;
  }

  /// Parses input for direct ayah reference e.g. "2:255", "٢:٢٥٥", "البقرة 255",
  /// "البقرة: 255", "سورة البقرة آية ٢٥٥", or common aliases (Bug #16 fix).
  Future<QuranReferenceMatch?> parseReference(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    final normalized = ArabicNormalizer.normalize(trimmed, loose: true);

    // 1. Check known aliases
    if (_normalizedAliases.containsKey(normalized)) {
      final target = _normalizedAliases[normalized]!;
      final parts = target.split(':');
      final sId = int.tryParse(parts[0]) ?? 1;
      final aNum = int.tryParse(parts[1]) ?? 1;
      final surahs = await QuranRepository.loadSurahs();
      if (surahs.isEmpty) return null;
      final surah = surahs.firstWhere((s) => s.id == sId, orElse: () => surahs.first);
      return QuranReferenceMatch(
        surahId: sId,
        ayahNumber: aNum,
        title: '${surah.nameAr} — آية $aNum',
        aliasNote: 'تسمية مشهورة: $trimmed',
      );
    }

    // 2. Check for format "2:255" or "٢:٢٥٥"
    final colonRegex = RegExp(r'^(\d+)\s*[:：/-]\s*(\d+)$');
    final matchColon = colonRegex.firstMatch(normalized);
    if (matchColon != null) {
      final sId = int.tryParse(matchColon.group(1)!);
      final aNum = int.tryParse(matchColon.group(2)!);
      if (sId != null && aNum != null && sId >= 1 && sId <= 114) {
        final surahs = await QuranRepository.loadSurahs();
        if (surahs.isEmpty) return null;
        final surah = surahs.firstWhere((s) => s.id == sId, orElse: () => surahs.first);
        if (aNum >= 1 && aNum <= surah.ayahCount) {
          return QuranReferenceMatch(
            surahId: sId,
            ayahNumber: aNum,
            title: '${surah.nameAr} — آية $aNum',
            aliasNote: 'مرجع مباشر: $sId:$aNum',
          );
        }
      }
    }

    // 3. Check for format "<SurahName> [:|آية|اية] <AyahNum>" e.g. "البقرة 255", "البقرة: ٢٥٥", "سورة الكهف آية 10"
    final surahs = await QuranRepository.loadSurahs();
    for (final s in surahs) {
      final normSurahName = ArabicNormalizer.normalize(s.nameAr, loose: true);
      final cleanName = normSurahName.replaceAll(RegExp(r'^(?:سوره|سورة)\s+'), '').trim();
      final pattern = RegExp(
        '^(?:(?:سوره|سورة)\\s+)?(?:${RegExp.escape(normSurahName)}|${RegExp.escape(cleanName)})(?:\\s*[:：-]\\s*|\\s+(?:(?:ايه|آيه|آية|اية)\\s+)?)(\\d+)\$',
      );
      final match = pattern.firstMatch(normalized);
      if (match != null) {
        final aNum = int.tryParse(match.group(1)!);
        if (aNum != null && aNum >= 1 && aNum <= s.ayahCount) {
          return QuranReferenceMatch(
            surahId: s.id,
            ayahNumber: aNum,
            title: 'سورة ${s.nameAr} — آية $aNum',
            aliasNote: 'بحث بالاسم والرقم',
          );
        }
      }
    }

    return null;
  }

  /// Searches for Ayahs matching query across all 6,236 Ayahs using cached normalized index (FR-SRC-001)
  Future<List<AyahSearchResult>> searchAyahs(
    String query, {
    int? surahFilter,
    int limit = 100,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final normalizedQuery = ArabicNormalizer.normalize(cleanQuery, loose: true);
    final surahs = await QuranRepository.loadSurahs();
    if (surahs.isEmpty) return [];
    final surahMap = {for (final s in surahs) s.id: s};
    final index = await _ensureNormalizedIndex();

    final List<AyahSearchResult> results = [];

    if (surahFilter != null) {
      final entries = index[surahFilter] ?? [];
      final surah = surahMap[surahFilter] ?? surahs.first;
      for (final entry in entries) {
        if (entry.value.contains(normalizedQuery)) {
          results.add(AyahSearchResult(ayah: entry.key, surah: surah, query: cleanQuery));
          if (results.length >= limit) break;
        }
      }
    } else {
      for (int sId = 1; sId <= 114; sId++) {
        final entries = index[sId] ?? [];
        final surah = surahMap[sId] ?? surahs.first;
        for (final entry in entries) {
          if (entry.value.contains(normalizedQuery)) {
            results.add(AyahSearchResult(ayah: entry.key, surah: surah, query: cleanQuery));
            if (results.length >= limit) return results;
          }
        }
      }
    }

    return results;
  }

  /// Loads search history from SharedPreferences (FR-SRC-004)
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [
      'آية الكرسي',
      'الرحمن الرحيم',
      'سورة الكهف',
      'خواتيم البقرة',
      'الله نور السماوات',
    ];
  }

  /// Adds a query to search history
  Future<void> addToHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty || trimmed.length < 2) return;

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];

    list.remove(trimmed);
    list.insert(0, trimmed);

    if (list.length > 20) {
      list.removeRange(20, list.length);
    }

    await prefs.setStringList(_historyKey, list);
  }

  /// Removes single item from search history
  Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    list.remove(query);
    await prefs.setStringList(_historyKey, list);
  }

  /// Clears full search history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
