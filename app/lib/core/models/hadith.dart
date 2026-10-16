class HadithBook {
  final String id;
  final String title;
  final String author;
  final String deathYear;
  final String description;
  final int hadithCount;
  final String iconName;

  const HadithBook({
    required this.id,
    required this.title,
    required this.author,
    required this.deathYear,
    required this.description,
    required this.hadithCount,
    required this.iconName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'deathYear': deathYear,
        'description': description,
        'hadithCount': hadithCount,
        'iconName': iconName,
      };

  factory HadithBook.fromJson(Map<String, dynamic> json) => HadithBook(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        deathYear: json['deathYear'] as String,
        description: json['description'] as String,
        hadithCount: json['hadithCount'] as int,
        iconName: json['iconName'] as String,
      );
}

class HadithItem {
  final int id;
  final String bookId;
  final int number;
  final String title;
  final String narrator;
  final String matn;
  final String grading; // e.g. "صحيح", "متفق عليه", "حسن"
  final String source; // e.g. "رواه البخاري ومسلم"
  final String explanation; // فوائد وشرح الحديث
  final String chapter; // اسم الباب

  const HadithItem({
    required this.id,
    required this.bookId,
    required this.number,
    required this.title,
    required this.narrator,
    required this.matn,
    required this.grading,
    required this.source,
    required this.explanation,
    required this.chapter,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'number': number,
        'title': title,
        'narrator': narrator,
        'matn': matn,
        'grading': grading,
        'source': source,
        'explanation': explanation,
        'chapter': chapter,
      };

  factory HadithItem.fromJson(Map<String, dynamic> json) => HadithItem(
        id: json['id'] as int,
        bookId: json['bookId'] as String,
        number: json['number'] as int,
        title: json['title'] as String,
        narrator: json['narrator'] as String,
        matn: json['matn'] as String,
        grading: json['grading'] as String,
        source: json['source'] as String,
        explanation: json['explanation'] as String,
        chapter: json['chapter'] as String,
      );
}
