import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/arab_countries.dart';
import 'package:almomin/core/services/prayer_service.dart';
import 'package:almomin/core/services/settings_service.dart';
import 'package:almomin/features/prayer/widgets/arab_city_picker_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SettingsService.instance.init();
    await PrayerService.instance.init(forceReload: true);
  });

  group('Arab Countries & Cities Dataset Completeness Tests', () {
    test('Contains all 22 sovereign Arab League nations', () {
      final countries = ArabCountriesData.countries;
      expect(countries.length, 22);

      final countryNames = countries.map((c) => c.name).toList();
      expect(countryNames.any((n) => n.contains('مصر')), isTrue);
      expect(countryNames.any((n) => n.contains('السعودية')), isTrue);
      expect(countryNames.any((n) => n.contains('الإمارات')), isTrue);
      expect(countryNames.any((n) => n.contains('الكويت')), isTrue);
      expect(countryNames.any((n) => n.contains('قطر')), isTrue);
      expect(countryNames.any((n) => n.contains('البحرين')), isTrue);
      expect(countryNames.any((n) => n.contains('عُمان')), isTrue);
      expect(countryNames.any((n) => n.contains('الأردن')), isTrue);
      expect(countryNames.any((n) => n.contains('فلسطين')), isTrue);
      expect(countryNames.any((n) => n.contains('لبنان')), isTrue);
      expect(countryNames.any((n) => n.contains('سوريا')), isTrue);
      expect(countryNames.any((n) => n.contains('العراق')), isTrue);
      expect(countryNames.any((n) => n.contains('اليمن')), isTrue);
      expect(countryNames.any((n) => n.contains('السودان')), isTrue);
      expect(countryNames.any((n) => n.contains('ليبيا')), isTrue);
      expect(countryNames.any((n) => n.contains('تونس')), isTrue);
      expect(countryNames.any((n) => n.contains('الجزائر')), isTrue);
      expect(countryNames.any((n) => n.contains('المغرب')), isTrue);
      expect(countryNames.any((n) => n.contains('موريتانيا')), isTrue);
      expect(countryNames.any((n) => n.contains('الصومال')), isTrue);
      expect(countryNames.any((n) => n.contains('جيبوتي')), isTrue);
      expect(countryNames.any((n) => n.contains('جزر القمر')), isTrue);
    });

    test('Every Arab country has valid cities with non-null coordinates and valid bounds', () {
      for (final country in ArabCountriesData.countries) {
        expect(country.flag.isNotEmpty, isTrue);
        expect(country.cities.isNotEmpty, isTrue, reason: 'Country ${country.name} must have cities');

        for (final city in country.cities) {
          expect(city.name.isNotEmpty, isTrue);
          expect(city.latitude, inInclusiveRange(-90.0, 90.0));
          expect(city.longitude, inInclusiveRange(-180.0, 180.0));
          expect(city.method.isNotEmpty, isTrue);
        }
      }
    });

    test('allCities flattens over 150 Arab cities across all countries', () {
      final allCities = ArabCountriesData.allCities;
      expect(allCities.length, greaterThan(150));
      expect(PrayerService.famousCities.length, equals(allCities.length));
    });

    test('findCountryByCityName accurately locates country', () {
      final egypt = ArabCountriesData.findCountryByCityName('القاهرة، مصر');
      expect(egypt.id, 'eg');

      final saudi = ArabCountriesData.findCountryByCityName('مكة المكرمة');
      expect(saudi.id, 'sa');

      final uae = ArabCountriesData.findCountryByCityName('دبي');
      expect(uae.id, 'ae');

      final palestine = ArabCountriesData.findCountryByCityName('القدس الشريف');
      expect(palestine.id, 'ps');
    });
  });

  group('PrayerService Cascading Selection & Live Continuous Updates', () {
    test('setManualCity updates location, calculation method, and coordinates', () async {
      const riyadh = CityCoordinate('الرياض، السعودية', 24.7136, 46.6753, 'makkah', 'السعودية');
      await PrayerService.instance.setManualCity(riyadh);

      final data = PrayerService.instance.currentData;
      expect(data, isNotNull);
      expect(data!.locationName, 'الرياض، السعودية');
      expect(data.latitude, 24.7136);
      expect(data.longitude, 46.6753);
      expect(SettingsService.instance.calculationMethod, 'makkah');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('last_city'), 'الرياض، السعودية');
      expect(prefs.getString('last_country'), 'السعودية');
    });

    test('formatCountdown outputs HH:MM:SS format for live countdown', () {
      const d1 = Duration(hours: 2, minutes: 15, seconds: 40);
      expect(PrayerService.instance.formatCountdown(d1), '02:15:40');

      const d2 = Duration(minutes: 5, seconds: 9);
      expect(PrayerService.instance.formatCountdown(d2), '00:05:09');

      const d3 = Duration(seconds: -5);
      expect(PrayerService.instance.formatCountdown(d3), 'حان الآن');
    });
  });

  group('ArabCityPickerSheet Widget Tests', () {
    testWidgets('Renders Arab country dropdown and cascading cities list', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArabCityPickerSheet(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify title and 22 countries badge
      expect(find.text('اختيار الدولة والمدينة'), findsOneWidget);
      expect(find.textContaining('٢٢ دولة عربية'), findsOneWidget);

      // 2. Verify country dropdown presence
      expect(find.text('اختر الدولة العربية:'), findsOneWidget);

      // 3. Verify GPS button presence
      expect(find.textContaining('تحديد موقعي الجغرافي تلقائياً عبر الأقمار الصناعية (GPS)'), findsOneWidget);
    });

    testWidgets('Selecting a city from the list updates PrayerService', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ArabCityPickerSheet(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Find Alexandria and tap it
      final alexTile = find.text('الإسكندرية');
      expect(alexTile, findsOneWidget);

      await tester.tap(alexTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final current = PrayerService.instance.currentData?.locationName;
      expect(current, contains('الإسكندرية'));
    });
  });
}
