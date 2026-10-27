import 'package:flutter/material.dart';

/// ١. نموذج مسألة فقهية في مكتبة الفقه الميسر على المذاهب الأربعة
class FiqhTopicItem {
  final String id;
  final String chapter; // الطهارة، الصلاة، الصيام، الزكاة، الحج، المعاملات
  final String title;
  final String summaryRuling;
  final String evidenceText;
  final Map<String, String> madhahibComparison; // الحنفي، المالكي، الشافعي، الحنبلي
  final String contemporaryNote;

  const FiqhTopicItem({
    required this.id,
    required this.chapter,
    required this.title,
    required this.summaryRuling,
    required this.evidenceText,
    required this.madhahibComparison,
    required this.contemporaryNote,
  });
}

/// ٢. نموذج مبحث في مكتبة علوم القرآن وأسباب النزول
class QuranScienceEntry {
  final String id;
  final String category; // أسباب النزول، المكي والمدني، فضائل السور، مقاصد السور، أصول التفسير
  final String surahName;
  final String ayahReference;
  final String title;
  final String narrationOrRule;
  final String scholarlySource;
  final String practicalBenefit;

  const QuranScienceEntry({
    required this.id,
    required this.category,
    required this.surahName,
    required this.ayahReference,
    required this.title,
    required this.narrationOrRule,
    required this.scholarlySource,
    required this.practicalBenefit,
  });
}

/// ٣. نموذج اسم من أسماء الله الحسنى
class AsmaAllahEntry {
  final int number;
  final String nameAr;
  final String transliteration;
  final String meaningSummary;
  final String quranicReference;
  final String tadabburAndImpact;
  final String duaaWithThisName;

  const AsmaAllahEntry({
    required this.number,
    required this.nameAr,
    required this.transliteration,
    required this.meaningSummary,
    required this.quranicReference,
    required this.tadabburAndImpact,
    required this.duaaWithThisName,
  });
}

/// ٤. نموذج باب في مكتبة الشمائل المحمدية والأخلاق النبوية
class PropheticShamailEntry {
  final String id;
  final String category; // خَلْقه ﷺ، عبادته، أخلاقه ورحمته، هديه اليومي
  final String title;
  final String hadithText;
  final String narratorAndSource;
  final String practicalSunnah;

  const PropheticShamailEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.hadithText,
    required this.narratorAndSource,
    required this.practicalSunnah,
  });
}

/// ٥. نموذج حدث تاريخي أو ترجمة علم في مكتبة التاريخ الإسلامي والصحابة والأعلام
class IslamicHistoryEntry {
  final String id;
  final String eraOrCategory; // السيرة والغزوات، الصحابة الكرام، أمهات المؤمنين، أئمة الهدى والعلماء
  final String yearHijri;
  final String title;
  final String summary;
  final List<String> keyHighlights;
  final String lessonLearned;

  const IslamicHistoryEntry({
    required this.id,
    required this.eraOrCategory,
    required this.yearHijri,
    required this.title,
    required this.summary,
    required this.keyHighlights,
    required this.lessonLearned,
  });
}

/// ٦. نموذج عنصر الورد اليومي الذكي وخطة الطاعات
class DailyWirdTaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeSlot; // الفجر والصباح، الظهيرة، العصر والمساء، الليل والوتر
  final int rewardPoints;
  final IconData icon;

  const DailyWirdTaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeSlot,
    required this.rewardPoints,
    required this.icon,
  });
}

/// ٧. نموذج نتيجة البحث الموحد عبر جميع المكتبات العشر
class UnifiedLibrarySearchResult {
  final String id;
  final String libraryName;
  final String category;
  final String title;
  final String snippet;
  final String sourceReference;
  final IconData icon;
  final Color accentColor;

  const UnifiedLibrarySearchResult({
    required this.id,
    required this.libraryName,
    required this.category,
    required this.title,
    required this.snippet,
    required this.sourceReference,
    required this.icon,
    required this.accentColor,
  });
}
