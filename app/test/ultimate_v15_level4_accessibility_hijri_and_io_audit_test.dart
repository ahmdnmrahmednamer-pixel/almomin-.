import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/backup_restore_service.dart';
import 'package:almomin/core/services/hajj_umrah_service.dart';
import 'package:almomin/core/services/mawarith_calculator_service.dart';
import 'package:almomin/core/services/ramadan_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/core/services/voluntary_fasting_service.dart';
import 'package:almomin/core/ui/app_dropdown_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
    await VoluntaryFastingService.instance.init();
    await RamadanService.instance.init(forceReload: true);
    await HajjUmrahService.instance.init();
  });

  group('Ultimate v15.0 Level-4 Accessibility, Hijri Math, Dropdown Safety & I/O Audit Tests', () {
    testWidgets('1. AppDropdownField handles empty options list and duplicate option values without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppDropdownField<String>(
                  label: 'قائمة فارغة قيد التحميل',
                  value: 'initial',
                  options: const [],
                  onChanged: (_) {},
                ),
                AppDropdownField<String>(
                  label: 'قائمة بها قيم مكررة',
                  value: 'dup',
                  options: const [
                    AppDropdownOption(value: 'dup', label: 'الخيار الأول'),
                    AppDropdownOption(value: 'dup', label: 'الخيار المكرر'),
                    AppDropdownOption(value: 'other', label: 'الخيار الثاني'),
                  ],
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('قائمة فارغة قيد التحميل'), findsOneWidget);
      expect(find.text('قائمة بها قيم مكررة'), findsOneWidget);
    });

    test('2. VoluntaryFastingService synchronizes _fastedDateLogs on decrementFastCount and detects White Days', () async {
      final service = VoluntaryFastingService.instance;
      await service.logFastedDay('white_days', date: DateTime(2026, 10, 27));
      expect(service.getCountForType('white_days'), equals(1));
      expect(service.fastedDateLogs.length, equals(1));

      await service.decrementFastCount('white_days');
      expect(service.getCountForType('white_days'), equals(0));
      expect(service.fastedDateLogs, isEmpty);

      expect(service.isWhiteDay(13), isTrue);
      expect(service.isWhiteDay(14), isTrue);
      expect(service.isWhiteDay(15), isTrue);
      expect(service.isWhiteDay(16), isFalse);
    });

    test('3. BackupRestoreService exports and restores RamadanTracker, VoluntaryFasting counts/logs, and HajjUmrah state', () async {
      await RamadanService.instance.toggleFasted(1);
      await RamadanService.instance.toggleTaraweeh(1);
      await VoluntaryFastingService.instance.logFastedDay('monday_thursday');
      await HajjUmrahService.instance.incrementTawaf();

      final jsonStr = await BackupRestoreService.instance.exportBackupJson();
      final validation = BackupRestoreService.instance.validateBackup(jsonStr);
      expect(validation.isValid, isTrue);

      SharedPreferences.setMockInitialValues({});
      await RamadanService.instance.init(forceReload: true);
      await VoluntaryFastingService.instance.init();
      await HajjUmrahService.instance.init();
      expect(RamadanService.instance.isDayFasted(1), isFalse);
      expect(VoluntaryFastingService.instance.getCountForType('monday_thursday'), equals(0));
      expect(HajjUmrahService.instance.tawafLap, equals(0));

      final ok = await BackupRestoreService.instance.restoreBackup(
        validation.rawData!,
        replaceMode: true,
      );
      expect(ok, isTrue);
      expect(RamadanService.instance.isDayFasted(1), isTrue);
      expect(RamadanService.instance.isTaraweehCompleted(1), isTrue);
      expect(VoluntaryFastingService.instance.getCountForType('monday_thursday'), equals(1));
      expect(HajjUmrahService.instance.tawafLap, equals(1));
    });

    test('4. MawarithCalculatorService safely clamps negative heir counts to 0', () {
      final res = MawarithCalculatorService.calculate(
        grossEstate: 100000,
        spouseStatus: 'wife_1',
        hasFather: true,
        hasMother: true,
        sonsCount: -5,
        daughtersCount: -2,
        fullBrothersCount: -1,
        fullSistersCount: -3,
      );
      expect(res.netDistributableEstate, equals(100000));
      expect(res.shares, isNotEmpty);
    });
  });
}
