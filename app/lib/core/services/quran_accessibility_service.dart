/// Native Zero-Toggle Accessibility & Screen Reader Engine
/// Provides automatic phonetic normalization and rich Arabic semantic labels
/// across all screens out-of-the-box without requiring any manual user setting.
library;

class QuranAccessibilityService {
  /// Diacritics and archaic Quranic recitation signs that break screen readers / TTS
  static final RegExp _quranicRecitationSigns = RegExp(
    r'[\u06D6-\u06DC\u06DD\u06DE\u06DF\u06E0\u06E2\u06E3\u06E4\u06E7\u06E8\u06E9\u06EA\u06EB\u06EC\u06ED\u08D3-\u08FF]',
  );

  /// Zero-width format and invisible joiner characters that cause TTS engines to pause incorrectly
  static final RegExp _zeroWidthChars = RegExp(
    r'[\u2000-\u200F\u2028-\u202F\u205F-\u206F\uFEFF\u034F]',
  );

  /// Converts complex Uthmani Quranic text into phonetically smooth Arabic
  /// pronounced accurately by Arabic Text-To-Speech engines
  /// without deleting essential vowels (fat-ha, damma, kasra, shadda, sukun).
  static String toScreenReaderText(String textUthmani) {
    if (textUthmani.isEmpty) return '';

    String text = textUthmani;

    // 1. Remove zero-width characters
    text = text.replaceAll(_zeroWidthChars, '');

    // 2. Remove marginal recitation stop marks (ج, صلي, قلي, مـ, لا, سكت, سجدة, حزب)
    text = text.replaceAll(_quranicRecitationSigns, '');

    // 3. Replace archaic Quranic Sukun (U+06E1) with standard Sukun (U+0652)
    text = text.replaceAll('\u06E1', '\u0652');

    // 4. Replace Waslah Alef (U+0671 ٱ) with standard bare Alef (U+0627 ا)
    text = text.replaceAll('\u0671', '\u0627');

    // 5. Replace Farsi/Urdu Yeh (U+06CC ی) with standard Arabic Yeh (U+064A ي)
    text = text.replaceAll('\u06CC', '\u064A');

    // 6. Replace Keheh (U+06A9 ک) with standard Arabic Kaf (U+0643 ك)
    text = text.replaceAll('\u06A9', '\u0643');

    // 7. Replace Small Waw (U+06E5 ۥ) with standard Waw (و)
    text = text.replaceAll('\u06E5', 'و');

    // 8. Replace Small Ya (U+06E6 ۦ) with standard Ya (ي)
    text = text.replaceAll('\u06E6', 'ي');

    // 9. Normalize Tatweel + Dagger Alef (ـٰ) or standalone Dagger Alef (ٰ)
    text = text.replaceAll('ـ\u0670', 'ا');
    text = text.replaceAll('\u0640', '');

    // 10. Replace standalone Dagger Alef with Alef
    text = text.replaceAll('\u0670', 'ا');

    // 11. Collapse redundant spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  /// Builds a rich, reverent semantic label for any Ayah
  static String buildAyahSemanticLabel({
    required String surahName,
    required int ayahNumber,
    required String uthmaniText,
  }) {
    final cleanPronunciation = toScreenReaderText(uthmaniText);
    return 'آية رقم $ayahNumber من سورة $surahName: $cleanPronunciation';
  }

  /// Semantic interaction hint for an Ayah
  static String get ayahSemanticHint =>
      'انقر للاستماع إلى تلاوة الآية، أو انقر مطولاً لعرض الإعراب وأسباب النزول والتفسير.';

  /// Builds a semantic label for a Surah Header
  static String buildSurahHeaderSemanticLabel({
    required String surahName,
    required bool isMakki,
    required int ayahCount,
    required int revelationOrder,
  }) {
    final type = isMakki ? 'مكية' : 'مدنية';
    return 'سورة $surahName، $type، عدد آياتها $ayahCount آية، ترتيب نزولها $revelationOrder.';
  }

  /// Builds a semantic label for a Mushaf Page Header
  static String buildPageSemanticLabel({
    required int pageNumber,
    required int juz,
    required int hizb,
    required String surahName,
  }) {
    return 'صفحة المصحف رقم $pageNumber من 604، سورة $surahName، الجزء $juz، الحزب $hizb.';
  }

  /// Builds a semantic label for a Prayer Time row
  static String buildPrayerTimeSemanticLabel({
    required String prayerName,
    required String formattedTime,
    required bool isNext,
  }) {
    final nextTag = isNext ? '، وهي الصلاة القادمة' : '';
    return 'صلاة $prayerName، الموعد: $formattedTime$nextTag';
  }

  /// Builds a semantic label for an Adhkar item card
  static String buildDhikrSemanticLabel({
    required String text,
    required int currentCount,
    required int targetCount,
    String? virtue,
  }) {
    final clean = toScreenReaderText(text);
    final status = currentCount >= targetCount
        ? 'مكتمل ($targetCount من $targetCount)'
        : 'العدد الحالي $currentCount من أصل $targetCount';
    final v = (virtue != null && virtue.isNotEmpty) ? '، الفضل: $virtue' : '';
    return '$clean، $status$v';
  }

  /// Builds a semantic label for a Hadith or Riyad As-Salihin entry
  static String buildHadithSemanticLabel({
    required String title,
    required String matn,
    required String narrator,
    required String source,
  }) {
    final cleanMatn = toScreenReaderText(matn);
    return '$title، عن $narrator: $cleanMatn، رواه $source';
  }
}
