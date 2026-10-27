import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';

/// استوديو تصميم ومشاركة البطاقات الدعوية والآيات والحِكم (Daawah Card Studio)
class DaawahCardStudioScreen extends StatefulWidget {
  const DaawahCardStudioScreen({super.key});

  @override
  State<DaawahCardStudioScreen> createState() => _DaawahCardStudioScreenState();
}

class _DaawahCardStudioScreenState extends State<DaawahCardStudioScreen> {
  int _selectedPresetIndex = 0;
  int _selectedThemeIndex = 0;
  late final TextEditingController _quoteController;
  late final TextEditingController _sourceController;
  late final TextEditingController _dedicationController;

  static const List<Map<String, String>> _presets = [
    {
      'title': 'آية السكينة والفرج',
      'quote': '﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
      'source': 'سورة الشرح: ٥ - ٦',
    },
    {
      'title': 'حديث محبة الله ومعيته',
      'quote': '«احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجَاهَكَ»',
      'source': 'وصية النبي ﷺ لابن عباس — رواه الترمذي',
    },
    {
      'title': 'من خواطر الشيخ الشعراوي',
      'quote': '«لا تقلق من تدابير البشر، فأقصى ما يستطيعونه هو تنفيذ إرادة الله فيك»',
      'source': 'إمام الدعاة الشيخ محمد متولي الشعراوي',
    },
    {
      'title': 'ابتهال الفجر — الشيخ النقشبندي',
      'quote': '«مَوْلايَ إِنِّي بِبَابِكَ قَدْ بَسَطْتُ يَدِي — مَنْ لِي أَلُوذُ بِهِ إِلَّاكَ يَا سَنَدِي»',
      'source': 'من روائع إذاعة القرآن الكريم من القاهرة',
    },
  ];

  static const List<List<Color>> _cardThemes = [
    [Color(0xFF0B4F3A), Color(0xFF06291E)], // الزمرد الملكي
    [Color(0xFF1F2B3E), Color(0xFF0D1520)], // ليل المحروسة
    [Color(0xFF5C3D28), Color(0xFF362214)], // الرقّ العثماني
    [Color(0xFF3E1F47), Color(0xFF1E0E24)], // الفجر الروحاني
  ];

  @override
  void initState() {
    super.initState();
    _quoteController = TextEditingController(text: _presets[0]['quote']);
    _sourceController = TextEditingController(text: _presets[0]['source']);
    _dedicationController = TextEditingController(
      text: 'صدقة جارية عن روح مؤمن إبراهيم (رحمه الله)',
    );
  }

  @override
  void dispose() {
    _quoteController.dispose();
    _sourceController.dispose();
    _dedicationController.dispose();
    super.dispose();
  }

  void _applyPreset(int idx) {
    setState(() {
      _selectedPresetIndex = idx;
      _quoteController.text = _presets[idx]['quote']!;
      _sourceController.text = _presets[idx]['source']!;
    });
  }

  String _composeCardText() {
    return '''✨ بطاقة نور المؤمن الدعوية ✨

${_quoteController.text.trim()}

— ${_sourceController.text.trim()}
🤲 ${_dedicationController.text.trim()}''';
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _cardThemes[_selectedThemeIndex];

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('استوديو تصميم البطاقات الدعوية'),
          actions: [
            IconButton(
              tooltip: 'نسخ النص المصمم',
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _composeCardText())).catchError((_) {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ البطاقة الدعوية إلى الحافظة')),
                );
              },
            ),
            IconButton(
              tooltip: 'مشاركة البطاقة',
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
              try {
                Share.share(_composeCardText());
              } catch (_) {}
            },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Live Card Preview
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.accentGold, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accentGold,
                    size: 28,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _quoteController.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _sourceController.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.softGold,
                    ),
                  ),
                  if (_dedicationController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 6),
                    Text(
                      _dedicationController.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اختر من النماذج المختارة أو عدّل النص بحرية:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_presets.length, (i) {
                final selected = _selectedPresetIndex == i;
                return ChoiceChip(
                  label: Text(_presets[i]['title']!),
                  selected: selected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => _applyPreset(i),
                );
              }),
            ),
            const SizedBox(height: 14),
            const Text(
              'سمة البطاقة البصرية:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(_cardThemes.length, (i) {
                final selected = _selectedThemeIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedThemeIndex = i),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: _cardThemes[i]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.accentGold : Colors.white24,
                          width: selected ? 3 : 1,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quoteController,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'نص الآية أو الحديث أو الحكمة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sourceController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'المصدر أو القائل',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dedicationController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'إهداء أو دعاء في أسفل البطاقة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
