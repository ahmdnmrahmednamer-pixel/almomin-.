import 'package:flutter/material.dart';

/// Category of the prophetic audio story
enum StoryCategory {
  prophet, // قصص الأنبياء والمرسلين
  quranStory, // قصص وعِبر القرآن الكبرى
}

/// Rich Model for Prophet Audio Story (قصص الأنبياء الصوتية)
class ProphetAudioStory {
  final String id;
  final String title;
  final String characterName;
  final String subtitle;
  final StoryCategory category;
  final String narrator;
  final String duration;
  final int durationSeconds;
  final int fileSizeBytes;
  final String audioUrl;
  final String era;
  final List<String> surahsMentioned;
  final String summary;
  final List<String> keyLessons;
  final String? propheticDuaa;
  final String? duaaReference;
  final bool isUluAlAzm;

  final String seriesName;
  final String scholarId;

  const ProphetAudioStory({
    required this.id,
    required this.title,
    required this.characterName,
    required this.subtitle,
    required this.category,
    this.narrator = 'فضيلة الشيخ نبيل العوضي',
    this.seriesName = 'سلسلة قصص الأنبياء',
    this.scholarId = 'al_awadi',
    required this.duration,
    required this.durationSeconds,
    required this.fileSizeBytes,
    required this.audioUrl,
    required this.era,
    required this.surahsMentioned,
    required this.summary,
    required this.keyLessons,
    this.propheticDuaa,
    this.duaaReference,
    this.isUluAlAzm = false,
  });

  String get categoryName {
    switch (category) {
      case StoryCategory.prophet:
        return 'قصص الأنبياء والمرسلين';
      case StoryCategory.quranStory:
        return 'قصص وعِبر القرآن';
    }
  }

  String get formattedSize {
    if (fileSizeBytes <= 0) return '0 MB';
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb < 0.1) {
      final kb = fileSizeBytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }
}

// Backwards compatibility alias
typedef ProphetStory = ProphetAudioStory;
