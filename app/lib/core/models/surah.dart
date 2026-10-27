class Surah {
  final int id;
  final String nameAr;
  final String nameSimple;
  final String revelationPlace;
  final int revelationOrder;
  final int ayahCount;
  final bool hasBasmala;
  final int pageStart;
  final int pageEnd;

  const Surah({
    required this.id,
    required this.nameAr,
    required this.nameSimple,
    required this.revelationPlace,
    required this.revelationOrder,
    required this.ayahCount,
    required this.hasBasmala,
    required this.pageStart,
    required this.pageEnd,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String,
      nameSimple: json['name_simple'] as String? ?? '',
      revelationPlace: json['revelation_place'] as String,
      revelationOrder: json['revelation_order'] as int,
      ayahCount: json['ayah_count'] as int,
      hasBasmala: (json['has_basmala'] as int? ?? 1) == 1,
      pageStart: json['page_start'] as int,
      pageEnd: json['page_end'] as int,
    );
  }

  bool get isMakki => revelationPlace == 'makkah';
}
