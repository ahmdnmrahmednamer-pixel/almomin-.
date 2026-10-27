import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/prophet_story.dart';
import 'package:almomin/core/services/stories_service.dart';
import 'package:almomin/features/stories/stories_screen.dart';
import 'package:almomin/features/stories/story_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StoriesService.instance.init();
  });

  group('StoriesService Audio & Catalog Unit Tests', () {
    test('Loads 38 authentic prophet audio stories with full metadata', () {
      final stories = StoriesService.instance.getAllStories();
      expect(stories.length, 38);

      final prophets = StoriesService.instance.getStoriesByCategory(StoryCategory.prophet);
      expect(prophets.length, 29);

      final quranStories = StoriesService.instance.getStoriesByCategory(StoryCategory.quranStory);
      expect(quranStories.length, 9);
    });

    test('Each audio story has valid audio URL, duration, size, and narrator', () {
      final stories = StoriesService.instance.getAllStories();
      for (final story in stories) {
        expect(story.id.isNotEmpty, isTrue);
        expect(story.title.isNotEmpty, isTrue);
        expect(story.characterName.isNotEmpty, isTrue);
        expect(story.narrator.isNotEmpty, isTrue);
        expect(story.duration.isNotEmpty, isTrue);
        expect(story.durationSeconds, greaterThan(0));
        expect(story.fileSizeBytes, greaterThan(1000000));
        expect(story.audioUrl, startsWith('https://archive.org/'));
        expect(story.summary.isNotEmpty, isTrue);
        expect(story.era.isNotEmpty, isTrue);
        expect(story.surahsMentioned.isNotEmpty, isTrue);
        expect(story.keyLessons.isNotEmpty, isTrue);
      }
    });

    test('Scholar filtering works correctly across all 7 scholars', () {
      final service = StoriesService.instance;
      final awadiStories = service.getStoriesByScholar('al_awadi');
      expect(awadiStories.length, 28);

      final suwaidanStories = service.getStoriesByScholar('suwaidan');
      expect(suwaidanStories.length, 2);

      final shaarawiStories = service.getStoriesByScholar('shaarawi');
      expect(shaarawiStories.length, 2);

      final abdelkafyStories = service.getStoriesByScholar('abdelkafy');
      expect(abdelkafyStories.length, 2);

      final othmanStories = service.getStoriesByScholar('othman_khamis');
      expect(othmanStories.length, 2);

      final nabulsiStories = service.getStoriesByScholar('ratib_nabulsi');
      expect(nabulsiStories.length, 2);

      final scholars = service.getAvailableScholars();
      expect(scholars.length, 7);
    });

    test('Ulu Al-Azm filter correctly identifies the firmest messengers across series', () {
      final uluAlAzm = StoriesService.instance.getUluAlAzmStories();
      expect(uluAlAzm.length, 9);
      final ids = uluAlAzm.map((s) => s.id).toList();
      expect(ids, containsAll(['nuh', 'ibrahim', 'musa_pharaoh', 'isa', 'muhammad_saw']));
    });

    test('Searching by prophet name or keyword returns matched stories', () {
      final service = StoriesService.instance;

      final yusufResults = service.searchStories('يوسف');
      expect(yusufResults.length, greaterThanOrEqualTo(1));
      expect(yusufResults.first.characterName, contains('يوسف'));

      final kahfResults = service.searchStories('الكهف');
      expect(kahfResults.length, greaterThanOrEqualTo(1));

      final nonExistent = service.searchStories('كلمة_غير_موجودة_نهائيا');
      expect(nonExistent.isEmpty, isTrue);
    });

    test('Toggle favorite stores in memory and persists to SharedPreferences', () async {
      final service = StoriesService.instance;
      expect(service.isFavorite('yusuf'), isFalse);

      await service.toggleFavorite('yusuf');
      expect(service.isFavorite('yusuf'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('stories_favorites'), contains('yusuf'));

      final favs = service.getFavoriteStories();
      expect(favs.any((s) => s.id == 'yusuf'), isTrue);

      await service.toggleFavorite('yusuf');
      expect(service.isFavorite('yusuf'), isFalse);
    });

    test('getStoryOfTheDay returns deterministic story for given date', () {
      final service = StoriesService.instance;
      final date1 = DateTime(2026, 10, 17);
      final story1 = service.getStoryOfTheDay(date1);

      final story2 = service.getStoryOfTheDay(date1);
      expect(story1.id, story2.id);
    });

    test('Offline and download status methods initialize cleanly', () {
      final service = StoriesService.instance;
      expect(service.isDownloaded('yusuf'), isFalse);
      expect(service.isDownloading('yusuf'), isFalse);
      expect(service.getDownloadProgress('yusuf'), 0.0);
      expect(service.getDownloadedStories(), isEmpty);
      expect(service.totalDownloadedStoriesBytes, 0);
      expect(service.formattedTotalDownloadedStorage, '0 MB');
    });
  });

  group('StoriesScreen & StoryDetailScreen Audio Widget Tests', () {
    testWidgets('Renders StoriesScreen with search, audio chips, and series banner', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: StoriesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('قصص الأنبياء الصوتية'), findsOneWidget);

      // Verify Search TextField
      expect(find.byType(TextField), findsOneWidget);

      // Verify Category Chips
      expect(find.textContaining('جميع القصص (38)'), findsOneWidget);
      expect(find.text('أولو العزم من الرسل'), findsOneWidget);

      // Verify Narrator Banner
      expect(find.textContaining('نبيل العوضي'), findsWidgets);

      // Verify story cards are listed
      expect(find.textContaining('يوسف'), findsWidgets);
    });

    testWidgets('Renders StoryDetailScreen with audio banner, lessons, duaa, and play button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final story = StoriesService.instance.getAllStories().firstWhere((s) => s.id == 'yusuf');

      await tester.pumpWidget(
        MaterialApp(
          home: StoryDetailScreen(story: story),
        ),
      );
      await tester.pumpAndSettle();

      // Title & Narrator
      expect(find.text(story.characterName), findsOneWidget);
      expect(find.text(story.title), findsOneWidget);
      expect(find.textContaining('نبيل العوضي'), findsWidgets);

      // Audio Play Button
      expect(find.text('تشغيل القصة الصوتية الآن'), findsOneWidget);

      // Prophetic Duaa
      expect(find.text('دعاء نبوي مأثور في القرآن الكريم'), findsOneWidget);

      // Lessons
      expect(find.text('أعظم العِبر والدروس المستفادة'), findsOneWidget);

      // Spiritual Banner
      expect(find.textContaining('عبر وعظات من قصص القرآن الكريم'), findsOneWidget);
    });
  });
}
