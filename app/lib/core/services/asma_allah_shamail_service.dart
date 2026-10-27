import 'package:flutter/foundation.dart';
import '../models/islamic_libraries_models.dart';
import '../text/arabic_normalizer.dart';

/// خدمة مكتبة أسماء الله الحسنى والشمائل المحمدية والأخلاق النبوية
class AsmaAllahShamailService extends ChangeNotifier {
  static final AsmaAllahShamailService instance =
      AsmaAllahShamailService._internal();
  AsmaAllahShamailService._internal();

  static const List<AsmaAllahEntry> asmaAllahList = [
    AsmaAllahEntry(
      number: 1,
      nameAr: 'اللَّهُ',
      transliteration: 'Allah',
      meaningSummary:
          'العَلَم على الذات الإلهية المقدسة، المألوه المعبود بحق محبةً وتعظيماً وخضوعاً، الجامع لجميع صفات الكمال والجلال.',
      quranicReference: '﴿هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ﴾ [الحشر: 22]',
      tadabburAndImpact:
          'يمتلئ قلب المؤمن بالتوحيد الخالص فلا يتعلق قلبه إلا بالله رغبةً ورهبةً وتوكلاً.',
      duaaWithThisName:
          'اللهم إني أسألك بأنك أنت الله لا إله إلا أنت الأحد الصمد أن تملأ قلبي بمحبتك ومعرفتك وذكرك.',
    ),
    AsmaAllahEntry(
      number: 2,
      nameAr: 'الرَّحْمَٰنُ الرَّحِيمُ',
      transliteration: 'Ar-Rahman Ar-Rahim',
      meaningSummary:
          'الرحمن: ذو الرحمة الواسعة التي وسعت كل شيء في الدنيا؛ والرحيم: الموصل رحمته الخاصة لعباده المؤمنين في الدنيا والآخرة.',
      quranicReference: '﴿وَرَحْمَتِي وَسِعَتْ كُلَّ شَيْءٍ﴾ [الأعراف: 156]',
      tadabburAndImpact:
          'يورث حسن الظن بالله وعدم القنوط مهما عظمت الذنوب، مع التحلي بالرحمة بالخلق والضعفاء.',
      duaaWithThisName:
          'يا رحمن الدنيا والآخرة ورحيمهما، ارحمني رحمةً تغنيني بها عن رحمة من سواك.',
    ),
    AsmaAllahEntry(
      number: 3,
      nameAr: 'الْمَلِكُ الْقُدُّوسُ السَّلَامُ',
      transliteration: 'Al-Malik Al-Quddus As-Salam',
      meaningSummary:
          'المتصرف المطلق في ملكه، المنزه عن كل نقص وعيب، السالم من كل آفة ومانح السلام والأمن لعباده.',
      quranicReference: '﴿الْمَلِكُ الْقُدُّوسُ السَّلَامُ الْمُؤْمِنُ الْمُهَيْمِنُ﴾ [الحشر: 23]',
      tadabburAndImpact:
          'سكينة النفس وطمأنينتها بأن مقاليد الأمور بيد الملك الحق، ونشر السلام بين الناس.',
      duaaWithThisName:
          'اللهم أنت السلام ومنك السلام، تباركت يا ذا الجلال والإكرام، سلِّم قلبي وديني ودنياي.',
    ),
    AsmaAllahEntry(
      number: 4,
      nameAr: 'الْغَفَّارُ الْغَفُورُ التَّوَّابُ',
      transliteration: 'Al-Ghaffar Al-Ghafur At-Tawwab',
      meaningSummary:
          'الذي يغفر الذنوب مرة بعد مرة، ويستر العيوب في الدنيا والآخرة، ويوفق عباده للتوبة ثم يقبلها منهم.',
      quranicReference: '﴿وَإِنِّي لَغَفَّارٌ لِّمَن تَابَ وَآمَنَ وَعَمِلَ صَالِحًا﴾ [طه: 82]',
      tadabburAndImpact:
          'المبادرة الدائمة لتجديد التوبة والاستغفار، وستر عورات المسلمين والعفو عن المسيء.',
      duaaWithThisName:
          'ربِّ اغفر لي وتب عليَّ إنك أنت التواب الغفور الرحيم.',
    ),
    AsmaAllahEntry(
      number: 5,
      nameAr: 'الرَّزَّاقُ الْفَتَّاحُ الْعَلِيمُ',
      transliteration: 'Ar-Razzaq Al-Fattah Al-Alim',
      meaningSummary:
          'المتكفل بأرزاق الخلائق أجمعين (رزق الأبدان ورزق القلوب بالعلم والإيمان)، والذي يفتح مغاليق الأمور بحكمته وعلمه.',
      quranicReference: '﴿إِنَّ اللَّهَ هُوَ الرَّزَّاقُ ذُو الْقُوَّةِ الْمَتِينُ﴾ [الذاريات: 58]',
      tadabburAndImpact:
          'الأخذ بالأسباب المشروعة مع راحة القلب من همِّ الرزق، وطلب الفتح في العلم والعمل من الفتاح العليم.',
      duaaWithThisName:
          'يا فتاح يا عليم يا رزاق يا كريم، افتح لي أبواب فضلك ورزقك الحلال الطيب المبارك.',
    ),
    AsmaAllahEntry(
      number: 6,
      nameAr: 'اللَّطِيفُ الْخَبِيرُ',
      transliteration: 'Al-Latif Al-Khabir',
      meaningSummary:
          'العليم بدقائق الأمور وخفايا الصدور، الذي يوصل الخير والبر إلى عباده من طرقٍ خفية لا يحتسبونها.',
      quranicReference: '﴿أَلَا يَعْلَمُ مَنْ خَلَقَ وَهُوَ اللَّطِيفُ الْخَبِيرُ﴾ [الملك: 14]',
      tadabburAndImpact:
          'إدراك لطف الله الخفي في الأقدار والمحن، ومراقبة الله في السر والعلانية.',
      duaaWithThisName:
          'اللهم الطف بي في تيسير كل عسير، فإن تيسير كل عسير عليك يسير.',
    ),
    AsmaAllahEntry(
      number: 7,
      nameAr: 'الْحَفِيظُ الْوَكِيلُ الشَّافِي',
      transliteration: 'Al-Hafiz Al-Wakil Ash-Shafi',
      meaningSummary:
          'الذي يحفظ عباده وأعمالهم، والكفيل بأمور من توكل عليه وفوض أمره إليه، والشافي للقلوب والأبدان من كل سقم.',
      quranicReference: '﴿فَاللَّهُ خَيْرٌ حَافِظًا وَهُوَ أَرْحَمُ الرَّاحِمِينَ﴾ [يوسف: 64]',
      tadabburAndImpact:
          'حفظ حدود الله ليحفظك الله، والتوكل الصادق عليه عند الشدائد والأمراض.',
      duaaWithThisName:
          'حسبي الله ونعم الوكيل، اللهم رب الناس أذهب البأس اشفِ أنت الشافي لا شفاء إلا شفاؤك.',
    ),
    AsmaAllahEntry(
      number: 8,
      nameAr: 'الْحَيُّ الْقَيُّومُ ذُو الْجَلَالِ وَالْإِكْرَامِ',
      transliteration: 'Al-Hayy Al-Qayyum',
      meaningSummary:
          'الحي حياةً كاملة أزلية أبدية، القائم بنفسه المقيم لكل ما سواه؛ وهما الاسم الأعظم الذي إذا دُعي به أجاب.',
      quranicReference: '﴿اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ﴾ [البقرة: 255]',
      tadabburAndImpact:
          'افتقار العبد في كل طرفة عين إلى قيومية الله ومعونته وتثبيته.',
      duaaWithThisName:
          'يا حي يا قيوم برحمتك أستغيث، أصلح لي شأني كله ولا تكلني إلى نفسي طرفة عين.',
    ),
  ];

