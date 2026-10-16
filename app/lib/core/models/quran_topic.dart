import 'package:flutter/material.dart';

enum TopicCategory {
  faith('الإيمانيات والعقيدة', Icons.auto_awesome),
  morals('الأخلاق والسلوك', Icons.favorite_rounded),
  worship('العبادات والطاعات', Icons.access_time_filled_rounded),
  life('الحياة والابتلاء', Icons.wb_sunny_rounded),
  family('الأسرة والمجتمع', Icons.people_alt_rounded),
  dua('الأدعية القرآنية', Icons.volunteer_activism_rounded);

  final String label;
  final IconData icon;
  const TopicCategory(this.label, this.icon);
}

class TopicAyahItem {
  final int surahId;
  final int ayahNumber;
  final String surahName;
  final int page;
  final String text;
  final String significance; // وجه الاستدلال والإضاءة القرآنية

  const TopicAyahItem({
    required this.surahId,
    required this.ayahNumber,
    required this.surahName,
    required this.page,
    required this.text,
    required this.significance,
  });

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'ayahNumber': ayahNumber,
        'surahName': surahName,
        'page': page,
        'text': text,
        'significance': significance,
      };

  factory TopicAyahItem.fromJson(Map<String, dynamic> json) => TopicAyahItem(
        surahId: json['surahId'] as int,
        ayahNumber: json['ayahNumber'] as int,
        surahName: json['surahName'] as String,
        page: json['page'] as int,
        text: json['text'] as String,
        significance: json['significance'] as String,
      );
}

class QuranTopic {
  final String id;
  final String title;
  final TopicCategory category;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final List<TopicAyahItem> ayahs;

  const QuranTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.ayahs,
  });

  int get ayahCount => ayahs.length;
}
