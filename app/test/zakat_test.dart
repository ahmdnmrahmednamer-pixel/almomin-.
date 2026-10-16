import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/zakat_calculation.dart';
import 'package:almomin/core/services/zakat_service.dart';
import 'package:almomin/features/zakat/zakat_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ZakatService.instance.init();
    await ZakatService.instance.reset();
  });

  group('ZakatCalculation Mathematical & Sharia Rules Tests (FR-ZKT)', () {
    test('Gold purity conversions accurately normalize to 24k pure gold', () {
      const calc = ZakatCalculation(
        gold24Grams: 10,
        gold21Grams: 24, // 24 * 21/24 = 21g pure
        gold18Grams: 24, // 24 * 18/24 = 18g pure
      );

      // Total pure gold = 10 + 21 + 18 = 49g
      expect(calc.totalPureGoldGrams, closeTo(49.0, 0.001));
    });

    test('Gold and silver monetary values compute correctly based on prices', () {
      const calc = ZakatCalculation(
        gold24Grams: 10,
        silverGrams: 100,
        goldPricePerGram24: 3000,
        silverPricePerGram: 40,
      );

      expect(calc.goldMonetaryValue, 30000.0);
      expect(calc.silverMonetaryValue, 4000.0);
    });

    test('Net zakatable wealth accurately accounts for assets and due debts', () {
      const calc = ZakatCalculation(
        cashOnHand: 50000,
        tradeGoods: 30000,
        debtsReceivable: 10000,
        debtsPayable: 20000,
      );

      // Gross: 50000 + 30000 + 10000 = 90000
      // Net: 90000 - 20000 = 70000
      expect(calc.grossAssets, 90000.0);
      expect(calc.netZakatableWealth, 70000.0);
    });

    test('Net wealth does not become negative when debts exceed assets', () {
      const calc = ZakatCalculation(
        cashOnHand: 10000,
        debtsPayable: 25000,
      );

      expect(calc.netZakatableWealth, 0.0);
      expect(calc.isNisabReached, false);
      expect(calc.zakatDue, 0.0);
    });

    test('Gold Nisab threshold: 85g of 24k gold determines liability', () {
      const goldPrice = 3000.0;
      const nisabThreshold = 85.0 * goldPrice; // 255,000

      // Below Nisab
      const calcBelow = ZakatCalculation(
        cashOnHand: 254000,
        goldPricePerGram24: goldPrice,
        nisabBasis: ZakatNisabBasis.gold,
      );
      expect(calcBelow.nisabThresholdValue, nisabThreshold);
      expect(calcBelow.isNisabReached, false);
      expect(calcBelow.zakatDue, 0.0);

      // At or Above Nisab
      const calcAbove = ZakatCalculation(
        cashOnHand: 300000,
        goldPricePerGram24: goldPrice,
        nisabBasis: ZakatNisabBasis.gold,
      );
      expect(calcAbove.isNisabReached, true);
      // 2.5% of 300,000 = 7,500
      expect(calcAbove.zakatDue, 7500.0);
    });

    test('Silver Nisab threshold: 595g of pure silver determines liability', () {
      const silverPrice = 40.0;
      const nisabThreshold = 595.0 * silverPrice; // 23,800

      const calc = ZakatCalculation(
        cashOnHand: 30000,
        silverPricePerGram: silverPrice,
        nisabBasis: ZakatNisabBasis.silver,
      );

      expect(calc.nisabThresholdValue, nisabThreshold);
      expect(calc.isNisabReached, true);
      // 2.5% of 30,000 = 750
      expect(calc.zakatDue, 750.0);
    });

    test('JSON serialization and roundtrip preserves all values and hawlDate', () {
      final now = DateTime(2026, 10, 16);
      final calc = ZakatCalculation(
        cashOnHand: 125000,
        gold24Grams: 50,
        gold21Grams: 20,
        gold18Grams: 10,
        silverGrams: 200,
        tradeGoods: 45000,
        debtsReceivable: 5000,
        debtsPayable: 15000,
        goldPricePerGram24: 3850,
        silverPricePerGram: 46,
        currency: 'ر.س',
        nisabBasis: ZakatNisabBasis.silver,
        hawlDate: now,
      );

      final jsonMap = calc.toJson();
      final restored = ZakatCalculation.fromJson(jsonMap);

      expect(restored.cashOnHand, 125000);
      expect(restored.gold24Grams, 50);
      expect(restored.gold21Grams, 20);
      expect(restored.gold18Grams, 10);
      expect(restored.silverGrams, 200);
      expect(restored.tradeGoods, 45000);
      expect(restored.debtsReceivable, 5000);
      expect(restored.debtsPayable, 15000);
      expect(restored.goldPricePerGram24, 3850);
      expect(restored.silverPricePerGram, 46);
      expect(restored.currency, 'ر.س');
      expect(restored.nisabBasis, ZakatNisabBasis.silver);
      expect(restored.hawlDate?.year, 2026);
    });
  });

  group('ZakatService Tests', () {
    test('updateCalculation persists to storage and updates state', () async {
      final service = ZakatService.instance;
      expect(service.calculation.cashOnHand, 0.0);

      const updated = ZakatCalculation(
        cashOnHand: 100000,
        currency: 'د.إ',
      );

      await service.updateCalculation(updated);
      expect(service.calculation.cashOnHand, 100000);
      expect(service.calculation.currency, 'د.إ');
    });

    test('reset clears inputs while preserving currency and prices', () async {
      final service = ZakatService.instance;
      await service.updateCalculation(const ZakatCalculation(
        cashOnHand: 200000,
        gold24Grams: 40,
        currency: 'ر.س',
        goldPricePerGram24: 3500,
      ));

      await service.reset();
      expect(service.calculation.cashOnHand, 0.0);
      expect(service.calculation.gold24Grams, 0.0);
      expect(service.calculation.currency, 'ر.س');
      expect(service.calculation.goldPricePerGram24, 3500);
    });

    test('exportData and importData preserves state for backup and restore', () async {
      final service = ZakatService.instance;
      await service.updateCalculation(const ZakatCalculation(
        cashOnHand: 80000,
        currency: 'د.ك',
      ));

      final exported = service.exportData();
      expect(exported['cash_on_hand'], 80000);
      expect(exported['currency'], 'د.ك');

      await service.reset();
      expect(service.calculation.cashOnHand, 0.0);

      await service.importData(exported);
      expect(service.calculation.cashOnHand, 80000);
      expect(service.calculation.currency, 'د.ك');
    });
  });

  group('ZakatScreen Widget Tests', () {
    testWidgets('Renders ZakatScreen with dedication, inputs, and updates live result', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ZakatScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen title
      expect(find.text('حاسبة الزكاة الشرعية الذكية'), findsOneWidget);

      // Verify Noble Dedication Banner for Momin Ibrahim
      expect(find.text('صدقة جارية عن مؤمن إبراهيم رحمه الله'), findsOneWidget);

      // Verify Summary Card components
      expect(find.text('ملخص الحساب الشرعي'), findsOneWidget);
      expect(find.text('لم يبلغ النصاب بعد'), findsOneWidget);

      // Enter Cash amount: 400,000 (exceeding default 85g * 3800 = 323,000)
      final cashField = find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.labelText?.contains('الأموال النقدية') ?? false),
      );
      expect(cashField, findsOneWidget);

      await tester.enterText(cashField, '400000');
      await tester.pumpAndSettle();

      // Verify status flipped to 'بلغ النصاب الشرعي ✓'
      expect(find.text('بلغ النصاب الشرعي ✓'), findsOneWidget);

      // Verify Zakat Due (2.5% of 400,000 = 10,000.00)
      expect(find.textContaining('10000.00'), findsOneWidget);
    });
  });
}
