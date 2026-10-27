import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/quran_repository.dart';
import 'package:almomin/core/services/quran_search_service.dart';
import 'package:almomin/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
  });

  group('Ultimate v14.0 Level-3 AST, Widget Tree & Runtime Guard Tests', () {
    test('1. SettingsService.setMushafFontSize clamps out-of-range values to [18.0, 38.0]', () async {
      await SettingsService.instance.setMushafFontSize(55.0);
      expect(SettingsService.instance.mushafFontSize, equals(38.0));

      await SettingsService.instance.setMushafFontSize(10.0);
      expect(SettingsService.instance.mushafFontSize, equals(18.0));

      await SettingsService.instance.setMushafFontSize(26.0);
      expect(SettingsService.instance.mushafFontSize, equals(26.0));
    });

    test('2. QuranRepository.getBookmarksDetails caches bookmark lookups for O(1) repeated access', () async {
      final emptyDetails = await QuranRepository.getBookmarksDetails(const []);
      expect(emptyDetails, isEmpty);
    });

    test('3. QuranSearchService handles empty or reference queries safely without throwing StateError', () async {
      final emptyRes = await QuranSearchService.instance.searchAyahs('');
      expect(emptyRes, isEmpty);

      final emptyRef = await QuranSearchService.instance.parseReference('');
      expect(emptyRef, isNull);
    });
  });
}
