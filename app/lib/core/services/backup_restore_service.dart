import 'stories_service.dart';
import 'adhan_sensor_gesture_service.dart';
import 'ramadan_service.dart';
import 'hajj_umrah_service.dart';
import '../notifications/prayer_notification_service.dart';
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
import 'zakat_service.dart';
import 'hadith_service.dart';
import 'egyptian_heritage_service.dart';
import 'fiqh_library_service.dart';
import 'daily_wird_service.dart';
import 'fajr_qiyam_alarm_service.dart';
import 'scholars_lectures_service.dart';
import 'scholar_audio_resolver_service.dart';
import 'sunan_rawatib_service.dart';
import 'voluntary_fasting_service.dart';
import 'tadabbur_journal_service.dart';
import 'riyad_alsalihin_service.dart';
import 'islamic_mutoon_service.dart';
import 'gharib_quran_service.dart';
import 'tajweed_service.dart';

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

/// Service managing export, import, and verification of user data backups (v12 Full-Feature Coverage)
class BackupRestoreService {
  static final BackupRestoreService instance = BackupRestoreService._internal();
  BackupRestoreService._internal();

  static const int currentSchemaVersion = 1;
  static const String dedicationNote =
      'تطبيق نور المؤمن - النسخ الاحتياطي الآمن للبيانات';

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

