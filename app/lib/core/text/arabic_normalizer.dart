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

  /// Normalizes Arabic-Indic (٠-٩) and Eastern Arabic/Urdu (۰-۹) digits to ASCII (0-9)
  static String normalizeDigits(String input) {
    if (input.isEmpty) return '';
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      if (digitMap.containsKey(ch)) {
        sb.write(digitMap[ch]);
      } else if (ch == '٫') {
        sb.write('.');
      } else if (ch == '،' || ch == ',' || ch == '٬') {
        // strip thousand separators
      } else {
        sb.write(ch);
      }
    }
    return sb.toString().trim();
  }

  /// Safely parses an integer from user input containing ASCII, Arabic-Indic, or Urdu digits
  static int? tryParseInt(String input) {
    final cleaned = normalizeDigits(input);
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  /// Safely parses a double from user input containing ASCII, Arabic-Indic, or Urdu digits
  static double? tryParseDouble(String input) {
    final cleaned = normalizeDigits(input);
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}
