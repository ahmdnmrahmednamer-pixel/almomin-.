import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نموذج خطوة من مناسك الحج أو العمرة
class ManasikStep {
  final String id;
  final String ritualType; // 'umrah' or 'hajj'
  final int order;
  final String title;
  final String location;
  final String ruling; // 'ركن', 'واجب', 'سنة مؤكدة'
  final String description;
  final String propheticDua;
  final String sunnahNotes;

  const ManasikStep({
    required this.id,
    required this.ritualType,
    required this.order,
    required this.title,
    required this.location,
    required this.ruling,
    required this.description,
    required this.propheticDua,
    required this.sunnahNotes,
  });
}

/// نموذج شوط من أشواط الطواف أو السعي السبعة
class RitualLapInfo {
  final int lapNumber; // 1..7
  final String titleAr;
  final String specificGuidance;
  final String recommendedDua;
  final String betweenCornersDua;

  const RitualLapInfo({
    required this.lapNumber,
    required this.titleAr,
    required this.specificGuidance,
    required this.recommendedDua,
    this.betweenCornersDua =
        '﴿رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ﴾',
  });
}

/// خدمة رفيق الحاج والمعتمر الذكي وعدّاد الطواف والسعي
class HajjUmrahService extends ChangeNotifier {
  static final HajjUmrahService instance = HajjUmrahService._internal();
  HajjUmrahService._internal();

