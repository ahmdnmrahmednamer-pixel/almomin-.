import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:almomin/core/models/quran_topic.dart';
import 'package:almomin/core/services/quran_topic_service.dart';
import 'package:almomin/features/topics/quran_topics_screen.dart';
import 'package:almomin/features/topics/topic_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    QuranTopicService.instance.init();
  });

  group('Quran Thematic Index Data Integrity (FR-TPC-001)', () {
    test('Verifies catalog has valid topics with required metadata', () {
      final topics = QuranTopicService.instance.allTopics;
      expect(topics.length, greaterThanOrEqualTo(12));
      expect(QuranTopicService.instance.totalTopicsCount, greaterThanOrEqualTo(12));
      expect(QuranTopicService.instance.totalAyahsCount, greaterThan(30));
    });

    test('Verifies every topic and ayah has valid references and valid page numbers', () {
      final topics = QuranTopicService.instance.allTopics;
      for (final topic in topics) {
        expect(topic.id.isNotEmpty, isTrue);
        expect(topic.title.isNotEmpty, isTrue);
        expect(topic.description.isNotEmpty, isTrue);
        expect(topic.ayahCount, greaterThan(0));

        for (final ayah in topic.ayahs) {
          expect(ayah.surahId, inInclusiveRange(1, 114));
          expect(ayah.ayahNumber, greaterThan(0));
          expect(ayah.page, inInclusiveRange(1, 604));
          expect(ayah.surahName.isNotEmpty, isTrue);
          expect(ayah.text.isNotEmpty, isTrue);
          expect(ayah.significance.isNotEmpty, isTrue);
        }
      }
    });

    test('Verifies key topics exist (الصبر، بر الوالدين، الرزق، التوبة، الصدقة)', () {
      expect(QuranTopicService.instance.getTopicById('patience'), isNotNull);
      expect(QuranTopicService.instance.getTopicById('parents'), isNotNull);
      expect(QuranTopicService.instance.getTopicById('provision'), isNotNull);
      expect(QuranTopicService.instance.getTopicById('repentance'), isNotNull);
      expect(QuranTopicService.instance.getTopicById('charity'), isNotNull);
    });
  });

  group('Quran Topics Category Filtering', () {
    test('Filters by categories correctly', () {
      final faithTopics = QuranTopicService.instance.getTopicsByCategory(TopicCategory.faith);
      expect(faithTopics.isNotEmpty, isTrue);
      for (final t in faithTopics) {
        expect(t.category, TopicCategory.faith);
      }

      final moralsTopics = QuranTopicService.instance.getTopicsByCategory(TopicCategory.morals);
      expect(moralsTopics.isNotEmpty, isTrue);
      for (final t in moralsTopics) {
        expect(t.category, TopicCategory.morals);
      }

      final duaTopics = QuranTopicService.instance.getTopicsByCategory(TopicCategory.dua);
      expect(duaTopics.isNotEmpty, isTrue);
      for (final t in duaTopics) {
        expect(t.category, TopicCategory.dua);
      }
    });
  });

  group('Quran Topics Search Engine (Normalized Search)', () {
    test('Searches by topic title with and without tashkeel / hamza', () {
      final results1 = QuranTopicService.instance.searchTopics('الصبر');
      expect(results1.any((t) => t.id == 'patience'), isTrue);

      final results2 = QuranTopicService.instance.searchTopics('بر الوالدين');
      expect(results2.any((t) => t.id == 'parents'), isTrue);

      final results3 = QuranTopicService.instance.searchTopics('التوبه'); // هاء بدلا من تاء مربوطة
      expect(results3.any((t) => t.id == 'repentance'), isTrue);
    });

    test('Searches by ayah text', () {
      // "استعينوا بالصبر والصلاة"
      final results = QuranTopicService.instance.searchTopics('استعينوا بالصبر');
      expect(results.any((t) => t.id == 'patience'), isTrue);
    });

    test('Searches by Surah name', () {
      final results = QuranTopicService.instance.searchTopics('الإسراء');
      expect(results.isNotEmpty, isTrue);
    });
  });

  group('Featured Topic & Share Formatting', () {
    test('Returns featured topic deterministically', () {
      final t1 = QuranTopicService.instance.getFeaturedTopic();
      final t2 = QuranTopicService.instance.getFeaturedTopic();
      expect(t1.id, t2.id);
      expect(t1.ayahCount, greaterThan(0));
    });

    test('Formats share text with ayah, topic, and dedication to مؤمن إبراهيم رحمه الله', () {
      final topic = QuranTopicService.instance.getTopicById('patience')!;
      final ayah = topic.ayahs.first;
      final text = QuranTopicService.instance.formatShareText(topic, ayah);

      expect(text, contains(topic.title));
      expect(text, contains(ayah.text));
      expect(text, contains('سورة ${ayah.surahName}'));
      expect(text, contains('صفحة ${ayah.page}'));
      expect(text, contains(ayah.significance));
      expect(text, contains('تطبيق نور المؤمن'));
    });
  });

  group('Quran Topics UI Widgets Rendering', () {
    testWidgets('Renders QuranTopicsScreen with search, filter chips, and topic cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: QuranTopicsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الفهرس الموضوعي لآيات القرآن'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('الكل'), findsOneWidget);
      expect(find.text('الصبر وبشارات الصابرين'), findsWidgets);
    });

    testWidgets('Renders TopicDetailScreen with header, ayahs, significance, and dedication', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: TopicDetailScreen(topicId: 'patience'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الصبر وبشارات الصابرين'), findsWidgets);
      expect(find.text('سورة البقرة'), findsWidgets);
      expect(find.textContaining('اسْتَعِينُوا'), findsOneWidget);
      expect(find.text('عرض في المصحف'), findsWidgets);
      expect(find.text('مُؤْمِن إِبْرَاهِيم'), findsOneWidget);
    });
  });
}
