import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/prophet_story.dart';
import '../../core/services/stories_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/prophet_story_player_sheet.dart';

class StoryDetailScreen extends StatefulWidget {
  final ProphetAudioStory story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    StoriesService.instance.setLastReadStory(widget.story.id);
  }

  void _shareStory() {
    final story = widget.story;
    final text = '''
🎙️ ${story.title}
✨ من سلسلة قصص الأنبياء الصوتية في تطبيق نور المؤمن
🔊 بصوت: ${story.narrator} (المدة: ${story.duration})

📜 ملخص القصة:
${story.summary}

💎 من أعظم العبر والدروس:
${story.keyLessons.map((l) => '• $l').join('\n')}

${story.propheticDuaa != null ? '🤲 دعاء نبوي مأثور:\n«${story.propheticDuaa}» (${story.duaaReference ?? ""})\n' : ''}
---
تطبيق نور المؤمن — قصص الأنبياء والسيرة النبوية
''';
    try {
      Share.share(text);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = StoriesService.instance;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(story.characterName, style: const TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'مشاركة القصة والعبر',
              onPressed: _shareStory,
            ),
            AnimatedBuilder(
              animation: service,
              builder: (context, _) {
                final isFav = service.isFavorite(story.id);
                return IconButton(
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFav ? AppColors.accentGold : null,
                  ),
                  tooltip: isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                  onPressed: () => service.toggleFavorite(story.id),
                );
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: service,
          builder: (context, _) {
            final isDownloaded = service.isDownloaded(story.id);
            final isDownloading = service.isDownloading(story.id);
            final downloadProgress = service.getDownloadProgress(story.id);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Dedication Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, color: Color(0xFFD4AF37), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'عبر وعظات من قصص القرآن الكريم والسيرة النبوية العطرة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Hero Audio Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              story.categoryName,
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDownloaded
                                  ? Colors.green.withOpacity(0.85)
                                  : AppColors.accentGold.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isDownloaded ? Icons.offline_pin_rounded : Icons.headphones_rounded,
                                  color: isDownloaded ? Colors.white : AppColors.accentGold,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isDownloaded ? 'متاح أوفلاين ⚡' : '${story.duration} • ${story.formattedSize}',
                                  style: TextStyle(
                                    color: isDownloaded ? Colors.white : AppColors.accentGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        story.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'صوت: ${story.narrator}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Prominent Audio Play Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded, size: 24),
                          label: const Text(
                            'تشغيل القصة الصوتية الآن',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: const Color(0xFF1B4332),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => ProphetStoryPlayerSheet.show(context, story),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Download / Offline Toggle Row
                      Center(
                        child: isDownloading
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.clamp(0.0, 1.0),
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'جاري التحميل للاستماع دون إنترنت (${(downloadProgress * 100).toInt()}%)...',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              )
                            : isDownloaded
                                ? TextButton.icon(
                                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                    label: const Text(
                                      'تم التحميل بنجاح (استمع في أي وقت دون نت)',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    onPressed: () {},
                                  )
                                : TextButton.icon(
                                    icon: const Icon(Icons.download_for_offline_outlined, color: Colors.white, size: 16),
                                    label: Text(
                                      'تحميل القصة على هاتفك (${story.formattedSize}) للاستماع دون إنترنت',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    onPressed: () async {
                                      final ok = await service.downloadStory(story.id);
                                      if (ok && mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم تنزيل القصة بنجاح للاستماع دون إنترنت')),
                                        );
                                      }
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Prophetic Duaa Card (if available)
                if (story.propheticDuaa != null) ...[
                  _buildSectionTitle('دعاء نبوي مأثور في القرآن الكريم', Icons.favorite_rounded),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2B20) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '«${story.propheticDuaa}»',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.8,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        if (story.duaaReference != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            story.duaaReference!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.accentGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text('نسخ الدعاء', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: '${story.propheticDuaa} (${story.duaaReference ?? ""})',
                                )).catchError((_) {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('تم نسخ الدعاء إلى الحافظة')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Story Summary Card
                _buildSectionTitle('نبذة وموجز القصة', Icons.auto_stories_rounded),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                  ),
                  child: Text(
                    story.summary,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.7,
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Surahs Mentioned
                if (story.surahsMentioned.isNotEmpty) ...[
                  _buildSectionTitle('السور القرآنية التي وردت فيها القصة', Icons.menu_book_rounded),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: story.surahsMentioned.map((sName) {
                      return Chip(
                        label: Text('سورة $sName', style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.08),
                        side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.2)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                ],

                // Key Lessons & Morals
                _buildSectionTitle('أعظم العِبر والدروس المستفادة', Icons.lightbulb_outline_rounded),
                const SizedBox(height: 8),
                ...story.keyLessons.map((lesson) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.accentGold, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            lesson,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
