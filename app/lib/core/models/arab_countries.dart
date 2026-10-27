import '../text/arabic_normalizer.dart';
import 'dart:math';

/// Representation of a city's coordinates and prayer calculation parameters
class CityCoordinate {
  final String name;
  final double latitude;
  final double longitude;
  final String method;
  final String country;

  const CityCoordinate(
    this.name,
    this.latitude,
    this.longitude, [
    this.method = 'egyptian',
    this.country = 'مصر',
  ]);

  const CityCoordinate.named({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.method = 'egyptian',
    this.country = 'مصر',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityCoordinate &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

/// Representation of an Arab country and its major cities
class ArabCountry {
  final String id;
  final String name;
  final String flag;
  final String defaultMethod;
  final String methodDescription;
  final List<CityCoordinate> cities;

  const ArabCountry({
    required this.id,
    required this.name,
    required this.flag,
    required this.defaultMethod,
    required this.methodDescription,
    required this.cities,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArabCountry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Canonical dataset of all 22 Arab League nations and their cities
class ArabCountriesData {
  static const List<ArabCountry> countries = [
    // 1. مصر (Egypt)
    ArabCountry(
      id: 'eg',
      name: 'جمهورية مصر العربية',
      flag: '🇪🇬',
      defaultMethod: 'egyptian',
      methodDescription: 'الهيئة المصرية العامة للمساحة',
      cities: [
        CityCoordinate('القاهرة', 30.0444, 31.2357, 'egyptian', 'مصر'),
        CityCoordinate('الإسكندرية', 31.2001, 29.9187, 'egyptian', 'مصر'),
        CityCoordinate('الجيزة', 30.0131, 31.2089, 'egyptian', 'مصر'),
        CityCoordinate('المنصورة / الدقهلية', 31.0409, 31.3785, 'egyptian', 'مصر'),
        CityCoordinate('طنطا / الغربية', 30.7865, 31.0004, 'egyptian', 'مصر'),
        CityCoordinate('الزقازيق / الشرقية', 30.5877, 31.5020, 'egyptian', 'مصر'),
        CityCoordinate('بنها / القليوبية', 30.4660, 31.1853, 'egyptian', 'مصر'),
        CityCoordinate('شبين الكوم / المنوفية', 30.5526, 31.0090, 'egyptian', 'مصر'),
        CityCoordinate('دمنهور / البحيرة', 31.0434, 30.4716, 'egyptian', 'مصر'),
        CityCoordinate('كفر الشيخ', 31.1107, 30.9388, 'egyptian', 'مصر'),
        CityCoordinate('دمياط', 31.4175, 31.8144, 'egyptian', 'مصر'),
        CityCoordinate('بورسعيد', 31.2653, 32.3019, 'egyptian', 'مصر'),
        CityCoordinate('الإسماعيلية', 30.5965, 32.2715, 'egyptian', 'مصر'),
        CityCoordinate('السويس', 29.9668, 32.5498, 'egyptian', 'مصر'),
        CityCoordinate('الفيوم', 29.3084, 30.8428, 'egyptian', 'مصر'),
        CityCoordinate('بني سويف', 29.0661, 31.0994, 'egyptian', 'مصر'),
        CityCoordinate('المنيا', 28.0871, 30.7618, 'egyptian', 'مصر'),
        CityCoordinate('أسيوط', 27.1783, 31.1859, 'egyptian', 'مصر'),
        CityCoordinate('سوهاج', 26.5569, 31.6948, 'egyptian', 'مصر'),
        CityCoordinate('قنا', 26.1551, 32.7160, 'egyptian', 'مصر'),
        CityCoordinate('الأقصر', 25.6872, 32.6396, 'egyptian', 'مصر'),
        CityCoordinate('أسوان', 24.0889, 32.8998, 'egyptian', 'مصر'),
        CityCoordinate('الغردقة / البحر الأحمر', 27.2579, 33.8116, 'egyptian', 'مصر'),
        CityCoordinate('شرم الشيخ / جنوب سيناء', 27.9158, 34.3299, 'egyptian', 'مصر'),
        CityCoordinate('العريش / شمال سيناء', 31.1316, 33.7984, 'egyptian', 'مصر'),
        CityCoordinate('مرسى مطروح / الساحل الشمالي', 31.3543, 27.2373, 'egyptian', 'مصر'),
        CityCoordinate('الخارجة / الوادي الجديد', 25.4514, 30.5471, 'egyptian', 'مصر'),
        CityCoordinate('العاصمة الإدارية الجديدة', 30.0131, 31.7336, 'egyptian', 'مصر'),
        CityCoordinate('مدينة ٦ أكتوبر', 29.9726, 30.9435, 'egyptian', 'مصر'),
        CityCoordinate('الشيخ زايد', 30.0441, 30.9772, 'egyptian', 'مصر'),
        CityCoordinate('القاهرة الجديدة / التجمع الخامس', 30.0074, 31.4913, 'egyptian', 'مصر'),
        CityCoordinate('العاشر من رمضان', 30.2969, 31.7417, 'egyptian', 'مصر'),
        CityCoordinate('المحلة الكبرى', 30.9706, 31.1669, 'egyptian', 'مصر'),
        CityCoordinate('ميت غمر', 30.7167, 31.2606, 'egyptian', 'مصر'),
        CityCoordinate('دسوق', 31.1319, 30.6481, 'egyptian', 'مصر'),
        CityCoordinate('العين السخنة', 29.6002, 32.3167, 'egyptian', 'مصر'),
        CityCoordinate('الجونة', 27.3942, 33.6782, 'egyptian', 'مصر'),
        CityCoordinate('دهب', 28.5091, 34.5136, 'egyptian', 'مصر'),
        CityCoordinate('واحة سيوة', 29.2032, 25.5195, 'egyptian', 'مصر'),
        CityCoordinate('الواحات البحرية', 28.3492, 28.8647, 'egyptian', 'مصر'),
        CityCoordinate('إدفو', 24.9785, 32.8758, 'egyptian', 'مصر'),
        CityCoordinate('نجع حمادي', 26.0495, 32.2414, 'egyptian', 'مصر'),
      ],
    ),

    // 2. المملكة العربية السعودية (Saudi Arabia)
    ArabCountry(
      id: 'sa',
      name: 'المملكة العربية السعودية',
      flag: '🇸🇦',
      defaultMethod: 'makkah',
      methodDescription: 'جامعة أم القرى (مكة المكرمة)',
      cities: [
        CityCoordinate('مكة المكرمة', 21.3891, 39.8579, 'makkah', 'السعودية'),
        CityCoordinate('المدينة المنورة', 24.5247, 39.5692, 'makkah', 'السعودية'),
        CityCoordinate('الرياض', 24.7136, 46.6753, 'makkah', 'السعودية'),
        CityCoordinate('جدة', 21.4858, 39.1925, 'makkah', 'السعودية'),
        CityCoordinate('الدمام', 26.4207, 50.0888, 'makkah', 'السعودية'),
        CityCoordinate('الخبر', 26.2172, 50.1971, 'makkah', 'السعودية'),
        CityCoordinate('الظهران', 26.2361, 50.0393, 'makkah', 'السعودية'),
        CityCoordinate('الطائف', 21.2854, 40.4222, 'makkah', 'السعودية'),
        CityCoordinate('بريدة / القصيم', 26.3260, 43.9750, 'makkah', 'السعودية'),
        CityCoordinate('عنيزة', 26.0844, 43.9936, 'makkah', 'السعودية'),
        CityCoordinate('تبوك', 28.3835, 36.5662, 'makkah', 'السعودية'),
        CityCoordinate('أبها / عسير', 18.2164, 42.5053, 'makkah', 'السعودية'),
        CityCoordinate('خميس مشيط', 18.3000, 42.7333, 'makkah', 'السعودية'),
        CityCoordinate('جازان', 16.8894, 42.5706, 'makkah', 'السعودية'),
        CityCoordinate('نجران', 17.5656, 44.2289, 'makkah', 'السعودية'),
        CityCoordinate('حائل', 27.5114, 41.7208, 'makkah', 'السعودية'),
        CityCoordinate('سكاكا / الجوف', 29.9697, 40.2064, 'makkah', 'السعودية'),
        CityCoordinate('عرعر / الحدود الشمالية', 30.9753, 41.0381, 'makkah', 'السعودية'),
        CityCoordinate('ينبع', 24.0232, 38.1900, 'makkah', 'السعودية'),
        CityCoordinate('الجبيل', 27.0046, 49.6606, 'makkah', 'السعودية'),
        CityCoordinate('الهفوف / الأحساء', 25.3835, 49.5864, 'makkah', 'السعودية'),
        CityCoordinate('حفر الباطن', 28.4328, 45.9708, 'makkah', 'السعودية'),
      ],
    ),

    // 3. الإمارات العربية المتحدة (UAE)
    ArabCountry(
      id: 'ae',
      name: 'الإمارات العربية المتحدة',
      flag: '🇦🇪',
      defaultMethod: 'makkah',
      methodDescription: 'الهيئة العامة للشؤون الإسلامية والأوقاف',
      cities: [
        CityCoordinate('أبوظبي', 24.4539, 54.3773, 'makkah', 'الإمارات'),
        CityCoordinate('دبي', 25.2048, 55.2708, 'makkah', 'الإمارات'),
        CityCoordinate('الشارقة', 25.3463, 55.4209, 'makkah', 'الإمارات'),
        CityCoordinate('عجمان', 25.4052, 55.5136, 'makkah', 'الإمارات'),
        CityCoordinate('رأس الخيمة', 25.7895, 55.9432, 'makkah', 'الإمارات'),
        CityCoordinate('الفجيرة', 25.1288, 56.3265, 'makkah', 'الإمارات'),
        CityCoordinate('أم القيوين', 25.5647, 55.5552, 'makkah', 'الإمارات'),
        CityCoordinate('العين', 24.2075, 55.7447, 'makkah', 'الإمارات'),
      ],
    ),

    // 4. دولة الكويت (Kuwait)
    ArabCountry(
      id: 'kw',
      name: 'دولة الكويت',
      flag: '🇰🇼',
      defaultMethod: 'makkah',
      methodDescription: 'وزارة الأوقاف والشؤون الإسلامية بدولة الكويت',
      cities: [
        CityCoordinate('مدينة الكويت', 29.3759, 47.9774, 'makkah', 'الكويت'),
        CityCoordinate('حولي', 29.3328, 48.0289, 'makkah', 'الكويت'),
        CityCoordinate('السالمية', 29.3344, 48.0772, 'makkah', 'الكويت'),
        CityCoordinate('الأحمدي', 29.0769, 48.0839, 'makkah', 'الكويت'),
        CityCoordinate('الفروانية', 29.2778, 47.9589, 'makkah', 'الكويت'),
        CityCoordinate('الجهراء', 29.3375, 47.6581, 'makkah', 'الكويت'),
        CityCoordinate('مبارك الكبير', 29.2139, 48.0558, 'makkah', 'الكويت'),
      ],
    ),

    // 5. دولة قطر (Qatar)
    ArabCountry(
      id: 'qa',
      name: 'دولة قطر',
      flag: '🇶🇦',
      defaultMethod: 'makkah',
      methodDescription: 'وزارة الأوقاف والشؤون الإسلامية بدولة قطر',
      cities: [
        CityCoordinate('الدوحة', 25.2854, 51.5310, 'makkah', 'قطر'),
        CityCoordinate('الريان', 25.2919, 51.4244, 'makkah', 'قطر'),
        CityCoordinate('الوكرة', 25.1768, 51.6048, 'makkah', 'قطر'),
        CityCoordinate('الخور', 25.6839, 51.5058, 'makkah', 'قطر'),
        CityCoordinate('لوسيل', 25.4200, 51.4900, 'makkah', 'قطر'),
        CityCoordinate('أم صلال', 25.4167, 51.4000, 'makkah', 'قطر'),
      ],
    ),

    // 6. مملكة البحرين (Bahrain)
    ArabCountry(
      id: 'bh',
      name: 'مملكة البحرين',
      flag: '🇧🇭',
      defaultMethod: 'makkah',
      methodDescription: 'وزارة العدل والشؤون الإسلامية بالبحرين',
      cities: [
        CityCoordinate('المنامة', 26.2285, 50.5860, 'makkah', 'البحرين'),
        CityCoordinate('المحرق', 26.2572, 50.6119, 'makkah', 'البحرين'),
        CityCoordinate('الرفاع', 26.1300, 50.5550, 'makkah', 'البحرين'),
        CityCoordinate('مدينة عيسى', 26.1736, 50.5478, 'makkah', 'البحرين'),
        CityCoordinate('مدينة حمد', 26.1153, 50.5069, 'makkah', 'البحرين'),
        CityCoordinate('سترة', 26.1547, 50.6206, 'makkah', 'البحرين'),
      ],
    ),

    // 7. سلطنة عُمان (Oman)
    ArabCountry(
      id: 'om',
      name: 'سلطنة عُمان',
      flag: '🇴🇲',
      defaultMethod: 'makkah',
      methodDescription: 'وزارة الأوقاف والشؤون الدينية بسلطنة عمان',
      cities: [
        CityCoordinate('مسقط', 23.5880, 58.3829, 'makkah', 'عمان'),
        CityCoordinate('السيب', 23.6703, 58.1891, 'makkah', 'عمان'),
        CityCoordinate('صلالة', 17.0151, 54.0924, 'makkah', 'عمان'),
        CityCoordinate('صحار', 24.3642, 56.7468, 'makkah', 'عمان'),
        CityCoordinate('نزوى', 22.9333, 57.5333, 'makkah', 'عمان'),
        CityCoordinate('صور', 22.5667, 59.5289, 'makkah', 'عمان'),
        CityCoordinate('البريمي', 24.2509, 55.7931, 'makkah', 'عمان'),
      ],
    ),

    // 8. المملكة الأردنية الهاشمية (Jordan)
    ArabCountry(
      id: 'jo',
      name: 'المملكة الأردنية الهاشمية',
      flag: '🇯🇴',
      defaultMethod: 'mwl',
      methodDescription: 'رابطة العالم الإسلامي / وزارة الأوقاف الأردنية',
      cities: [
        CityCoordinate('عمّان', 31.9454, 35.9284, 'mwl', 'الأردن'),
        CityCoordinate('إربد', 32.5568, 35.8469, 'mwl', 'الأردن'),
        CityCoordinate('الزرقاء', 32.0728, 36.0880, 'mwl', 'الأردن'),
        CityCoordinate('العقبة', 29.5267, 35.0078, 'mwl', 'الأردن'),
        CityCoordinate('السلط', 32.0392, 35.7272, 'mwl', 'الأردن'),
        CityCoordinate('مادبا', 31.7167, 35.7933, 'mwl', 'الأردن'),
        CityCoordinate('جرش', 32.2747, 35.8961, 'mwl', 'الأردن'),
        CityCoordinate('الكرك', 31.1833, 35.7000, 'mwl', 'الأردن'),
        CityCoordinate('معان', 30.1962, 35.7340, 'mwl', 'الأردن'),
      ],
    ),

    // 9. دولة فلسطين (Palestine)
    ArabCountry(
      id: 'ps',
      name: 'دولة فلسطين',
      flag: '🇵🇸',
      defaultMethod: 'mwl',
      methodDescription: 'رابطة العالم الإسلامي / وزارة الأوقاف الفلسطينية',
      cities: [
        CityCoordinate('القدس الشريف', 31.7683, 35.2137, 'mwl', 'فلسطين'),
        CityCoordinate('غزة', 31.5017, 34.4668, 'egyptian', 'فلسطين'),
        CityCoordinate('الخليل', 31.5326, 35.0998, 'mwl', 'فلسطين'),
        CityCoordinate('نابلس', 32.2211, 35.2544, 'mwl', 'فلسطين'),
        CityCoordinate('رام الله والبيرة', 31.9038, 35.2034, 'mwl', 'فلسطين'),
        CityCoordinate('خان يونس', 31.3462, 34.3063, 'egyptian', 'فلسطين'),
        CityCoordinate('رفح', 31.2968, 34.2435, 'egyptian', 'فلسطين'),
        CityCoordinate('جنين', 32.4644, 35.2958, 'mwl', 'فلسطين'),
        CityCoordinate('بيت لحم', 31.7054, 35.2024, 'mwl', 'فلسطين'),
        CityCoordinate('طولكرم', 32.3117, 35.0275, 'mwl', 'فلسطين'),
        CityCoordinate('قلقيلية', 32.1960, 34.9815, 'mwl', 'فلسطين'),
        CityCoordinate('أريحا', 31.8611, 35.4608, 'mwl', 'فلسطين'),
      ],
    ),

    // 10. الجمهورية اللبنانية (Lebanon)
    ArabCountry(
      id: 'lb',
      name: 'الجمهورية اللبنانية',
      flag: '🇱🇧',
      defaultMethod: 'mwl',
      methodDescription: 'رابطة العالم الإسلامي / دار الفتوى اللبنانية',
      cities: [
        CityCoordinate('بيروت', 33.8938, 35.5018, 'mwl', 'لبنان'),
        CityCoordinate('طرابلس', 34.4367, 35.8497, 'mwl', 'لبنان'),
        CityCoordinate('صيدا', 33.5631, 35.3689, 'mwl', 'لبنان'),
        CityCoordinate('صور', 33.2733, 35.1939, 'mwl', 'لبنان'),
        CityCoordinate('زحلة', 33.8463, 35.9020, 'mwl', 'لبنان'),
        CityCoordinate('النبطية', 33.3772, 35.4839, 'mwl', 'لبنان'),
        CityCoordinate('بعلبك', 34.0058, 36.2181, 'mwl', 'لبنان'),
      ],
    ),

    // 11. الجمهورية العربية السورية (Syria)
    ArabCountry(
      id: 'sy',
      name: 'الجمهورية العربية السورية (سوريا)',
      flag: '🇸🇾',
      defaultMethod: 'mwl',
      methodDescription: 'رابطة العالم الإسلامي / وزارة الأوقاف السورية',
      cities: [
        CityCoordinate('دمشق', 33.5138, 36.2765, 'mwl', 'سوريا'),
        CityCoordinate('حلب', 36.2021, 37.1343, 'mwl', 'سوريا'),
        CityCoordinate('حمص', 34.7324, 36.7137, 'mwl', 'سوريا'),
        CityCoordinate('اللاذقية', 35.5317, 35.7901, 'mwl', 'سوريا'),
        CityCoordinate('حماة', 35.1318, 36.7578, 'mwl', 'سوريا'),
        CityCoordinate('طرطوس', 34.8890, 35.8866, 'mwl', 'سوريا'),
        CityCoordinate('دير الزور', 35.3359, 40.1408, 'mwl', 'سوريا'),
        CityCoordinate('الرقة', 35.9594, 39.0089, 'mwl', 'سوريا'),
        CityCoordinate('درعا', 32.6189, 36.1047, 'mwl', 'سوريا'),
        CityCoordinate('السويداء', 32.7089, 36.5695, 'mwl', 'سوريا'),
      ],
    ),

    // 12. جمهورية العراق (Iraq)
    ArabCountry(
      id: 'iq',
      name: 'جمهورية العراق',
      flag: '🇮🇶',
      defaultMethod: 'mwl',
      methodDescription: 'رابطة العالم الإسلامي / ديوان الوقف',
      cities: [
        CityCoordinate('بغداد', 33.3152, 44.3661, 'mwl', 'العراق'),
        CityCoordinate('البصرة', 30.5081, 47.7835, 'mwl', 'العراق'),
        CityCoordinate('الموصل / نينوى', 36.3400, 43.1300, 'mwl', 'العراق'),
        CityCoordinate('أربيل', 36.1901, 44.0091, 'mwl', 'العراق'),
        CityCoordinate('النجف الأشرف', 32.0259, 44.3463, 'mwl', 'العراق'),
        CityCoordinate('كربلاء المقدسة', 32.6160, 44.0249, 'mwl', 'العراق'),
        CityCoordinate('السليمانية', 35.5558, 45.4351, 'mwl', 'العراق'),
        CityCoordinate('كركوك', 35.4681, 44.3922, 'mwl', 'العراق'),
        CityCoordinate('الحلة / بابل', 32.4833, 44.4333, 'mwl', 'العراق'),
        CityCoordinate('الكوت / واسط', 32.5139, 45.8197, 'mwl', 'العراق'),
        CityCoordinate('الناصرية / ذي قار', 31.0583, 46.2575, 'mwl', 'العراق'),
        CityCoordinate('العمارة / ميسان', 31.8389, 47.1436, 'mwl', 'العراق'),
        CityCoordinate('الرمادي / الأنبار', 33.4233, 43.2981, 'mwl', 'العراق'),
        CityCoordinate('تكريت / صلاح الدين', 34.6078, 43.6786, 'mwl', 'العراق'),
        CityCoordinate('سامراء', 34.1983, 43.8742, 'mwl', 'العراق'),
      ],
    ),

    // 13. الجمهورية اليمنية (Yemen)
    ArabCountry(
      id: 'ye',
      name: 'الجمهورية اليمنية',
      flag: '🇾🇪',
      defaultMethod: 'makkah',
      methodDescription: 'أم القرى / وزارة الأوقاف والإرشاد اليمنية',
      cities: [
        CityCoordinate('صنعاء', 15.3694, 44.1910, 'makkah', 'اليمن'),
        CityCoordinate('عدن', 12.7855, 45.0187, 'makkah', 'اليمن'),
        CityCoordinate('تعز', 13.5795, 44.0209, 'makkah', 'اليمن'),
        CityCoordinate('الحديدة', 14.7978, 42.9545, 'makkah', 'اليمن'),
        CityCoordinate('المكلا / حضرموت', 14.5425, 49.1242, 'makkah', 'اليمن'),
        CityCoordinate('إب', 13.9667, 44.1833, 'makkah', 'اليمن'),
        CityCoordinate('ذمار', 14.5500, 44.4000, 'makkah', 'اليمن'),
        CityCoordinate('مأرب', 15.4639, 45.3258, 'makkah', 'اليمن'),
        CityCoordinate('صعدة', 16.9402, 43.7639, 'makkah', 'اليمن'),
      ],
    ),

    // 14. جمهورية السودان (Sudan)
    ArabCountry(
      id: 'sd',
      name: 'جمهورية السودان',
      flag: '🇸🇩',
      defaultMethod: 'egyptian',
      methodDescription: 'الهيئة العامة للمساحة / الشؤون الدينية بالسودان',
      cities: [
        CityCoordinate('الخرطوم', 15.5007, 32.5599, 'egyptian', 'السودان'),
        CityCoordinate('أم درمان', 15.6500, 32.4833, 'egyptian', 'السودان'),
        CityCoordinate('الخرطوم بحري', 15.6333, 32.5333, 'egyptian', 'السودان'),
        CityCoordinate('بورتسودان', 19.6175, 37.2164, 'egyptian', 'السودان'),
        CityCoordinate('كسلا', 15.4510, 36.4000, 'egyptian', 'السودان'),
        CityCoordinate('القضارف', 14.0333, 35.3833, 'egyptian', 'السودان'),
        CityCoordinate('ود مدني / الجزيرة', 14.4012, 33.5199, 'egyptian', 'السودان'),
        CityCoordinate('الأبيض / كردفان', 13.1833, 30.2167, 'egyptian', 'السودان'),
        CityCoordinate('الفاشر / دارفور', 13.6279, 25.3494, 'egyptian', 'السودان'),
        CityCoordinate('نيالا', 12.0500, 24.8833, 'egyptian', 'السودان'),
        CityCoordinate('دنقلا / الشمالية', 19.1667, 30.4833, 'egyptian', 'السودان'),
        CityCoordinate('عطبرة / نهر النيل', 17.7022, 33.9864, 'egyptian', 'السودان'),
      ],
    ),

    // 15. دولة ليبيا (Libya)
    ArabCountry(
      id: 'ly',
      name: 'دولة ليبيا',
      flag: '🇱🇾',
      defaultMethod: 'mwl',
      methodDescription: 'الهيئة العامة للأوقاف والشؤون الإسلامية بليبيا',
      cities: [
        CityCoordinate('طرابلس', 32.8872, 13.1913, 'mwl', 'ليبيا'),
        CityCoordinate('بنغازي', 32.1167, 20.0667, 'mwl', 'ليبيا'),
        CityCoordinate('مصراتة', 32.3754, 15.0925, 'mwl', 'ليبيا'),
        CityCoordinate('البيضاء', 32.7628, 21.7551, 'mwl', 'ليبيا'),
        CityCoordinate('الزاوية', 32.7522, 12.7278, 'mwl', 'ليبيا'),
        CityCoordinate('طبرق', 32.0836, 23.9764, 'mwl', 'ليبيا'),
        CityCoordinate('سبها', 27.0377, 14.4283, 'mwl', 'ليبيا'),
        CityCoordinate('سرت', 31.2089, 16.5887, 'mwl', 'ليبيا'),
        CityCoordinate('درنة', 32.7670, 22.6367, 'mwl', 'ليبيا'),
        CityCoordinate('زليتن', 32.4674, 14.5687, 'mwl', 'ليبيا'),
      ],
    ),

    // 16. الجمهورية التونسية (Tunisia)
    ArabCountry(
      id: 'tn',
      name: 'الجمهورية التونسية',
      flag: '🇹🇳',
      defaultMethod: 'mwl',
      methodDescription: 'وزارة الشؤون الدينية التونسية / رابطة العالم الإسلامي',
      cities: [
        CityCoordinate('تونس العاصمة', 36.8065, 10.1815, 'mwl', 'تونس'),
        CityCoordinate('صفاقس', 34.7406, 10.7603, 'mwl', 'تونس'),
        CityCoordinate('سوسة', 35.8256, 10.6369, 'mwl', 'تونس'),
        CityCoordinate('القيروان', 35.6781, 10.0963, 'mwl', 'تونس'),
        CityCoordinate('بنزرت', 37.2744, 9.8739, 'mwl', 'تونس'),
        CityCoordinate('قابس', 33.8815, 10.0982, 'mwl', 'تونس'),
        CityCoordinate('أريانة', 36.8663, 10.1956, 'mwl', 'تونس'),
        CityCoordinate('المنستير', 35.7780, 10.8262, 'mwl', 'تونس'),
        CityCoordinate('مدنين / جربة', 33.3549, 10.4927, 'mwl', 'تونس'),
        CityCoordinate('نابل / الحمامات', 36.4561, 10.7376, 'mwl', 'تونس'),
        CityCoordinate('توزر', 33.9197, 8.1335, 'mwl', 'تونس'),
      ],
    ),

    // 17. الجمهورية الجزائرية (Algeria)
    ArabCountry(
      id: 'dz',
      name: 'الجمهورية الجزائرية الديمقراطية الشعبية',
      flag: '🇩🇿',
      defaultMethod: 'mwl',
      methodDescription: 'وزارة الشؤون الدينية والأوقاف الجزائرية',
      cities: [
        CityCoordinate('الجزائر العاصمة', 36.7538, 3.0588, 'mwl', 'الجزائر'),
        CityCoordinate('وهران', 35.6971, -0.6308, 'mwl', 'الجزائر'),
        CityCoordinate('قسنطينة', 36.3650, 6.6147, 'mwl', 'الجزائر'),
        CityCoordinate('عنابة', 36.9000, 7.7667, 'mwl', 'الجزائر'),
        CityCoordinate('باتنة', 35.5558, 6.1742, 'mwl', 'الجزائر'),
        CityCoordinate('سطيف', 36.1905, 5.4137, 'mwl', 'الجزائر'),
        CityCoordinate('تلمسان', 34.8783, -1.3150, 'mwl', 'الجزائر'),
        CityCoordinate('البليدة', 36.4700, 2.8300, 'mwl', 'الجزائر'),
        CityCoordinate('الشلف', 36.1650, 1.3344, 'mwl', 'الجزائر'),
        CityCoordinate('بسكرة', 34.8500, 5.7333, 'mwl', 'الجزائر'),
        CityCoordinate('ورقلة', 31.9500, 5.3167, 'mwl', 'الجزائر'),
        CityCoordinate('تيزي وزو', 36.7169, 4.0497, 'mwl', 'الجزائر'),
        CityCoordinate('بجاية', 36.7559, 5.0843, 'mwl', 'الجزائر'),
        CityCoordinate('تمنراست', 22.7850, 5.5228, 'mwl', 'الجزائر'),
      ],
    ),

    // 18. المملكة المغربية (Morocco)
    ArabCountry(
      id: 'ma',
      name: 'المملكة المغربية',
      flag: '🇲🇦',
      defaultMethod: 'mwl',
      methodDescription: 'وزارة الأوقاف والشؤون الإسلامية بالمغرب',
      cities: [
        CityCoordinate('الرباط', 34.0209, -6.8416, 'mwl', 'المغرب'),
        CityCoordinate('الدار البيضاء', 33.5731, -7.5898, 'mwl', 'المغرب'),
        CityCoordinate('مراكش', 31.6295, -7.9811, 'mwl', 'المغرب'),
        CityCoordinate('فاس', 34.0331, -5.0003, 'mwl', 'المغرب'),
        CityCoordinate('طنجة', 35.7595, -5.8340, 'mwl', 'المغرب'),
        CityCoordinate('أكادير', 30.4278, -9.5981, 'mwl', 'المغرب'),
        CityCoordinate('مكناس', 33.8938, -5.5473, 'mwl', 'المغرب'),
        CityCoordinate('وجدة', 34.6867, -1.9114, 'mwl', 'المغرب'),
        CityCoordinate('القنيطرة', 34.2610, -6.5802, 'mwl', 'المغرب'),
        CityCoordinate('تطوان', 35.5785, -5.3684, 'mwl', 'المغرب'),
        CityCoordinate('العيون', 27.1536, -13.2033, 'mwl', 'المغرب'),
        CityCoordinate('الصويرة', 31.5085, -9.7595, 'mwl', 'المغرب'),
      ],
    ),

    // 19. الجمهورية الإسلامية الموريتانية (Mauritania)
    ArabCountry(
      id: 'mr',
      name: 'الجمهورية الإسلامية الموريتانية (موريتانيا)',
      flag: '🇲🇷',
      defaultMethod: 'mwl',
      methodDescription: 'وزارة الشؤون الإسلامية والتعليم الأصلي بموريتانيا',
      cities: [
        CityCoordinate('نواكشوط', 18.0735, -15.9582, 'mwl', 'موريتانيا'),
        CityCoordinate('نواذيبو', 20.9411, -17.0347, 'mwl', 'موريتانيا'),
        CityCoordinate('كيفة', 16.6167, -11.4000, 'mwl', 'موريتانيا'),
        CityCoordinate('روصو', 16.5133, -15.8050, 'mwl', 'موريتانيا'),
        CityCoordinate('أطار', 20.5167, -13.0500, 'mwl', 'موريتانيا'),
        CityCoordinate('كيهيدي', 16.1500, -13.5000, 'mwl', 'موريتانيا'),
        CityCoordinate('النعمة', 16.6167, -7.2500, 'mwl', 'موريتانيا'),
      ],
    ),

    // 20. جمهورية الصومال الفيدرالية (Somalia)
    ArabCountry(
      id: 'so',
      name: 'جمهورية الصومال الفيدرالية (الصومال)',
      flag: '🇸🇴',
      defaultMethod: 'makkah',
      methodDescription: 'رابطة العالم الإسلامي / وزارة الأوقاف الصومالية',
      cities: [
        CityCoordinate('مقديشو', 2.0469, 45.3182, 'makkah', 'الصومال'),
        CityCoordinate('هرجيسا', 9.5600, 44.0650, 'makkah', 'الصومال'),
        CityCoordinate('بوساسو', 11.2842, 49.1814, 'makkah', 'الصومال'),
        CityCoordinate('كيسمايو', -0.3582, 42.5454, 'makkah', 'الصومال'),
        CityCoordinate('غاروي', 8.4021, 48.4845, 'makkah', 'الصومال'),
        CityCoordinate('بربرة', 10.4396, 45.0143, 'makkah', 'الصومال'),
        CityCoordinate('بيداوا', 3.1139, 43.6498, 'makkah', 'الصومال'),
      ],
    ),

    // 21. جمهورية جيبوتي (Djibouti)
    ArabCountry(
      id: 'dj',
      name: 'جمهورية جيبوتي',
      flag: '🇩🇯',
      defaultMethod: 'makkah',
      methodDescription: 'وزارة الشؤون الإسلامية والثقافة والأوقاف بجيبوتي',
      cities: [
        CityCoordinate('جيبوتي العاصمة', 11.5721, 43.1456, 'makkah', 'جيبوتي'),
        CityCoordinate('علي صبيح', 11.1558, 42.7125, 'makkah', 'جيبوتي'),
        CityCoordinate('تاجورة', 11.7853, 42.8822, 'makkah', 'جيبوتي'),
        CityCoordinate('أوبوك', 11.9625, 43.2906, 'makkah', 'جيبوتي'),
        CityCoordinate('دخيل', 11.1075, 42.3739, 'makkah', 'جيبوتي'),
      ],
    ),

    // 22. جمهورية جزر القمر (Comoros)
    ArabCountry(
      id: 'km',
      name: 'جمهورية جزر القمر المتحدة',
      flag: '🇰🇲',
      defaultMethod: 'makkah',
      methodDescription: 'رابطة العالم الإسلامي / دار الإفتاء القُمرية',
      cities: [
        CityCoordinate('موروني', -11.7172, 43.2473, 'makkah', 'جزر القمر'),
        CityCoordinate('موتسامودو', -12.1672, 44.4003, 'makkah', 'جزر القمر'),
        CityCoordinate('فومبوني', -12.2800, 43.7425, 'makkah', 'جزر القمر'),
        CityCoordinate('دوموني', -12.2575, 44.5319, 'makkah', 'جزر القمر'),
      ],
    ),
  ];

  /// Flattened list of all cities across all 22 countries with premier cities first
  static List<CityCoordinate> get allCities {
    final list = <CityCoordinate>[];
    for (final country in countries) {
      list.addAll(country.cities);
    }
    return list;
  }

  /// Locate which country a given city belongs to (supports Arabic-normalized matching)
  static ArabCountry findCountryByCityName(String cityName) {
    final cleanTarget = cityName.trim();
    if (cleanTarget.isEmpty) return countries.first;
    final normTarget = ArabicNormalizer.normalize(cleanTarget, loose: true);
    for (final c in countries) {
      for (final city in c.cities) {
        final normCity = ArabicNormalizer.normalize(city.name, loose: true);
        if (cleanTarget.contains(city.name) ||
            city.name.contains(cleanTarget) ||
            (normTarget.isNotEmpty &&
                (normTarget.contains(normCity) || normCity.contains(normTarget)))) {
          return c;
        }
      }
    }
    // Default fallback is Egypt
    return countries.first;
  }

  /// Locate which country by country id
  static ArabCountry findCountryById(String id) {
    return countries.firstWhere(
      (c) => c.id == id,
      orElse: () => countries.first,
    );
  }

  static ArabCountry getCountryById(String id) => findCountryById(id);
  ArabCountry getCountryByIdInstance(String id) => findCountryById(id);
}

typedef ArabCountriesCatalog = ArabCountriesData;
