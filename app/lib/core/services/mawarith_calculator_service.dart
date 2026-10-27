class HeirShareResult {
  final String heirNameAr;
  final int count;
  final String shareTypeAr; // مثل: الثمن فرضا، السدس فرضا، الباقي تعصيبا
  final double percentage;
  final double totalAmount;
  final double amountPerPerson;
  final String quranicEvidence;

  const HeirShareResult({
    required this.heirNameAr,
    required this.count,
    required this.shareTypeAr,
    required this.percentage,
    required this.totalAmount,
    required this.amountPerPerson,
    required this.quranicEvidence,
  });
}

class MawarithCalculationSummary {
  final double grossEstate;
  final double debtsAndFuneral;
  final double requestedBequest;
  final double allowedBequest; // capped at 1/3 of (gross - debts)
  final double netDistributableEstate;
  final List<HeirShareResult> shares;
  final bool hasAwl;
  final bool hasRadd;

  const MawarithCalculationSummary({
    required this.grossEstate,
    required this.debtsAndFuneral,
    required this.requestedBequest,
    required this.allowedBequest,
    required this.netDistributableEstate,
    required this.shares,
    this.hasAwl = false,
    this.hasRadd = false,
  });

  double get netEstate => netDistributableEstate;
}

/// الميزة الرابعة الجديدة: محرك حساب المواريث الشرعية والفرائض وفق الكتاب والسنة وقانون المواريث المصري
class MawarithCalculatorService {
  static final MawarithCalculatorService instance = MawarithCalculatorService();