  static const List<ManasikStep> allSteps = [
    // --- مناسك العمرة خطوة بخطوة ---
    ManasikStep(
      id: 'umrah_1_ihram',
      ritualType: 'umrah',
      order: 1,
      title: '١. الإحرام من الميقات والتلبية',
      location: 'الميقات (رابغ/الجحفة لأهل مصر والشام، ذو الحليفة لأهل المدينة)',
      ruling: 'ركن',
      description:
          'الاغتسال والتطيب في البدن، ولبس إزار ورداء أبيضين للرجال، والملابس الساترة الفضفاضة للنساء، ثم عقد نية العمرة وبدء التلبية.',
      propheticDua:
          '«لَبَّيْكَ اللَّهُمَّ عُمْرَةً — لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ»',
      sunnahNotes:
          'يستمر المعتمر في التلبية حتى يشرع في استلام الحجر الأسود لبدء الطواف.',
    ),
    ManasikStep(
      id: 'umrah_2_tawaf',
      ritualType: 'umrah',
      order: 2,
      title: '٢. طواف العمرة (٧ أشواط حول الكعبة المشرفة)',
      location: 'المسجد الحرام — صحن المطاف',
      ruling: 'ركن',
      description:
          'يبدأ من الحجر الأسود ويجعل الكعبة عن يساره، ويطوف ٧ أشواط كاملة ينتهي كل شوط منها عند الحجر الأسود.',
      propheticDua:
          'عند الحجر الأسود: «بِسْمِ اللَّهِ وَاللَّهُ أَكْبَرُ» وبين الركن اليماني والحجر الأسود: ﴿رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ﴾',
      sunnahNotes:
          'يسن للرجل في طواف القدوم/العمرة الاضطباع في جميع الأشواط، والرَّمَل (الإسراع مع مقاربة الخطى) في الأشواط الثلاثة الأولى.',
    ),
    ManasikStep(
      id: 'umrah_3_maqam',
      ritualType: 'umrah',
      order: 3,
      title: '٣. صلاة ركعتي الطواف والشرب من ماء زمزم',
      location: 'خلف مقام إبراهيم عليه السلام أو في أي مكان بالحرم',
      ruling: 'سنة مؤكدة',
      description:
          'بعد إتمام الأشواط السبعة يغطي الرجل كتفيه ويصلي ركعتين خلف مقام إبراهيم إن تيسر، ثم يشرب من ماء زمزم ويتضلع منه.',
      propheticDua:
          '﴿وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى﴾ — يقرأ في الأولى الفاتحة و﴿قُلْ يَا أَيُّهَا الْكَافِرُونَ﴾ وفي الثانية الفاتحة و﴿قُلْ هُوَ اللَّهُ أَحَدٌ﴾.',
      sunnahNotes:
          'ماء زمزم لما شُرب له؛ فادعُ الله بالعلم النافع والرزق الواسع والشفاء من كل داء.',
    ),
    ManasikStep(
      id: 'umrah_4_sai',
      ritualType: 'umrah',
      order: 4,
      title: '٤. السعي بين الصفا والمروة (٧ أشواط)',
      location: 'المسعى — من جبل الصفا إلى جبل المروة',
      ruling: 'ركن',
      description:
          'يبدأ بالصفا ويختم بالمروة (الذهاب من الصفا للمروة شوط ١، والعودة من المروة للصفا شوط ٢، وهكذا حتى الشوط السابع عند المروة).',
      propheticDua:
          'عند الصعود على الصفا والمروة: «إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ... اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ، أَنْجَزَ وَعْدَهُ، وَنَصَرَ عَبْدَهُ، وَهَزَمَ الْأَحْزَابَ وَحْدَهُ»',
      sunnahNotes:
          'يسن للرجال فقط الهرولة بين العلمين الأخضرين في الأشواط السبعة.',
    ),
    ManasikStep(
      id: 'umrah_5_tahallul',
      ritualType: 'umrah',
      order: 5,
      title: '٥. الحلق أو التقصير والتحلل من الإحرام',
      location: 'خارج المسعى',
      ruling: 'واجب',
      description:
          'حلق شعر الرأس بالكامل للرجل أو تقصيره من جميع جوانبه (والحلق أفضل)، وتقصر المرأة من أطراف شعرها قدر أنملة.',
      propheticDua:
          'دعا النبي ﷺ للمحلّقين ثلاثاً وللمقصرين مرة: «اللَّهُمَّ ارْحَمِ الْمُحَلِّقِينَ».',
      sunnahNotes:
          'بهذا تكتمل العمرة ويحل للمعتمر كل شيء حُرّم عليه بالإحرام.',
    ),

    // --- مناسك الحج خطوة بخطوة ---
    ManasikStep(
      id: 'hajj_1_tarwiyah',
      ritualType: 'hajj',
      order: 1,
      title: '١. يوم التروية (٨ ذو الحجة) — الإحرام والتوجه إلى منى',
      location: 'مكة المكرمة ثم مشعر منى',
      ruling: 'سنة مؤكدة',
      description:
          'يحرم الحاج المتمتع بالحج ضحى اليوم الثامن من مكانه بمكة، ويتوجه إلى منى فيصلي بها الظهر والعصر والمغرب والعشاء والفجر قصراً بلا جمع.',
      propheticDua: '«لَبَّيْكَ اللَّهُمَّ حَجّاً» مع الإكثار من التلبية والذكر.',
      sunnahNotes: 'المبيت بمنى ليلة التاسع سنة مؤكدة اقتداءً بالنبي ﷺ.',
    ),
    ManasikStep(
      id: 'hajj_2_arafah',
      ritualType: 'hajj',
      order: 2,
      title: '٢. يوم عرفة (٩ ذو الحجة) — الوقوف بعرفة (الحج عرفة)',
      location: 'مشعر عرفات',
      ruling: 'ركن أعظم',
      description:
          'التوجه إلى عرفة بعد شروق شمس اليوم التاسع، وصلاة الظهر والعصر جمع تقديم وقصراً بأذان واحد وإقامتين، ثم التفرغ للدعاء والتضرع حتى غروب الشمس.',
      propheticDua:
          'خير الدعاء دعاء يوم عرفة: «لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ»',
      sunnahNotes:
          'احرص على استقبال القبلة ورفع اليدين والابتهال حتى تغيب الشمس تماماً.',
    ),
    ManasikStep(
      id: 'hajj_3_muzdalifah',
      ritualType: 'hajj',
      order: 3,
      title: '٣. ليلة النحر — الإفاضة إلى مزدلفة والمبيت بها',
      location: 'مشعر مزدلفة (المشعر الحرام)',
      ruling: 'واجب',
      description:
          'بعد غروب شمس عرفة ينفر الحجاج بسكينة إلى مزدلفة، فيصلون المغرب والعشاء جمع تأخير مع قصر العشاء، ويبيتون بها حتى الفجر.',
      propheticDua:
          '﴿فَإِذَا أَفَضْتُم مِّنْ عَرَفَاتٍ فَاذْكُرُوا اللَّهَ عِندَ الْمَشْعَرِ الْحَرَامِ﴾',
      sunnahNotes:
          'يجوز للضعفة والنساء وكبار السن الدفع من مزدلفة بعد منتصف الليل.',
    ),
    ManasikStep(
      id: 'hajj_4_nahr',
      ritualType: 'hajj',
      order: 4,
      title: '٤. يوم النحر (١٠ ذو الحجة) — رمي جمرة العقبة والنحر والحلق وطواف الإفاضة',
      location: 'منى ثم المسجد الحرام',
      ruling: 'ركن وواجبات',
      description:
          'أعمال يوم العيد أربعة مرتبة: (١) رمي جمرة العقبة الكبرى بـ ٧ حصيات، (٢) نحر الهدي للمتمتع والقارن، (٣) الحلق أو التقصير (التحلل الأصغر)، (٤) طواف الإفاضة والسعي (التحلل الأكبر).',
      propheticDua: 'يكبر مع رمي كل حصاة: «اللَّهُ أَكْبَرُ» ويقطع التلبية عند بدء الرمي.',
      sunnahNotes:
          'ما سُئل النبي ﷺ يوم النحر عن شيء قُدّم ولا أُخّر إلا قال: «افْعَلْ وَلَا حَرَجَ».',
    ),
    ManasikStep(
      id: 'hajj_5_tashreeq',
      ritualType: 'hajj',
      order: 5,
      title: '٥. أيام التشريق (١١ و١٢ و١٣ ذو الحجة) وطواف الوداع',
      location: 'مشعر منى ثم الكعبة المشرفة',
      ruling: 'واجب',
      description:
          'المبيت بمنى ليالي التشريق، ورمي الجمرات الثلاث بعد الزوال (الصغرى، ثم الوسطى، ثم جمرة العقبة الكبرى، كل واحدة بـ ٧ حصيات)، ثم طواف الوداع قبل مغادرة مكة.',
      propheticDua:
          'يقف للدعاء طويلاً مستقبلاً القبلة بعد رمي الصغرى والوسطى، ولا يقف بعد جمرة العقبة.',
      sunnahNotes:
          'طواف الوداع آخر عهد الحاج بالبيت الحرام، ويسقط عن الحائض والنفساء.',
    ),
  ];

