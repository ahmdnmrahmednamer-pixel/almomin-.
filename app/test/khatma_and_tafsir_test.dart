import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/khatma_service.dart';
import 'package:almomin/core/services/tafsir_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Khatma Planner Mathematical & Algorithmic Tests (Appendix C)', () {
    test('Calculates exact pagesPerDay using ceil(604 / days)', () {
      final plan30 = KhatmaPlan(
        id: 'test_30',
        title: 'ختمة الشهر',
        targetDays: 30,
        startDate: DateTime.now(),
      );
      // 604 / 30 = 20.133... -> ceil = 21
      expect(plan30.pagesPerDay, equals(21));

      final plan60 = KhatmaPlan(
        id: 'test_60',
        title: 'ختمة الشهرين',
        targetDays: 60,
        startDate: DateTime.now(),
      );
      // 604 / 60 = 10.066... -> ceil = 11
      expect(plan60.pagesPerDay, equals(11));

      final plan15 = KhatmaPlan(
        id: 'test_15',
        title: 'ختمة النصف شهر',
        targetDays: 15,
        startDate: DateTime.now(),
      );
      // 604 / 15 = 40.266... -> ceil = 41
      expect(plan15.pagesPerDay, equals(41));
    });

    test('Calculates per-prayer breakdown ceil(pagesPerDay / 5)', () {
      final plan30 = KhatmaPlan(
        id: 'test_30',
        title: 'ختمة الشهر',
        targetDays: 30,
        startDate: DateTime.now(),
      );
      // 21 / 5 = 4.2 -> ceil = 5 pages per prayer
      expect(plan30.pagesPerPrayer, equals(5));

      final plan60 = KhatmaPlan(
        id: 'test_60',
        title: 'ختمة الشهرين',
        targetDays: 60,
        startDate: DateTime.now(),
      );
      // 11 / 5 = 2.2 -> ceil = 3 pages per prayer
      expect(plan60.pagesPerPrayer, equals(3));
    });

    test('Progress percentage correctly tracks from 0.0 to 1.0', () {
      final plan = KhatmaPlan(
        id: 'test_prog',
        title: 'ختمة التقدم',
        targetDays: 30,
        startDate: DateTime.now(),
        currentPage: 151, // exactly 25% of 604
      );

      expect(plan.progressPercentage, closeTo(0.25, 0.01));
      expect(plan.remainingPages, equals(453));
    });

    test('Adjusted pace formula recalculates pages when behind', () {
      // Started 10 days ago, total 30 days -> 20 days remaining
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      final plan = KhatmaPlan(
        id: 'test_adj',
        title: 'ختمة التعويض',
        targetDays: 30,
        startDate: tenDaysAgo,
        currentPage: 100, // should have been ~210 pages
      );

      expect(plan.isBehindSchedule, isTrue);
      // Remaining pages: 604 - 100 = 504. Remaining days: 20.
      // 504 / 20 = 25.2 -> ceil = 26 pages/day
      expect(plan.adjustedPagesPerDay, equals(26));
    });
  });

  group('KhatmaService Lifecycle & Persistence', () {
    test('Creates and persists a new Khatma plan', () async {
      final s = KhatmaService.instance;
      await s.init();

      await s.createPlan(
        title: 'ختمة رمضان المبارك',
        targetDays: 30,
        splitByPrayer: true,
        startingPage: 1,
      );

      expect(s.hasActivePlan, isTrue);
      expect(s.activePlan!.title, equals('ختمة رمضان المبارك'));
      expect(s.activePlan!.targetDays, equals(30));
      expect(s.activePlan!.currentPage, equals(1));

      // Advance reading progress
      await s.updateProgress(45);
      expect(s.activePlan!.currentPage, equals(45));

      // Toggle prayer completion
      await s.togglePrayerCompleted('fajr');
      expect(s.activePlan!.completedPrayersToday.contains('fajr'), isTrue);

      // Cancel plan
      await s.cancelPlan();
      expect(s.hasActivePlan, isFalse);
    });
  });

  group('TafsirService Editions & Attribution (FR-TAF-001..005)', () {
    test('Contains 5 canonical Tafsir editions', () {
      expect(TafsirService.availableEditions.length, equals(5));

      final ids = TafsirService.availableEditions.map((e) => e.id).toList();
      expect(ids.contains('muyassar'), isTrue);
      expect(ids.contains('saadi'), isTrue);
      expect(ids.contains('ibn_kathir'), isTrue);
      expect(ids.contains('waseet'), isTrue);
      expect(ids.contains('baghawi'), isTrue);
    });

    test('Formats Tafsir attribution for copy and share per FR-TAF-005', () {
      final res = TafsirResult(
        editionId: 'saadi',
        editionName: 'تفسير السعدي',
        author: 'الشيخ عبد الرحمن السعدي',
        surahId: 1,
        ayahNumber: 1,
        ayahText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        tafsirText: 'أي: أبتدئ قراءتي مستعينا بالله، طالبا لبركته وتوفيقه.',
      );

      final shareText = res.formatForShare('الفاتحة');
      expect(shareText.contains('سورة الفاتحة'), isTrue);
      expect(shareText.contains('تفسير السعدي'), isTrue);
      expect(shareText.contains('الشيخ عبد الرحمن السعدي'), isTrue);
      expect(shareText.contains('تطبيق المؤمن'), isTrue);
    });
  });
}
