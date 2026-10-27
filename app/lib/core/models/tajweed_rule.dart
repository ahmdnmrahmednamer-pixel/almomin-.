import 'package:flutter/material.dart';

enum TajweedCategory {
  nunTanween, // أحكام النون الساكنة والتنوين
  meemSakinah, // أحكام الميم الساكنة
  madd, // أحكام المدود
  qalqalah, // أحكام القلقلة
  waqfMarks, // علامات الوقف وضبط المصحف
  raaLaam, // أحكام الراء واللام (التفخيم والترقيق)
  makhaarij, // مخارج الحروف وصفاتها
}

class TajweedExample {
  final String ayahSnippet;
  final String targetWord;
  final String surahName;
  final int ayahNumber;
  final String explanation;

  const TajweedExample({
    required this.ayahSnippet,
    required this.targetWord,
    required this.surahName,
    required this.ayahNumber,
    required this.explanation,
  });
}

class TajweedRule {
  final String id;
  final String title;
  final String arabicTitle;
  final TajweedCategory category;
  final String summary;
  final String definition;
  final List<String> letters;
  final Color ruleColor;
  final String poeticVerse; // بيت الشعر من تحفة الأطفال أو الجزرية
  final String poeticSource;
  final List<TajweedExample> examples;
  final String howToPronounce; // كيفية الأداء الصوتي الصحيح

  const TajweedRule({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.category,
    required this.summary,
    required this.definition,
    required this.letters,
    required this.ruleColor,
    required this.poeticVerse,
    required this.poeticSource,
    required this.examples,
    required this.howToPronounce,
  });

  String get categoryName {
    switch (category) {
      case TajweedCategory.nunTanween:
        return 'النون الساكنة والتنوين';
      case TajweedCategory.meemSakinah:
        return 'الميم الساكنة';
      case TajweedCategory.madd:
        return 'أحكام المدود';
      case TajweedCategory.qalqalah:
        return 'القلقلة ومراتبها';
      case TajweedCategory.waqfMarks:
        return 'علامات الوقف والضبط';
      case TajweedCategory.raaLaam:
        return 'الراء واللام';
      case TajweedCategory.makhaarij:
        return 'مخارج الحروف والصفات';
    }
  }
}

class TajweedColorGuideItem {
  final String title;
  final String description;
  final Color color;
  final String durationOrEffect;
  final List<String> rules;

  const TajweedColorGuideItem({
    required this.title,
    required this.description,
    required this.color,
    required this.durationOrEffect,
    required this.rules,
  });
}
