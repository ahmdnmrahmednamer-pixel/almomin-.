import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';
import 'khatma_service.dart';
import 'adhkar_service.dart';
import 'prayer_service.dart';
import 'prayer_tracker_service.dart';
import 'ayah_notes_service.dart';
import 'memorization_service.dart';

/// Result of validating a backup JSON payload
class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? createdAt;
  final int bookmarksCount;
  final int notesCount;
  final int memorizationCount;
  final bool hasKhatma;
  final int khatmaPage;
  final String? city;
  final Map<String, dynamic>? rawData;

  const BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.createdAt,
    this.bookmarksCount = 0,
    this.notesCount = 0,
    this.memorizationCount = 0,
    this.hasKhatma = false,
    this.khatmaPage = 1,
    this.city,
    this.rawData,
  });
}

/// Service managing export, import, and verification of user data backups (FR-BKM-003 / T-305)
class BackupRestoreService {
  static final BackupRestoreService instance = BackupRestoreService._internal();
  BackupRestoreService._internal();

  static const int currentSchemaVersion = 1;
  static const String dedicationNote =
      'صدقة جارية عن روح المرحوم بإذن الله تعالى: مؤمن إبراهيم رحمه الله تعالى';

  /// Deterministic 64-bit FNV-1a checksum for backup integrity verification
  static String calculateChecksum(String data) {
    BigInt hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final BigInt fnvPrime = BigInt.parse('100000001b3', radix: 16);
    final BigInt mask64 = BigInt.parse('ffffffffffffffff', radix: 16);

    final bytes = utf8.encode(data);
    for (final b in bytes) {
      hash = (hash ^ BigInt.from(b)) & mask64;
      hash = (hash * fnvPrime) & mask64;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  /// Exports all user data into a structured Map
  Future<Map<String, dynamic>> exportBackupData() async {
    final prefs = await SharedPreferences.getInstance();

    final settings = {
      'mushaf_font_size': prefs.getDouble('mushaf_font_size') ?? 24.0,
      'selected_reciter_id': prefs.getString('selected_reciter_id') ?? 'alafasy',
      'calculation_method': prefs.getString('calculation_method') ?? 'egyptian',
      'theme_mode': prefs.getString('theme_mode') ?? 'light',
      'adhan_alerts': prefs.getBool('adhan_alerts') ?? true,
      'has_completed_onboarding': prefs.getBool('has_completed_onboarding') ?? false,
    };

    final readingPosition = {
      'last_read_surah_id': prefs.getInt('last_read_surah_id') ?? 1,
      'last_read_ayah_number': prefs.getInt('last_read_ayah_number') ?? 1,
      'last_read_page_number': prefs.getInt('last_read_page_number') ?? 1,
      'last_read_surah_name': prefs.getString('last_read_surah_name') ?? 'الفاتحة',
    };

    final bookmarks = prefs.getStringList('bookmarks') ?? [];

    final khatmaJson = prefs.getString('active_khatma_plan');
    Map<String, dynamic>? khatmaData;
    if (khatmaJson != null && khatmaJson.isNotEmpty) {
      try {
        khatmaData = json.decode(khatmaJson);
      } catch (_) {}
    }

    final adhkar = {
      'tasbih_count': prefs.getInt('tasbih_count') ?? 0,
      'tasbih_target': prefs.getInt('tasbih_target') ?? 33,
      'tasbih_total_today': prefs.getInt('tasbih_total_today') ?? 0,
      'tasbih_phrase': prefs.getString('tasbih_phrase') ?? 'سُبْحَانَ اللَّهِ',
      'tasbih_haptic': prefs.getBool('tasbih_haptic') ?? true,
    };

    final location = {
      'last_latitude': prefs.getDouble('last_latitude') ?? 30.0444,
      'last_longitude': prefs.getDouble('last_longitude') ?? 31.2357,
      'last_city': prefs.getString('last_city') ?? 'القاهرة، مصر',
    };

    final prayerTrackerJson = prefs.getString('prayer_tracker_records_v1');
    Map<String, dynamic>? prayerTrackerData;
    if (prayerTrackerJson != null && prayerTrackerJson.isNotEmpty) {
      try {
        prayerTrackerData = json.decode(prayerTrackerJson);
      } catch (_) {}
    }

    final dataPayload = {
      'settings': settings,
      'reading_position': readingPosition,
      'bookmarks': bookmarks,
      'khatma': khatmaData,
      'adhkar': adhkar,
      'location': location,
      'prayer_tracker': prayerTrackerData,
      'ayah_notes': AyahNotesService.instance.exportNotesList(),
      'memorization_items': MemorizationService.instance.exportData(),
    };

    final dataCanonical = json.encode(dataPayload);
    final checksum = calculateChecksum(dataCanonical);

    return {
      'app': 'AlMomin',
      'schema_version': currentSchemaVersion,
      'app_version': '1.2.0',
      'created_at': DateTime.now().toIso8601String(),
      'dedicated_to': dedicationNote,
      'checksum': checksum,
      'data': dataPayload,
    };
  }

  /// Exports backup data as a formatted JSON string
  Future<String> exportBackupJson() async {
    final data = await exportBackupData();
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  /// Exports backup data and shares it via the device share sheet
  Future<bool> shareBackupFile() async {
    try {
      final jsonString = await exportBackupJson();

      if (kIsWeb) {
        await Share.share(
          jsonString,
          subject: 'نسخة احتياطية - تطبيق المؤمن',
        );
        return true;
      }

      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'almomin_backup_$dateStr.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json', name: fileName)],
        text: 'نسخة احتياطية لتطبيق المؤمن 🕌\n$dedicationNote',
        subject: 'نسخة احتياطية لتطبيق المؤمن',
      );
      return true;
    } catch (e) {
      debugPrint('Backup share error: $e');
      return false;
    }
  }

