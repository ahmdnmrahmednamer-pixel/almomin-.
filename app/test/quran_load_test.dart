import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/services/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads Surah 1 ayahs from assets', () async {
    final ayahs = await QuranRepository.getAyahsForSurah(1);
    print('Ayahs loaded for Surah 1: ${ayahs.length}');
    expect(ayahs.length, 7);
    expect(ayahs[0].textUthmani, contains('ٱللَّهِ'));
  });

  test('loads Surah 2 ayahs from assets', () async {
    final ayahs = await QuranRepository.getAyahsForSurah(2);
    print('Ayahs loaded for Surah 2: ${ayahs.length}');
    expect(ayahs.length, 286);
  });
}
