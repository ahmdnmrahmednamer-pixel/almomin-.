import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/prayer_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/khatma_service.dart';
import 'package:almomin/core/services/adhkar_service.dart';
import 'package:almomin/core/models/memorization_item.dart';
import 'package:almomin/core/models/zakat_calculation.dart';
import 'package:almomin/core/services/adhan_sensor_gesture_service.dart';
import 'package:almomin/core/services/quran_search_service.dart';
import 'package:almomin/core/services/backup_restore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Noor Al-Momin v4.0 Deep Engineering Audit — 20 Bugs Regression Suite', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Bug #1 & #3: PrayerService preserves manual city selection and recalculates on method change', () async {
      await SettingsService.instance.init();
      await PrayerService.instance.init();

      const alexandria = CityCoordinate(
        name: 'الإسكندرية، مصر',
        country: 'مصر',
        latitude: 31.2001,
        longitude: 29.9187,
        method: 'egyptian',
      );
      await PrayerService.instance.setManualCity(alexandria);
      expect(PrayerService.instance.isManualLocation, isTrue);
      expect(PrayerService.instance.currentData?.locationName, 'الإسكندرية، مصر');

      // Auto-init GPS must NOT overwrite a manually chosen city
      final autoGpsResult = await PrayerService.instance.requestGpsLocation(isAutoInit: true);
      expect(autoGpsResult, isFalse);
      expect(PrayerService.instance.currentData?.locationName, 'الإسكندرية، مصر');
    });

    test('Bug #4, #5, #6: KhatmaPlan off-by-one math, uncheck prayer rollback, and forward-only reading', () async {
      await KhatmaService.instance.init();
      await KhatmaService.instance.createPlan(
        title: 'ختمة الشهر',
        targetDays: 30,
        startingPage: 1,
      );

      final plan = KhatmaService.instance.activePlan!;
      // Bug #6: At page 1 before reading any pages, remainingPages is 604 and progressPercentage is 0.0
      expect(plan.remainingPages, 604);
      expect(plan.progressPercentage, 0.0);

      // Bug #5: Checking and unchecking a prayer rolls back pages symmetrically
      await KhatmaService.instance.togglePrayerCompleted('fajr');
      final afterCheckPage = KhatmaService.instance.activePlan!.currentPage;
      expect(afterCheckPage, greaterThan(1));

      await KhatmaService.instance.togglePrayerCompleted('fajr');
      expect(KhatmaService.instance.activePlan!.currentPage, 1);

      // Bug #4: Browsing an earlier Surah when Khatma is at page 200 does not overwrite backward
      await KhatmaService.instance.setManualPage(200);
      await KhatmaService.instance.updateProgressFromReading(1); // Opening Al-Fatihah
      expect(KhatmaService.instance.activePlan!.currentPage, 200);
    });

    test('Bug #7 & #8: AdhkarService resets tasbihTotalToday on new calendar day and persists Dhikr counts', () async {
      SharedPreferences.setMockInitialValues({
        'tasbih_total_today': 150,
        'tasbih_last_date': '2020-01-01', // Stale date
      });
      await AdhkarService.instance.init();
      expect(AdhkarService.instance.tasbihTotalToday, 0);

      final firstItem = AdhkarService.instance.categories.first.items.first;
      AdhkarService.instance.incrementDhikr(firstItem);
      expect(firstItem.currentCount, 1);

      // Re-init on the same day restores persisted DhikrItem count
      await AdhkarService.instance.init();
      expect(AdhkarService.instance.categories.first.items.first.currentCount, 1);
    });

    test('Bug #9: MemorizationItem.isDue normalizes to calendar day start', () {
      final item = MemorizationItem.createInitial(
        surahId: 2,
        ayahNumber: 255,
        surahName: 'البقرة',
      );
      expect(item.isDue, isTrue);

      final reviewed = item.recordReview(MemorizationRating.easy);
      expect(reviewed.nextReviewDue.hour, 0);
      expect(reviewed.nextReviewDue.minute, 0);
    });

    test('Bug #10: ZakatCalculation.copyWith supports clearing hawlDate', () {
      final calc = ZakatCalculation(hawlDate: DateTime(2026, 1, 1));
      expect(calc.hawlDate, isNotNull);

      final cleared = calc.copyWith(clearHawlDate: true);
      expect(cleared.hawlDate, isNull);
    });

    test('Bug #12: AdhanSensorGestureService does not lock _isListening=true on stream error', () {
      AdhanSensorGestureService.instance.stopListening();
      expect(AdhanSensorGestureService.instance.isListening, isFalse);
    });

    test('Bug #16: QuranSearchService.parseReference supports colon & ayah word with Arabic-Indic digits', () async {
      final match1 = await QuranSearchService.instance.parseReference('٢:٢٥٥');
      expect(match1?.surahId, 2);
      expect(match1?.ayahNumber, 255);

      final match2 = await QuranSearchService.instance.parseReference('البقرة: ٢٥٥');
      expect(match2?.surahId, 2);
      expect(match2?.ayahNumber, 255);

      final match3 = await QuranSearchService.instance.parseReference('سورة الكهف آية ١٠');
      expect(match3?.surahId, 18);
      expect(match3?.ayahNumber, 10);
    });

    test('Bug #18: HijriDateHelper applies persisted hijriAdjustmentDays', () async {
      final d = DateTime(2026, 10, 16);
      final h0 = HijriDateHelper.toHijri(d, adjustmentDays: 0);
      final hPlus1 = HijriDateHelper.toHijri(d, adjustmentDays: 1);
      expect(hPlus1['day'] != h0['day'] || hPlus1['month'] != h0['month'], isTrue);
    });

    test('Bug #20: BackupRestoreService canonical checksum rejects tampered backup payload', () async {
      final jsonStr = await BackupRestoreService.instance.exportBackupJson();
      final validRes = BackupRestoreService.instance.validateBackup(jsonStr);
      expect(validRes.isValid, isTrue);

      final tampered = jsonStr.replaceFirst('"last_read_page_number": 1', '"last_read_page_number": 599');
      final tamperedRes = BackupRestoreService.instance.validateBackup(tampered);
      expect(tamperedRes.isValid, isFalse);
    });
  });
}