  static const List<RitualLapInfo> tawafLaps = [
    RitualLapInfo(
      lapNumber: 1,
      titleAr: 'الشوط الأول من الطواف',
      specificGuidance:
          'استقبل الحجر الأسود وكبّر، واضطبع بردائك، وارمُل (أسرع الخطى للرجال) في هذا الشوط.',
      recommendedDua:
          '«سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ»',
    ),
    RitualLapInfo(
      lapNumber: 2,
      titleAr: 'الشوط الثاني من الطواف',
      specificGuidance:
          'كبّر عند محاذاة الحجر الأسود، واستمر في الرَّمَل للرجال مع الإكثار من الاستغفار.',
      recommendedDua:
          '«اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدِّينِ وَالدُّنْيَا وَالْآخِرَةِ»',
    ),
    RitualLapInfo(
      lapNumber: 3,
      titleAr: 'الشوط الثالث من الطواف',
      specificGuidance:
          'آخر أشواط الرَّمَل الثلاثة للرجال؛ استشعر عظمة البيت العتيق وأكثر من الثناء على الله.',
      recommendedDua:
          '«اللَّهُمَّ يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ، وَيَا مُصَرِّفَ الْقُلُوبِ صَرِّفْ قَلْبِي عَلَى طَاعَتِكَ»',
    ),
    RitualLapInfo(
      lapNumber: 4,
      titleAr: 'الشوط الرابع من الطواف',
      specificGuidance:
          'امشِ مشياً عادياً بسكينة ووقار من بداية هذا الشوط حتى نهاية الطواف.',
      recommendedDua:
          '«اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى»',
    ),
    RitualLapInfo(
      lapNumber: 5,
      titleAr: 'الشوط الخامس من الطواف',
      specificGuidance:
          'استلم الركن اليماني بيدك إن تيسر دون تقبيل ولا مزاحمة، وقل ربنا آتنا في الدنيا حسنة.',
      recommendedDua:
          '«اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ يَوْمَ يَقُومُ الْحِسَابُ»',
    ),
    RitualLapInfo(
      lapNumber: 6,
      titleAr: 'الشوط السادس من الطواف',
      specificGuidance:
          'ادعُ بجوامع الكلم وبما شئت من خيري الدنيا والآخرة لك ولأهلك وللمسلمين.',
      recommendedDua:
          '«اللَّهُمَّ إِنِّي أَسْأَلُكَ رِضَاكَ وَالْجَنَّةَ، وَأَعُوذُ بِكَ مِنْ سَخَطِكَ وَالنَّارِ»',
    ),
    RitualLapInfo(
      lapNumber: 7,
      titleAr: 'الشوط السابع والأخير من الطواف',
      specificGuidance:
          'ينتهي الشوط السابع عند محاذاة الحجر الأسود، ثم غطِّ كتفيك وتوجه لصلاة ركعتي الطواف.',
      recommendedDua:
          '«اللَّهُمَّ تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ، وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ»',
    ),
  ];

