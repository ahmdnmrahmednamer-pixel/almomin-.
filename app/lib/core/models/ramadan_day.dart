class RamadanDay {
  final int dayNumber; // 1 to 30
  final DateTime gregorianDate;
  final String dayName;
  final String imsakTime;
  final String fajrTime;
  final String sunriseTime;
  final String dhuhrTime;
  final String asrTime;
  final String maghribTime; // وقت الإفطار
  final String ishaTime;
  final String dailyDuaa;

  const RamadanDay({
    required this.dayNumber,
    required this.gregorianDate,
    required this.dayName,
    required this.imsakTime,
    required this.fajrTime,
    required this.sunriseTime,
    required this.dhuhrTime,
    required this.asrTime,
    required this.maghribTime,
    required this.ishaTime,
    required this.dailyDuaa,
  });
}

class RamadanDuaa {
  final String title;
  final String arabicText;
  final String category; // إفطار، سحور، ليلة القدر، عام
  final String source;

  const RamadanDuaa({
    required this.title,
    required this.arabicText,
    required this.category,
    required this.source,
  });
}
