import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';
import 'quran_repository.dart';

/// Metadata for a downloaded Surah audio file (FR-AUD-004)
class DownloadedSurahInfo {
  final String reciterId;
  final String reciterName;
  final int surahId;
  final String surahName;
  final String localPath;
  final int fileSizeBytes;
  final DateTime downloadedAt;

  const DownloadedSurahInfo({
    required this.reciterId,
    required this.reciterName,
    required this.surahId,
    required this.surahName,
    required this.localPath,
    required this.fileSizeBytes,
    required this.downloadedAt,
  });

  String get formattedSize {
    if (fileSizeBytes <= 0) return '0 MB';
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb < 0.1) {
      final kb = fileSizeBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() {
    return {
      'reciterId': reciterId,
      'reciterName': reciterName,
      'surahId': surahId,
      'surahName': surahName,
      'localPath': localPath,
      'fileSizeBytes': fileSizeBytes,
      'downloadedAt': downloadedAt.toIso8601String(),
    };
  }

  factory DownloadedSurahInfo.fromJson(Map<String, dynamic> json) {
    return DownloadedSurahInfo(
      reciterId: json['reciterId'] as String? ?? '',
      reciterName: json['reciterName'] as String? ?? '',
      surahId: json['surahId'] as int? ?? 1,
      surahName: json['surahName'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 0,
      downloadedAt: DateTime.tryParse(json['downloadedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Service managing audio downloads and offline storage (FR-AUD-004 / T-205 & T-304)
class AudioDownloadService extends ChangeNotifier {
  static final AudioDownloadService instance = AudioDownloadService._internal();
  AudioDownloadService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(minutes: 10),
  ));

  final Map<String, DownloadedSurahInfo> _downloadedSurahs = {};
  final Map<String, double> _activeProgress = {};
  final Map<String, CancelToken> _cancelTokens = {};

  String? _storageDirPath;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Map<String, DownloadedSurahInfo> get downloadedSurahs => Map.unmodifiable(_downloadedSurahs);

  static String _key(String reciterId, int surahId) => '${reciterId}_$surahId';

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final dir = await _getAudioDirectory();
      _storageDirPath = dir.path;
      await _scanStorageDirectory(dir);
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioDownloadService init error: $e');
    }
  }

  Future<Directory> _getAudioDirectory() async {
    if (kIsWeb) {
      return Directory('/web_audio');
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDocDir.path}/quran_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  Future<void> _scanStorageDirectory(Directory dir) async {
    _downloadedSurahs.clear();
    if (!await dir.exists()) return;

    final entities = dir.listSync();
    final reciters = SettingsService.availableReciters;
    Map<int, String> surahNames = {};
    try {
      final surahs = await QuranRepository.loadSurahs();
      surahNames = {for (final s in surahs) s.id: s.nameAr};
    } catch (_) {}

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
        // Format: {reciterId}_{surahNumber3digits}.mp3
        final dotIndex = filename.lastIndexOf('.');
        final raw = dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
        final parts = raw.split('_');
        if (parts.length >= 2) {
          final surahNumStr = parts.last;
          final reciterId = parts.sublist(0, parts.length - 1).join('_');
          final surahId = int.tryParse(surahNumStr);

          if (surahId != null && surahId >= 1 && surahId <= 114) {
            final reciter = reciters.firstWhere(
              (r) => r.id == reciterId,
              orElse: () => reciters.first,
            );
            final length = entity.lengthSync();
            final key = _key(reciterId, surahId);

            _downloadedSurahs[key] = DownloadedSurahInfo(
              reciterId: reciterId,
              reciterName: reciter.nameAr,
              surahId: surahId,
              surahName: surahNames[surahId] ?? 'سورة رقم $surahId',
              localPath: entity.path,
              fileSizeBytes: length,
              downloadedAt: entity.lastModifiedSync(),
            );
          }
        }
      }
    }
  }

  bool isDownloaded(String reciterId, int surahId) {
    final key = _key(reciterId, surahId);
    final info = _downloadedSurahs[key];
    if (info == null) return false;
    final f = File(info.localPath);
    return f.existsSync() && f.lengthSync() > 1000;
  }

  String? getLocalAudioPath(String reciterId, int surahId) {
    final key = _key(reciterId, surahId);
    final info = _downloadedSurahs[key];
    if (info != null && File(info.localPath).existsSync()) {
      return info.localPath;
    }
    return null;
  }

  bool isDownloading(String reciterId, int surahId) {
    return _activeProgress.containsKey(_key(reciterId, surahId));
  }

  double getDownloadProgress(String reciterId, int surahId) {
    return _activeProgress[_key(reciterId, surahId)] ?? 0.0;
  }

  Future<bool> downloadSurah({
    required String reciterId,
    required int surahId,
    required String surahName,
  }) async {
    final key = _key(reciterId, surahId);
    if (isDownloading(reciterId, surahId)) return false;

    await init();
    final dirPath = _storageDirPath;
    if (dirPath == null) return false;

    final sNumStr = surahId.toString().padLeft(3, '0');
    final filePath = '$dirPath/${reciterId}_$sNumStr.mp3';
    final tempFilePath = '$filePath.tmp';

    final downloadUrl = SettingsService.instance.getSurahAudioUrl(surahId, reciterId);
    final cancelToken = CancelToken();
    _cancelTokens[key] = cancelToken;
    _activeProgress[key] = 0.01;
    notifyListeners();

    try {
      final tempFile = File(tempFilePath);
      if (tempFile.existsSync()) {
        tempFile.deleteSync();
      }

      int lastEmitMs = 0;

      await _dio.download(
        downloadUrl,
        tempFilePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final progress = (received / total).clamp(0.0, 1.0);
            _activeProgress[key] = progress;
            // Debounce notifications to avoid flooding the UI
            if (now - lastEmitMs > 250 || progress >= 1.0) {
              lastEmitMs = now;
              notifyListeners();
            }
          }
        },
      );

      // Rename temp file to permanent file
      final finalFile = File(filePath);
      if (finalFile.existsSync()) finalFile.deleteSync();
      await File(tempFilePath).rename(filePath);

      final reciters = SettingsService.availableReciters;
      final reciter = reciters.firstWhere(
        (r) => r.id == reciterId,
        orElse: () => reciters.first,
      );

      final length = finalFile.lengthSync();
      _downloadedSurahs[key] = DownloadedSurahInfo(
        reciterId: reciterId,
        reciterName: reciter.nameAr,
        surahId: surahId,
        surahName: surahName,
        localPath: filePath,
        fileSizeBytes: length,
        downloadedAt: DateTime.now(),
      );

      _activeProgress.remove(key);
      _cancelTokens.remove(key);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Download error for $key: $e');
      _activeProgress.remove(key);
      _cancelTokens.remove(key);
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

  void cancelDownload(String reciterId, int surahId) {
    final key = _key(reciterId, surahId);
    final token = _cancelTokens[key];
    if (token != null && !token.isCancelled) {
      token.cancel('Cancelled by user');
    }
    _activeProgress.remove(key);
    _cancelTokens.remove(key);
    notifyListeners();
  }

  Future<bool> deleteDownloadedSurah(String reciterId, int surahId) async {
    final key = _key(reciterId, surahId);
    final info = _downloadedSurahs[key];
    if (info == null) return false;

    try {
      final file = File(info.localPath);
      if (file.existsSync()) {
        file.deleteSync();
      }
      _downloadedSurahs.remove(key);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  Future<void> deleteAllDownloads() async {
    for (final info in _downloadedSurahs.values.toList()) {
      try {
        final file = File(info.localPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    _downloadedSurahs.clear();
    notifyListeners();
  }

  int get totalStorageUsedBytes {
    int total = 0;
    for (final info in _downloadedSurahs.values) {
      total += info.fileSizeBytes;
    }
    return total;
  }

  String get formattedTotalStorage {
    final bytes = totalStorageUsedBytes;
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

  List<DownloadedSurahInfo> getDownloadedSurahsList([String? filterReciterId]) {
    final list = _downloadedSurahs.values.toList();
    if (filterReciterId != null && filterReciterId.isNotEmpty) {
      return list.where((item) => item.reciterId == filterReciterId).toList();
    }
    list.sort((a, b) => a.surahId.compareTo(b.surahId));
    return list;
  }
}
