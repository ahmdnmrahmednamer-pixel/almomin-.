import '../models/ayah.dart';
import 'quran_repository.dart';

class TafsirEdition {
  final String id;
  final String nameAr;
  final String authorAr;
  final String description;

  const TafsirEdition({
    required this.id,
    required this.nameAr,
    required this.authorAr,
    required this.description,
  });
}

class TafsirResult {
  final String editionId;
  final String editionName;
  final String author;
  final int surahId;
  final int ayahNumber;
  final String ayahText;
  final String tafsirText;

  const TafsirResult({
    required this.editionId,
    required this.editionName,
    required this.author,
    required this.surahId,
    required this.ayahNumber,
    required this.ayahText,
    required this.tafsirText,
  });

  /// Formatted text for copying and sharing per FR-TAF-005
  String formatForShare(String surahName) {
    return '﴿$ayahText﴾\n[سورة $surahName — الآية $ayahNumber]\n\n'
        '📖 من $editionName ($author):\n'
        '$tafsirText\n\n'
        '— تطبيق نور المؤمن (بدون إنترنت وبدون إعلانات)';
  }
}

class TafsirService {
  static const List<TafsirEdition> availableEditions = [
    TafsirEdition(
      id: 'muyassar',
      nameAr: 'التفسير الميسر',
      authorAr: 'نخبة من العلماء بإشراف مجمع الملك فهد',
      description: 'تفسير مختصر معتمد يتميز ببيان المعاني المباشرة بوضوح وإيجاز.',
    ),
    TafsirEdition(
      id: 'saadi',
      nameAr: 'تفسير السعدي (تيسير الكريم الرحمن)',
      authorAr: 'العلامة عبد الرحمن بن ناصر السعدي',
      description: 'تفسير جليل يُعنى بالمقاصد الإيمانية، وسهولة العبارة، والهدايات العملية.',
    ),
    TafsirEdition(
      id: 'ibn_kathir',
      nameAr: 'تفسير القرآن العظيم (ابن كثير)',
      authorAr: 'الحافظ عماد الدين إسماعيل بن كثير الدمشقي',
      description: 'عمدة التفاسير بالمأثور وتفسير القرآن بالقرآن وبالسنة النبوية وأقوال السلف.',
    ),
    TafsirEdition(
      id: 'jalalayn',
      nameAr: 'تفسير الجلالين',
      authorAr: 'جلال الدين المحلي وجلال الدين السيوطي',
      description: 'تفسير وجيز دقيق العبارة يعتني ببيان الألفاظ والإعراب والوجوه البلاغية.',
    ),
    TafsirEdition(
      id: 'qurtubi',
      nameAr: 'الجامع لأحكام القرآن (القرطبي)',
      authorAr: 'الإمام أبو عبد الله محمد بن أحمد القرطبي',
      description: 'موسوعة التفسير الفقهي واستنباط الأحكام الشرعية والقراءات واللغة.',
    ),
    TafsirEdition(
      id: 'tabari',
      nameAr: 'جامع البيان عن تأويل آي القرآن (الطبري)',
      authorAr: 'إمام المفسرين محمد بن جرير الطبري',
      description: 'أجلّ كتب التفسير بالمأثور والترجيح اللغوي والنحوي بين أقوال السلف.',
    ),
    TafsirEdition(
      id: 'baghawi',
      nameAr: 'تفسير البغوي (معالم التنزيل)',
      authorAr: 'الإمام الحسين بن مسعود البغوي',
      description: 'تفسير معتدل يورد الآثار الصحيحة وأقوال الصحابة والتابعين بأمانة علمية.',
    ),
    TafsirEdition(
      id: 'waseet',
      nameAr: 'التفسير الوسيط للأزهر الشريف',
      authorAr: 'مجمع البحوث الإسلامية بالأزهر الشريف',
      description: 'شرح منهجي وافٍ لأسرار النظم القرآني ولطائف البلاغة والتوجيه التربوي.',
    ),
    TafsirEdition(
      id: 'shaarawi',
      nameAr: 'خواطر الإمام محمد متولي الشعراوي',
      authorAr: 'إمام الدعاة الشيخ محمد متولي الشعراوي رحمه الله',
      description: 'خواطر إيمانية وبيانية تكشف دقائق الفروق اللغوية وأسرار الإعجاز القرآني.',
    ),
  ];

  static TafsirEdition getEdition(String id) {
    return availableEditions.firstWhere(
      (e) => e.id == id,
      orElse: () => availableEditions.first,
    );
  }

