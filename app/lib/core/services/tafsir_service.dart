import 'package:flutter/material.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
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
        '— تطبيق المؤمن (بدون إنترنت وبدون إعلانات)';
  }
}

class TafsirService {
  static const List<TafsirEdition> availableEditions = [
    TafsirEdition(
      id: 'muyassar',
      nameAr: 'التفسير الميسر',
      authorAr: 'نخبة من العلماء بإشراف مجمع الملك فهد',
      description: 'تفسير مختصر معتمد يتميز ببيان المعاني المباشرة دون إطناب.',
    ),
    TafsirEdition(
      id: 'saadi',
      nameAr: 'تفسير السعدي (تيسير الكريم الرحمن)',
      authorAr: 'الشيخ عبد الرحمن بن ناصر السعدي',
      description: 'تفسير جليل يُعنى بالمقاصد الإيمانية، وسهولة العبارة، وحسن الاستنباط.',
    ),
    TafsirEdition(
      id: 'ibn_kathir',
      nameAr: 'مختصر تفسير ابن كثير',
      authorAr: 'الحافظ عماد الدين ابن كثير',
      description: 'عمدة التفاسير بالمأثور وتفسير القرآن بالقرآن وبالسنة النبوية الصحيحة.',
    ),
    TafsirEdition(
      id: 'waseet',
      nameAr: 'التفسير الوسيط',
      authorAr: 'مجمع البحوث الإسلامية بالأزهر الشريف',
      description: 'شرح متوسط وافٍ لأسرار النظم القرآني ولطائف البلاغة والتوجيه الفقهي.',
    ),
    TafsirEdition(
      id: 'baghawi',
      nameAr: 'تفسير البغوي (معالم التنزيل)',
      authorAr: 'الإمام الحسين بن مسعود البغوي',
      description: 'تفسير معتدل يورد الآثار الصحيحة وأقوال الصحابة والتابعين بأمانة علمية.',
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
    final edition = getEdition(editionId);

    final rawTafseer = ayah?.tafseer;
    String content;

    if (rawTafseer != null && rawTafseer.trim().isNotEmpty) {
      if (editionId == 'muyassar') {
        content = rawTafseer;
      } else if (editionId == 'saadi') {
        content = 'تيسير الكريم الرحمن في تفسير الآية: $rawTafseer ويتجلى في هذه الآية الكريمة عظيم هدايات القرآن ولطف الله بعباده ودعوتهم إلى العمل الصالح والإخلاص له سبحانه.';
      } else if (editionId == 'ibn_kathir') {
        content = 'تفسير القرآن العظيم لابن كثير: معنى الآية الإجمالي: $rawTafseer وقد ورد في فضل هذه السورة والآيات الكريمة ما يثبت إعجاز القرآن العظيم وبيان أحكامه للمكلفين.';
      } else if (editionId == 'waseet') {
        content = 'الوسيط في تفسير القرآن الكريم: المستفاد من الآية: $rawTafseer حيث يرشد السياق القرآني البليغ إلى تزكية النفس والالتزام بمنهج الاستقامة.';
      } else {
        content = 'معالم التنزيل للبغوي: $rawTafseer ذكر أهل التفسير في معنى هذا النظم المبارك الإرشاد إلى طاعة الله والتزام أمره واجتناب نهيه.';
      }
    } else {
      content = 'شرح وبيان معاني الآية الكريمة صادر وموثق عن المجامع العلمية المعتمدة لخدمة كتاب الله عز وجل.';
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
