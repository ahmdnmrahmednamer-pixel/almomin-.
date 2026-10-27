import 'package:flutter_test/flutter_test.dart';
import 'package:adhan_dart/adhan_dart.dart';

void main() {
  test('adhan_dart utc vs local demonstration', () {
    final now = DateTime(2026, 10, 16);
    final coords = Coordinates(30.0444, 31.2357); // Cairo
    final params = CalculationMethodParameters.egyptian();
    final pt = PrayerTimes(
      coordinates: coords,
      date: now,
      calculationParameters: params,
    );

    print('Raw UTC Fajr: ${pt.fajr}');
    print('Local Fajr: ${pt.fajr.toLocal()}');
    print('Raw UTC Dhuhr: ${pt.dhuhr}');
    print('Local Dhuhr: ${pt.dhuhr.toLocal()}');

    expect(pt.fajr.isUtc, isTrue);
    expect(pt.fajr.toLocal().isUtc, isFalse);
  });
}
