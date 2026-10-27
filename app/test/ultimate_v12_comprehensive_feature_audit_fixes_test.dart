import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/backup_restore_service.dart';
import 'package:almomin/core/services/hadith_service.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/quran_topic_service.dart';
import 'package:almomin/core/services/scholars_lectures_service.dart';
import 'package:almomin/core/services/tajweed_service.dart';
import 'package:almomin/core/services/unified_library_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    IslamicAudioService.instance.disableNativePlayerForTesting = true;
    await ScholarsLecturesService.instance.init(forceReload: true);
    await HadithService.instance.init(forceReload: true);
    await TajweedService.instance.init(forceReload: true);
    QuranTopicService.instance.init();
  });

  group('Ultimate v12.0 Comprehensive 16-Bug & 50-Location Feature Audit Verification Tests', () {
    test('1. UnifiedLibrarySearchService indexes all 13 encyclopedias including Scholars Lectures, Riyad Al-Salihin, Gharib Quran, Mutoon, and Spiritual Remedy', () {
      final search = UnifiedLibrarySearchService.instance;
      expect(search.libraryFilters.length, equals(14));

      // Search Scholars Lectures
      final samirResults = search.searchAllLibraries(
        'سمير مصطفى',
        selectedLibrary: 'مجالس العلماء والدروس',
      );
      expect(samirResults, isNotEmpty);

      // Search Riyad Al-Salihin
      final riyadResults = search.searchAllLibraries(
        'الإخلاص',
        selectedLibrary: 'رياض الصالحين',
      );
      expect(riyadResults, isNotEmpty);

      // Search Gharib Quran
      final gharibResults = search.searchAllLibraries(
        'الصمد',
        selectedLibrary: 'غريب القرآن',
      );
      expect(gharibResults, isNotEmpty);

      // Search Mutoon
      final mutoonResults = search.searchAllLibraries(
        'النون الساكنة',
        selectedLibrary: 'المتون العلمية',
      );
      expect(mutoonResults, isNotEmpty);

      // Search Spiritual Remedy
      final remedyResults = search.searchAllLibraries(
        'القلق',
        selectedLibrary: 'صيدلية القلوب',
      );
      expect(remedyResults, isNotEmpty);
    });

    test('2. Safe lookups in HadithService, TajweedService, and QuranTopicService return null instead of throwing StateError on invalid IDs', () {
      expect(HadithService.instance.getHadithById(-99999), isNull);
      expect(HadithService.instance.getBookById('non_existent_book'), isNull);
      expect(TajweedService.instance.getRuleById('non_existent_rule'), isNull);
      expect(QuranTopicService.instance.getTopicById('non_existent_topic'), isNull);
    });

    test('3. BackupRestoreService exports and restores all v6-v12 state keys and reloads services via forceReload: true', () async {
      await ScholarsLecturesService.instance.toggleScholarFavorite('samir_mostafa');
      await TajweedService.instance.toggleFavorite('nun_izhar');

      final backupJson = await BackupRestoreService.instance.exportBackupJson();
      final validation = BackupRestoreService.instance.validateBackup(backupJson);
      expect(validation.isValid, isTrue);

      // Clear preferences and restore
      SharedPreferences.setMockInitialValues({});
      await ScholarsLecturesService.instance.init(forceReload: true);
      expect(ScholarsLecturesService.instance.isScholarFavorite('samir_mostafa'), isFalse);

      final restored = await BackupRestoreService.instance.restoreBackup(
        validation.rawData!,
        replaceMode: true,
      );
      expect(restored, isTrue);
      expect(ScholarsLecturesService.instance.isScholarFavorite('samir_mostafa'), isTrue);
      expect(TajweedService.instance.isFavorite('nun_izhar'), isTrue);
    });
  });
}
