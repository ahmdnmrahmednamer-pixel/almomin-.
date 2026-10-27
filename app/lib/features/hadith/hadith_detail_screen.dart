import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/hadith.dart';
import '../../core/services/hadith_service.dart';
import '../../core/theme/app_theme.dart';

class HadithDetailScreen extends StatefulWidget {
  final int hadithId;

  const HadithDetailScreen({
    super.key,
    required this.hadithId,
  });

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  late int _currentId;
  double _fontSize = 20.0;
  bool _showExplanation = true;

  @override
  void initState() {
    super.initState();
    _currentId = widget.hadithId;
    HadithService.instance.setLastRead(_currentId);
  }

  Color _getGradingColor(String grading) {
    if (grading.contains('متفق عليه') || grading.contains('صحيح')) {
      return AppColors.primaryGreen;
    } else if (grading.contains('حسن')) {
      return Colors.amber.shade800;
    }
    return AppColors.accentGold;
  }

  void _shareHadith(HadithItem hadith) {
    final text = HadithService.instance.formatShareText(hadith);
    try {
      Share.share(text, subject: 'حديث شريف: ${hadith.title}');
    } catch (_) {}
  }

  void _copyHadith(HadithItem hadith) {
    final text = HadithService.instance.formatShareText(hadith);
    Clipboard.setData(ClipboardData(text: text)).catchError((_) {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الحديث الشريف والإهداء إلى الحافظة ✓'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _navigateToHadith(int delta) {
    final hadiths = HadithService.instance.allHadiths;
    final currentIndex = hadiths.indexWhere((h) => h.id == _currentId);
    if (currentIndex != -1) {
      final nextIndex = currentIndex + delta;
      if (nextIndex >= 0 && nextIndex < hadiths.length) {
        setState(() {
          _currentId = hadiths[nextIndex].id;
        });
        HadithService.instance.setLastRead(_currentId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hadith = HadithService.instance.getHadithById(_currentId);
    if (hadith == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حديث شريف')),
        body: const Center(child: Text('الحديث غير متوفر')),
      );
    }

    final isFav = HadithService.instance.isFavorite(hadith.id);
    final gradingColor = _getGradingColor(hadith.grading);

    return Scaffold(
      appBar: AppBar(
        title: Text(hadith.title),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? AppColors.accentGold : null,
            ),
            tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            onPressed: () {
              HadithService.instance.toggleFavorite(hadith.id);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav ? 'تمت إزالة الحديث من المفضلة' : 'تمت إضافة الحديث إلى المفضلة ⭐',
                  ),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'نسخ الحديث',
            onPressed: () => _copyHadith(hadith),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة الحديث',
            onPressed: () => _shareHadith(hadith),
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.format_size),
            tooltip: 'حجم الخط',
            onSelected: (size) => setState(() => _fontSize = size),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 17.0, child: Text('خط صغير')),
              const PopupMenuItem(value: 20.0, child: Text('خط متوسط (افتراضي)')),
              const PopupMenuItem(value: 24.0, child: Text('خط كبير')),
              const PopupMenuItem(value: 28.0, child: Text('خط كبير جداً')),
            ],
          ),
        ],
      ),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Chapter and Number Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    'الحديث رقم ${hadith.number}',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hadith.chapter,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Narrator Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: AppColors.accentGold, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hadith.narrator,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sacred Hadith Matn Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SelectableText(
                      hadith.matn,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: 'Uthmanic',
                        fontSize: _fontSize,
                        height: 1.9,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Authenticity & Source Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Takhrij / Source
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.menu_book, size: 18, color: AppColors.primaryGreen),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  hadith.source,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Grading Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: gradingColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: gradingColor.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 14, color: gradingColor),
                              const SizedBox(width: 4),
                              Text(
                                hadith.grading,
                                style: TextStyle(
                                  color: gradingColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Benefits & Explanation Section
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ExpansionTile(
                initiallyExpanded: _showExplanation,
                leading: const Icon(Icons.lightbulb_outline, color: AppColors.accentGold),
                title: const Text(
                  'فوائد وشرح الحديث',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      hadith.explanation,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.7,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Golden Dedication Card to مؤمن إبراهيم رحمه الله
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGold.withOpacity(0.15),
                    AppColors.primaryGreen.withOpacity(0.1),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism, color: AppColors.accentGold, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    'دُعَاءٌ وَرَجَاءٌ بِالمَغْفِرَةِ لِلْمَرْحُومِ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'مُؤْمِن إِبْرَاهِيم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '«اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ، وَاجْعَلْ قَبْرَهُ رَوْضَةً مِنْ رِيَاضِ الجَنَّةِ، وَاجْعَلْ كُلَّ عِلْمٍ نَافِعٍ يُتَعَلَّمُ فِي هَذَا التَّطْبِيقِ نُوراً فِي مِيزَانِ حَسَنَاتِهِ»',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 1.6, color: Colors.brown.shade700, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward),
                label: const Text('السابق'),
                onPressed: () => _navigateToHadith(-1),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_outlined),
                    tooltip: 'نسخ',
                    onPressed: () => _copyHadith(hadith),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: 'مشاركة',
                    onPressed: () => _shareHadith(hadith),
                  ),
                ],
              ),
              TextButton.icon(
                icon: const Text('التالي'),
                label: const Icon(Icons.arrow_back),
                onPressed: () => _navigateToHadith(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