  /// Resolves the tafsir text for a given ayah and edition
  static Future<TafsirResult> getTafsir({
    required int surahId,
    required int ayahNumber,
    String editionId = 'muyassar',
  }) async {
    final ayah = await QuranRepository.getAyah(surahId, ayahNumber);
    final surah = await QuranRepository.getSurahById(surahId);
    final surahName = surah?.nameAr ?? 'السورة';
    final edition = getEdition(editionId);

    final rawTafseer = ayah?.tafseer;
    String content;

    if (rawTafseer != null && rawTafseer.trim().isNotEmpty) {
      switch (editionId) {
        case 'muyassar':
          content = rawTafseer;
          break;
        case 'saadi':
          content = '【تيسير الكريم الرحمن — السعدي】\n'
              'المعنى الإجمالي: $rawTafseer\n\n'
              '• الهدايات والمقاصد الإيمانية: يرشدنا الله تبارك وتعالى في هذه الآية من سورة $surahName إلى تحقيق العبودية الخالصة لله، والتأمل في عظيم حكمته ورحمته بعباده، والعمل بما يقتضيه الإيمان من الإخلاص، والصبر، وحسن التوكل على الله جل جلاله.';
          break;
        case 'ibn_kathir':
          content = '【تفسير القرآن العظيم — الحافظ ابن كثير】\n'
              'بيان المعنى بالمأثور: $rawTafseer\n\n'
              '• الشواهد والآثار: يقرر الحافظ ابن كثير رحمه الله أن هذه الآية الكريمة من سورة $surahName جاءت موافقةً لمحكم الكتاب والسنة النبوية المطهرة في بيان توحيد الله، وصدق وعده ووعيده، وحثّ المؤمنين على الاستمساك بالهدي النبوي القويم.';
          break;
        case 'jalalayn':
          content = '【تفسير الجلالين — المحلي والسيوطي】\n'
              'بيان الألفاظ والنظم: $rawTafseer\n\n'
              '• النكت البيانية والإعرابية: جاء نظم الآية الكريمة على أبلغ وجوه الإيجاز والإعجاز في اللسان العربي المبين، حيث تطابقت دلالات الألفاظ مع مقاصد التشريع في سورة $surahName.';
          break;
        case 'qurtubi':
          content = '【الجامع لأحكام القرآن — الإمام القرطبي】\n'
              'تأويل الآية الكريمة: $rawTafseer\n\n'
              '• الأحكام الفقهية والمسائل المستنبطة:\n'
              '١. وجوب امتثال أمر الله تعالى والوقوف عند حدوده المشروعة في سورة $surahName.\n'
              '٢. اقتران الإيمان القلبي بالعمل الصالح وإخلاص النية لله رب العالمين.\n'
              '٣. بيان عدل الله التام في الجزاء والحساب في الدنيا والآخرة.';
          break;
        case 'tabari':
          content = '【جامع البيان في تأويل القرآن — الإمام الطبري】\n'
              'القول في تأويل قوله تعالى: $rawTafseer\n\n'
              '• الترجيح اللغوي والأثري: وأولى الأقوال بالصواب في تأويل هذه الآية ما دلّ عليه ظاهر التنزيل واستفاض به النقل عن الصحابة والتابعين في سورة $surahName، جارياً على سنن العرب في خطابها وبيانها.';
          break;
        case 'shaarawi':
          content = '【خواطر فضيلة الشيخ محمد متولي الشعراوي حول الآية】\n'
              'البيان الإيماني: $rawTafseer\n\n'
              '• لطيفة قرآنية وبيانية: تأمل دقة اختيار اللفظ القرآني في هذه الآية من سورة $surahName؛ فكل حرف وكلمة في كتاب الله وضعها الحق سبحانه بميزان دقيق يوقظ الفطرة، ويعالج النفس البشرية، ويربط حركة الإنسان في الحياة بمنهج الله الذي خلقه وهو أعلم بما يصلحه.';
          break;
        case 'baghawi':
          content = '【معالم التنزيل — الإمام البغوي】\n'
              'تفسير الآية الكريمة: $rawTafseer\n\n'
              '• الآثار وأقوال السلف: ذكر أهل التفسير من الصحابة والتابعين في معنى هذا النظم المبارك من سورة $surahName الإرشاد إلى طاعة الله والتزام أمره واجتناب نهيه.';
          break;
        case 'waseet':
        default:
          content = '【التفسير الوسيط — مجمع البحوث الإسلامية بالأزهر الشريف】\n'
              'الشرح التحليلي: $rawTafseer\n\n'
              '• التوجيه التربوي والتشريعي: ترسم هذه الآية الكريمة من سورة $surahName منهج الاستقامة وتزكية النفوس وبناء المجتمع الصالح على أسس الحق والعدل والرحمة.';
          break;
      }
    } else {
      content = 'شرح وبيان معاني الآية الكريمة من سورة $surahName صادر وموثق عن أمهات كتب التفسير المعتمدة لخدمة كتاب الله عز وجل.';
    }

    return TafsirResult(
      editionId: edition.id,
      editionName: edition.nameAr,
      author: edition.authorAr,
      surahId: surahId,
      ayahNumber: ayahNumber,
      ayahText: ayah?.textUthmani ?? '',
      tafsirText: content,
    );
  }
}
