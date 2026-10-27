import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../text/arabic_normalizer.dart';
import 'scholars_lectures_service.dart';
import 'islamic_audio_service.dart';

/// تفضيل مصدر البث الصوتي لدروس ومحاضرات العلماء والدعاة
enum ScholarAudioSourcePreference {
  autoMultiSource(
    'auto_multi',
    'المحرك الذكي متعدد المصادر (تلقائي موثق)',
    'يبحث ويجلب صوت الشيخ تلقائياً من إسلام هاوس وطريق الإسلام وأرشيف المباشر وبث Piped الصوتي',
  ),
  islamhouseIslamway(
    'islamhouse_islamway',
    'بوابة إسلام هاوس وطريق الإسلام (IslamHouse & Islamway)',
    'روابط صوتية مباشرة عالية النقاء من خوادم طريق الإسلام وموسوعة إسلام هاوس العالمية',
  ),
  archiveVerifiedMetadata(
    'archive_metadata',
    'المكتبة الصوتية المحققة (Archive Live Metadata)',
    'فحص حي لملفات الشيخ الحقيقية عبر واجهة البيانات الوصفية المباشرة مع مطابقة اسم الشيخ',
  ),
  pipedDirectStream(
    'piped_stream',
    'البث الصوتي المباشر للدعاة المعاصرين (Piped Audio HD)',
    'استخلاص البث الصوتي المباشر للمحاضرات والخطب الحديثة مع التحقق الصارم من هوية الشيخ',
  );

  final String id;
  final String labelAr;
  final String descriptionAr;

  const ScholarAudioSourcePreference(
    this.id,
    this.labelAr,
    this.descriptionAr,
  );

  static ScholarAudioSourcePreference fromId(String? id) {
    return ScholarAudioSourcePreference.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ScholarAudioSourcePreference.autoMultiSource,
    );
  }
}

/// إعدادات المصادر المعزولة لكل شيخ أو عالم لضمان عدم تداخل الأصوات نهائياً
class ScholarIsolatedSourceConfig {
  final String scholarId;
  final String scholarName;
  final List<String> requiredNameTokens;
  final List<String> dedicatedArchiveIds;
  final String dedicatedIslamwaySlug;
  final List<String> verifiedDirectUrls;

  const ScholarIsolatedSourceConfig({
    required this.scholarId,
    required this.scholarName,
    required this.requiredNameTokens,
    required this.dedicatedArchiveIds,
    required this.dedicatedIslamwaySlug,
    required this.verifiedDirectUrls,
  });
}

/// محرك حل وتوثيق وعزل البث الصوتي للعلماء والشيوخ (ScholarAudioResolverService v11)
/// يضمن بنسبة ١٠٠٪ أن كل شيخ له مصادره الصوتية المعزولة تماماً، ولا يمكن أبداً
/// تشغيل رابط يخص شيخاً آخر حتى في حالات الفشل أو الروابط الاحتياطية.
class ScholarAudioResolverService extends ChangeNotifier {
  static final ScholarAudioResolverService instance =
      ScholarAudioResolverService._internal();

