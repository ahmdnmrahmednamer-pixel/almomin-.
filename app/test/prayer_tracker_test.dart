import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/prayer_tracker_service.dart';
import 'package:almomin/features/prayer/prayer_tracker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PrayerTrackerService.instance.init();
  });

  group('PrayerTrackerService Unit Tests (FR-PRY-009)', () {
    test('DailyPrayerRecord computes obligatory and rawatib counts accurately', () {
      final record = DailyPrayerRecord(
        dateStr: '2026-10-16',
        fajr: true,
        dhuhr: true,
        asr: true,
        maghrib: false,
        isha: false,
        fajrSunnah: true, // 2 rak'ahs
        dhuhrSunnahBefore: true, // 4 rak'ahs
        dhuhrSunnahAfter: false,
        maghribSunnah: false,
        ishaSunnah: false,
      );

      expect(record.completedObligatoryCount, equals(3));
      expect(record.isAllObligatoryCompleted, isFalse);
      expect(record.completedRawatibRakats, equals(6)); // 2 + 4 = 6
      expect(record.isAllRawatibCompleted, isFalse);

      // Complete all 5 obligatory and 12 rawatib
      record.maghrib = true;
      record.isha = true;
      record.dhuhrSunnahAfter = true; // +2 = 8
      record.maghribSunnah = true; // +2 = 10
      record.ishaSunnah = true; // +2 = 12

      expect(record.completedObligatoryCount, equals(5));
      expect(record.isAllObligatoryCompleted, isTrue);
      expect(record.completedRawatibRakats, equals(12));
      expect(record.isAllRawatibCompleted, isTrue);
    });

    test('toggleObligatory updates prayer state and persists to storage', () async {
      final now = DateTime.now();

      // Initially false
      expect(PrayerTrackerService.instance.todayRecord.fajr, isFalse);

      // Toggle to true
      final s1 = await PrayerTrackerService.instance.toggleObligatory('الفجر', now);
      expect(s1, isTrue);
      expect(PrayerTrackerService.instance.todayRecord.fajr, isTrue);

      // Re-init to test persistence
      await PrayerTrackerService.instance.init();
      expect(PrayerTrackerService.instance.todayRecord.fajr, isTrue);

      // Toggle back to false
      final s2 = await PrayerTrackerService.instance.toggleObligatory('الفجر', now);
      expect(s2, isFalse);
      expect(PrayerTrackerService.instance.todayRecord.fajr, isFalse);
    });

    test('toggleSunnah and voluntary prayers works correctly', () async {
      final now = DateTime.now();

      expect(PrayerTrackerService.instance.todayRecord.fajrSunnah, isFalse);
      await PrayerTrackerService.instance.toggleSunnah('fajr_sunnah', now);
      expect(PrayerTrackerService.instance.todayRecord.fajrSunnah, isTrue);

      expect(PrayerTrackerService.instance.todayRecord.duha, isFalse);
      await PrayerTrackerService.instance.toggleSunnah('duha', now);
      expect(PrayerTrackerService.instance.todayRecord.duha, isTrue);

      expect(PrayerTrackerService.instance.todayRecord.witr, isFalse);
      await PrayerTrackerService.instance.toggleSunnah('witr', now);
      expect(PrayerTrackerService.instance.todayRecord.witr, isTrue);
    });

    test('getRecent7Days returns exactly 7 consecutive records ending today', () {
      final list = PrayerTrackerService.instance.getRecent7Days();
      expect(list.length, equals(7));
      expect(list.last.dateStr, equals(PrayerTrackerService.instance.todayRecord.dateStr));
    });

    test('getGentleEncouragement provides positive non-punitive messaging', () {
      final msgEmpty = PrayerTrackerService.instance.getGentleEncouragement();
      expect(msgEmpty, isNotEmpty);
      expect(msgEmpty, contains('الصلاة'));

      // Complete 5
      final today = DateTime.now();
      PrayerTrackerService.instance.toggleObligatory('الفجر', today);
      PrayerTrackerService.instance.toggleObligatory('الظهر', today);
      PrayerTrackerService.instance.toggleObligatory('العصر', today);
      PrayerTrackerService.instance.toggleObligatory('المغرب', today);
      PrayerTrackerService.instance.toggleObligatory('العشاء', today);

      final msgComplete = PrayerTrackerService.instance.getGentleEncouragement();
      expect(msgComplete, contains('أتممت الصلوات الخمس'));
    });
  });

  group('PrayerTrackerScreen Widget Tests', () {
    testWidgets('Renders PrayerTrackerScreen with dedication, stats, and checkboxes', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: PrayerTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and noble dedication
      expect(find.text('سجل متابعة الصلوات والسنن'), findsOneWidget);
      expect(find.textContaining('حافظ على صلواتك في أوقاتها'), findsOneWidget);

      // Check progress titles
      expect(find.text('إنجاز اليوم في الصلاة'), findsOneWidget);
      expect(find.textContaining('السنن الرواتب'), findsWidgets);

      // Check prayers checkboxes
      expect(find.text('صلاة الفجر'), findsOneWidget);
      expect(find.text('صلاة الظهر'), findsOneWidget);
      expect(find.text('صلاة العصر'), findsOneWidget);
      expect(find.text('صلاة المغرب'), findsOneWidget);
      expect(find.text('صلاة العشاء'), findsOneWidget);

      // Check voluntary prayers
      expect(find.textContaining('صلاة الضحى'), findsOneWidget);
      expect(find.textContaining('صلاة الوتر'), findsOneWidget);
      expect(find.text('قيام الليل والتهجد'), findsOneWidget);

      // Check Hadith of Umm Habiba
      expect(find.textContaining('فضل السنن الرواتب'), findsOneWidget);
    });
  });
}
