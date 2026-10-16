class Juz {
  final int id;
  final int startSurah;
  final int startAyah;
  final int pageStart;
  final String nameAr;

  const Juz({
    required this.id,
    required this.startSurah,
    required this.startAyah,
    required this.pageStart,
    required this.nameAr,
  });

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      id: json['id'] as int,
      startSurah: json['start_surah'] as int,
      startAyah: json['start_ayah'] as int,
      pageStart: json['page_start'] as int,
      nameAr: json['name_ar'] as String,
    );
  }
}
