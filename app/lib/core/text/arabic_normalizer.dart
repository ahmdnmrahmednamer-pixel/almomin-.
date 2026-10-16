/// Arabic Search Normalization (Appendix A Reference Algorithm)
/// Matches normalizer.py and normalizer_vectors.json test vectors.
library;

class ArabicNormalizer {
  // Tashkeel, Quranic recitation signs, tatweel, and ayah markers
  static final RegExp diacriticsRegex = RegExp(
    r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u08D3-\u08FF\u0640\u06DD]',
  );

  static final Map<String, String> digitMap = {
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };

  static final Map<String, String> looseLetterMap = {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
    'ى': 'ي',
    'ؤ': 'و', 'ئ': 'ي',
    'ة': 'ه',
    'ی': 'ي', 'ک': 'ك',
  };

  /// Normalizes Arabic text for searching and indexing.
  /// Never mutates canonical Quran text.
  static String normalize(String text, {bool loose = true}) {
    if (text.isEmpty) return '';

    // 1. Remove diacritics and recitation signs
    String cleaned = text.replaceAll(diacriticsRegex, '');

    // 2. Normalize letter variants
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      String char = cleaned[i];
      if (loose && looseLetterMap.containsKey(char)) {
        sb.write(looseLetterMap[char]);
      } else if (digitMap.containsKey(char)) {
        sb.write(digitMap[char]);
      } else {
        sb.write(char);
      }
    }

    // 3. Collapse whitespace and trim
    return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
