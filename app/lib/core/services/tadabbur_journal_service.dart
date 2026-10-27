import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TadabburReflectionItem {
  final String id;
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final String ayahSnippet;
  final String faithMessage; // الرسالة الإيمانية
  final String practicalAction; // العمل التطبيقي
  final String derivedDua; // الدعاء المستنبط
  final DateTime createdAt;

  const TadabburReflectionItem({
    required this.id,
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahSnippet,
    required this.faithMessage,
    required this.practicalAction,
    required this.derivedDua,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'surahId': surahId,
        'surahName': surahName,
        'ayahNumber': ayahNumber,
        'ayahSnippet': ayahSnippet,
        'faithMessage': faithMessage,
        'practicalAction': practicalAction,
        'derivedDua': derivedDua,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TadabburReflectionItem.fromJson(Map<String, dynamic> json) {
    return TadabburReflectionItem(
      id: json['id'] as String? ?? 'tadabbur_1',
      surahId: json['surahId'] as int? ?? 1,
      surahName: json['surahName'] as String? ?? 'الفاتحة',
      ayahNumber: json['ayahNumber'] as int? ?? 5,
      ayahSnippet: json['ayahSnippet'] as String? ?? '',
      faithMessage: json['faithMessage'] as String? ?? '',
      practicalAction: json['practicalAction'] as String? ?? '',
      derivedDua: json['derivedDua'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// الميزة الخامسة الجديدة: دفتر التدبر والعمل بالقرآن ومحاسبة النفس الإيمانية اليومية
class TadabburJournalService extends ChangeNotifier {
  static final TadabburJournalService instance = TadabburJournalService._internal();
  TadabburJournalService._internal() {
    _entries.addAll(_defaultInspiringReflections);
  }

  static const String _storageKey = 'tadabbur_journal_entries_v1';
  static const String _dailyAccountabilityKey = 'tadabbur_daily_accountability_v1';

  bool _isInitialized = false;
  final List<TadabburReflectionItem> _entries = [];
  final Map<String, Set<String>> _dailyAccountability = {};

  List<TadabburReflectionItem> get entries => List.unmodifiable(_entries);

  static const List<Map<String, String>> dailyEthicalChecklist = [
    {
      'id': 'birr_walidayn',
      'title': 'بر الوالدين وصلة الرحم وإدخال السرور عليهما',
      'verse': '﴿وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا﴾ [الإسراء: ٢٣]',
    },
    {
      'id': 'hifz_lisan',
      'title': 'حفظ اللسان عن الغيبة والنميمة وقول الخير',
      'verse': '﴿مَّا يَلْفِظُ مِن قَوْلٍ إِلَّا لَدَيْهِ رَقِيبٌ عَتِيدٌ﴾ [ق: ١٨]',
    },
    {
      'id': 'sadaqah_ihsan',
      'title': 'صدقة اليوم أو قضاء حاجة مسلم أو كلمة طيبة',
      'verse': '﴿مَّن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا فَيُضَاعِفَهُ لَهُ أَضْعَافًا كَثِيرَةً﴾ [البقرة: ٢٤٥]',
    },
    {
      'id': 'istighfar_tawbah',
      'title': 'تجديد التوبة والاستغفار مائة مرة في اليوم',
      'verse': '﴿وَأَنِ اسْتَغْفِرُوا رَبَّكُمْ ثُمَّ تُوبُوا إِلَيْهِ يُمَتِّعْكُم مَّتَاعًا حَسَنًا﴾ [هود: ٣]',
    },
    {
      'id': 'afk_afw',
      'title': 'العفو والصفح وتطهير القلب من الغل والحسد',
      'verse': '﴿وَلَا تَجْعَلْ فِي قُلُوبِنَا غِلًّا لِّلَّذِينَ آمَنُوا﴾ [الحشر: ١٠]',
    },
  ];

  static final List<TadabburReflectionItem> _defaultInspiringReflections = [
    TadabburReflectionItem(
      id: 'seed_1',
      surahId: 1,
      surahName: 'الفاتحة',
      ayahNumber: 5,
      ayahSnippet: '﴿إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ﴾',
      faithMessage: 'تجمع هذه الآية سر القرآن كله: التبرؤ من الشرك والرياء بـ (إياك نعبد)، والتبرؤ من الحول والقوة إلا بالله بـ (وإياك نستعين).',
      practicalAction: 'أجدد نيتي قبل كل عمل اليوم وأستعين بالله قبل البدء في أي مهمة.',
      derivedDua: 'اللهم أعنّي على ذكرك وشكرك وحسن عبادتك.',
      createdAt: DateTime(2026, 10, 1),
    ),
    TadabburReflectionItem(
      id: 'seed_2',
      surahId: 65,
      surahName: 'الطلاق',
      ayahNumber: 2,
      ayahSnippet: '﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ﴾',
      faithMessage: 'وعد رباني قاطع بأن تقوى الله في السر والعلن هي مفتاح الفرج من كل ضيق وباب الرزق غير المتوقع.',
      practicalAction: 'مراقبة الله في الكسب والمعاملة والابتعاد عن كل شبهة طمعاً في كفاية الله.',
      derivedDua: 'اللهم ارزقني تقواك في الغيب والشهادة واكفني بحلالك عن حرامك.',
      createdAt: DateTime(2026, 10, 2),
    ),
  ];

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = json.decode(raw);
        _entries
          ..clear()
          ..addAll(list.map((e) => TadabburReflectionItem.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    final rawAcc = prefs.getString(_dailyAccountabilityKey);
    if (rawAcc != null && rawAcc.isNotEmpty) {
      try {
        final Map<String, dynamic> map = json.decode(rawAcc);
        _dailyAccountability.clear();
        map.forEach((k, v) {
          if (v is List) {
            _dailyAccountability[k] = v.map((e) => e.toString()).toSet();
          }
        });
      } catch (_) {}
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addReflection({
    required int surahId,
    required String surahName,
    required int ayahNumber,
    required String ayahSnippet,
    required String faithMessage,
    required String practicalAction,
    required String derivedDua,
  }) async {
    final item = TadabburReflectionItem(
      id: 'tadabbur_${DateTime.now().millisecondsSinceEpoch}',
      surahId: surahId,
      surahName: surahName,
      ayahNumber: ayahNumber,
      ayahSnippet: ayahSnippet,
      faithMessage: faithMessage,
      practicalAction: practicalAction,
      derivedDua: derivedDua,
      createdAt: DateTime.now(),
    );
    _entries.insert(0, item);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> deleteReflection(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }

  bool isEthicalItemDoneToday(String itemId) {
    return _dailyAccountability[_todayKey()]?.contains(itemId) ?? false;
  }

  Future<void> toggleEthicalItemToday(String itemId) async {
    final key = _todayKey();
    final set = _dailyAccountability.putIfAbsent(key, () => <String>{});
    if (set.contains(itemId)) {
      set.remove(itemId);
    } else {
      set.add(itemId);
    }
    final prefs = await SharedPreferences.getInstance();
    final map = <String, List<String>>{
      for (final e in _dailyAccountability.entries) e.key: e.value.toList(),
    };
    await prefs.setString(_dailyAccountabilityKey, json.encode(map));
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode(_entries.map((e) => e.toJson()).toList()),
    );
  }
}