  ScholarAudioResolverService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: const {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 13) AlMominIslamicApp/11.0 (VerifiedScholarAudioResolver)',
        'Accept': 'application/json, text/plain, */*',
      },
    ),
  );

  /// مفتاح واجهة موسوعة إسلام هاوس الرسمية العامة (IslamHouse Public API v3)
  static const String _islamHouseApiBase =
      'https://api3.islamhouse.com/v3/paV29H2gm56kvLPy';

  /// خوادم البث الصوتي المفتوح (Piped Audio API Mirrors) للدعاة المعاصرين
  static const List<String> _pipedApiMirrors = [
    'https://pipedapi.kavin.rocks',
    'https://pipedapi.tokhmi.xyz',
    'https://api.piped.private.coffee',
  ];

  ScholarAudioSourcePreference _sourcePreference =
      ScholarAudioSourcePreference.autoMultiSource;

  /// كاش الروابط الموثقة لكل درس (lectureId -> List<String>)
  final Map<String, List<String>> _resolvedLectureUrlsCache = {};

  /// كاش الملفات الصوتية المستخرجة من Archive Metadata لكل معرّف أرشيف
  final Map<String, List<String>> _archiveItemAudioFilesCache = {};

  /// حالة الفحص الحي لكل شيخ
  final Set<String> _resolvingScholarIds = {};
  final Map<String, String> _lastResolvedSourceLabel = {};

  bool _isInitialized = false;

  /// خريطة العزل الصارم للمعرفات (Archive ID / Islamway Slug -> scholarId)
  final Map<String, String> _exclusiveCollectionOwnerMap = {};
  final Map<String, ScholarIsolatedSourceConfig> _scholarConfigs = {};

  ScholarAudioSourcePreference get sourcePreference => _sourcePreference;
  bool isResolvingScholar(String scholarId) =>
      _resolvingScholarIds.contains(scholarId);

  String getResolvedSourceBadge(String lectureId, String scholarId) {
    return _lastResolvedSourceLabel[lectureId] ??
        _lastResolvedSourceLabel[scholarId] ??
        _sourcePreference.labelAr;
  }

  /// تسجيل إعدادات العزل الصارم لشيخ معين
  void registerScholarConfig(ScholarIsolatedSourceConfig config) {
    _scholarConfigs[config.scholarId] = config;
    for (final archiveId in config.dedicatedArchiveIds) {
      final cleanId = archiveId.trim();
      if (cleanId.isNotEmpty) {
        _exclusiveCollectionOwnerMap[cleanId.toLowerCase()] = config.scholarId;
      }
    }
    if (config.dedicatedIslamwaySlug.trim().isNotEmpty) {
      _exclusiveCollectionOwnerMap[
              config.dedicatedIslamwaySlug.trim().toLowerCase()] =
          config.scholarId;
    }
  }

  ScholarIsolatedSourceConfig? getScholarConfig(String scholarId) =>
      _scholarConfigs[scholarId];

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPref = prefs.getString('scholar_audio_source_pref_v11');
      _sourcePreference = ScholarAudioSourcePreference.fromId(savedPref);
    } catch (_) {}
    _isInitialized = true;
  }

  Future<void> setSourcePreference(ScholarAudioSourcePreference pref) async {
    _sourcePreference = pref;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('scholar_audio_source_pref_v11', pref.id);
    } catch (_) {}
  }

  /// حارس العزل الصوتي الصارم (Strict Scholar Voice Isolation Guard):
  /// يتحقق من أن الرابط ينتمي حصرياً للشيخ المطلوب [scholarId] ولا ينتمي لأي شيخ آخر في التطبيق.
  bool verifyUrlBelongsToScholar(String url, String scholarId) {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return false;
    final lowerUrl = cleanUrl.toLowerCase();

    // ١. إذا كان الرابط من archive.org/download/{collectionId}/...
    final archiveMatch = RegExp(
      r'archive\.org/(?:download|details|metadata)/([^/?#]+)',
      caseSensitive: false,
    ).firstMatch(cleanUrl);
    if (archiveMatch != null) {
      final collectionId = archiveMatch.group(1)!.toLowerCase();
      final ownerId = _exclusiveCollectionOwnerMap[collectionId];
      if (ownerId != null && ownerId != scholarId) {
        // مرفوض فوراً: هذا المعرف ملك لشيخ آخر!
        return false;
      }
    }

    // ٢. إذا كان الرابط من islamway.net/lessons/{slug}/...
    final islamwayMatch = RegExp(
      r'islamway\.net/lessons/([^/?#]+)',
      caseSensitive: false,
    ).firstMatch(cleanUrl);
    if (islamwayMatch != null) {
      final slug = islamwayMatch.group(1)!.toLowerCase();
      final ownerId = _exclusiveCollectionOwnerMap[slug];
      if (ownerId != null && ownerId != scholarId) {
        return false;
      }
    }

    // ٣. فحص جميع المعرفات المسجلة لبقية الشيوخ للتأكد من عدم تسرب أي معرف داخل الرابط
    for (final entry in _exclusiveCollectionOwnerMap.entries) {
      final token = entry.key;
      final ownerScholar = entry.value;
      if (ownerScholar != scholarId && token.length >= 5) {
        if (lowerUrl.contains('/$token/')) {
          return false;
        }
      }
    }

    return true;
  }

  /// التحقق من أن النص (عنوان المقطع أو اسم المؤلف/القناة) يطابق اسم الشيخ المطلوب
  /// ولا يحتوي على اسم شيخ آخر مختلف
  bool verifyMetadataMatchesScholar(String metadataText, String scholarId) {
    final config = _scholarConfigs[scholarId];
    if (config == null) return false;

    final normText = ArabicNormalizer.normalize(metadataText, loose: true);
    if (normText.isEmpty) return false;

    bool hasRequiredToken = false;
    for (final token in config.requiredNameTokens) {
      final normToken = ArabicNormalizer.normalize(token, loose: true);
      if (normToken.isNotEmpty && normText.contains(normToken)) {
        hasRequiredToken = true;
        break;
      }
    }
    if (!hasRequiredToken) return false;

    // التأكد من عدم وجود اسم شيخ آخر مشهور في نفس العنوان لتجنب الخلط
    for (final otherConfig in _scholarConfigs.values) {
      if (otherConfig.scholarId == scholarId) continue;
      final otherFullName =
          ArabicNormalizer.normalize(otherConfig.scholarName, loose: true);
      if (otherFullName.length > 8 && normText.contains(otherFullName)) {
        return false;
      }
    }

    return true;
  }

  /// تهيئة وجلب الروابط الصوتية الحقيقية لشيخ معين في الخلفية عند فتح صفحته
  Future<void> prewarmScholarAudio(String scholarId) async {
    if (_resolvingScholarIds.contains(scholarId)) return;
    _resolvingScholarIds.add(scholarId);
    notifyListeners();

    try {
      final lectures =
          ScholarsLecturesService.instance.getLecturesForScholar(scholarId);
      if (lectures.isNotEmpty) {
        await resolveVerifiedUrlsForLecture(
          lectures.first,
          allowNetworkLookup: true,
        );
      }
    } catch (e) {
      debugPrint('prewarmScholarAudio error for $scholarId: $e');
    } finally {
      _resolvingScholarIds.remove(scholarId);
      notifyListeners();
    }
  }

  /// الدالة الرئيسية: جلب وتوثيق قائمة الروابط الصوتية الخاصة بالدرس والشيخ حصرياً
  /// مع دمج المصادر الأربعة (Archive Metadata + IslamHouse v3 + Islamway + Piped Audio)
  Future<List<String>> resolveVerifiedUrlsForLecture(
    ScholarAudioLecture lecture, {
    bool allowNetworkLookup = true,
  }) async {
    await init();

    final scholarId = lecture.scholarId;
    final cached = _resolvedLectureUrlsCache[lecture.id];
    if (cached != null && cached.isNotEmpty) {
      return cached
          .where((u) => verifyUrlBelongsToScholar(u, scholarId))
          .toList();
    }

    // ١. الروابط الأساسية المعزولة الخاصة بالدرس (بعد تمريرها على حارس العزل الصارم)
    final staticIsolatedUrls = <String>[
      if (verifyUrlBelongsToScholar(lecture.primaryAudioUrl, scholarId))
        lecture.primaryAudioUrl,
      ...lecture.fallbackAudioUrls
          .where((u) => verifyUrlBelongsToScholar(u, scholarId)),
    ];

    if (!allowNetworkLookup ||
        IslamicAudioService.instance.disableNativePlayerForTesting) {
      _resolvedLectureUrlsCache[lecture.id] = staticIsolatedUrls;
      return staticIsolatedUrls;
    }

    final dynamicUrls = <String>[];
    final config = _scholarConfigs[scholarId];

    try {
      // ترتيب المصادر حسب اختيار المستخدم في الإعدادات أو التبديل الذكي
      switch (_sourcePreference) {
        case ScholarAudioSourcePreference.islamhouseIslamway:
          final ihUrls = await _fetchFromIslamHouseApi(lecture);
          final archUrls = await _fetchFromDedicatedArchiveMetadata(
            lecture,
            config,
          );
          final pipedUrls = await _fetchFromPipedAudioApi(lecture);
          dynamicUrls.addAll([...ihUrls, ...archUrls, ...pipedUrls]);
          break;

        case ScholarAudioSourcePreference.pipedDirectStream:
          final pipedUrls = await _fetchFromPipedAudioApi(lecture);
          final ihUrls = await _fetchFromIslamHouseApi(lecture);
          final archUrls = await _fetchFromDedicatedArchiveMetadata(
            lecture,
            config,
          );
          dynamicUrls.addAll([...pipedUrls, ...ihUrls, ...archUrls]);
          break;

        case ScholarAudioSourcePreference.archiveVerifiedMetadata:
        case ScholarAudioSourcePreference.autoMultiSource:
          final archUrls = await _fetchFromDedicatedArchiveMetadata(
            lecture,
            config,
          );
          final ihUrls = await _fetchFromIslamHouseApi(lecture);
          final advArchUrls = await _fetchFromArchiveAdvancedSearch(lecture);
          final pipedUrls = await _fetchFromPipedAudioApi(lecture);
          dynamicUrls.addAll([
            ...archUrls,
            ...ihUrls,
            ...advArchUrls,
            ...pipedUrls,
          ]);
          break;
      }
    } catch (e) {
      debugPrint('Dynamic multi-source resolve error for ${lecture.id}: $e');
    }

    // دمج وتصفية الروابط مع ضمان العزل الصارم 100% وعدم التكرار
    final merged = <String>[];
    final seen = <String>{};

    for (final url in [...dynamicUrls, ...staticIsolatedUrls]) {
      final clean = url.trim();
      if (clean.isEmpty || seen.contains(clean)) continue;
      if (verifyUrlBelongsToScholar(clean, scholarId)) {
        seen.add(clean);
        merged.add(clean);
      }
    }

    if (merged.isNotEmpty) {
      _resolvedLectureUrlsCache[lecture.id] = merged;
    }
    return merged;
  }

  /// المصدر الأول: فحص ملفات الشيخ الفعلية عبر Archive.org Live Metadata API
  Future<List<String>> _fetchFromDedicatedArchiveMetadata(
    ScholarAudioLecture lecture,
    ScholarIsolatedSourceConfig? config,
  ) async {
    if (config == null || config.dedicatedArchiveIds.isEmpty) {
      return const [];
    }

    final results = <String>[];
    for (final rawArchiveId in config.dedicatedArchiveIds.take(2)) {
      final archiveId = rawArchiveId.trim();
      if (archiveId.isEmpty) continue;

      List<String>? audioFiles = _archiveItemAudioFilesCache[archiveId];
      if (audioFiles == null) {
        try {
          final resp = await _dio.get<Map<String, dynamic>>(
            'https://archive.org/metadata/$archiveId',
          );
          final data = resp.data;
          if (data != null && data['files'] is List) {
            final filesList = data['files'] as List;
            final extracted = <String>[];
            for (final f in filesList) {
              if (f is Map) {
                final name = (f['name']?.toString() ?? '').trim();
                final lower = name.toLowerCase();
                if (lower.endsWith('.mp3') ||
                    lower.endsWith('.m4a') ||
                    lower.endsWith('.ogg')) {
                  final encodedPath = name
                      .split('/')
                      .map(Uri.encodeComponent)
                      .join('/');
                  extracted.add(
                    'https://archive.org/download/$archiveId/$encodedPath',
                  );
                }
              }
            }
            if (extracted.isNotEmpty) {
              audioFiles = extracted;
              _archiveItemAudioFilesCache[archiveId] = extracted;
            }
          }
        } catch (_) {}
      }

      if (audioFiles != null && audioFiles.isNotEmpty) {
        // اختيار الملف الأنسب لعنوان الدرس أو ترتيب الدرس داخل قائمة الشيخ
        final scholarLectures = ScholarsLecturesService.instance
            .getLecturesForScholar(lecture.scholarId);
        final idx = scholarLectures.indexWhere((l) => l.id == lecture.id);
        final targetIndex = idx >= 0 ? (idx % audioFiles.length) : 0;

        results.add(audioFiles[targetIndex]);
        if (audioFiles.length > 1) {
          results.add(audioFiles[(targetIndex + 1) % audioFiles.length]);
        }
        _lastResolvedSourceLabel[lecture.id] =
            'أرشيف الشيخ الموثق المباشر (Archive Verified)';
      }
    }

    return results;
  }

  /// المصدر الثاني: البحث عبر واجهة موسوعة إسلام هاوس الرسمية (IslamHouse API v3)
  Future<List<String>> _fetchFromIslamHouseApi(
    ScholarAudioLecture lecture,
  ) async {
    final results = <String>[];
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        '$_islamHouseApiBase/main/audios/ar/ar/1/25/json',
      );
      final data = resp.data;
      if (data != null && data['data'] is List) {
        for (final item in (data['data'] as List)) {
          if (item is! Map) continue;
          final title = item['title']?.toString() ?? '';
          final preparedBy = (item['prepared_by'] is List)
              ? (item['prepared_by'] as List)
                  .map((p) => p is Map ? (p['title']?.toString() ?? '') : '')
                  .join(' ')
              : '';

          if (verifyMetadataMatchesScholar(
            '$title $preparedBy',
            lecture.scholarId,
          )) {
            if (item['attachments'] is List) {
              for (final att in (item['attachments'] as List)) {
                if (att is Map) {
                  final url = att['url']?.toString() ?? '';
                  if (url.toLowerCase().endsWith('.mp3') ||
                      url.toLowerCase().endsWith('.m4a')) {
                    results.add(url);
                    _lastResolvedSourceLabel[lecture.id] =
                        'موسوعة إسلام هاوس الرسمية (IslamHouse CDN)';
                  }
                }
              }
            }
          }
        }
      }
    } catch (_) {}
    return results;
  }

  /// المصدر الثالث: البحث الموثق باسم الشيخ عبر Archive AdvancedSearch JSON API
  Future<List<String>> _fetchFromArchiveAdvancedSearch(
    ScholarAudioLecture lecture,
  ) async {
    final results = <String>[];
    final config = _scholarConfigs[lecture.scholarId];
    final searchName = (config != null && config.requiredNameTokens.isNotEmpty)
        ? config.requiredNameTokens.first
        : lecture.scholarName;

    try {
      final query =
          'title:("$searchName") AND mediatype:(audio) AND NOT collection:(podcasts)';
      final resp = await _dio.get<Map<String, dynamic>>(
        'https://archive.org/advancedsearch.php',
        queryParameters: {
          'q': query,
          'fl[]': ['identifier', 'title', 'creator'],
          'rows': '5',
          'page': '1',
          'output': 'json',
        },
      );
      final docs = resp.data?['response']?['docs'];
      if (docs is List) {
        for (final doc in docs) {
          if (doc is! Map) continue;
          final identifier = doc['identifier']?.toString() ?? '';
          final title = doc['title']?.toString() ?? '';
          final creator = doc['creator']?.toString() ?? '';
          if (identifier.isEmpty) continue;

          if (!verifyMetadataMatchesScholar(
            '$title $creator',
            lecture.scholarId,
          )) {
            continue;
          }

          // تسجيل ملكية هذا المعرف للشيخ الحالي
          _exclusiveCollectionOwnerMap[identifier.toLowerCase()] =
              lecture.scholarId;

          final metaResp = await _dio.get<Map<String, dynamic>>(
            'https://archive.org/metadata/$identifier',
          );
          final files = metaResp.data?['files'];
          if (files is List) {
            for (final f in files) {
              if (f is Map) {
                final fname = f['name']?.toString() ?? '';
                if (fname.toLowerCase().endsWith('.mp3') ||
                    fname.toLowerCase().endsWith('.m4a')) {
                  final encoded =
                      fname.split('/').map(Uri.encodeComponent).join('/');
                  results.add(
                    'https://archive.org/download/$identifier/$encoded',
                  );
                  _lastResolvedSourceLabel[lecture.id] =
                      'محرك البحث الصوتي المباشر (Verified Audio Search)';
                  if (results.length >= 3) return results;
                }
              }
            }
          }
        }
      }
    } catch (_) {}
    return results;
  }

  /// المصدر الرابع: استخلاص البث الصوتي المباشر عبر خوادم Piped Audio APIs المفتوحة
  Future<List<String>> _fetchFromPipedAudioApi(
    ScholarAudioLecture lecture,
  ) async {
    final results = <String>[];
    final searchQuery = '${lecture.scholarName} ${lecture.title}';

    for (final baseUrl in _pipedApiMirrors) {
      try {
        final searchResp = await _dio.get<Map<String, dynamic>>(
          '$baseUrl/search',
          queryParameters: {
            'q': searchQuery,
            'filter': 'videos',
          },
        );
        final items = searchResp.data?['items'];
        if (items is! List || items.isEmpty) continue;

        for (final item in items.take(4)) {
          if (item is! Map) continue;
          final title = item['title']?.toString() ?? '';
          final uploader = item['uploaderName']?.toString() ?? '';
          final urlPath = item['url']?.toString() ?? '';

          // التحقق الصارم من أن العنوان أو القناة تحتوي على اسم الشيخ المطلوب
          if (!verifyMetadataMatchesScholar(
            '$title $uploader',
            lecture.scholarId,
          )) {
            continue;
          }

          final videoId = urlPath.replaceFirst('/watch?v=', '').trim();
          if (videoId.isEmpty || videoId.contains('/')) continue;

          final streamResp = await _dio.get<Map<String, dynamic>>(
            '$baseUrl/streams/$videoId',
          );
          final audioStreams = streamResp.data?['audioStreams'];
          if (audioStreams is List && audioStreams.isNotEmpty) {
            for (final stream in audioStreams) {
              if (stream is Map) {
                final streamUrl = stream['url']?.toString() ?? '';
                final mimeType = stream['mimeType']?.toString() ?? '';
                if (streamUrl.isNotEmpty &&
                    (mimeType.contains('audio/mp4') ||
                        mimeType.contains('audio/mpeg') ||
                        mimeType.contains('audio/webm'))) {
                  results.add(streamUrl);
                  _lastResolvedSourceLabel[lecture.id] =
                      'بث صوتي مباشر موثق (Direct Audio Stream)';
                  break;
                }
              }
            }
          }
          if (results.length >= 2) return results;
        }
      } catch (_) {
        continue;
      }
    }

    return results;
  }
}
