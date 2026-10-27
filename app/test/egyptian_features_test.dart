import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/arab_countries.dart';
import 'package:almomin/core/services/egyptian_heritage_service.dart';
import 'package:almomin/features/egypt/egyptian_heritage_screen.dart';
import 'package:almomin/features/zakat/zakat_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EgyptianHeritageService.instance.init(forceReload: true);
  });

  group('Egyptian Heritage Service & Datasets Tests', () {
    test('Egyptian cities list includes 42 governorates and new urban centers', () {
      final egypt = ArabCountriesData.getCountryById('eg');
      expect(egypt, isNotNull);
      expect(egypt!.defaultMethod, equals('egyptian'));
      expect(egypt.cities.length, equals(42));
      expect(
        egypt.cities.any((c) => c.name.contains('العاصمة الإدارية الجديدة')),
        isTrue,
      );
      expect(
        egypt.cities.any((c) => c.name.contains('مدينة ٦ أكتوبر')),
        isTrue,
      );
      expect(
        egypt.cities.any((c) => c.name.contains('واحة سيوة')),
        isTrue,
      );
    });

    test('Cairo Quran Radio and Egyptian Reciter Stations are populated', () {
      final service = EgyptianHeritageService.instance;
      expect(service.radioStations.length, equals(5));
      final cairoRadio = service.radioStations.first;
      expect(cairoRadio.id, equals('eqr_cairo_main'));
      expect(cairoRadio.frequencyLabel, contains('98.2 FM'));
      expect(cairoRadio.dailySchedule.length, greaterThanOrEqualTo(6));
    });

    test('Egyptian Ibtihalat & Al-Shaarawi reflections are populated and filterable', () {
      final service = EgyptianHeritageService.instance;
      expect(service.ibtihalat.length, equals(6));
      expect(service.shaarawiReflections.length, equals(5));

      final naqshbandi = service.getIbtihalatByMubtahil('الشيخ سيد النقشبندي');
      expect(naqshbandi.length, equals(2));
      expect(naqshbandi.first.title, contains('مولاي إني ببابك'));
    });

    test('Historic Egyptian Mosques search and Haversine distance calculation', () {
      final service = EgyptianHeritageService.instance;
      expect(service.historicMosques.length, equals(10));

      final azharResults = service.searchMosques('الأزهر');
      expect(azharResults.isNotEmpty, isTrue);
      expect(azharResults.first.id, equals('mosque_al_azhar'));

      // Distance between Downtown Cairo (30.0444, 31.2357) and Al-Azhar (30.0459, 31.2627) ~ 2.6 km
      final dist = service.calculateDistanceKm(
        fromLat: 30.0444,
        fromLng: 31.2357,
        toLat: 30.0459,
        toLng: 31.2627,
      );
      expect(dist, greaterThan(1.5));
      expect(dist, lessThan(4.0));
    });

    test('Dar Al-Ifta rulings search and favorites persistence', () async {
      final service = EgyptianHeritageService.instance;
      expect(service.darAlIftaRulings.length, equals(5));

      final goldRulings = service.searchFatwas('الشبكة');
      expect(goldRulings.isNotEmpty, isTrue);
      expect(goldRulings.first.id, equals('fatwa_gold_jewelry_shabka'));

      expect(service.isFavorite('fatwa_gold_jewelry_shabka'), isFalse);
      await service.toggleFavorite('fatwa_gold_jewelry_shabka');
      expect(service.isFavorite('fatwa_gold_jewelry_shabka'), isTrue);

      final exported = service.exportFavorites();
      expect(exported, contains('fatwa_gold_jewelry_shabka'));
    });
  });

  group('Egyptian Heritage & Zakat UI Widget Tests', () {
    testWidgets('EgyptianHeritageScreen renders all 4 tabs and switches cleanly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EgyptianHeritageScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('واحة التراث المصري'), findsOneWidget);
      expect(find.text('إذاعة القرآن (98.2 FM)'), findsOneWidget);
      expect(find.text('الابتهالات والشعراوي'), findsOneWidget);
      expect(find.text('مساجد مصر التاريخية'), findsOneWidget);
      expect(find.text('فتاوى دار الإفتاء'), findsOneWidget);

      // Switch to Historic Mosques tab
      await tester.tap(find.text('مساجد مصر التاريخية'));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجامع الأزهر الشريف'), findsOneWidget);

      // Switch to Dar Al-Ifta tab
      await tester.tap(find.text('فتاوى دار الإفتاء'));
      await tester.pumpAndSettle();
      expect(find.textContaining('شهادات الادخار'), findsOneWidget);
    });

    testWidgets('ZakatScreen renders Egyptian gold quick-add chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ZakatScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('+ جنيه ذهب (8 جم عيار 21)'), findsOneWidget);
      expect(find.text('+ أونصة ذهب (31.1 جم عيار 24)'), findsOneWidget);
    });
  });
}