  static MawarithCalculationSummary calculate({
    double? grossEstate,
    double? estateValue,
    double debts = 0.0,
    double debtsAndFuneral = 0.0,
    double funeralExpenses = 0.0,
    double bequest = 0.0,
    double bequestAmount = 0.0,
    String spouseStatus = 'none',
    bool hasHusband = false,
    int wivesCount = 0,
    bool hasFather = false,
    bool hasMother = false,
    int sonsCount = 0,
    int daughtersCount = 0,
    int fullBrothersCount = 0,
    int fullSistersCount = 0,
  }) {
    final effectiveGross = grossEstate ?? estateValue ?? 0.0;
    final effectiveDebts = debtsAndFuneral > 0 ? debtsAndFuneral : (debts + funeralExpenses);
    final effectiveBequest = bequest > 0 ? bequest : bequestAmount;
    String effectiveSpouse = spouseStatus;
    if (hasHusband) {
      effectiveSpouse = 'husband';
    } else if (wivesCount > 0) {
      final safeWives = wivesCount.clamp(1, 4);
      effectiveSpouse = 'wife_$safeWives';
    }
    sonsCount = sonsCount.clamp(0, 50);
    daughtersCount = daughtersCount.clamp(0, 50);
    fullBrothersCount = fullBrothersCount.clamp(0, 50);
    fullSistersCount = fullSistersCount.clamp(0, 50);
    final afterDebts = (effectiveGross - effectiveDebts).clamp(0.0, double.infinity);
    // الوصية تنفذ في حدود الثلث شرعاً
    final maxBequest = afterDebts / 3.0;
    final allowedBequest = effectiveBequest.clamp(0.0, maxBequest);
    final netEstate = (afterDebts - allowedBequest).clamp(0.0, double.infinity);

    final bool hasDescendant = sonsCount > 0 || daughtersCount > 0;
    final bool hasMaleAscendantOrDescendant = hasFather || sonsCount > 0;
    final int siblingsTotal = fullBrothersCount + fullSistersCount;

    // 1. Calculate fixed Quranic fractions (أصحاب الفروض)
    final Map<String, double> rawFractions = {};
    final Map<String, String> shareDescriptions = {};
    final Map<String, String> evidences = {};
    final Map<String, int> counts = {};

    // Spouse share
    if (spouseStatus == 'husband') {
      final frac = hasDescendant ? 0.25 : 0.50;
      rawFractions['الزوج'] = frac;
      counts['الزوج'] = 1;
      shareDescriptions['الزوج'] = hasDescendant
          ? 'الربع (١/٤) فرضاً لوجود الفرع الوارث'
          : 'النصف (١/٢) فرضاً لعدم وجود الفرع الوارث';
      evidences['الزوج'] = 'قوله تعالى: ﴿وَلَكُمْ نِصْفُ مَا تَرَكَ أَزْوَاجُكُمْ إِن لَّمْ يَكُن لَّهُنَّ وَلَدٌ فَإِن كَانَ لَهُنَّ وَلَدٌ فَلَكُمُ الرُّبُعُ﴾ [النساء: ١٢].';
    } else if (spouseStatus.startsWith('wife_')) {
      final wCount = int.tryParse(spouseStatus.split('_').last) ?? 1;
      final frac = hasDescendant ? 0.125 : 0.25;
      rawFractions['الزوجة / الزوجات'] = frac;
      counts['الزوجة / الزوجات'] = wCount;
      shareDescriptions['الزوجة / الزوجات'] = hasDescendant
          ? 'الثمن (١/٨) فرضاً لوجود الفرع الوارث'
          : 'الربع (١/٤) فرضاً لعدم وجود الفرع الوارث';
      evidences['الزوجة / الزوجات'] = 'قوله تعالى: ﴿وَلَهُنَّ الرُّبُعُ مِمَّا تَرَكْتُمْ إِن لَّمْ يَكُن لَّكُمْ وَلَدٌ فَإِن كَانَ لَكُمْ وَلَدٌ فَلَهُنَّ الثُّمُنُ﴾ [النساء: ١٢].';
    }

    // Mother share
    if (hasMother) {
      final bool getsOneSixth = hasDescendant || siblingsTotal >= 2;
      final frac = getsOneSixth ? (1.0 / 6.0) : (1.0 / 3.0);
      rawFractions['الأم'] = frac;
      counts['الأم'] = 1;
      shareDescriptions['الأم'] = getsOneSixth
          ? 'السدس (١/٦) فرضاً لوجود الفرع الوارث أو جمع من الإخوة'
          : 'الثلث (١/٣) فرضاً لعدم الفرع الوارث وعدم الجمع من الإخوة';
      evidences['الأم'] = 'قوله تعالى: ﴿وَلِأَبَوَيْهِ لِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ مِمَّا تَرَكَ إِن كَانَ لَهُ وَلَدٌ فَإِن لَّمْ يَكُن لَّهُ وَلَدٌ وَوَرِثَهُ أَبَوَاهُ فَلِأُمِّهِ الثُّلُثُ﴾ [النساء: ١١].';
    }

    // Father fixed share when descendants exist
    if (hasFather && sonsCount > 0) {
      rawFractions['الأب'] = 1.0 / 6.0;
      counts['الأب'] = 1;
      shareDescriptions['الأب'] = 'السدس (١/٦) فرضاً لوجود الفرع الوارث المذكر (الابن)';
      evidences['الأب'] = 'قوله تعالى: ﴿وَلِأَبَوَيْهِ لِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ مِمَّا تَرَكَ إِن كَانَ لَهُ وَلَدٌ﴾ [النساء: ١١].';
    } else if (hasFather && sonsCount == 0 && daughtersCount > 0) {
      rawFractions['الأب'] = 1.0 / 6.0;
      counts['الأب'] = 1;
      shareDescriptions['الأب'] = 'السدس (١/٦) فرضاً + الباقي تعصيباً لوجود الفرع المؤنث فقط';
      evidences['الأب'] = 'قوله تعالى: ﴿وَلِأَبَوَيْهِ لِكُلِّ وَاحِدٍ مِّنْهُمَا السُّدُسُ﴾ وحديث: «ألحقوا الفرائض بأهلها فما بقي فهو لأولى رجل ذكر».';
    }

    // Daughters fixed share when no sons exist
    if (sonsCount == 0 && daughtersCount > 0) {
      final frac = daughtersCount == 1 ? 0.50 : (2.0 / 3.0);
      rawFractions['البنات'] = frac;
      counts['البنات'] = daughtersCount;
      shareDescriptions['البنات'] = daughtersCount == 1
          ? 'النصف (١/٢) فرضاً لانفرادها وعدم المعصب'
          : 'الثلثان (٢/٣) فرضاً لتعددهن وعدم المعصب';
      evidences['البنات'] = 'قوله تعالى: ﴿فَإِن كُنَّ نِسَاءً فَوْقَ اثْنَتَيْنِ فَلَهُنَّ ثُلُثَا مَا تَرَكَ وَإِن كَانَتْ وَاحِدَةً فَلَهَا النِّصْفُ﴾ [النساء: ١١].';
    }

    // Full Sisters fixed share when no descendants and no Father and no Full Brothers
    if (!hasDescendant && !hasFather && fullBrothersCount == 0 && fullSistersCount > 0) {
      final frac = fullSistersCount == 1 ? 0.50 : (2.0 / 3.0);
      rawFractions['الأخوات الشقيقات'] = frac;
      counts['الأخوات الشقيقات'] = fullSistersCount;
      shareDescriptions['الأخوات الشقيقات'] = fullSistersCount == 1
          ? 'النصف (١/٢) فرضاً لعدم الفرع والأصل والمعصب'
          : 'الثلثان (٢/٣) فرضاً لتعددهن وعدم الفرع والأصل والمعصب';
      evidences['الأخوات الشقيقات'] = 'قوله تعالى في آية الكلالة: ﴿إِنِ امْرُؤٌ هَلَكَ لَيْسَ لَهُ وَلَدٌ وَلَهُ أُخْتٌ فَلَهَا نِصْفُ مَا تَرَكَ... فَإِن كَانَتَا اثْنَتَيْنِ فَلَهُمَا الثُّلُثَانِ مِمَّا تَرَكَ﴾ [النساء: ١٧٦].';
    }

    // Check total fixed fractions (handle Awl if sum > 1.0)
    double sumFixed = rawFractions.values.fold(0.0, (a, b) => a + b);
    bool hasAwl = false;
    bool hasRadd = false;

    if (sumFixed > 1.0001) {
      hasAwl = true;
      for (final k in rawFractions.keys.toList()) {
        rawFractions[k] = rawFractions[k]! / sumFixed;
      }
      sumFixed = 1.0;
    }

    double remainder = (1.0 - sumFixed).clamp(0.0, 1.0);

    // 2. Distribute Remainder by Ta'sib (التعصيب)
    if (remainder > 0.0001) {
      if (sonsCount > 0) {
        final totalUnits = (sonsCount * 2) + daughtersCount;
        final sonFrac = remainder * ((sonsCount * 2) / totalUnits);
        rawFractions['الأبناء الذكور'] = sonFrac;
        counts['الأبناء الذكور'] = sonsCount;
        shareDescriptions['الأبناء الذكور'] = daughtersCount > 0
            ? 'الباقي تعصيباً (للذكر مثل حظ الأنثيين)'
            : 'الباقي تعصيباً بالنفس بعد أصحاب الفروض';
        evidences['الأبناء الذكور'] = 'قوله تعالى: ﴿يُوصِيكُمُ اللَّهُ فِي أَوْلَادِكُمْ لِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ﴾ [النساء: ١١].';

        if (daughtersCount > 0) {
          final daughterFrac = remainder * (daughtersCount / totalUnits);
          rawFractions['البنات'] = daughterFrac;
          counts['البنات'] = daughtersCount;
          shareDescriptions['البنات'] = 'تعصيباً بالغير مع الأبناء (للذكر مثل حظ الأنثيين)';
          evidences['البنات'] = 'قوله تعالى: ﴿يُوصِيكُمُ اللَّهُ فِي أَوْلَادِكُمْ لِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ﴾ [النساء: ١١].';
        }
        remainder = 0.0;
      } else if (hasFather) {
        rawFractions['الأب'] = (rawFractions['الأب'] ?? 0.0) + remainder;
        counts['الأب'] = 1;
        if (!shareDescriptions.containsKey('الأب')) {
          shareDescriptions['الأب'] = 'الباقي تعصيباً بالنفس لعدم الفرع الوارث';
          evidences['الأب'] = 'حديث ابن عباس المتفق عليه: «ألحقوا الفرائض بأهلها فما بقي فهو لأولى رجل ذكر».';
        }
        remainder = 0.0;
      } else if (!hasMaleAscendantOrDescendant && fullBrothersCount > 0) {
        final totalUnits = (fullBrothersCount * 2) + fullSistersCount;
        final broFrac = remainder * ((fullBrothersCount * 2) / totalUnits);
        rawFractions['الإخوة الأشقاء'] = broFrac;
        counts['الإخوة الأشقاء'] = fullBrothersCount;
        shareDescriptions['الإخوة الأشقاء'] = fullSistersCount > 0
            ? 'الباقي تعصيباً (للذكر مثل حظ الأنثيين)'
            : 'الباقي تعصيباً بالنفس';
        evidences['الإخوة الأشقاء'] = 'قوله تعالى: ﴿وَإِن كَانُوا إِخْوَةً رِّجَالًا وَنِسَاءً فَلِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ﴾ [النساء: ١٧٦].';

        if (fullSistersCount > 0) {
          final sisFrac = remainder * (fullSistersCount / totalUnits);
          rawFractions['الأخوات الشقيقات'] = sisFrac;
          counts['الأخوات الشقيقات'] = fullSistersCount;
          shareDescriptions['الأخوات الشقيقات'] = 'تعصيباً بالغير مع الإخوة الأشقاء';
          evidences['الأخوات الشقيقات'] = 'قوله تعالى: ﴿وَإِن كَانُوا إِخْوَةً رِّجَالًا وَنِسَاءً فَلِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ﴾ [النساء: ١٧٦].';
        }
        remainder = 0.0;
      } else if (rawFractions.isNotEmpty) {
        // Radd (الرد على أصحاب الفروض غير الزوجين)
        final nonSpouseKeys = rawFractions.keys
            .where((k) => k != 'الزوج' && k != 'الزوجة / الزوجات')
            .toList();
        if (nonSpouseKeys.isNotEmpty) {
          hasRadd = true;
          final nonSpouseSum = nonSpouseKeys.fold(0.0, (a, k) => a + rawFractions[k]!);
          if (nonSpouseSum > 0) {
            for (final k in nonSpouseKeys) {
              rawFractions[k] = rawFractions[k]! + remainder * (rawFractions[k]! / nonSpouseSum);
              shareDescriptions[k] = '${shareDescriptions[k]} + الرد لعدم العاصب';
            }
          }
        }
      }
    }

    final List<HeirShareResult> results = [];
    for (final entry in rawFractions.entries) {
      final name = entry.key;
      final frac = entry.value;
      final cnt = counts[name] ?? 1;
      final tot = netEstate * frac;
      results.add(
        HeirShareResult(
          heirNameAr: name,
          count: cnt,
          shareTypeAr: shareDescriptions[name] ?? 'نصيب شرعي مقدر',
          percentage: frac * 100.0,
          totalAmount: tot,
          amountPerPerson: cnt > 0 ? tot / cnt : tot,
          quranicEvidence: evidences[name] ?? 'آيات المواريث في سورة النساء',
        ),
      );
    }

    return MawarithCalculationSummary(
      grossEstate: effectiveGross,
      debtsAndFuneral: effectiveDebts,
      requestedBequest: effectiveBequest,
      allowedBequest: allowedBequest,
      netDistributableEstate: netEstate,
      shares: results,
      hasAwl: hasAwl,
      hasRadd: hasRadd,
    );
  }
}

