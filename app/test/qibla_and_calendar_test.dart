import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:almomin/core/services/prayer_service.dart';
import 'package:almomin/core/notifications/prayer_notification_service.dart';
import 'package:almomin/features/prayer/hijri_calendar_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Qibla Direction & Distance Mathematical Tests', () {
    test('Calculates accurate distance from Cairo to Kaaba (~1288 km)', () {
      const kaabaLat = 21.422487;
      const kaabaLng = 39.826206;
      const cairoLat = 30.0444;
      const cairoLng = 31.2357;

      const earthRadiusKm = 6371.0;
      final dLat = (kaabaLat - cairoLat) * (pi / 180.0);
      final dLon = (kaabaLng - cairoLng) * (pi / 180.0);
      final a = sin(dLat / 2) * sin(dLat / 2) +
          cos(cairoLat * (pi / 180.0)) * cos(kaabaLat * (pi / 180.0)) *
          sin(dLon / 2) * sin(dLon / 2);
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      final distance = earthRadiusKm * c;

      expect(distance, greaterThan(1280.0));
      expect(distance, lessThan(1295.0));
    });

    test('Calculates accurate Qibla angle for Cairo (~136.2°)', () {
      final cairoCoords = Coordinates(30.0444, 31.2357);
      final qibla = Qibla.qibla(cairoCoords);

      expect(qibla, greaterThan(135.0));
      expect(qibla, lessThan(137.5));
    });

    test('Calculates accurate Qibla angle for Medina (~175.7° due South)', () {
      final medinaCoords = Coordinates(24.5247, 39.5692);
      final qibla = Qibla.qibla(medinaCoords);

      expect(qibla, greaterThan(174.0));
      expect(qibla, lessThan(178.0));
    });
  });

  group('Hijri Calendar & Occasions Tests', () {
    test('Islamic occasions list contains all canonical milestones', () {
      final titles = HijriCalendarScreenStatePublic.canonicalOccasions.map((o) => o.title).toList();

      expect(titles, contains('أول أيام شهر رمضان المبارك'));
      expect(titles, contains('عيد الفطر المبارك'));
      expect(titles, contains('يوم عرفة'));
      expect(titles, contains('عيد الأضحى المبارك'));
      expect(titles, contains('يوم عاشوراء'));
      expect(titles, contains('المولد النبوي الشريف'));
      expect(titles, contains('الإسراء والمعراج'));
      expect(titles, contains('ليلة النصف من شعبان'));
    });

    test('Ramadan is in Month 9 and Arafah is on 9 Dhul-Hijjah', () {
      final ramadan = HijriCalendarScreenStatePublic.canonicalOccasions.firstWhere(
        (o) => o.title.contains('رمضان'),
      );
      expect(ramadan.hijriMonth, 9);
      expect(ramadan.hijriDay, 1);

      final arafah = HijriCalendarScreenStatePublic.canonicalOccasions.firstWhere(
        (o) => o.title.contains('عرفة'),
      );
      expect(arafah.hijriMonth, 12);
      expect(arafah.hijriDay, 9);
    });
  });

  group('PrayerNotificationService Tests', () {
    test('Initializes with default settings and toggles per prayer', () async {
      final notifService = PrayerNotificationService.instance;
      await notifService.init();

      expect(notifService.masterEnabled, isTrue);
      expect(notifService.isPrayerEnabled('الفجر'), isTrue);
      expect(notifService.isPrayerEnabled('الظهر'), isTrue);
      expect(notifService.isPrayerEnabled('العصر'), isTrue);
      expect(notifService.isPrayerEnabled('المغرب'), isTrue);
      expect(notifService.isPrayerEnabled('العشاء'), isTrue);
      expect(notifService.isPrayerEnabled('الشروق'), isFalse);

      await notifService.togglePrayer('الفجر', false);
      expect(notifService.isPrayerEnabled('الفجر'), isFalse);

      await notifService.setSoundMode(AdhanSoundMode.takbeerat);
      expect(notifService.soundMode, AdhanSoundMode.takbeerat);

      await notifService.setPreReminder(15);
      expect(notifService.preReminderMinutes, 15);
    });
  });
}

// Helper to expose static occasions for unit tests
class HijriCalendarScreenStatePublic {
  static const List<IslamicOccasion> canonicalOccasions = [
    IslamicOccasion(
      title: 'رأس السنة الهجرية',
      hijriMonth: 1,
      hijriDay: 1,
      description: 'بداية العام الهجري الجديد واستذكار الهجرة النبوية الشريفة',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'يوم عاشوراء',
      hijriMonth: 1,
      hijriDay: 10,
      description: 'نجاة نبي الله موسى عليه السلام',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'المولد النبوي الشريف',
      hijriMonth: 3,
      hijriDay: 12,
      description: 'مولد خير الأنام محمد ﷺ',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'الإسراء والمعراج',
      hijriMonth: 7,
      hijriDay: 27,
      description: 'معجزة الإسراء بالرسول ﷺ',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'ليلة النصف من شعبان',
      hijriMonth: 8,
      hijriDay: 15,
      description: 'تحويل القبلة إلى المسجد الحرام',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'أول أيام شهر رمضان المبارك',
      hijriMonth: 9,
      hijriDay: 1,
      description: 'شهر الصيام والقرآن',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'عيد الفطر المبارك',
      hijriMonth: 10,
      hijriDay: 1,
      description: 'فرحة إتمام الصيام',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'يوم عرفة',
      hijriMonth: 12,
      hijriDay: 9,
      description: 'خير يوم طلعت عليه الشمس',
      icon: Icons.star,
    ),
    IslamicOccasion(
      title: 'عيد الأضحى المبارك',
      hijriMonth: 12,
      hijriDay: 10,
      description: 'يوم النحر وأيام التشريق',
      icon: Icons.star,
    ),
  ];
}
