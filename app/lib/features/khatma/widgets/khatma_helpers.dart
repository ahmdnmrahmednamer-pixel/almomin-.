/// Shared Arabic-Indic numeral and time formatting helpers for Khatma widgets.
class KhatmaFormatHelper {
  static const List<String> arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String toArabicIndic(int number) {
    return number.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicDigits[digit] : char;
    }).join();
  }

  static String formatTimeOfDay(int hour, int minute) {
    final period = hour >= 12 ? 'م' : 'ص';
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final minStr = minute.toString().padLeft(2, '0');
    return '${toArabicIndic(h12)}:${toArabicIndic(int.tryParse(minStr) ?? 0)} $period';
  }
}
