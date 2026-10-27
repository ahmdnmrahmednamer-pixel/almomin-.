import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/sunan_rawatib_service.dart';
import 'package:almomin/core/services/tafsir_service.dart';
import 'package:almomin/core/services/islamic_mutoon_service.dart';
import 'package:almomin/core/services/mawarith_calculator_service.dart';
import 'package:almomin/core/services/tadabbur_journal_service.dart';
import 'package:almomin/core/services/adhkar_service.dart';
import 'package:almomin/core/services/khatma_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Noor Al-Momin Ultimate v6.0 — Full Audit & 5 New Features Verification Suite', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Audit Fix Verification: AdhkarService.categories is synchronously initialized before async init()', () {
      // Accessing categories before init() must never throw LateInitializationError
      expect(AdhkarService.instance.categories, isNotEmpty);
      expect(AdhkarService.instance.categories.length, 10);
    });

    test('Audit Fix Verification: KhatmaPlan satisfies both Day 1 start (604 remaining, 0% progress) and mid-plan math', () {
      final startPlan = KhatmaPlan(
        id: 'p1',
        title: 'ختمة جديدة',
        targetDays: 30,
        startDate: DateTime.now(),
        currentPage: 1,
      );
      expect(startPlan.remainingPages, 604);
      expect(startPlan.progressPercentage, 0.0);

      final midPlan = KhatmaPlan(
        id: 'p2',
        title: 'ختمة منتصف',
        targetDays: 30,
        startDate: DateTime.now(),
        currentPage: 151,
      );
      expect(midPlan.remainingPages, 453);
      expect(midPlan.progressPercentage, closeTo(0.25, 0.01));
    });

    test('New Feature 1: SunanRawatibService tracks 12 daily Rawatib rak\'ahs and builds House in Paradise', () async {
      final s = SunanRawatibService.instance;
      await s.init();

      final testDate = DateTime(2026, 10, 26);
      expect(s.getCompletedRawatibRakahs(date: testDate), 0);
      expect(s.isHouseInParadiseCompleted(date: testDate), isFalse);

      for (final item in SunanRawatibService.allSunan.where((i) => i.isRawatib12)) {
        await s.toggleSunnah(item.id, date: testDate);
      }

      expect(s.getCompletedRawatibRakahs(date: testDate), 12);
      expect(s.isHouseInParadiseCompleted(date: testDate), isTrue);
    });

    test('New Feature 2: Comparative Tafsir Engine supports all 9 authoritative Tafsirs side-by-side', () async {
      expect(TafsirService.availableEditions.length, 9);
      final ids = TafsirService.availableEditions.map((e) => e.id).toSet();
      expect(
        ids.containsAll([
          'muyassar',
          'saadi',
          'ibn_kathir',
          'jalalayn',
          'qurtubi',
          'tabari',
          'baghawi',
          'waseet',
          'shaarawi',
        ]),
        isTrue,
      );

      final r1 = await TafsirService.getTafsir(surahId: 1, ayahNumber: 1, editionId: 'ibn_kathir');
      final r2 = await TafsirService.getTafsir(surahId: 1, ayahNumber: 1, editionId: 'shaarawi');
      expect(r1.tafsirText, isNot(equals(r2.tafsirText)));
    });

    test('New Feature 3: IslamicMutoonService provides 4 foundational Matn books and persists memorization', () async {
      final m = IslamicMutoonService.instance;
      await m.init();

      expect(IslamicMutoonService.matnBooks.length, 4);
      expect(m.getSectionsForBook('tuhfat_atfal').length, greaterThanOrEqualTo(4));

      expect(m.isMemorized('tuhfa_1'), isFalse);
      await m.toggleMemorized('tuhfa_1');
      expect(m.isMemorized('tuhfa_1'), isTrue);
    });

    test('New Feature 4: MawarithCalculatorService accurately calculates Quranic fixed shares and Ta\'sib', () {
      // Case: Wife (1/8 = 12.5%), Father (1/6 = 16.67%), Mother (1/6 = 16.67%), 2 Sons + 1 Daughter (Remainder 13/24 = 54.17% distributed 2:2:1)
      final res = MawarithCalculatorService.calculate(
        grossEstate: 240000,
        debtsAndFuneral: 0,
        bequest: 0,
        spouseStatus: 'wife_1',
        hasFather: true,
        hasMother: true,
        sonsCount: 2,
        daughtersCount: 1,
        fullBrothersCount: 0,
        fullSistersCount: 0,
      );

      expect(res.netDistributableEstate, 240000);
      final wifeShare = res.shares.firstWhere((s) => s.heirNameAr.contains('الزوجة'));
      expect(wifeShare.totalAmount, closeTo(30000, 1.0)); // 1/8 of 240,000 = 30,000

      final motherShare = res.shares.firstWhere((s) => s.heirNameAr == 'الأم');
      expect(motherShare.totalAmount, closeTo(40000, 1.0)); // 1/6 of 240,000 = 40,000

      final fatherShare = res.shares.firstWhere((s) => s.heirNameAr == 'الأب');
      expect(fatherShare.totalAmount, closeTo(40000, 1.0)); // 1/6 of 240,000 = 40,000

      // Remainder = 240,000 - 110,000 = 130,000 divided into 5 shares (2 sons = 4 shares = 104,000, 1 daughter = 1 share = 26,000)
      final sonsShare = res.shares.firstWhere((s) => s.heirNameAr == 'الأبناء الذكور');
      expect(sonsShare.totalAmount, closeTo(104000, 1.0));
      expect(sonsShare.amountPerPerson, closeTo(52000, 1.0));

      final daughterShare = res.shares.firstWhere((s) => s.heirNameAr == 'البنات');
      expect(daughterShare.totalAmount, closeTo(26000, 1.0));
    });

    test('New Feature 5: TadabburJournalService records reflections and daily ethical self-accountability', () async {
      final tj = TadabburJournalService.instance;
      await tj.init();

      final initialCount = tj.entries.length;
      await tj.addReflection(
        surahId: 2,
        surahName: 'البقرة',
        ayahNumber: 255,
        ayahSnippet: '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ﴾',
        faithMessage: 'قيومية الله التامة على خلقه.',
        practicalAction: 'التوكل على الحي القيوم في كل أموري.',
        derivedDua: 'يا حي يا قيوم برحمتك أستغيث.',
      );
      expect(tj.entries.length, initialCount + 1);

      expect(tj.isEthicalItemDoneToday('birr_walidayn'), isFalse);
      await tj.toggleEthicalItemToday('birr_walidayn');
      expect(tj.isEthicalItemDoneToday('birr_walidayn'), isTrue);
    });
  });
}