  /// Recursively sorts all Map keys alphabetically so checksums never fail due to JSON key reordering
  static String canonicalJsonEncode(dynamic value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((k) => k.toString()).toList()..sort();
      final Map<String, dynamic> sortedMap = {};
      for (final k in sortedKeys) {
        sortedMap[k] = _canonicalizeValue(value[k]);
      }
      return json.encode(sortedMap);
    }
    return json.encode(_canonicalizeValue(value));
  }

  static dynamic _canonicalizeValue(dynamic value) {
    if (value is Map) {
      final sortedKeys = value.keys.map((k) => k.toString()).toList()..sort();
      final Map<String, dynamic> sortedMap = {};
      for (final k in sortedKeys) {
        sortedMap[k] = _canonicalizeValue(value[k]);
      }
      return sortedMap;
    } else if (value is List) {
      return value.map(_canonicalizeValue).toList();
    }
    return value;
  }

  /// Exports all user data into a structured Map (including v6-v12 features)
  Future<Map<String, dynamic>> exportBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    await AyahNotesService.instance.init();
    await MemorizationService.instance.init();
    await ZakatService.instance.init();
    await HadithService.instance.init();
    await EgyptianHeritageService.instance.init();
    await FiqhLibraryService.instance.init();
    await DailyWirdService.instance.init();
    await FajrQiyamAlarmService.instance.init();
    await ScholarsLecturesService.instance.init();
    await SunanRawatibService.instance.init();
    await VoluntaryFastingService.instance.init(forceReload: true);
      await RamadanService.instance.init(forceReload: true);
      await HajjUmrahService.instance.init(forceReload: true);
    await TadabburJournalService.instance.init();

    final settings = {
      'mushaf_font_size': prefs.getDouble('mushaf_font_size') ?? 24.0,
      'selected_reciter_id':
          prefs.getString('selected_reciter_id') ?? 'minshawi_murattal',
      'calculation_method': prefs.getString('calculation_method') ?? 'egyptian',
      'theme_mode': prefs.getString('theme_mode') ?? 'light',
      'adhan_alerts': prefs.getBool('adhan_alerts') ?? true,
      'has_completed_onboarding':
          prefs.getBool('has_completed_onboarding') ?? false,
      'app_language': prefs.getString('app_language') ?? 'ar',
      'app_language_code': prefs.getString('app_language') ?? 'ar',
      'quran_translation_edition':
          prefs.getString('quran_translation_edition') ?? 'en_saheeh',
      'bilingual_display_enabled':
          prefs.getBool('bilingual_display_enabled') ?? false,
      'hijri_adjustment_days':
          prefs.getInt('hijri_adjustment_days') ?? 0,
      'default_playback_speed':
          prefs.getDouble('default_playback_speed') ?? 1.0,
      'ayah_repeat_count':
          prefs.getInt('ayah_repeat_count') ?? 1,
      'default_tafsir_edition':
          prefs.getString('default_tafsir_edition') ?? 'muyassar',
      'fiqh_madhhab':
          prefs.getString('fiqh_madhhab') ?? 'shafii',
      'mushaf_default_mode':
          prefs.getString('mushaf_default_mode') ?? 'surah',
      'screen_layout_mode':
          prefs.getString('screen_layout_mode') ?? 'comfortable',
      'tasbih_vibration':
          prefs.getBool('tasbih_vibration') ?? true,
      'scholar_audio_source_pref_v11':
          prefs.getString('scholar_audio_source_pref_v11') ?? 'auto_multi',
    };

    final readingPosition = {
      'last_read_surah_id': prefs.getInt('last_read_surah_id') ?? 1,
      'last_read_ayah_number': prefs.getInt('last_read_ayah_number') ?? 1,
      'last_read_page_number': prefs.getInt('last_read_page_number') ?? 1,
      'last_read_surah_name':
          prefs.getString('last_read_surah_name') ?? 'الفاتحة',
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
      'tasbih_last_date': prefs.getString('tasbih_last_date') ?? '',
      'adhkar_daily_counts_v1': prefs.getString('adhkar_daily_counts_v1'),
      'tasbih_phrase': prefs.getString('tasbih_phrase') ?? 'سُبْحَانَ اللَّهِ',
      'tasbih_haptic': prefs.getBool('tasbih_haptic') ?? true,
      'tasbih_volume_button_enabled':
          prefs.getBool('tasbih_volume_button_enabled') ??
          prefs.getBool('tasbih_volume_up_button_enabled') ??
          true,
      'tasbih_volume_up_button_enabled':
          prefs.getBool('tasbih_volume_button_enabled') ??
          prefs.getBool('tasbih_volume_up_button_enabled') ??
          true,
      'tasbih_slider_enabled':
          prefs.getBool('tasbih_slider_enabled') ?? true,
      'tasbih_slider_step_value':
          prefs.getInt('tasbih_slider_step_value') ?? 1,
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

    final scholarsData = {
      'scholars_fav_lectures':
          prefs.getStringList('scholars_fav_lectures') ?? const <String>[],
      'scholars_fav_profiles':
          prefs.getStringList('scholars_fav_profiles') ?? const <String>[],
      'scholars_last_played_lecture':
          prefs.getString('scholars_last_played_lecture'),
    };

    final extendedFeatures = {
      'sunan_rawatib': prefs.getString('sunan_rawatib_logs_v1'),
      'tadabbur_journal': prefs.getString('tadabbur_journal_entries_v1'),
      'voluntary_fasting': {
        'suhoor_reminder':
            prefs.getBool('voluntary_fast_suhoor_reminder') ?? true,
        'date_logs': prefs.getStringList('vfast_date_logs') ?? const <String>[],
        'counts': {
          for (final ft in VoluntaryFastingService.fastTypes)
            ft.id: prefs.getInt('vfast_count_${ft.id}') ?? 0,
        },
      },
      'ramadan_tracker': {
        'fasted_days': prefs.getStringList('ramadan_fasted_days') ?? const <String>[],
        'taraweeh_days': prefs.getStringList('ramadan_taraweeh_days') ?? const <String>[],
        'quran_days': prefs.getStringList('ramadan_quran_days') ?? const <String>[],
      },
      'hajj_umrah': {
        'tawaf_lap': prefs.getInt('hajj_tawaf_lap') ?? 0,
        'sai_lap': prefs.getInt('hajj_sai_lap') ?? 0,
        'completed_steps': prefs.getStringList('hajj_completed_steps') ?? const <String>[],
      },
      'riyad_bookmarks_v1':
          prefs.getStringList('riyad_bookmarks_v1') ?? const <String>[],
      'memorized_mutoon_ids_v1':
          prefs.getStringList('memorized_mutoon_ids_v1') ?? const <String>[],
      'gharib_mastered_words':
          prefs.getStringList('gharib_mastered_words') ?? const <String>[],
      'gharib_quiz_best_score':
          prefs.getInt('gharib_quiz_best_score') ?? 0,
      'tajweed_favorites':
          prefs.getStringList('tajweed_favorites') ?? const <String>[],
      'tadabbur_daily_accountability':
          prefs.getString('tadabbur_daily_accountability_v1'),
      'stories_favorites':
          prefs.getStringList('stories_favorites') ?? const <String>[],
      'stories_last_read':
          prefs.getString('stories_last_read'),
      'hadith_last_read_id':
          prefs.getInt('hadith_last_read_id'),
      'quran_search_history_v1':
          prefs.getStringList('quran_search_history_v1') ?? const <String>[],
      'sensor_gestures': {
        'notif_shake_to_stop': prefs.getBool('notif_shake_to_stop') ?? true,
        'notif_flip_to_mute': prefs.getBool('notif_flip_to_mute') ?? true,
        'notif_overlay_window': prefs.getBool('notif_overlay_window') ?? true,
      },
    };

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
      'zakat_calculation': ZakatService.instance.exportData(),
      'hadith_favorites': HadithService.instance.exportFavorites(),
      'egyptian_heritage_favorites':
          EgyptianHeritageService.instance.exportFavorites(),
      'fiqh_library_favorites': FiqhLibraryService.instance.exportFavorites(),
      'daily_wird_records': DailyWirdService.instance.exportData(),
      'fajr_qiyam_alarms': FajrQiyamAlarmService.instance.exportData(),
      'scholars_library': scholarsData,
      'extended_features': extendedFeatures,
    };

    final dataCanonical = canonicalJsonEncode(dataPayload);
    final checksum = calculateChecksum(dataCanonical);

    return {
      'app': 'AlMomin',
      'schema_version': currentSchemaVersion,
      'app_version': '20.0.0',
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
          subject: 'نسخة احتياطية - تطبيق نور المؤمن',
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
        text: 'نسخة احتياطية لتطبيق نور المؤمن 🕌\n$dedicationNote',
        subject: 'نسخة احتياطية لتطبيق نور المؤمن',
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
          errorMessage: 'هذا الملف لا ينتمي لتطبيق نور المؤمن',
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

      final storedChecksum = decoded['checksum'] as String?;
      if (storedChecksum != null && storedChecksum.isNotEmpty) {
        final computedCanonical = calculateChecksum(canonicalJsonEncode(data));
        final computedRaw = calculateChecksum(json.encode(data));
        if (storedChecksum != computedCanonical &&
            storedChecksum != computedRaw) {
          return const BackupValidationResult(
            isValid: false,
            errorMessage:
                'ملف النسخة الاحتياطية تالف أو تم التعديل على محتواه (فشل التحقق من البصمة الرقمية Checksum)',
          );
        }
      }

      final bookmarks =
          (data['bookmarks'] as List<dynamic>?)?.cast<String>() ?? [];
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
  Future<bool> restoreBackup(
    Map<String, dynamic> backupEnvelope, {
    bool replaceMode = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = backupEnvelope['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      // 1. Restore / Merge Bookmarks
      final importedBookmarks = (data['bookmarks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
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
            await prefs.setDouble('mushaf_font_size',
                (settings['mushaf_font_size'] as num).toDouble());
          }
        }
        if (replaceMode || !prefs.containsKey('selected_reciter_id')) {
          if (settings['selected_reciter_id'] != null) {
            await prefs.setString('selected_reciter_id',
                settings['selected_reciter_id'].toString());
          }
        }
        if (replaceMode || !prefs.containsKey('calculation_method')) {
          if (settings['calculation_method'] != null) {
            await prefs.setString('calculation_method',
                settings['calculation_method'].toString());
          }
        }
        if (replaceMode || !prefs.containsKey('theme_mode')) {
          if (settings['theme_mode'] != null) {
            await prefs.setString(
                'theme_mode', settings['theme_mode'].toString());
          }
        }
        if (replaceMode || !prefs.containsKey('adhan_alerts')) {
          if (settings['adhan_alerts'] is bool) {
            await prefs.setBool(
                'adhan_alerts', settings['adhan_alerts'] as bool);
          }
        }
        if (settings['app_language'] != null) {
          await prefs.setString(
              'app_language', settings['app_language'].toString());
        }
        if (settings['quran_translation_edition'] != null) {
          await prefs.setString('quran_translation_edition',
              settings['quran_translation_edition'].toString());
        }
        if (settings['bilingual_display_enabled'] is bool) {
          await prefs.setBool('bilingual_display_enabled',
              settings['bilingual_display_enabled'] as bool);
        }
        if (settings['hijri_adjustment_days'] is int) {
          await prefs.setInt('hijri_adjustment_days',
              settings['hijri_adjustment_days'] as int);
        }
        if (settings['default_playback_speed'] is num) {
          await prefs.setDouble('default_playback_speed',
              (settings['default_playback_speed'] as num).toDouble());
        }
        if (settings['ayah_repeat_count'] is int) {
          await prefs.setInt('ayah_repeat_count',
              settings['ayah_repeat_count'] as int);
        }
        if (settings['default_tafsir_edition'] != null) {
          await prefs.setString('default_tafsir_edition',
              settings['default_tafsir_edition'].toString());
        }
        if (settings['fiqh_madhhab'] != null) {
          await prefs.setString(
              'fiqh_madhhab', settings['fiqh_madhhab'].toString());
        }
        if (settings['mushaf_default_mode'] != null) {
          await prefs.setString('mushaf_default_mode',
              settings['mushaf_default_mode'].toString());
        }
        if (settings['screen_layout_mode'] != null) {
          await prefs.setString('screen_layout_mode',
              settings['screen_layout_mode'].toString());
        }
        if (settings['tasbih_vibration'] is bool) {
          await prefs.setBool(
              'tasbih_vibration', settings['tasbih_vibration'] as bool);
        }
        if (settings['scholar_audio_source_pref_v11'] != null) {
          await prefs.setString('scholar_audio_source_pref_v11',
              settings['scholar_audio_source_pref_v11'].toString());
        }
      }

      // 3. Reading Position
      final reading = data['reading_position'] as Map<String, dynamic>?;
      if (reading != null) {
        if (replaceMode || (prefs.getInt('last_read_page_number') ?? 1) <= 1) {
          if (reading['last_read_surah_id'] is int) {
            await prefs.setInt(
                'last_read_surah_id', reading['last_read_surah_id'] as int);
          }
          if (reading['last_read_ayah_number'] is int) {
            await prefs.setInt('last_read_ayah_number',
                reading['last_read_ayah_number'] as int);
          }
          if (reading['last_read_page_number'] is int) {
            await prefs.setInt('last_read_page_number',
                reading['last_read_page_number'] as int);
          }
          if (reading['last_read_surah_name'] != null) {
            await prefs.setString('last_read_surah_name',
                reading['last_read_surah_name'].toString());
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
            try {
              final currentKhatma =
                  json.decode(currentKhatmaStr) as Map<String, dynamic>;
              final currentPage = (currentKhatma['currentPage'] as int?) ?? 1;
              final importedPage = (khatma['currentPage'] as int?) ?? 1;
              if (importedPage > currentPage) {
                await prefs.setString(
                    'active_khatma_plan', json.encode(khatma));
              }
            } catch (_) {}
          }
        }
      }

      // 5. Adhkar & Tasbih (including v9 Slider & Volume-Up Button settings)
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
            await prefs.setInt(
                'tasbih_total_today', adhkar['tasbih_total_today'] as int);
            final now = DateTime.now();
            final todayKey =
                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
            final savedDate = (adhkar['tasbih_last_date'] as String?) ?? '';
            await prefs.setString(
              'tasbih_last_date',
              savedDate.isNotEmpty ? savedDate : todayKey,
            );
          }
          if (adhkar['adhkar_daily_counts_v1'] is String) {
            await prefs.setString('adhkar_daily_counts_v1',
                adhkar['adhkar_daily_counts_v1'] as String);
          }
          if (adhkar['tasbih_phrase'] != null) {
            await prefs.setString(
                'tasbih_phrase', adhkar['tasbih_phrase'].toString());
          }
          if (adhkar['tasbih_haptic'] is bool) {
            await prefs.setBool(
                'tasbih_haptic', adhkar['tasbih_haptic'] as bool);
          }
          final volBtn = adhkar['tasbih_volume_button_enabled'] ??
              adhkar['tasbih_volume_up_button_enabled'];
          if (volBtn is bool) {
            await prefs.setBool('tasbih_volume_button_enabled', volBtn);
            await prefs.setBool('tasbih_volume_up_button_enabled', volBtn);
          }
          if (adhkar['tasbih_slider_enabled'] is bool) {
            await prefs.setBool('tasbih_slider_enabled',
                adhkar['tasbih_slider_enabled'] as bool);
          }
          if (adhkar['tasbih_slider_step_value'] is int) {
            await prefs.setInt('tasbih_slider_step_value',
                adhkar['tasbih_slider_step_value'] as int);
          }
        } else {
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
          await prefs.setDouble(
              'last_latitude', (location['last_latitude'] as num).toDouble());
        }
        if (location['last_longitude'] is num) {
          await prefs.setDouble(
              'last_longitude', (location['last_longitude'] as num).toDouble());
        }
        if (location['last_city'] != null) {
          await prefs.setString('last_city', location['last_city'].toString());
        }
      }

      // 7. Prayer Tracker Records
      final trackerData = data['prayer_tracker'] as Map<String, dynamic>?;
      if (trackerData != null) {
        if (replaceMode) {
          await prefs.setString(
              'prayer_tracker_records_v1', json.encode(trackerData));
        } else {
          final curJson = prefs.getString('prayer_tracker_records_v1');
          if (curJson == null || curJson.isEmpty) {
            await prefs.setString(
                'prayer_tracker_records_v1', json.encode(trackerData));
          } else {
            try {
              final cur = json.decode(curJson) as Map<String, dynamic>;
              cur.addAll(trackerData);
              await prefs.setString(
                  'prayer_tracker_records_v1', json.encode(cur));
            } catch (_) {}
          }
        }
      }

      // 8. Quranic Reflections & Notes
      final importedNotes = data['ayah_notes'] as List<dynamic>?;
      if (importedNotes != null) {
        await AyahNotesService.instance
            .restoreNotesList(importedNotes, replace: replaceMode);
      }

      // 9. Quran Memorization & Leitner Data
      final importedMem = data['memorization_items'] as List<dynamic>?;
      if (importedMem != null) {
        await MemorizationService.instance
            .importData(importedMem, merge: !replaceMode);
      }

      // 10. Islamic Zakat Calculation
      final importedZakat = data['zakat_calculation'] as Map<String, dynamic>?;
      if (importedZakat != null) {
        await ZakatService.instance.importData(importedZakat);
      }

      // 11. Hadith, Egyptian Heritage, Fiqh, Wird, Fajr/Qiyam
      final importedHadithFavs = (data['hadith_favorites'] as List<dynamic>?)
          ?.map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
      if (importedHadithFavs != null) {
        await HadithService.instance.importFavorites(importedHadithFavs, replace: replaceMode);
      }

      final importedEgyptFavs =
          (data['egyptian_heritage_favorites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
      if (importedEgyptFavs != null) {
        await EgyptianHeritageService.instance.importFavorites(
          importedEgyptFavs,
          replace: replaceMode,
        );
      }

      final importedFiqhFavs =
          (data['fiqh_library_favorites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList();
      if (importedFiqhFavs != null) {
        await FiqhLibraryService.instance.importFavorites(
          importedFiqhFavs,
          replace: replaceMode,
        );
      }
      final importedWird = data['daily_wird_records'] as Map<String, dynamic>?;
      if (importedWird != null) {
        await DailyWirdService.instance.importData(
          importedWird,
          replace: replaceMode,
        );
      }
      final importedFajrQiyam =
          data['fajr_qiyam_alarms'] as Map<String, dynamic>?;
      if (importedFajrQiyam != null) {
        await FajrQiyamAlarmService.instance.importData(importedFajrQiyam);
      }

      // 11d. Scholars Library Favorites & Extended v6-v12 Features
      final scholarsData = data['scholars_library'] as Map<String, dynamic>?;
      if (scholarsData != null) {
        final favLecs = (scholarsData['scholars_fav_lectures'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final favProfs = (scholarsData['scholars_fav_profiles'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        if (scholarsData['scholars_last_played_lecture'] is String) {
          await prefs.setString('scholars_last_played_lecture',
              scholarsData['scholars_last_played_lecture'] as String);
        }
        if (replaceMode) {
          await prefs.setStringList('scholars_fav_lectures', favLecs);
          await prefs.setStringList('scholars_fav_profiles', favProfs);
        } else {
          final curL = prefs.getStringList('scholars_fav_lectures') ?? [];
          final curP = prefs.getStringList('scholars_fav_profiles') ?? [];
          await prefs.setStringList(
              'scholars_fav_lectures', {...curL, ...favLecs}.toList());
          await prefs.setStringList(
              'scholars_fav_profiles', {...curP, ...favProfs}.toList());
        }
      }

      Future<void> restoreOrMergeList(String prefKey, List<dynamic> rawList) async {
        final imported = rawList.map((e) => e.toString()).toList();
        if (replaceMode) {
          await prefs.setStringList(prefKey, imported);
        } else {
          final current = prefs.getStringList(prefKey) ?? const <String>[];
          await prefs.setStringList(prefKey, {...current, ...imported}.toList());
        }
      }

      Future<void> restoreOrMaxInt(String prefKey, int importedVal) async {
        if (replaceMode) {
          await prefs.setInt(prefKey, importedVal);
        } else {
          final current = prefs.getInt(prefKey) ?? 0;
          if (importedVal > current) {
            await prefs.setInt(prefKey, importedVal);
          }
        }
      }

      final extData = data['extended_features'] as Map<String, dynamic>?;
      if (extData != null) {
        if (extData['sunan_rawatib'] is String) {
          await prefs.setString(
              'sunan_rawatib_logs_v1', extData['sunan_rawatib'] as String);
        }
        if (extData['tadabbur_journal'] is String) {
          await prefs.setString('tadabbur_journal_entries_v1',
              extData['tadabbur_journal'] as String);
        }
        if (extData['riyad_bookmarks_v1'] is List) {
          await restoreOrMergeList(
              'riyad_bookmarks_v1', extData['riyad_bookmarks_v1'] as List);
        }
        if (extData['memorized_mutoon_ids_v1'] is List) {
          await restoreOrMergeList('memorized_mutoon_ids_v1',
              extData['memorized_mutoon_ids_v1'] as List);
        }
        if (extData['tajweed_favorites'] is List) {
          await restoreOrMergeList(
              'tajweed_favorites', extData['tajweed_favorites'] as List);
        }
        if (extData['gharib_mastered_words'] is List) {
          await restoreOrMergeList('gharib_mastered_words',
              extData['gharib_mastered_words'] as List);
        }
        if (extData['gharib_quiz_best_score'] is int) {
          await restoreOrMaxInt('gharib_quiz_best_score',
              extData['gharib_quiz_best_score'] as int);
        }
        if (extData['tadabbur_daily_accountability'] is String) {
          await prefs.setString('tadabbur_daily_accountability_v1',
              extData['tadabbur_daily_accountability'] as String);
        }
        if (extData['stories_favorites'] is List) {
          await restoreOrMergeList(
              'stories_favorites', extData['stories_favorites'] as List);
        }
        if (extData['stories_last_read'] is String) {
          await prefs.setString(
              'stories_last_read', extData['stories_last_read'] as String);
        }
        if (extData['hadith_last_read_id'] is int) {
          await prefs.setInt('hadith_last_read_id',
              extData['hadith_last_read_id'] as int);
        }
        if (extData['quran_search_history_v1'] is List) {
          await restoreOrMergeList('quran_search_history_v1',
              extData['quran_search_history_v1'] as List);
        }
        if (extData['sensor_gestures'] is Map) {
          final sg = extData['sensor_gestures'] as Map;
          if (sg['notif_shake_to_stop'] is bool) {
            await prefs.setBool(
                'notif_shake_to_stop', sg['notif_shake_to_stop'] as bool);
          }
          if (sg['notif_flip_to_mute'] is bool) {
            await prefs.setBool(
                'notif_flip_to_mute', sg['notif_flip_to_mute'] as bool);
          }
          if (sg['notif_overlay_window'] is bool) {
            await prefs.setBool(
                'notif_overlay_window', sg['notif_overlay_window'] as bool);
          }
        }
        if (extData['voluntary_fasting'] is Map) {
          final vf = extData['voluntary_fasting'] as Map;
          if (vf['suhoor_reminder'] is bool) {
            await prefs.setBool('voluntary_fast_suhoor_reminder', vf['suhoor_reminder'] as bool);
          }
          if (vf['date_logs'] is List) {
            await restoreOrMergeList('vfast_date_logs', vf['date_logs'] as List);
          }
          if (vf['counts'] is Map) {
            final countsMap = vf['counts'] as Map;
            for (final entry in countsMap.entries) {
              if (entry.value is int) {
                await restoreOrMaxInt('vfast_count_${entry.key}', entry.value as int);
              }
            }
          }
        }
        if (extData['ramadan_tracker'] is Map) {
          final rm = extData['ramadan_tracker'] as Map;
          if (rm['fasted_days'] is List) {
            await restoreOrMergeList('ramadan_fasted_days', rm['fasted_days'] as List);
          }
          if (rm['taraweeh_days'] is List) {
            await restoreOrMergeList('ramadan_taraweeh_days', rm['taraweeh_days'] as List);
          }
          if (rm['quran_days'] is List) {
            await restoreOrMergeList('ramadan_quran_days', rm['quran_days'] as List);
          }
        }
        if (extData['hajj_umrah'] is Map) {
          final hj = extData['hajj_umrah'] as Map;
          if (hj['tawaf_lap'] is int) {
            await restoreOrMaxInt('hajj_tawaf_lap', hj['tawaf_lap'] as int);
          }
          if (hj['sai_lap'] is int) {
            await restoreOrMaxInt('hajj_sai_lap', hj['sai_lap'] as int);
          }
          if (hj['completed_steps'] is List) {
            await restoreOrMergeList('hajj_completed_steps', hj['completed_steps'] as List);
          }
        }
      }

      // 12. Refresh all active in-memory singletons with forceReload: true
      await SettingsService.instance.init(forceReload: true);
      await KhatmaService.instance.init(forceReload: true);
      await AdhkarService.instance.init(forceReload: true);
      await PrayerService.instance.init(forceRefresh: true);
      await PrayerTrackerService.instance.init(forceReload: true);
      await AyahNotesService.instance.init(forceReload: true);
      await MemorizationService.instance.init(forceReload: true);
      await ZakatService.instance.init(forceReload: true);
      await HadithService.instance.init(forceReload: true);
      await EgyptianHeritageService.instance.init(forceReload: true);
      await FiqhLibraryService.instance.init(forceReload: true);
      await DailyWirdService.instance.init(forceReload: true);
      await FajrQiyamAlarmService.instance.init(forceReload: true);
      await ScholarsLecturesService.instance.init(forceReload: true);
      await ScholarAudioResolverService.instance.init(forceReload: true);
      await SunanRawatibService.instance.init(forceReload: true);
      await VoluntaryFastingService.instance.init(forceReload: true);
      await RamadanService.instance.init(forceReload: true);
      await HajjUmrahService.instance.init(forceReload: true);
      await TadabburJournalService.instance.init(forceReload: true);
      await RiyadAlSalihinService.instance.init(forceReload: true);
      await IslamicMutoonService.instance.init(forceReload: true);
      await GharibQuranService.instance.init(forceReload: true);
      await StoriesService.instance.init(forceReload: true);
      await AdhanSensorGestureService.instance.init(forceReload: true);
      await TajweedService.instance.init(forceReload: true);
      await PrayerNotificationService.instance.init(forceReload: true);

      return true;
    } catch (e) {
      debugPrint('Backup restore error: $e');
      return false;
    }
  }
}
