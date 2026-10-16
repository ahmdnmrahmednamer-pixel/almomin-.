import 'package:flutter/foundation.dart';
import '../models/quran_topic.dart';
import '../text/arabic_normalizer.dart';
import 'quran_topic_data.dart';

class QuranTopicService extends ChangeNotifier {
  QuranTopicService._();
  static final QuranTopicService instance = QuranTopicService._();

  final List<QuranTopic> _topics = List.unmodifiable(kQuranTopics);
  bool _initialized = false;

  bool get isInitialized => _initialized;
  List<QuranTopic> get allTopics => _topics;
  int get totalTopicsCount => _topics.length;
  int get totalAyahsCount => _topics.fold(0, (sum, t) => sum + t.ayahCount);

  void init() {
    if (_initialized) return;
    _initialized = true;
    notifyListeners();
  }

  QuranTopic? getTopicById(String id) {
    try {
      return _topics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<QuranTopic> getTopicsByCategory(TopicCategory? category) {
    if (category == null) return _topics;
    return _topics.where((t) => t.category == category).toList();
  }

  QuranTopic getFeaturedTopic() {
    if (_topics.isEmpty) {
      throw StateError('No topics available');
    }
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _topics.length;
    return _topics[index];
  }

  List<QuranTopic> searchTopics(String query, {TopicCategory? category}) {
    final cleanQuery = ArabicNormalizer.normalize(query.trim());
    final baseList = category != null ? getTopicsByCategory(category) : _topics;

    if (cleanQuery.isEmpty) return baseList;

    return baseList.where((topic) {
      final normTitle = ArabicNormalizer.normalize(topic.title);
      final normDesc = ArabicNormalizer.normalize(topic.description);

      if (normTitle.contains(cleanQuery) || normDesc.contains(cleanQuery)) {
        return true;
      }

      // Check if any ayah matches query
      return topic.ayahs.any((ayah) {
        final normText = ArabicNormalizer.normalize(ayah.text);
        final normSurah = ArabicNormalizer.normalize(ayah.surahName);
        final normSig = ArabicNormalizer.normalize(ayah.significance);

        return normText.contains(cleanQuery) ||
            normSurah.contains(cleanQuery) ||
            normSig.contains(cleanQuery);
      });
    }).toList();
  }

  String formatShareText(QuranTopic topic, TopicAyahItem ayah) {
    return '''🌿 من هدي القرآن الكريم — موضوع: ${topic.title}

﴿ ${ayah.text} ﴾
[سورة ${ayah.surahName}: آية ${ayah.ayahNumber} — صفحة ${ayah.page}]

💡 إضاءة قرآنية:
${ayah.significance}

──────────────
🤲 صَدَقَةٌ جَارِيَةٌ عَنْ رُوحِ المَرْحُومِ بِإِذْنِ اللَّهِ: مُؤْمِن إِبْرَاهِيم (رَحِمَهُ اللَّهُ)
📱 من تطبيق المؤمن — رفيق المسلم اليومي''';
  }
}
