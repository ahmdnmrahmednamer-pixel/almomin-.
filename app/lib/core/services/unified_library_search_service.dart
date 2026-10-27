import 'package:flutter/material.dart';
import '../models/islamic_libraries_models.dart';
import '../text/arabic_normalizer.dart';
import '../theme/app_theme.dart';
import 'hadith_service.dart';
import 'stories_service.dart';
import 'tajweed_service.dart';
import 'quran_topic_service.dart';
import 'fiqh_library_service.dart';
import 'quran_sciences_service.dart';
import 'asma_allah_shamail_service.dart';
import 'islamic_history_service.dart';
import 'egyptian_heritage_service.dart';
import 'scholars_lectures_service.dart';
import 'riyad_alsalihin_service.dart';
import 'gharib_quran_service.dart';
import 'islamic_mutoon_service.dart';
import 'spiritual_mood_remedy_service.dart';

/// محرك البحث الموسوعي الموحد عبر جميع المكتبات الإسلامية والعلمية والصوتية في التطبيق (١٣ موسوعة)
class UnifiedLibrarySearchService {
  static final UnifiedLibrarySearchService instance =
      UnifiedLibrarySearchService._internal();
  UnifiedLibrarySearchService._internal();

  bool _matchesNormalized(String text, String rawQuery, String normQuery) {
    if (text.toLowerCase().contains(rawQuery.toLowerCase())) return true;
    if (normQuery.isNotEmpty) {
      return ArabicNormalizer.normalize(text, loose: true).contains(normQuery);
    }
    return false;
  }

  List<UnifiedLibrarySearchResult> searchAllLibraries(
    String query, {
    String selectedLibrary = 'الكل',
  }) {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final normQ = ArabicNormalizer.normalize(q, loose: true);

    final List<UnifiedLibrarySearchResult> results = [];

    // 1. موسوعة الحديث النبوي
    if (selectedLibrary == 'الكل' || selectedLibrary == 'الحديث النبوي') {
      for (final h in HadithService.instance.searchHadiths(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'hadith_${h.id}',
            libraryName: 'الحديث النبوي',
            category: h.narrator,
            title: h.title,
            snippet: h.matn,
            sourceReference: h.grade,
            icon: Icons.auto_stories_rounded,
            accentColor: AppColors.primaryGreen,
          ),
        );
      }
    }

