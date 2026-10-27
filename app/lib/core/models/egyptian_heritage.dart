import 'package:flutter/material.dart';

/// Represents a live radio stream or curated Egyptian recitation broadcast.
class EgyptianRadioStation {
  final String id;
  final String name;
  final String subtitle;
  final String frequencyOrBadge;
  final String streamUrl;
  final List<String> fallbackUrls;
  final IconData icon;
  final Color accentColor;
  final List<String> dailyScheduleHighlights;

  const EgyptianRadioStation({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.frequencyOrBadge,
    required this.streamUrl,
    this.fallbackUrls = const [],
    required this.icon,
    required this.accentColor,
    this.dailyScheduleHighlights = const [],
  });

  String get frequencyLabel => frequencyOrBadge;
  String get broadcaster => name;
  List<String> get fallbackStreamUrls => fallbackUrls;
  String get description => subtitle;
  List<String> get dailySchedule => dailyScheduleHighlights;
}

/// Represents a classic Egyptian Ibtihal or Tawshih track.
class EgyptianIbtihalItem {
  final String id;
  final String title;
  final String mubtahilName;
  final String mubtahilTitle;
  final String occasionOrMaqam;
  final String duration;
  final String audioUrl;
  final List<String> fallbackUrls;
  final String lyricsExcerpt;
  final String spiritualNote;

  const EgyptianIbtihalItem({
    required this.id,
    required this.title,
    required this.mubtahilName,
    required this.mubtahilTitle,
    required this.occasionOrMaqam,
    required this.duration,
    required this.audioUrl,
    this.fallbackUrls = const [],
    required this.lyricsExcerpt,
    required this.spiritualNote,
  });

  String get mubtahil => mubtahilName;
  String get maqamOrStyle => occasionOrMaqam;
  String get occasion => occasionOrMaqam;
  List<String> get fallbackAudioUrls => fallbackUrls;
}

/// Represents a reflection or supplication by Sheikh Muhammad Metwally Al-Sha'rawi.
class ShaarawiReflectionItem {
  final String id;
  final String title;
  final String category;
  final String surahOrTopic;
  final String arabicText;
  final String summaryInsight;
  final String? audioTrackId;
  final String? remoteAudioUrl;

  const ShaarawiReflectionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.surahOrTopic,
    required this.arabicText,
    required this.summaryInsight,
    this.audioTrackId,
    this.remoteAudioUrl,
  });

  String get topic => surahOrTopic;
  String get audioUrl => remoteAudioUrl ?? '';
  List<String> get fallbackAudioUrls => const [];
  String get surahOrAyah => surahOrTopic;
  String get reflectionText => arabicText;
  String get keyLesson => summaryInsight;
}

/// Represents a historic mosque or Islamic landmark in Egypt.
class EgyptianHistoricMosque {
  final String id;
  final String name;
  final String cityAndDistrict;
  final String foundedYear;
  final String era;
  final double latitude;
  final double longitude;
  final String architecturalHighlight;
  final String historicalStory;
  final List<String> famousReciters;

  const EgyptianHistoricMosque({
    required this.id,
    required this.name,
    required this.cityAndDistrict,
    required this.foundedYear,
    required this.era,
    required this.latitude,
    required this.longitude,
    required this.architecturalHighlight,
    required this.historicalStory,
    required this.famousReciters,
  });

  String get governorate => cityAndDistrict;
}

/// Represents a verified jurisprudential ruling from Dar Al-Ifta Al-Misriyyah & Al-Azhar Al-Sharif.
class EgyptianFatwaItem {
  final String id;
  final String title;
  final String category;
  final String questionSummary;
  final String rulingSummary;
  final String detailedEvidence;
  final String issuingAuthority;

  const EgyptianFatwaItem({
    required this.id,
    required this.title,
    required this.category,
    required this.questionSummary,
    required this.rulingSummary,
    required this.detailedEvidence,
    required this.issuingAuthority,
  });

  String get question => questionSummary;
  String get sourceAuthority => issuingAuthority;
  String get referenceNote => detailedEvidence;
}
