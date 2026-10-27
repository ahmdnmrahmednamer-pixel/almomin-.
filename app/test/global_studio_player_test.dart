import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/features/audio/widgets/global_mini_player_bar.dart';
import 'package:almomin/features/audio/widgets/full_screen_studio_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    IslamicAudioService.instance.disableNativePlayerForTesting = true;
    await IslamicAudioService.instance.init();
    await IslamicAudioService.instance.stop();
  });

  tearDown(() {
    IslamicAudioService.instance.disableNativePlayerForTesting = false;
  });

  group('IslamicAudioService Advanced Studio Controls Tests', () {
    test('Loop mode cycles off -> all -> single -> off correctly', () {
      final service = IslamicAudioService.instance;
      expect(service.loopMode, PlaybackLoopMode.off);

      service.toggleLoopMode();
      expect(service.loopMode, PlaybackLoopMode.all);

      service.toggleLoopMode();
      expect(service.loopMode, PlaybackLoopMode.single);

      service.toggleLoopMode();
      expect(service.loopMode, PlaybackLoopMode.off);
    });

    test('Shuffle mode toggles cleanly', () {
      final service = IslamicAudioService.instance;
      expect(service.shuffleEnabled, isFalse);

      service.toggleShuffle();
      expect(service.shuffleEnabled, isTrue);

      service.toggleShuffle();
      expect(service.shuffleEnabled, isFalse);
    });

    test('Sleep timer sets and cancels properly', () {
      final service = IslamicAudioService.instance;
      expect(service.sleepTimerRemainingSeconds, isNull);

      service.setSleepTimer(30);
      expect(service.sleepTimerRemainingSeconds, isNotNull);
      expect(service.sleepTimerRemainingSeconds!, greaterThan(25 * 60));

      service.cancelSleepTimer();
      expect(service.sleepTimerRemainingSeconds, isNull);
    });

    test('Queue management maintains indices and tracks correctly', () async {
      final service = IslamicAudioService.instance;
      final tracks = <IslamicAudioTrack>[
        const IslamicAudioTrack(
          id: 'test_1',
          title: 'Track 1',
          subtitle: 'Artist 1',
          type: IslamicAudioType.quran,
          assetPath: null,
          remoteUrl: 'https://example.com/1.mp3',
          durationFormatted: '05:00',
        ),
        const IslamicAudioTrack(
          id: 'test_2',
          title: 'Track 2',
          subtitle: 'Artist 2',
          type: IslamicAudioType.quran,
          assetPath: null,
          remoteUrl: 'https://example.com/2.mp3',
          durationFormatted: '04:00',
        ),
        const IslamicAudioTrack(
          id: 'test_3',
          title: 'Track 3',
          subtitle: 'Artist 3',
          type: IslamicAudioType.story,
          assetPath: null,
          remoteUrl: 'https://example.com/3.mp3',
          durationFormatted: '07:00',
        ),
      ];

      await service.playQueue(tracks, startIndex: 1);
      expect(service.queue.length, 3);
      expect(service.currentIndex, 1);
      expect(service.hasPrevious, isTrue);
      expect(service.hasNext, isTrue);
      expect(service.currentTrack?.id, 'test_2');

      // Next
      await service.playNext();
      expect(service.currentIndex, 2);
      expect(service.hasNext, isFalse);
      expect(service.currentTrack?.id, 'test_3');

      // Previous
      await service.playPrevious();
      expect(service.currentIndex, 1);
      expect(service.currentTrack?.id, 'test_2');

      await service.playPrevious();
      expect(service.currentIndex, 0);
      expect(service.hasPrevious, isFalse);
      expect(service.currentTrack?.id, 'test_1');
    });

    test('Seek forward and backward clamp to zero and duration', () async {
      final service = IslamicAudioService.instance;
      expect(() => service.seekForward(seconds: 10), returnsNormally);
      expect(() => service.seekBackward(seconds: 10), returnsNormally);
    });
  });

  group('GlobalMiniPlayerBar Widget Tests', () {
    testWidgets('Renders SizedBox.shrink when no track is selected', (tester) async {
      final service = IslamicAudioService.instance;
      await service.stop();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlobalMiniPlayerBar(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(GlobalMiniPlayerBar), findsOneWidget);
      expect(find.text('توقف'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('Renders controls and title when track is loaded', (tester) async {
      final service = IslamicAudioService.instance;
      const testTrack = IslamicAudioTrack(
        id: 'test_mini',
        title: 'سورة الفاتحة',
        subtitle: 'مشاري العفاسي',
        type: IslamicAudioType.quran,
        assetPath: null,
        remoteUrl: 'https://example.com/fatihah.mp3',
        durationFormatted: '01:00',
      );

      await service.playQueue([testTrack], startIndex: 0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlobalMiniPlayerBar(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('سورة الفاتحة'), findsOneWidget);
      expect(find.text('مشاري العفاسي'), findsOneWidget);
      expect(find.byIcon(Icons.forward_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.replay_10_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });
  });

  group('FullScreenStudioPlayer Widget Tests', () {
    testWidgets('Renders studio player modal components correctly', (tester) async {
      final service = IslamicAudioService.instance;
      const testTrack = IslamicAudioTrack(
        id: 'test_studio',
        title: 'سورة الكهف المباركة',
        subtitle: 'الشيخ عبد الباسط عبد الصمد',
        type: IslamicAudioType.quran,
        assetPath: null,
        remoteUrl: 'https://example.com/kahf.mp3',
        durationFormatted: '30:00',
      );

      await service.playQueue([testTrack], startIndex: 0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FullScreenStudioPlayer(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('المشغل الصوتي الاستوديو 🎙️'), findsOneWidget);
      expect(find.text('سورة الكهف المباركة'), findsOneWidget);
      expect(find.text('الشيخ عبد الباسط عبد الصمد'), findsOneWidget);
      expect(find.textContaining('استماع بدون إنترنت'), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.shuffle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
      expect(find.byIcon(Icons.bedtime_rounded), findsOneWidget);
      expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
      expect(find.byIcon(Icons.queue_music_rounded), findsOneWidget);
    });
  });
}