    // 2. موسوعة الفقه الميسر
    if (selectedLibrary == 'الكل' || selectedLibrary == 'الفقه الميسر') {
      for (final f in FiqhLibraryService.instance.searchTopics(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: f.id,
            libraryName: 'الفقه الميسر',
            category: f.chapter,
            title: f.title,
            snippet: f.summaryRuling,
            sourceReference: 'مقارنة المذاهب الأربعة والفتاوى المعاصرة',
            icon: Icons.balance_rounded,
            accentColor: const Color(0xFF0D5C46),
          ),
        );
      }
    }

    // 3. علوم القرآن وأسباب النزول
    if (selectedLibrary == 'الكل' || selectedLibrary == 'علوم القرآن') {
      for (final qs in QuranSciencesService.instance.searchEntries(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: qs.id,
            libraryName: 'علوم القرآن',
            category: qs.category,
            title: '${qs.title} (${qs.surahName})',
            snippet: qs.narrationOrRule,
            sourceReference: qs.scholarlySource,
            icon: Icons.menu_book_rounded,
            accentColor: const Color(0xFF1F6E58),
          ),
        );
      }
    }

    // 4. أسماء الله الحسنى والشمائل المحمدية
    if (selectedLibrary == 'الكل' || selectedLibrary == 'أسماء الله والشمائل') {
      for (final a in AsmaAllahShamailService.instance.searchAsma(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'asma_${a.number}',
            libraryName: 'أسماء الله والشمائل',
            category: 'أسماء الله الحسنى',
            title: 'اسم الله: ${a.nameAr}',
            snippet: '${a.meaningSummary}\nالدعاء: ${a.duaaWithThisName}',
            sourceReference: a.quranicReference,
            icon: Icons.stars_rounded,
            accentColor: const Color(0xFFB88917),
          ),
        );
      }
      for (final s in AsmaAllahShamailService.instance.searchShamail(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: s.id,
            libraryName: 'أسماء الله والشمائل',
            category: s.category,
            title: s.title,
            snippet: s.hadithText,
            sourceReference: s.narratorAndSource,
            icon: Icons.favorite_rounded,
            accentColor: const Color(0xFFB88917),
          ),
        );
      }
    }

    // 5. التاريخ الإسلامي والسيرة والصحابة
    if (selectedLibrary == 'الكل' || selectedLibrary == 'التاريخ والسيرة') {
      for (final h in IslamicHistoryService.instance.searchEntries(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: h.id,
            libraryName: 'التاريخ والسيرة',
            category: h.eraOrCategory,
            title: '${h.title} (${h.yearHijri})',
            snippet: h.summary,
            sourceReference: h.lessonLearned,
            icon: Icons.history_edu_rounded,
            accentColor: const Color(0xFF6B4C35),
          ),
        );
      }
    }

    // 6. التراث المصري ودار الإفتاء ومساجد مصر
    if (selectedLibrary == 'الكل' || selectedLibrary == 'التراث المصري') {
      for (final f in EgyptianHeritageService.instance.searchFatwas(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: f.id,
            libraryName: 'التراث المصري',
            category: 'فتاوى دار الإفتاء المصرية',
            title: f.question,
            snippet: f.rulingSummary,
            sourceReference: f.sourceAuthority,
            icon: Icons.gavel_rounded,
            accentColor: const Color(0xFF0A4D3C),
          ),
        );
      }
      for (final m in EgyptianHeritageService.instance.searchMosques(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: m.id,
            libraryName: 'التراث المصري',
            category: 'مساجد مصر التاريخية',
            title: '${m.name} (${m.governorate})',
            snippet: m.architecturalHighlight,
            sourceReference: '${m.era} — ${m.foundedYear}',
            icon: Icons.mosque_rounded,
            accentColor: const Color(0xFF0A4D3C),
          ),
        );
      }
    }

    // 7. قصص الأنبياء
    if (selectedLibrary == 'الكل' || selectedLibrary == 'قصص الأنبياء') {
      for (final st in StoriesService.instance.searchStories(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'story_${st.id}',
            libraryName: 'قصص الأنبياء',
            category: st.characterName,
            title: st.title,
            snippet: st.summary,
            sourceReference: 'رواية د. نبيل العوضي (${st.duration})',
            icon: Icons.record_voice_over_rounded,
            accentColor: const Color(0xFF2E5A44),
          ),
        );
      }
    }

    // 8. أحكام التجويد ومواضيع القرآن
    if (selectedLibrary == 'الكل' ||
        selectedLibrary == 'التجويد ومواضيع القرآن') {
      for (final r in TajweedService.instance.searchRules(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'tajweed_${r.id}',
            libraryName: 'التجويد ومواضيع القرآن',
            category: r.categoryName,
            title: r.title,
            snippet: r.definition,
            sourceReference: 'أمثلة قرآنية تطبيقية',
            icon: Icons.graphic_eq_rounded,
            accentColor: const Color(0xFF1565C0),
          ),
        );
      }
      for (final t in QuranTopicService.instance.searchTopics(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'topic_${t.id}',
            libraryName: 'التجويد ومواضيع القرآن',
            category: 'مواضيع القرآن',
            title: t.title,
            snippet: t.description,
            sourceReference: '${t.ayahCount} آيات قرآنية',
            icon: Icons.category_rounded,
            accentColor: const Color(0xFF1565C0),
          ),
        );
      }
    }

    // 9. مجالس العلماء والدروس الصوتية (١١٥ شيخاً وعالماً)
    if (selectedLibrary == 'الكل' ||
        selectedLibrary == 'مجالس العلماء والدروس') {
      for (final lec
          in ScholarsLecturesService.instance.searchLectures(query: q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'scholar_lec_${lec.id}',
            libraryName: 'مجالس العلماء والدروس',
            category: '${lec.scholarName} • ${lec.category.labelAr}',
            title: lec.title,
            snippet: lec.summary,
            sourceReference: '${lec.seriesName} (${lec.durationFormatted})',
            icon: Icons.mic_external_on_rounded,
            accentColor: const Color(0xFF0F5B45),
          ),
        );
      }
    }

    // 10. رياض الصالحين والأدب المفرد
    if (selectedLibrary == 'الكل' || selectedLibrary == 'رياض الصالحين') {
      for (final entry in RiyadAlSalihinService.allEntries) {
        if (_matchesNormalized(entry.chapterTitle, q, normQ) ||
            _matchesNormalized(entry.arabicMatn, q, normQ) ||
            _matchesNormalized(entry.sharhAndBenefits, q, normQ) ||
            _matchesNormalized(entry.bookTitle, q, normQ)) {
          results.add(
            UnifiedLibrarySearchResult(
              id: 'riyad_${entry.id}',
              libraryName: 'رياض الصالحين',
              category: entry.bookTitle,
              title: entry.chapterTitle,
              snippet: '${entry.arabicMatn}\n\nالفوائد: ${entry.sharhAndBenefits}',
              sourceReference: '${entry.narrator} — ${entry.sourceAndGrade}',
              icon: Icons.collections_bookmark_rounded,
              accentColor: const Color(0xFF1B5E20),
            ),
          );
        }
      }
    }

    // 11. غريب القرآن ومفرداته
    if (selectedLibrary == 'الكل' || selectedLibrary == 'غريب القرآن') {
      for (final w in GharibQuranService.instance.searchWords(q)) {
        results.add(
          UnifiedLibrarySearchResult(
            id: 'gharib_${w.id}',
            libraryName: 'غريب القرآن',
            category: 'سورة ${w.surahName} (الجذر: ${w.root})',
            title: 'مفردة: ${w.word}',
            snippet: '${w.meaningAr}\nالآية: «${w.ayahSnippet}»\nاللطيفة البلاغية: ${w.rhetoricalNote}',
            sourceReference: 'معجم غريب القرآن والبيان',
            icon: Icons.translate_rounded,
            accentColor: const Color(0xFF5D4037),
          ),
        );
      }
    }

    // 12. المتون العلمية الجامعة
    if (selectedLibrary == 'الكل' || selectedLibrary == 'المتون العلمية') {
      for (final m in IslamicMutoonService.allSections) {
        if (_matchesNormalized(m.chapterTitle, q, normQ) ||
            _matchesNormalized(m.vocalizedText, q, normQ) ||
            _matchesNormalized(m.sharhAndExplanation, q, normQ) ||
            _matchesNormalized(m.matnBookTitle, q, normQ)) {
          results.add(
            UnifiedLibrarySearchResult(
              id: 'matn_${m.id}',
              libraryName: 'المتون العلمية',
              category: m.matnBookTitle,
              title: m.chapterTitle,
              snippet: '${m.vocalizedText}\n\nالشرح: ${m.sharhAndExplanation}',
              sourceReference: m.keyTakeaway,
              icon: Icons.school_rounded,
              accentColor: const Color(0xFF4A148C),
            ),
          );
        }
      }
    }

    // 13. صيدلية القلوب والروشتة الإيمانية
    if (selectedLibrary == 'الكل' || selectedLibrary == 'صيدلية القلوب') {
      for (final rem in SpiritualMoodRemedyService.allRemedies) {
        if (_matchesNormalized(rem.moodTitle, q, normQ) ||
            _matchesNormalized(rem.shortSummary, q, normQ) ||
            _matchesNormalized(rem.quranAyah, q, normQ) ||
            _matchesNormalized(rem.propheticDua, q, normQ)) {
          results.add(
            UnifiedLibrarySearchResult(
              id: 'remedy_${rem.id}',
              libraryName: 'صيدلية القلوب',
              category: '${rem.emoji} ${rem.moodTitle}',
              title: 'علاج ومواساة: ${rem.moodTitle}',
              snippet: '${rem.quranAyah}\n\nالدعاء النبوي: ${rem.propheticDua}',
              sourceReference: '${rem.surahReference} • ${rem.hadithSource}',
              icon: Icons.healing_rounded,
              accentColor: const Color(0xFF00695C),
            ),
          );
        }
      }
    }

    return results;
  }

  Future<List<UnifiedLibrarySearchResult>> search(String query, {String? category}) async =>
      searchAllLibraries(query, selectedLibrary: category ?? 'الكل');

  static const List<String> libraryFilters = [
    'الكل',
    'مجالس العلماء والدروس',
    'الحديث النبوي',
    'رياض الصالحين',
    'الفقه الميسر',
    'علوم القرآن',
    'غريب القرآن',
    'المتون العلمية',
    'أسماء الله والشمائل',
    'التاريخ والسيرة',
    'التراث المصري',
    'قصص الأنبياء',
    'التجويد ومواضيع القرآن',
    'صيدلية القلوب',
  ];
}

extension UnifiedLibrarySearchServiceInstanceExt on UnifiedLibrarySearchService {
  List<String> get libraryFilters => UnifiedLibrarySearchService.libraryFilters;
}
