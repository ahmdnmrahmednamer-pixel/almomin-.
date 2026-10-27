import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/models/dhikr.dart';
import 'package:almomin/core/services/adhkar_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DhikrItem & DhikrCategory Model Tests', () {
    test('DhikrItem increments, completes, and resets correctly', () {
      final item = DhikrItem(
        id: 1,
        text: 'سبحان الله وبحمده',
        targetCount: 3,
        source: 'صحيح مسلم',
        virtue: 'حطت خطاياه وإن كانت مثل زبد البحر',
      );

      expect(item.currentCount, 0);
      expect(item.isCompleted, isFalse);
      expect(item.remaining, 3);

      item.increment();
      expect(item.currentCount, 1);
      expect(item.remaining, 2);
      expect(item.isCompleted, isFalse);

      item.increment();
      item.increment();
      expect(item.currentCount, 3);
      expect(item.remaining, 0);
      expect(item.isCompleted, isTrue);

      // Cannot increment past target
      item.increment();
      expect(item.currentCount, 3);

      item.reset();
      expect(item.currentCount, 0);
      expect(item.isCompleted, isFalse);
      expect(item.remaining, 3);
    });

    test('DhikrCategory accurately tracks total completed items', () {
      final item1 = DhikrItem(id: 1, text: 'ذكر 1', targetCount: 1);
      final item2 = DhikrItem(id: 2, text: 'ذكر 2', targetCount: 1);

      final catWithItems = DhikrCategory(
        id: 'test',
        title: 'اختبار',
        subtitle: 'فحص',
        icon: Icons.star,
        primaryColor: Colors.black,
        items: [item1, item2],
      );

      expect(catWithItems.totalItems, 2);
      expect(catWithItems.totalCompleted, 0);
      expect(catWithItems.isAllCompleted, isFalse);

      item1.increment();
      expect(catWithItems.totalCompleted, 1);
      expect(catWithItems.isAllCompleted, isFalse);

      item2.increment();
      expect(catWithItems.totalCompleted, 2);
      expect(catWithItems.isAllCompleted, isTrue);
    });
  });

  group('AdhkarService Integration Tests', () {
    test('AdhkarService initializes with all 10 canonical categories', () async {
      final service = AdhkarService.instance;
      await service.init();

      expect(service.categories.length, 10);
      final ids = service.categories.map((c) => c.id).toList();
      expect(ids, containsAll([
        'morning',
        'evening',
        'post_prayer',
        'sleep',
        'waking',
        'duas',
        'quran_duas',
        'home_mosque',
        'distress_relief',
        'ruqyah',
      ]));

      final morning = service.categories.firstWhere((c) => c.id == 'morning');
      expect(morning.items.isNotEmpty, isTrue);
      expect(morning.items.first.source, contains('سورة البقرة'));
    });

    test('AdhkarService incrementDhikr and reset operations', () async {
      final service = AdhkarService.instance;
      await service.init();

      final morning = service.categories.firstWhere((c) => c.id == 'morning');
      final firstItem = morning.items.first;

      service.resetDhikr(firstItem);
      expect(firstItem.currentCount, 0);

      service.incrementDhikr(firstItem);
      expect(firstItem.currentCount, 1);
      expect(firstItem.isCompleted, isTrue);

      service.resetCategory(morning);
      expect(morning.totalCompleted, 0);
    });

    test('Smart Tasbih state and counter operations', () async {
      final service = AdhkarService.instance;
      await service.init();

      service.resetTasbih();
      service.resetTasbihTotal();
      expect(service.tasbihCount, 0);
      expect(service.tasbihTotalToday, 0);

      service.setTasbihTarget(33);
      expect(service.tasbihTarget, 33);

      service.incrementTasbih();
      service.incrementTasbih();
      expect(service.tasbihCount, 2);
      expect(service.tasbihTotalToday, 2);

      service.setSelectedTasbihPhrase('الْحَمْدُ لِلَّهِ');
      expect(service.selectedTasbihPhrase, 'الْحَمْدُ لِلَّهِ');
      expect(service.tasbihCount, 0); // resets session on phrase change
      expect(service.tasbihTotalToday, 2); // preserves daily tally

      service.toggleHaptic(false);
      expect(service.hapticEnabled, isFalse);
      service.toggleHaptic(true);
      expect(service.hapticEnabled, isTrue);
    });

    test('Tasbih increment returns true when target is reached', () async {
      final service = AdhkarService.instance;
      await service.init();

      service.resetTasbih();
      service.setTasbihTarget(3);

      expect(service.incrementTasbih(), isFalse); // count 1
      expect(service.incrementTasbih(), isFalse); // count 2
      expect(service.incrementTasbih(), isTrue);  // count 3 -> reached target!

      // Continuing to next cycle
      expect(service.incrementTasbih(), isFalse); // count 4
      expect(service.incrementTasbih(), isFalse); // count 5
      expect(service.incrementTasbih(), isTrue);  // count 6 -> reached target for cycle 2!
    });

    test('Tasbih motivational quotes catalog provides rich authentic Hadiths', () {
      final service = AdhkarService.instance;
      expect(AdhkarService.motivationalQuotes.isNotEmpty, isTrue);

      final quote1 = service.getMotivationQuoteForCycle(1);
      expect(quote1.title.isNotEmpty, isTrue);
      expect(quote1.hadithOrAyah.isNotEmpty, isTrue);
      expect(quote1.inspiringMessage.isNotEmpty, isTrue);
      expect(quote1.reference.isNotEmpty, isTrue);

      final quote2 = service.getMotivationQuoteForCycle(2);
      expect(quote2.title.isNotEmpty, isTrue);
      expect(quote2.hadithOrAyah, contains('كَلِمَتَانِ'));

      // Cycle wrapping test
      final wrappedQuote = service.getMotivationQuoteForCycle(AdhkarService.motivationalQuotes.length + 1);
      expect(wrappedQuote.title, quote1.title);
    });
  });
}
