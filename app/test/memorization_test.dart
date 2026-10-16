import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/memorization_item.dart';
import 'package:almomin/core/services/memorization_service.dart';
import 'package:almomin/features/mushaf/memorization_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await MemorizationService.instance.init();
    await MemorizationService.instance.clearAll();
  });

  group('MemorizationMaskHelper Tests (FR-MEM-002)', () {
    test('splitAyahWords splits text accurately into words', () {
      const text = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      final words = MemorizationMaskHelper.splitAyahWords(text);
      expect(words.length, 4);
      expect(words[0], 'بِسْمِ');
      expect(words[1], 'اللَّهِ');
      expect(words[2], 'الرَّحْمَٰنِ');
      expect(words[3], 'الرَّحِيمِ');
    });

    test('isWordMasked returns false for HideMode.none', () {
      for (int i = 0; i < 4; i++) {
        final masked = MemorizationMaskHelper.isWordMasked(
          wordIndex: i,
          totalWords: 4,
          mode: MemorizationHideMode.none,
          isRevealed: false,
        );
        expect(masked, false);
      }
    });

    test('isWordMasked masks second half for HideMode.secondHalf', () {
      // 4 words: indices 0, 1 should be visible; 2, 3 should be masked
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 0,
          totalWords: 4,
          mode: MemorizationHideMode.secondHalf,
          isRevealed: false,
        ),
        false,
      );
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 1,
          totalWords: 4,
          mode: MemorizationHideMode.secondHalf,
          isRevealed: false,
        ),
        false,
      );
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 2,
          totalWords: 4,
          mode: MemorizationHideMode.secondHalf,
          isRevealed: false,
        ),
        true,
      );
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 3,
          totalWords: 4,
          mode: MemorizationHideMode.secondHalf,
          isRevealed: false,
        ),
        true,
      );
    });

    test('isWordMasked masks alternating words for HideMode.everyNthWord', () {
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 0,
          totalWords: 4,
          mode: MemorizationHideMode.everyNthWord,
          isRevealed: false,
        ),
        false,
      );
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 1,
          totalWords: 4,
          mode: MemorizationHideMode.everyNthWord,
          isRevealed: false,
        ),
        true,
      );
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 2,
          totalWords: 4,
          mode: MemorizationHideMode.everyNthWord,
          isRevealed: false,
        ),
        false,
      );
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 3,
          totalWords: 4,
          mode: MemorizationHideMode.everyNthWord,
          isRevealed: false,
        ),
        true,
      );
    });

    test('isWordMasked masks all words for HideMode.allWords unless revealed', () {
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 0,
          totalWords: 4,
          mode: MemorizationHideMode.allWords,
          isRevealed: false,
        ),
        true,
      );
      // When revealed by user tap
      expect(
        MemorizationMaskHelper.isWordMasked(
          wordIndex: 0,
          totalWords: 4,
          mode: MemorizationHideMode.allWords,
          isRevealed: true,
        ),
        false,
      );
    });
  });

  group('MemorizationItem & Leitner Spaced-Repetition Tests (FR-MEM-003)', () {
    test('initial creation starts at Box 1 with 0 reviews', () {
      final item = MemorizationItem.createInitial(
        surahId: 1,
        ayahNumber: 1,
        surahName: 'الفاتحة',
      );
      expect(item.leitnerBox, 1);
      expect(item.timesReviewed, 0);
      expect(item.timesCorrect, 0);
      expect(item.id, '1:1');
    });

    test('easy rating advances Leitner box and increments timesCorrect', () {
      final item = MemorizationItem.createInitial(
        surahId: 1,
        ayahNumber: 1,
        surahName: 'الفاتحة',
      );

      final r1 = item.recordReview(MemorizationRating.easy);
      expect(r1.leitnerBox, 2);
      expect(r1.timesReviewed, 1);
      expect(r1.timesCorrect, 1);
      expect(r1.lastRating, MemorizationRating.easy);

      final r2 = r1.recordReview(MemorizationRating.easy);
      expect(r2.leitnerBox, 3);
      expect(r2.timesCorrect, 2);
    });

    test('hard rating demotes box by 1 (minimum Box 1)', () {
      final item = MemorizationItem(
        id: '1:1',
        surahId: 1,
        ayahNumber: 1,
        surahName: 'الفاتحة',
        leitnerBox: 3,
        lastReviewedAt: DateTime.now(),
        nextReviewDue: DateTime.now(),
        timesReviewed: 3,
        timesCorrect: 2,
      );

      final reviewed = item.recordReview(MemorizationRating.hard);
      expect(reviewed.leitnerBox, 2);
      expect(reviewed.timesReviewed, 4);
      expect(reviewed.timesCorrect, 2); // unchanged
    });

    test('forgot rating resets box to Box 1', () {
      final item = MemorizationItem(
        id: '1:1',
        surahId: 1,
        ayahNumber: 1,
        surahName: 'الفاتحة',
        leitnerBox: 4,
        lastReviewedAt: DateTime.now(),
        nextReviewDue: DateTime.now(),
        timesReviewed: 5,
        timesCorrect: 4,
      );

      final reviewed = item.recordReview(MemorizationRating.forgot);
      expect(reviewed.leitnerBox, 1);
      expect(reviewed.timesReviewed, 6);
    });

    test('JSON serialization and deserialization roundtrip', () {
      final item = MemorizationItem(
        id: '2:255',
        surahId: 2,
        ayahNumber: 255,
        surahName: 'البقرة',
        leitnerBox: 4,
        lastReviewedAt: DateTime(2026, 10, 16, 12, 0),
        nextReviewDue: DateTime(2026, 10, 30, 12, 0),
        timesReviewed: 7,
        timesCorrect: 6,
        lastRating: MemorizationRating.easy,
      );

      final jsonMap = item.toJson();
      final restored = MemorizationItem.fromJson(jsonMap);

      expect(restored.id, '2:255');
      expect(restored.surahId, 2);
      expect(restored.ayahNumber, 255);
      expect(restored.leitnerBox, 4);
      expect(restored.timesReviewed, 7);
      expect(restored.timesCorrect, 6);
      expect(restored.lastRating, MemorizationRating.easy);
    });
  });

  group('MemorizationService Tests', () {
    test('recordReview updates service state and counts', () async {
      final service = MemorizationService.instance;
      expect(service.totalTrackedAyahs, 0);

      await service.recordReview(
        surahId: 1,
        ayahNumber: 1,
        surahName: 'الفاتحة',
        rating: MemorizationRating.easy,
      );

      expect(service.totalTrackedAyahs, 1);
      expect(service.hasItem(1, 1), true);
      expect(service.hasItem(1, 2), false);

      final item = service.getItem(1, 1);
      expect(item, isNotNull);
      expect(item!.leitnerBox, 2);

      // Advance to Box 3
      await service.recordReview(
        surahId: 1,
        ayahNumber: 1,
        surahName: 'الفاتحة',
        rating: MemorizationRating.easy,
      );
      expect(service.totalMasteredCount, 1);
    });

    test('exportData and importData preserves records and merges correctly', () async {
      final service = MemorizationService.instance;
      await service.recordReview(
        surahId: 1,
        ayahNumber: 2,
        surahName: 'الفاتحة',
        rating: MemorizationRating.easy,
      );

      final exported = service.exportData();
      expect(exported.length, 1);

      await service.clearAll();
      expect(service.totalTrackedAyahs, 0);

      final count = await service.importData(exported);
      expect(count, 1);
      expect(service.totalTrackedAyahs, 1);
      expect(service.hasItem(1, 2), true);
    });

    test('deleteItem removes item', () async {
      final service = MemorizationService.instance;
      await service.recordReview(
        surahId: 1,
        ayahNumber: 5,
        surahName: 'الفاتحة',
        rating: MemorizationRating.easy,
      );
      expect(service.hasItem(1, 5), true);

      final deleted = await service.deleteItem(1, 5);
      expect(deleted, true);
      expect(service.hasItem(1, 5), false);
    });
  });

  group('MemorizationScreen Widget Tests', () {
    testWidgets('Renders MemorizationScreen with dedication and controls', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MemorizationScreen(
            initialSurahId: 1,
            initialFromAyah: 1,
            initialToAyah: 7,
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify Screen title
      expect(find.text('المحفظ القرآني والتكرار الذكي'), findsOneWidget);

      // Verify Noble Dedication Header
      expect(find.text('صدقة جارية عن مؤمن إبراهيم رحمه الله'), findsOneWidget);
      expect(find.text('اللهم اجعل القرآن الكريم نوراً له وأنيساً في قبره ورفعة لدرجاته'), findsOneWidget);

      // Verify controls
      expect(find.text('كامل الآية ظاهر'), findsOneWidget);
      expect(find.text('إخفاء النصف الثاني'), findsOneWidget);
      expect(find.text('إخفاء كامل (غيباً)'), findsOneWidget);

      // Verify playback play button icon
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Switch to HideMode.secondHalf
      final secondHalfChip = find.text('إخفاء النصف الثاني');
      await tester.ensureVisible(secondHalfChip);
      await tester.tap(secondHalfChip);
      await tester.pumpAndSettle();

      // Masked pills should now be present
      expect(find.text('••••••'), findsWidgets);

      // Tap on the first masked pill to reveal it
      await tester.tap(find.text('••••••').first);
      await tester.pumpAndSettle();

      // Verify tap-to-reveal toggled state smoothly
      expect(find.byIcon(Icons.touch_app), findsWidgets);
    });
  });
}