  static const List<PropheticShamailEntry> shamailList = [
    PropheticShamailEntry(
      id: 'shamail_appearance_face',
      category: 'خَلْقه وصفته ﷺ',
      title: 'صفة وجهه الشريف ونوره ﷺ وهيبته',
      hadithText:
          'عن البراء بن عازب رضي الله عنه قال: «كان رسول الله ﷺ أحسن الناس وجهاً وأحسنهم خَلْقاً، ليس بالطويل البائن ولا بالقصير»، وعن كعب بن مالك رضي الله عنه: «كان رسول الله ﷺ إذا سُرَّ استنار وجهه حتى كأنه قطعة قمر».',
      narratorAndSource: 'متفق عليه (البخاري ومسلم) والشمائل المحمدية للترمذي',
      practicalSunnah:
          'بشاشة الوجه والابتسامة في وجوه الناس؛ لقوله ﷺ: «تبسمك في وجه أخيك لك صدقة».',
    ),
    PropheticShamailEntry(
      id: 'shamail_home_humility',
      category: 'أخلاقه ورحمته ﷺ',
      title: 'هديه ﷺ في بيته ومع أهله وتواضعه',
      hadithText:
          'سُئلت أم المؤمنين عائشة رضي الله عنها: ما كان النبي ﷺ يصنع في بيته؟ قالت: «كان يكون في مهنة أهله (أي خدمة أهله)، فإذا حضرت الصلاة خرج إلى الصلاة»، وقالت: «كان يخيط ثوبه، ويخصف نعله، ويعمل ما يعمل الرجال في بيوتهم».',
      narratorAndSource: 'رواه البخاري وأحمد في المسند',
      practicalSunnah:
          'التواضع داخل البيت، ومعاونة الأهل، والرفق بالزوجة والأبناء؛ لقوله ﷺ: «خيركم خيركم لأهله وأنا خيركم لأهلي».',
    ),
    PropheticShamailEntry(
      id: 'shamail_worship_night',
      category: 'عبادته وخشوعه ﷺ',
      title: 'قيامه بالليل وشكره لربه عز وجل',
      hadithText:
          'عن المغيرة بن شعبة وعائشة رضي الله عنهما: أن النبي ﷺ كان يقوم من الليل حتى تتفطر قدماه، فقيل له: أتفعل هذا وقد غفر الله لك ما تقدم من ذنبك وما تأخر؟ فقال: «أفلا أكون عبداً شكوراً!».',
      narratorAndSource: 'متفق عليه (البخاري ومسلم)',
      practicalSunnah:
          'المحافظة على صلاة الوتر وركعات من قيام الليل ولو يسيرة شكراً لله على نعمه.',
    ),
    PropheticShamailEntry(
      id: 'shamail_speech_mercy',
      category: 'هديه اليومي وآدابه ﷺ',
      title: 'صفة كلامه ﷺ وحلمه وعفوه',
      hadithText:
          'قالت عائشة رضي الله عنها: «ما كان رسول الله ﷺ يسرد الحديث كسردكم هذا، ولكن كان يتكلم بكلامٍ بيِّنٍ فصلٍ يحفظه من جلس إليه»، و«ما خُيِّر رسول الله ﷺ بين أمرين إلا اختار أيسرهما ما لم يكن إثماً».',
      narratorAndSource: 'متفق عليه والترمذي في الشمائل',
      practicalSunnah:
          'الهدوء والتأني في الكلام، واختيار التيسير والرفق في معاملة الناس؛ فإن الرفق لا يكون في شيء إلا زانه.',
    ),
  ];

  List<AsmaAllahEntry> searchAsma(String query) {
    final norm = ArabicNormalizer.normalize(query.trim());
    if (norm.isEmpty) return asmaAllahList;
    return asmaAllahList.where((item) {
      final hay = ArabicNormalizer.normalize(
        '${item.nameAr} ${item.meaningSummary} ${item.tadabburAndImpact} ${item.duaaWithThisName}',
      );
      return hay.contains(norm);
    }).toList();
  }

  List<PropheticShamailEntry> searchShamail(String query) {
    final norm = ArabicNormalizer.normalize(query.trim());
    if (norm.isEmpty) return shamailList;
    return shamailList.where((item) {
      final hay = ArabicNormalizer.normalize(
        '${item.title} ${item.category} ${item.hadithText} ${item.practicalSunnah}',
      );
      return hay.contains(norm);
    }).toList();
  }
}
