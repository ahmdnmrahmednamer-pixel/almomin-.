/// Model representing a personal Quranic reflection or free-text note on an Ayah (FR-BKM-004 / T-110)
class AyahNote {
  final String id;
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final String noteText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageNumber;

  const AyahNote({
    required this.id,
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
    this.pageNumber = 1,
  });

  static String generateId(int surahId, int ayahNumber) => '${surahId}_$ayahNumber';

  AyahNote copyWith({
    String? id,
    int? surahId,
    String? surahName,
    int? ayahNumber,
    String? ayahText,
    String? noteText,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? pageNumber,
  }) {
    return AyahNote(
      id: id ?? this.id,
      surahId: surahId ?? this.surahId,
      surahName: surahName ?? this.surahName,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      ayahText: ayahText ?? this.ayahText,
      noteText: noteText ?? this.noteText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahId': surahId,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'noteText': noteText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pageNumber': pageNumber,
    };
  }

  factory AyahNote.fromJson(Map<String, dynamic> json) {
    final surahId = json['surahId'] as int? ?? 1;
    final ayahNumber = json['ayahNumber'] as int? ?? 1;
    return AyahNote(
      id: json['id'] as String? ?? generateId(surahId, ayahNumber),
      surahId: surahId,
      surahName: json['surahName'] as String? ?? '',
      ayahNumber: ayahNumber,
      ayahText: json['ayahText'] as String? ?? '',
      noteText: json['noteText'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      pageNumber: json['pageNumber'] as int? ?? 1,
    );
  }
}
