class Ayah {
  final int id;
  final int surahId;
  final int ayahNumber;
  final int juz;
  final int hizb;
  final int rub;
  final int page;
  final int sajdah;
  final String textUthmani;
  final String textImlaei;
  final String textSearch;
  final String? tafseer;

  const Ayah({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.juz,
    required this.hizb,
    required this.rub,
    required this.page,
    required this.sajdah,
    required this.textUthmani,
    required this.textImlaei,
    required this.textSearch,
    this.tafseer,
  });

  factory Ayah.fromRow(Map<String, dynamic> row) {
    return Ayah(
      id: row['id'] as int,
      surahId: (row['surah_id'] ?? row['surahId']) as int,
      ayahNumber: (row['ayah_number'] ?? row['ayahNumber']) as int,
      juz: row['juz'] as int,
      hizb: row['hizb'] as int? ?? 1,
      rub: row['rub'] as int? ?? 1,
      page: row['page'] as int,
      sajdah: row['sajdah'] as int? ?? 0,
      textUthmani: (row['text_uthmani'] ?? row['textUthmani']) as String,
      textImlaei: (row['text_imlaei'] ?? row['textImlaei']) as String? ?? '',
      textSearch: (row['text_search'] ?? row['textSearch']) as String? ?? '',
      tafseer: row['tafseer'] as String?,
    );
  }

  bool get hasSajdah => sajdah > 0;
}
