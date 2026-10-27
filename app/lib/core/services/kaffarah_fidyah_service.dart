import 'package:flutter/foundation.dart';

/// نتيجة حساب زكاة الفطر وفدية الصيام وكفارة اليمين
class KaffarahCalculationResult {
  final String calculationType;
  final String summaryTitle;
  final double totalCashAmountEgp;
  final double totalFoodWeightKg;
  final int beneficiariesOrDaysCount;
  final String alternativeFastOption;
  final String shariahEvidence;
  final String fiqhNotes;

  const KaffarahCalculationResult({
    required this.calculationType,
    required this.summaryTitle,
    required this.totalCashAmountEgp,
    required this.totalFoodWeightKg,
    required this.beneficiariesOrDaysCount,
    required this.alternativeFastOption,
    required this.shariahEvidence,
    required this.fiqhNotes,
  });
}

/// خدمة حاسبة زكاة الفطر وفدية الصيام وكفارة اليمين والنذر
class KaffarahFidyahService extends ChangeNotifier {
  static final KaffarahFidyahService instance =
      KaffarahFidyahService._internal();
  KaffarahFidyahService._internal();

  /// حساب زكاة الفطر لعدد أفراد الأسرة
  /// الصاع النبوي = 2.5 كجم تقريباً من غالب قوت البلد
  KaffarahCalculationResult calculateZakatAlFitr({
    required int familyMembersCount,
    required double valuePerPersonEgp,
  }) {
    final safeMembers = familyMembersCount.clamp(1, 100);
    final safeValue = valuePerPersonEgp.clamp(10.0, 10000.0);
    final totalCash = safeMembers * safeValue;
    final totalKg = safeMembers * 2.5;

    return KaffarahCalculationResult(
      calculationType: 'zakat_fitr',
      summaryTitle: 'إجمالي زكاة الفطر لـ $safeMembers فرداً',
      totalCashAmountEgp: totalCash,
      totalFoodWeightKg: totalKg,
      beneficiariesOrDaysCount: safeMembers,
      alternativeFastOption:
          'تجب على كل مسلم كبير أو صغير، وتُخرج قبل صلاة عيد الفطر.',
      shariahEvidence:
          'عن ابن عمر رضي الله عنهما قال: «فَرَضَ رَسُولُ اللَّهِ ﷺ زَكَاةَ الْفِطْرِ صَاعاً مِنْ تَمْرٍ أَوْ صَاعاً مِنْ شَعِيرٍ عَلَى الْعَبْدِ وَالْحُرِّ، وَالذَّكَرِ وَالأُنْثَى، وَالصَّغِيرِ وَالْكَبِيرِ مِنَ الْمُسْلِمِينَ» (متفق عليه).',
      fiqhNotes:
          'يجوز إخراجها حبوباً (٢.٥ كجم للفرد) عند الجمهور، ويجوز إخراجها نقداً تيسيراً على الفقراء كما هو معتمد عند الحنفية ودار الإفتاء المصرية.',
    );
  }

  /// حساب فدية الصيام للعاجز عجزاً دائماً (الشيخ الكبير والمريض مرضاً مزمناً لا يُرجى برؤه)
  KaffarahCalculationResult calculateFastingFidyah({
    required int missedDaysCount,
    required double mealCostPerDayEgp,
  }) {
    final safeDays = missedDaysCount.clamp(1, 365);
    final safeMealCost = mealCostPerDayEgp.clamp(10.0, 5000.0);
    final totalCash = safeDays * safeMealCost;
    final totalKg = safeDays * 1.25; // نصف صاع أو مدّ من طعام لكل يوم

    return KaffarahCalculationResult(
      calculationType: 'fidyah_fasting',
      summaryTitle: 'إجمالي فدية الصيام عن $safeDays يوماً',
      totalCashAmountEgp: totalCash,
      totalFoodWeightKg: totalKg,
      beneficiariesOrDaysCount: safeDays,
      alternativeFastOption:
          'تجب الفدية فقط على العاجز عجزاً دائماً؛ أما المسافر والمريض مرضاً مؤقتاً والحامل والمرضع عند القدرة فيجب عليهم القضاء.',
      shariahEvidence:
          'قال الله تعالى: ﴿وَعَلَى الَّذِينَ يُطِيقُونَهُ فِدْيَةٌ طَعَامُ مِسْكِينٍ﴾ [البقرة: ١٨٤] — قال ابن عباس رضي الله عنهما: نزلت في الشيخ الكبير والمرأة الكبيرة لا يستطيعان أن يصوما، فيطعمان مكان كل يوم مسكيناً.',
      fiqhNotes:
          'مقدار الفدية إطعام مسكين وجبة مشبعة عن كل يوم، أو إخراج قيمتها نقداً للفقراء.',
    );
  }

  /// حساب كفارة اليمين المنعقدة (أو كفارة النذر عند الحنث)
  /// إطعام 10 مساكين أو كسوتهم أو تحرير رقبة، فمن لم يجد فصيام 3 أيام
  KaffarahCalculationResult calculateOathKaffarah({
    required int oathsCount,
    required double mealCostPerPoorPersonEgp,
  }) {
    final safeOaths = oathsCount.clamp(1, 50);
    final safeMealCost = mealCostPerPoorPersonEgp.clamp(10.0, 5000.0);
    final totalPoorPeople = safeOaths * 10;
    final totalCash = totalPoorPeople * safeMealCost;
    final totalKg = totalPoorPeople * 1.5;

    return KaffarahCalculationResult(
      calculationType: 'kaffarah_oath',
      summaryTitle:
          'كفارة $safeOaths يمين (إطعام $totalPoorPeople مسكيناً)',
      totalCashAmountEgp: totalCash,
      totalFoodWeightKg: totalKg,
      beneficiariesOrDaysCount: totalPoorPeople,
      alternativeFastOption:
          'فمن لم يجد القدرة المالية على إطعام ١٠ مساكين أو كسوتهم، فصيام ٣ أيام عن كل يمين (ويُستحب تتابعها).',
      shariahEvidence:
          'قال الله تعالى: ﴿لَا يُؤَاخِذُكُمُ اللَّهُ بِاللَّغْوِ فِي أَيْمَانِكُمْ وَلَٰكِن يُؤَاخِذُكُم بِمَا عَقَّدتُّمُ الْأَيْمَانَ ۖ فَكَفَّارَتُهُ إِطْعَامُ عَشَرَةِ مَسَاكِينَ مِنْ أَوْسَطِ مَا تُطْعِمُونَ أَهْلِيكُمْ أَوْ كِسْوَتُهُمْ أَوْ تَحْرِيرُ رَقَبَةٍ ۖ فَمَن لَّمْ يَجِدْ فَصِيَامُ ثَلَاثَةِ أَيَّامٍ ۚ ذَٰلِكَ كَفَّارَةُ أَيْمَانِكُمْ إِذَا حَلَفْتُمْ﴾ [المائدة: ٨٩].',
      fiqhNotes:
          'لا يجزئ الانتقال إلى صيام الثلاثة أيام إلا عند العجز المالي عن إطعام عشرة مساكين أو كسوتهم.',
    );
  }
}
