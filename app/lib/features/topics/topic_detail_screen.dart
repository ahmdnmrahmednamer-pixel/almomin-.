import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/quran_topic.dart';
import '../../core/services/quran_topic_service.dart';
import '../../core/theme/app_theme.dart';
import '../mushaf/page_mode_mushaf_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  final String topicId;

  const TopicDetailScreen({
    super.key,
    required this.topicId,
  });

  void _shareAyah(BuildContext context, QuranTopic topic, TopicAyahItem ayah) {
    final text = QuranTopicService.instance.formatShareText(topic, ayah);
    Share.share(text, subject: '${topic.title}: سورة ${ayah.surahName}');
  }

  void _copyAyah(BuildContext context, QuranTopic topic, TopicAyahItem ayah) {
    final text = QuranTopicService.instance.formatShareText(topic, ayah);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الآية الكريمة والإضاءة والإهداء إلى الحافظة ✓'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _openInMushaf(BuildContext context, TopicAyahItem ayah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PageModeMushafScreen(initialPage: ayah.page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = QuranTopicService.instance.getTopicById(topicId);
    if (topic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الموضوع القرآني')),
        body: const Center(child: Text('الموضوع غير متوفر')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.title),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Topic Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    topic.primaryColor,
                    topic.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: topic.primaryColor.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(topic.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                topic.category.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topic.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${topic.ayahCount} آيات',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    topic.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              children: [
                const Icon(Icons.menu_book, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'الآيات القرآنية الواردة في هذا الباب (${topic.ayahCount})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Ayahs Cards
            ...topic.ayahs.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final ayah = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: topic.primaryColor.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Row: Index, Surah, Ayah Number, and Page
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: topic.primaryColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$index',
                              style: TextStyle(
                                color: topic.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'سورة ${ayah.surahName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'آية ${ayah.ayahNumber}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'صفحة ${ayah.page}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Sacred Quran Ayah Text
                      SelectableText(
                        '﴿ ${ayah.text} ﴾',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontFamily: 'Uthmanic',
                          fontSize: 19,
                          height: 1.85,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Quranic Significance / Reflection Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.accentGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ayah.significance,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.brown.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.menu_book, size: 16),
                            label: const Text('عرض في المصحف', style: TextStyle(fontSize: 12)),
                            onPressed: () => _openInMushaf(context, ayah),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy_outlined, size: 20),
                                tooltip: 'نسخ الآية والإضاءة',
                                onPressed: () => _copyAyah(context, topic, ayah),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined, size: 20),
                                tooltip: 'مشاركة',
                                onPressed: () => _shareAyah(context, topic, ayah),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

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
                    'صَدَقَةٌ جَارِيَةٌ عَنْ رُوحِ المَرْحُومِ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'مُؤْمِن إِبْرَاهِيم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '«اللَّهُمَّ اجْعَلْ كُلَّ آيَةٍ يُتَدَبَّرُ مَعْنَاهَا وَيُعْمَلُ بِهَا فِي هَذَا التَّطْبِيقِ نُوراً فِي قَبْرِهِ وَرِفْعَةً فِي دَرَجَاتِهِ يَا أَرْحَمَ الرَّاحِمِينَ»',
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
    );
  }
}