  /// Validates a raw JSON backup string
  BackupValidationResult validateBackup(String jsonString) {
    if (jsonString.trim().isEmpty) {
      return const BackupValidationResult(
        isValid: false,
        errorMessage: 'النص المدخل فارغ',
      );
    }

    try {
      final dynamic decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'صيغة ملف النسخة الاحتياطية غير صالحة',
        );
      }

      final app = decoded['app'] as String?;
      if (app != 'AlMomin') {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'هذا الملف لا ينتمي لتطبيق المؤمن',
        );
      }

      final schemaVersion = decoded['schema_version'] as int?;
      if (schemaVersion == null || schemaVersion > currentSchemaVersion) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'إصدار النسخة الاحتياطية غير مدعوم أو أحدث من التطبيق',
        );
      }

      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'لا توجد بيانات داخل النسخة الاحتياطية',
        );
      }

      // Check integrity checksum if present
      final storedChecksum = decoded['checksum'] as String?;
      if (storedChecksum != null) {
        final canonical = json.encode(data);
        final computed = calculateChecksum(canonical);
        if (storedChecksum != computed) {
          debugPrint('Checksum mismatch warning: stored=$storedChecksum, computed=$computed');
          // Allow restoring with warning, but flag in debug
        }
      }

      final bookmarks = (data['bookmarks'] as List<dynamic>?)?.cast<String>() ?? [];
      final notes = (data['ayah_notes'] as List<dynamic>?) ?? [];
      final memItems = (data['memorization_items'] as List<dynamic>?) ?? [];
      final khatma = data['khatma'] as Map<String, dynamic>?;
      final location = data['location'] as Map<String, dynamic>?;
      final createdAt = decoded['created_at'] as String?;

      return BackupValidationResult(
        isValid: true,
        createdAt: createdAt,
        bookmarksCount: bookmarks.length,
        notesCount: notes.length,
        memorizationCount: memItems.length,
        hasKhatma: khatma != null,
        khatmaPage: (khatma?['currentPage'] as int?) ?? 1,
        city: location?['last_city'] as String?,
        rawData: decoded,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'خطأ في معالجة ملف النسخة: ${e.toString()}',
      );
    }
  }

  /// Restores backup data into the app state
  /// [replaceMode] = true replaces current data, false merges non-destructively
  Future<bool> restoreBackup(
    Map<String, dynamic> backupEnvelope, {
    bool replaceMode = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = backupEnvelope['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      // 1. Restore / Merge Bookmarks
      final importedBookmarks =
          (data['bookmarks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      if (replaceMode) {
        await prefs.setStringList('bookmarks', importedBookmarks);
      } else {
        final current = prefs.getStringList('bookmarks') ?? [];
        final merged = {...current, ...importedBookmarks}.toList();
        await prefs.setStringList('bookmarks', merged);
      }

      // 2. Settings
      final settings = data['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        if (replaceMode || !prefs.containsKey('mushaf_font_size')) {
          if (settings['mushaf_font_size'] is num) {
            await prefs.setDouble(
                'mushaf_font_size', (settings['mushaf_font_size'] as num).toDouble());
          }
        }
        if (replaceMode || !prefs.containsKey('selected_reciter_id')) {
          if (settings['selected_reciter_id'] != null) {
            await prefs.setString('selected_reciter_id', settings['selected_reciter_id'].toString());
          }
        }
        if (replaceMode || !prefs.containsKey('calculation_method')) {
          if (settings['calculation_method'] != null) {
            await prefs.setString('calculation_method', settings['calculation_method'].toString());
          }
        }
        if (replaceMode || !prefs.containsKey('theme_mode')) {
          if (settings['theme_mode'] != null) {
            await prefs.setString('theme_mode', settings['theme_mode'].toString());
          }
        }
        if (replaceMode || !prefs.containsKey('adhan_alerts')) {
          if (settings['adhan_alerts'] != null) {
            await prefs.setBool('adhan_alerts', settings['adhan_alerts'] as bool);
          }
        }
      }

      // 3. Reading Position
      final reading = data['reading_position'] as Map<String, dynamic>?;
      if (reading != null) {
        if (replaceMode || (prefs.getInt('last_read_page_number') ?? 1) <= 1) {
          if (reading['last_read_surah_id'] is int) {
            await prefs.setInt('last_read_surah_id', reading['last_read_surah_id'] as int);
          }
          if (reading['last_read_ayah_number'] is int) {
            await prefs.setInt('last_read_ayah_number', reading['last_read_ayah_number'] as int);
          }
          if (reading['last_read_page_number'] is int) {
            await prefs.setInt('last_read_page_number', reading['last_read_page_number'] as int);
          }
          if (reading['last_read_surah_name'] != null) {
            await prefs.setString('last_read_surah_name', reading['last_read_surah_name'].toString());
          }
        }
      }

      // 4. Khatma Plan
      final khatma = data['khatma'] as Map<String, dynamic>?;
      if (khatma != null) {
        if (replaceMode) {
          await prefs.setString('active_khatma_plan', json.encode(khatma));
        } else {
          final currentKhatmaStr = prefs.getString('active_khatma_plan');
          if (currentKhatmaStr == null || currentKhatmaStr.isEmpty) {
            await prefs.setString('active_khatma_plan', json.encode(khatma));
          } else {
            // Compare progress; keep the one with higher page
            try {
              final currentKhatma = json.decode(currentKhatmaStr) as Map<String, dynamic>;
              final currentPage = (currentKhatma['currentPage'] as int?) ?? 1;
              final importedPage = (khatma['currentPage'] as int?) ?? 1;
              if (importedPage > currentPage) {
                await prefs.setString('active_khatma_plan', json.encode(khatma));
              }
            } catch (_) {}
          }
        }
      }

      // 5. Adhkar & Tasbih
      final adhkar = data['adhkar'] as Map<String, dynamic>?;
      if (adhkar != null) {
        if (replaceMode) {
          if (adhkar['tasbih_count'] is int) {
            await prefs.setInt('tasbih_count', adhkar['tasbih_count'] as int);
          }
          if (adhkar['tasbih_target'] is int) {
            await prefs.setInt('tasbih_target', adhkar['tasbih_target'] as int);
          }
          if (adhkar['tasbih_total_today'] is int) {
            await prefs.setInt('tasbih_total_today', adhkar['tasbih_total_today'] as int);
          }
          if (adhkar['tasbih_phrase'] != null) {
            await prefs.setString('tasbih_phrase', adhkar['tasbih_phrase'].toString());
          }
          if (adhkar['tasbih_haptic'] != null) {
            await prefs.setBool('tasbih_haptic', adhkar['tasbih_haptic'] as bool);
          }
        } else {
          // Merge tasbih count by adding or taking max
          final curTotal = prefs.getInt('tasbih_total_today') ?? 0;
          final impTotal = (adhkar['tasbih_total_today'] as int?) ?? 0;
          if (impTotal > curTotal) {
            await prefs.setInt('tasbih_total_today', impTotal);
          }
        }
      }

      // 6. Location
      final location = data['location'] as Map<String, dynamic>?;
      if (location != null && replaceMode) {
        if (location['last_latitude'] is num) {
          await prefs.setDouble('last_latitude', (location['last_latitude'] as num).toDouble());
        }
        if (location['last_longitude'] is num) {
          await prefs.setDouble('last_longitude', (location['last_longitude'] as num).toDouble());
        }
        if (location['last_city'] != null) {
          await prefs.setString('last_city', location['last_city'].toString());
        }
      }

      // 7. Prayer Tracker Records
      final trackerData = data['prayer_tracker'] as Map<String, dynamic>?;
      if (trackerData != null) {
        if (replaceMode) {
          await prefs.setString('prayer_tracker_records_v1', json.encode(trackerData));
        } else {
          final curJson = prefs.getString('prayer_tracker_records_v1');
          if (curJson == null || curJson.isEmpty) {
            await prefs.setString('prayer_tracker_records_v1', json.encode(trackerData));
          } else {
            try {
              final cur = json.decode(curJson) as Map<String, dynamic>;
              cur.addAll(trackerData);
              await prefs.setString('prayer_tracker_records_v1', json.encode(cur));
            } catch (_) {}
          }
        }
      }

      // 8. Quranic Reflections & Notes (FR-BKM-004)
      final importedNotes = data['ayah_notes'] as List<dynamic>?;
      if (importedNotes != null) {
        await AyahNotesService.instance.restoreNotesList(importedNotes, replace: replaceMode);
      }

      // 9. Quran Memorization & Leitner Data (FR-MEM-001..003)
      final importedMem = data['memorization_items'] as List<dynamic>?;
      if (importedMem != null) {
        await MemorizationService.instance.importData(importedMem, merge: !replaceMode);
      }

      // 10. Refresh all active in-memory singletons
      await SettingsService.instance.init();
      await KhatmaService.instance.init();
      await AdhkarService.instance.init();
      await PrayerService.instance.init();
      await PrayerTrackerService.instance.init();
      await AyahNotesService.instance.init();
      await MemorizationService.instance.init();

      return true;
    } catch (e) {
      debugPrint('Backup restore error: $e');
      return false;
    }
  }
}