  static const List<RitualLapInfo> saiLaps = [
    RitualLapInfo(
      lapNumber: 1,
      titleAr: 'الشوط الأول (من الصفا إلى المروة)',
      specificGuidance:
          'ابدأ بالصفا، استقبل القبلة وكبّر ثلاثاً وادعُ، ثم اسعَ نحو المروة وهرول بين العلمين الأخضرين (للرجال).',
      recommendedDua:
          '«اللَّهُمَّ اعْصِمْنَا بِدِينِكَ وَطَوَاعِيَتِكَ وَطَوَاعِيَةِ رَسُولِكَ ﷺ وَجَنِّبْنَا حُدُودَكَ»',
    ),
    RitualLapInfo(
      lapNumber: 2,
      titleAr: 'الشوط الثاني (من المروة إلى الصفا)',
      specificGuidance:
          'قف على المروة مستقبل القبلة وكبّر وادعُ، ثم ارجع إلى الصفا.',
      recommendedDua:
          '«رَبِّ اغْفِرْ وَارْحَمْ إِنَّكَ أَنْتَ الْأَعَزُّ الْأَكْرَمُ»',
    ),
    RitualLapInfo(
      lapNumber: 3,
      titleAr: 'الشوط الثالث (من الصفا إلى المروة)',
      specificGuidance:
          'من الصفا إلى المروة مع الهرولة للرجال بين العلمين الأخضرين.',
      recommendedDua:
          '«اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ الْخَيْرِ كُلِّهِ عَاجِلِهِ وَآجِلِهِ مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ»',
    ),
    RitualLapInfo(
      lapNumber: 4,
      titleAr: 'الشوط الرابع (من المروة إلى الصفا)',
      specificGuidance: 'من المروة إلى الصفا مع الإكثار من الذكر وتلاوة القرآن.',
      recommendedDua:
          '«اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي»',
    ),
    RitualLapInfo(
      lapNumber: 5,
      titleAr: 'الشوط الخامس (من الصفا إلى المروة)',
      specificGuidance: 'من الصفا إلى المروة، استشعر سعي أمنا هاجر وتوكلها على الله.',
      recommendedDua:
          '«اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ»',
    ),
    RitualLapInfo(
      lapNumber: 6,
      titleAr: 'الشوط السادس (من المروة إلى الصفا)',
      specificGuidance: 'من المروة إلى الصفا، ألحّ على الله في الدعاء بالقبول.',
      recommendedDua:
          '«رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَاماً»',
    ),
    RitualLapInfo(
      lapNumber: 7,
      titleAr: 'الشوط السابع والأخير (من الصفا إلى المروة)',
      specificGuidance:
          'يُختم السعي عند جبل المروة، وبانتهائه يتوجه المعتمر للحلق أو التقصير.',
      recommendedDua:
          '«اللَّهُمَّ تَقَبَّلْ سَعْيَنَا وَاجْعَلْهُ سَعْياً مَشْكُوراً وَذَنْباً مَغْفُوراً وَعَمَلاً مَقْبُولاً»',
    ),
  ];

  int _tawafLap = 0; // 0..7
  int _saiLap = 0; // 0..7
  Set<String> _completedStepIds = {};

  int get tawafLap => _tawafLap;
  int get saiLap => _saiLap;
  Set<String> get completedStepIds => _completedStepIds;
  bool get isTawafComplete => _tawafLap >= 7;
  bool get isSaiComplete => _saiLap >= 7;

  Future<void> init({bool forceReload = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _tawafLap = (prefs.getInt('hajj_tawaf_lap') ?? 0).clamp(0, 7);
    _saiLap = (prefs.getInt('hajj_sai_lap') ?? 0).clamp(0, 7);
    _completedStepIds =
        (prefs.getStringList('hajj_completed_steps') ?? []).toSet();
    notifyListeners();
  }

  Future<void> incrementTawafLap() async {
    if (_tawafLap < 7) {
      _tawafLap++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hajj_tawaf_lap', _tawafLap);
      notifyListeners();
    }
  }

  Future<void> resetTawaf() async {
    _tawafLap = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hajj_tawaf_lap', 0);
    notifyListeners();
  }

  Future<void> incrementSaiLap() async {
    if (_saiLap < 7) {
      _saiLap++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hajj_sai_lap', _saiLap);
      notifyListeners();
    }
  }

  Future<void> resetSai() async {
    _saiLap = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hajj_sai_lap', 0);
    notifyListeners();
  }

  Future<void> toggleStepCompleted(String stepId) async {
    if (_completedStepIds.contains(stepId)) {
      _completedStepIds.remove(stepId);
    } else {
      _completedStepIds.add(stepId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'hajj_completed_steps', _completedStepIds.toList());
    notifyListeners();
  }

  List<ManasikStep> getStepsByType(String ritualType) {
    return allSteps.where((s) => s.ritualType == ritualType).toList();
  }
}
