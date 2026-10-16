enum MemorizationRating {
  easy,
  hard,
  forgot,
}

enum MemorizationHideMode {
  none,
  secondHalf,
  everyNthWord,
  allWords,
}

class MemorizationMaskHelper {
  /// Splits an Ayah's Uthmani text into individual words
  static List<String> splitAyahWords(String uthmaniText) {
    return uthmaniText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Determines whether a word should be hidden based on the hide mode and user reveal state
  static bool isWordMasked({
    required int wordIndex,
    required int totalWords,
    required MemorizationHideMode mode,
    required bool isRevealed,
  }) {
    if (isRevealed) return false;
    switch (mode) {
      case MemorizationHideMode.none:
        return false;
      case MemorizationHideMode.secondHalf:
        return wordIndex >= (totalWords / 2).ceil();
      case MemorizationHideMode.everyNthWord:
        return wordIndex % 2 == 1;
      case MemorizationHideMode.allWords:
        return true;
    }
  }
}

class MemorizationItem {
  final String id; // format: '${surahId}:${ayahNumber}'
  final int surahId;
  final int ayahNumber;
  final String surahName;
  final int leitnerBox; // 1 to 5
  final DateTime lastReviewedAt;
  final DateTime nextReviewDue;
  final int timesReviewed;
  final int timesCorrect;
  final MemorizationRating? lastRating;

  const MemorizationItem({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.surahName,
    required this.leitnerBox,
    required this.lastReviewedAt,
    required this.nextReviewDue,
    required this.timesReviewed,
    required this.timesCorrect,
    this.lastRating,
  });

  static String generateId(int surahId, int ayahNumber) => '$surahId:$ayahNumber';

  bool get isDue => DateTime.now().isAfter(nextReviewDue);

  /// Leitner spaced repetition interval calculation (1, 3, 7, 14, 30 days)
  static Duration getIntervalForBox(int box) {
    switch (box) {
      case 1:
        return const Duration(days: 1);
      case 2:
        return const Duration(days: 3);
      case 3:
        return const Duration(days: 7);
      case 4:
        return const Duration(days: 14);
      case 5:
      default:
        return const Duration(days: 30);
    }
  }

  factory MemorizationItem.createInitial({
    required int surahId,
    required int ayahNumber,
    required String surahName,
  }) {
    final now = DateTime.now();
    return MemorizationItem(
      id: generateId(surahId, ayahNumber),
      surahId: surahId,
      ayahNumber: ayahNumber,
      surahName: surahName,
      leitnerBox: 1,
      lastReviewedAt: now,
      nextReviewDue: now,
      timesReviewed: 0,
      timesCorrect: 0,
    );
  }

  MemorizationItem recordReview(MemorizationRating rating) {
    final now = DateTime.now();
    int newBox = leitnerBox;
    int newTimesCorrect = timesCorrect;

    switch (rating) {
      case MemorizationRating.easy:
        newBox = (leitnerBox < 5) ? leitnerBox + 1 : 5;
        newTimesCorrect += 1;
        break;
      case MemorizationRating.hard:
        newBox = (leitnerBox > 1) ? leitnerBox - 1 : 1;
        break;
      case MemorizationRating.forgot:
        newBox = 1;
        break;
    }

    final interval = getIntervalForBox(newBox);
    final nextDue = now.add(interval);

    return MemorizationItem(
      id: id,
      surahId: surahId,
      ayahNumber: ayahNumber,
      surahName: surahName,
      leitnerBox: newBox,
      lastReviewedAt: now,
      nextReviewDue: nextDue,
      timesReviewed: timesReviewed + 1,
      timesCorrect: newTimesCorrect,
      lastRating: rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_id': surahId,
      'ayah_number': ayahNumber,
      'surah_name': surahName,
      'leitner_box': leitnerBox,
      'last_reviewed_at': lastReviewedAt.toIso8601String(),
      'next_review_due': nextReviewDue.toIso8601String(),
      'times_reviewed': timesReviewed,
      'times_correct': timesCorrect,
      'last_rating': lastRating?.name,
    };
  }

  factory MemorizationItem.fromJson(Map<String, dynamic> json) {
    MemorizationRating? rating;
    if (json['last_rating'] != null) {
      try {
        rating = MemorizationRating.values.byName(json['last_rating'] as String);
      } catch (_) {}
    }

    return MemorizationItem(
      id: json['id'] as String? ?? generateId(json['surah_id'] as int, json['ayah_number'] as int),
      surahId: json['surah_id'] as int,
      ayahNumber: json['ayah_number'] as int,
      surahName: json['surah_name'] as String? ?? '',
      leitnerBox: json['leitner_box'] as int? ?? 1,
      lastReviewedAt: DateTime.tryParse(json['last_reviewed_at'] as String? ?? '') ?? DateTime.now(),
      nextReviewDue: DateTime.tryParse(json['next_review_due'] as String? ?? '') ?? DateTime.now(),
      timesReviewed: json['times_reviewed'] as int? ?? 0,
      timesCorrect: json['times_correct'] as int? ?? 0,
      lastRating: rating,
    );
  }
}
