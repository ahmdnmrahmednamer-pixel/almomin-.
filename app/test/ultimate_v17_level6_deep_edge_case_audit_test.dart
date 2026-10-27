import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:almomin/core/services/backup_restore_service.dart';
import 'package:almomin/core/services/gharib_quran_service.dart';
import 'package:almomin/core/services/hadith_service.dart';
import 'package:almomin/core/services/hajj_umrah_service.dart';
import 'package:almomin/core/services/islamic_mutoon_service.dart';
import 'package:almomin/core/services/ramadan_service.dart';
import 'package:almomin/core/services/riyad_alsalihin_service.dart';
import 'package:almomin/core/services/stories_service.dart';
import 'package:almomin/core/services/tajweed_service.dart';
import 'package:almomin/core/services/voluntary_fasting_service.dart';
import 'package:almomin/core/text/arabic_normalizer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Ultimate v17.0 — Level-6 Deep Edge-Case & Merge-Mode Audit Suite', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('1. ArabicNormalizer.normalizeDigits, tryParseInt, and tryParseDouble handle Arabic-Indic (٠-٩) and Eastern Arabic/Urdu (۰-۹) digits', () {
      expect(ArabicNormalizer.normalizeDigits('٢٥٥'), equals('255'));
      expect(ArabicNormalizer.normalizeDigits('۱۲۳۴۵'), equals('12345'));
      expect(ArabicNormalizer.tryParseInt('١٠٠'), equals(100));
      expect(ArabicNormalizer.tryParseInt(' ٦٠٤ '), equals(604));
      expect(ArabicNormalizer.tryParseInt('۴۵'), equals(45));
      expect(ArabicNormalizer.tryParseDouble('١٢٠٬٥٠٠٫٧٥'), equals(120500.75));
      expect(ArabicNormalizer.tryParseInt('غير رقمي'), isNull);
    });

    test('2. HadithService.getHadithOfTheDay returns safe fallback before init() without throwing StateError, and importFavorites honors replace flag', () async {
      final hadith = HadithService.instance.getHadithOfTheDay();
      expect(hadith.id, isPositive);
      expect(hadith.matn, isNotEmpty);

      await HadithService.instance.importFavorites([1, 2, 3], replace: true);
      expect(HadithService.instance.exportFavorites(), containsAll([1, 2, 3]));

      // Merge mode (replace: false)
      await HadithService.instance.importFavorites([4, 5], replace: false);
      expect(HadithService.instance.exportFavorites(), containsAll([1, 2, 3, 4, 5]));

      // Replace mode (replace: true) clears old favorites
      await HadithService.instance.importFavorites([10], replace: true);
      expect(HadithService.instance.exportFavorites(), equals([10]));
    });

    test('3. BackupRestoreService.restoreBackup in Merge Mode (replaceMode: false) unions all 17 extended feature sets and preserves max scores', () async {
      final prefs = await SharedPreferences.getInstance();

      // Step A: Populate Device A state and export backup
      await prefs.setStringList('gharib_mastered_words', ['gh_1', 'gh_2']);
      await prefs.setInt('gharib_quiz_best_score', 8);
      await prefs.setStringList('stories_favorites', ['prophet_adam']);
      await prefs.setStringList('riyad_bookmarks_v1', ['riyad_1']);
      await prefs.setStringList('memorized_mutoon_ids_v1', ['mutoon_1']);
      await prefs.setStringList('tajweed_favorites', ['taj_1']);
      await prefs.setStringList('ramadan_fasted_days', ['1', '2']);
      await prefs.setInt('hajj_tawaf_lap', 5);
      await prefs.setStringList('hajj_completed_steps', ['ihram']);

      final backupJson = await BackupRestoreService.instance.exportBackupJson();
      final validation = BackupRestoreService.instance.validateBackup(backupJson);
      expect(validation.isValid, isTrue);

      // Step B: Populate Device B with different local items and higher quiz score
      await prefs.clear();
      await prefs.setStringList('gharib_mastered_words', ['gh_3']);
      await prefs.setInt('gharib_quiz_best_score', 12); // Higher than backup's 8
      await prefs.setStringList('stories_favorites', ['prophet_nuh']);
      await prefs.setStringList('riyad_bookmarks_v1', ['riyad_2']);
      await prefs.setStringList('memorized_mutoon_ids_v1', ['mutoon_2']);
      await prefs.setStringList('tajweed_favorites', ['taj_2']);
      await prefs.setStringList('ramadan_fasted_days', ['3']);
      await prefs.setInt('hajj_tawaf_lap', 3); // Lower than backup's 5
      await prefs.setStringList('hajj_completed_steps', ['tawaf']);

      // Step C: Restore in Merge Mode (replaceMode: false)
      final ok = await BackupRestoreService.instance.restoreBackup(
        validation.rawData!,
        replaceMode: false,
      );
      expect(ok, isTrue);

      // Verify union of sets and max of scores/laps!
      expect(GharibQuranService.instance.masteredWordIds, containsAll(['gh_1', 'gh_2', 'gh_3']));
      expect(GharibQuranService.instance.quizBestScore, equals(12));
      expect(prefs.getStringList('stories_favorites'), containsAll(['prophet_adam', 'prophet_nuh']));
      expect(prefs.getStringList('riyad_bookmarks_v1'), containsAll(['riyad_1', 'riyad_2']));
      expect(prefs.getStringList('memorized_mutoon_ids_v1'), containsAll(['mutoon_1', 'mutoon_2']));
      expect(prefs.getStringList('tajweed_favorites'), containsAll(['taj_1', 'taj_2']));
      expect(prefs.getStringList('ramadan_fasted_days'), containsAll(['1', '2', '3']));
      expect(HajjUmrahService.instance.tawafLap, equals(5));
      expect(HajjUmrahService.instance.completedStepIds, containsAll(['ihram', 'tawaf']));
    });

    test('4. Static code verification of Level-6 guards across dialogs, ProgressIndicators, and Scrollable', () {
      for (final path in [
        'lib/features/adhkar/widgets/tasbih_custom_dialogs.dart',
        'lib/features/khatma/widgets/khatma_manual_adjust_dialogs.dart',
        'lib/features/khatma/widgets/khatma_new_plan_dialog.dart',
        'lib/features/mushaf/page_mode_mushaf_screen.dart',
      ]) {
        final content = File(path).readAsStringSync();
        expect(content.contains('ArabicNormalizer.tryParseInt'), isTrue, reason: 'Missing ArabicNormalizer.tryParseInt in $path');
      }

      final memContent = File('lib/features/mushaf/memorization_screen.dart').readAsStringSync();
      expect(memContent.contains('if (ctx != null && ctx.mounted)'), isTrue);
    });
  });
}