extension MawarithCalculatorServiceInstanceExt on MawarithCalculatorService {
  MawarithCalculationSummary calculate({
    double? grossEstate,
    double? estateValue,
    double debts = 0.0,
    double debtsAndFuneral = 0.0,
    double funeralExpenses = 0.0,
    double bequest = 0.0,
    double bequestAmount = 0.0,
    String spouseStatus = 'none',
    bool hasHusband = false,
    int wivesCount = 0,
    bool hasFather = false,
    bool hasMother = false,
    int sonsCount = 0,
    int daughtersCount = 0,
    int fullBrothersCount = 0,
    int fullSistersCount = 0,
  }) =>
      MawarithCalculatorService.calculate(
        grossEstate: grossEstate,
        estateValue: estateValue,
        debts: debts,
        debtsAndFuneral: debtsAndFuneral,
        funeralExpenses: funeralExpenses,
        bequest: bequest,
        bequestAmount: bequestAmount,
        spouseStatus: spouseStatus,
        hasHusband: hasHusband,
        wivesCount: wivesCount,
        hasFather: hasFather,
        hasMother: hasMother,
        sonsCount: sonsCount,
        daughtersCount: daughtersCount,
        fullBrothersCount: fullBrothersCount,
        fullSistersCount: fullSistersCount,
      );
}
