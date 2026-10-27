import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/fajr_qiyam_alarm_service.dart';
import 'package:almomin/core/services/prayer_tracker_service.dart';
import 'package:almomin/features/prayer/fajr_qiyam_alarm_screen.dart';
import 'package:almomin/features/prayer/prayer_tracker_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    IslamicAudioService.instance.disableNativePlayerForTesting = true;
    await SettingsService.instance.init();
    await FajrQiyamAlarmService.instance.init(forceReload: true);
    await PrayerTrackerService.instance.init();
  });

  group('1. Sheikh & Muezzin Audio Fidelity Tests', () {
    test('playTrackById resolves every Muezzin and alias to its exact track (never wrong Sheikh)', () async {
      final audio = IslamicAudioService.instance;

      // Test Cairo alias 'adhan_cairo' -> must resolve to Sheikh Muhammad Rifaat ('adhan_cairo_refaat'), NOT Makkah
      await audio.playTrackById('adhan_cairo');
      expect(audio.currentTrack?.id, equals('adhan_cairo_refaat'));
      expect(audio.currentTrack?.muezzinName, contains('محمد رفعت'));
      await audio.stop();

      // Test Sheikh Al-Husary
      await audio.playTrackById('adhan_hussary');
      expect(audio.currentTrack?.id, equals('adhan_hussary'));
      expect(audio.currentTrack?.muezzinName, contains('الحصري'));
      await audio.stop();

      // Test Sheikh Abdulbasit
      await audio.playTrackById('adhan_abdulbasit');
      expect(audio.currentTrack?.id, equals('adhan_abdulbasit'));
      expect(audio.currentTrack?.muezzinName, contains('عبد الباسط'));
      await audio.stop();

      // Test Sheikh Mishary Al-Afasy
      await audio.playTrackById('adhan_afasy');
      expect(audio.currentTrack?.id, equals('adhan_afasy'));
      expect(audio.currentTrack?.muezzinName, contains('العفاسي'));
      await audio.stop();
    });

    test('All 61 Quran Reciters in SettingsService have unique IDs and distinct audio URLs', () {
      const reciters = SettingsService.availableReciters;
      expect(reciters.length, greaterThanOrEqualTo(45));

      final ids = <String>{};
      final urls = <String>{};
      for (final r in reciters) {
        expect(ids.add(r.id), isTrue, reason: 'Duplicate reciter ID: ${r.id}');
        final surahUrl = SettingsService.instance.getSurahAudioUrl(1, r.id);
        expect(
          urls.add(surahUrl),
          isTrue,
          reason: 'Reciter ${r.id} shares surah URL with another reciter: $surahUrl',
        );
      }
    });
  });

  group('2. Pre-Fajr Wake-Up Alarm & Qiyam Al-Layl Smart Alarm Tests', () {
    test('FajrQiyamAlarmService calculates Pre-Fajr and Last-Third-of-Night wake times accurately', () async {
      final service = FajrQiyamAlarmService.instance;

      await service.setPreFajrMinutesBefore(30);
      expect(service.preFajrMinutesBefore, equals(30));

      final nextFajr = service.getNextFajrTime();
      final nextWake = service.getNextPreFajrWakeTime();
      final diffMinutes = nextFajr.difference(nextWake).inMinutes % (24 * 60);
      expect(diffMinutes, equals(30));

      await service.setPreFajrTone('adhan_cairo_refaat');
      expect(service.preFajrToneId, equals('adhan_cairo_refaat'));

      await service.setQiyamMode('before_fajr');
      await service.setQiyamMinutesBeforeFajr(75);
      expect(service.qiyamMode, equals('before_fajr'));
      expect(service.qiyamMinutesBeforeFajr, equals(75));
    });

    testWidgets('FajrQiyamAlarmScreen renders Pre-Fajr and Qiyam alarm sections and tones',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: FajrQiyamAlarmScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('منبّه الاستعداد للفجر وقيام الليل'), findsOneWidget);
      expect(find.textContaining('منبّه الاستيقاظ والاستعداد قبل صلاة الفجر'), findsOneWidget);
      expect(find.textContaining('منبّه قيام الليل والتهجد الذكي'), findsOneWidget);
    });
  });

  group('3. Daily Prayer Form, Weekly Tracker & Missed-Prayer Diagnostics Tests', () {
    test('PrayerTrackerService records prayer statuses, missed reasons, and generates weekly diagnostic report', () async {
      final tracker = PrayerTrackerService.instance;
      final today = DateTime.now();

      // Mark Fajr as missed with a specific reason
      await tracker.setPrayerFormStatus(
        prayerNameAr: 'الفجر',
        status: PrayerPerformanceStatus.missed,
        reasonText: 'النوم الثقيل / السهر المتأخر',
        date: today,
      );

      // Mark Dhuhr and Asr as on-time congregation
      await tracker.setPrayerFormStatus(
        prayerNameAr: 'الظهر',
        status: PrayerPerformanceStatus.onTimeCongregation,
        date: today,
      );
      await tracker.setPrayerFormStatus(
        prayerNameAr: 'العصر',
        status: PrayerPerformanceStatus.onTimeCongregation,
        date: today,
      );

      // Mark Maghrib as Qada with reason
      await tracker.setPrayerFormStatus(
        prayerNameAr: 'المغرب',
        status: PrayerPerformanceStatus.lateQada,
        reasonText: 'التواجد خارج المنزل أو في المواصلات',
        date: today,
      );

      final record = tracker.getRecordForDate(today);
      expect(record.fajr, isFalse);
      expect(record.dhuhr, isTrue);
      expect(record.asr, isTrue);
      expect(record.maghrib, isTrue);
      expect(record.completedObligatoryCount, equals(3));
      expect(record.getReasonForPrayer('الفجر'), equals('النوم الثقيل / السهر المتأخر'));

      final report = tracker.getWeeklyDiagnosticReport(today);
      expect(report.totalObligatoryInWeek, equals(35));
      expect(report.prayedOnTimeCount, equals(2));
      expect(report.prayedQadaCount, equals(1));
      expect(report.totalPrayedCount, equals(3));
      expect(report.explicitlyMissedCount, equals(1));
      expect(report.diagnosticEntries.length, equals(2));
      expect(report.reasonFrequency['النوم الثقيل / السهر المتأخر'], equals(1));
      expect(report.actionableRemedies.isNotEmpty, isTrue);
    });

    testWidgets('PrayerTrackerScreen renders Daily Form chips and Weekly Diagnostic Report',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: PrayerTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سجل متابعة الصلوات والسنن'), findsOneWidget);
      expect(find.textContaining('التقرير الأسبوعي وسجل تشخيص أسباب فوات الصلاة'), findsOneWidget);
      expect(find.text('في وقتها ✅'), findsNWidgets(5));
      expect(find.text('قضاء ⏳'), findsNWidgets(5));
      expect(find.text('فاتتني ❌'), findsNWidgets(5));
    });
  });
}
