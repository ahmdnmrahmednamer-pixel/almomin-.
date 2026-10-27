import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/dhikr.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/islamic_audio_service.dart';
import '../audio/widgets/islamic_audio_player_sheet.dart';
import 'tasbih_screen.dart';
import 'widgets/sharawi_post_prayer_card.dart';

class AdhkarScreen extends StatefulWidget {
  final int initialCategoryIndex;

  const AdhkarScreen({
    super.key,
    this.initialCategoryIndex = 0,
  });

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final categories = AdhkarService.instance.categories;
    final initialIndex = widget.initialCategoryIndex.clamp(0, categories.isNotEmpty ? categories.length - 1 : 0);
    _tabController = TabController(
      length: categories.length,
      initialIndex: initialIndex,
      vsync: this,
    );
    IslamicAudioService.instance.init();
    IslamicAudioService.instance.addListener(_onAudioUpdate);
  }

  @override
  void dispose() {
    IslamicAudioService.instance.removeListener(_onAudioUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onAudioUpdate() {
    if (mounted) setState(() {});
  }

  void _shareDhikr(DhikrItem item, String categoryTitle) {
    final buffer = StringBuffer();
    buffer.writeln('﴿ $categoryTitle ﴾');
    buffer.writeln(item.text);
    if (item.source != null) {
      buffer.writeln('المصدر: ${item.source}');
    }
    if (item.virtue != null) {
      buffer.writeln('الفضل: ${item.virtue}');
    }
    buffer.writeln('\nتمت المشاركة من تطبيق نور المؤمن 🕌');
    try {
      Share.share(buffer.toString());
    } catch (_) {}
  }

  void _copyDhikr(DhikrItem item, BuildContext context) {
    final text = '${item.text}\n${item.source != null ? "المصدر: ${item.source}\n" : ""}${item.virtue != null ? "الفضل: ${item.virtue}" : ""}';
    Clipboard.setData(ClipboardData(text: text)).catchError((_) {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الذكر بنجاح'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmResetCategory(DhikrCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AlertDialog(
          title: const Text('إعادة ضبط العدادات'),
          content: Text('هل تريد تصفير عدادات ${category.title}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: () {
                AdhkarService.instance.resetCategory(category);
                Navigator.pop(ctx);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = AdhkarService.instance.categories;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حصن المسلم والأذكار'),
          actions: [
            IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              tooltip: 'المكتبة الصوتية للأذكار والأذان',
              onPressed: () {
                IslamicAudioPlayerSheet.show(context, filter: IslamicAudioType.adhkar);
              },
            ),
            IconButton(
              icon: const Icon(Icons.touch_app_outlined),
              tooltip: 'السبحة الإلكترونية',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TasbihScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.accentGold,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: categories.map((cat) {
              return Tab(
                icon: Icon(cat.icon, size: 20),
                text: cat.title,
              );
            }).toList(),
          ),
        ),
        body: AnimatedBuilder(
          animation: AdhkarService.instance,
          builder: (context, _) {
            return TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                return _buildCategoryTab(category, isDark);
              }).toList(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.softGold,
          icon: const Icon(Icons.fingerprint),
          label: const Text('السبحة الذكية'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TasbihScreen()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTab(DhikrCategory category, bool isDark) {
    final completedCount = category.totalCompleted;
    final totalCount = category.totalItems;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      children: [
        // Category Header & Progress Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.darkSurface, const Color(0xFF263238)]
                  : [category.primaryColor.withOpacity(0.12), AppColors.softGold.withOpacity(0.2)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: category.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.accentGold : category.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.accentGold),
                    tooltip: 'إعادة ضبط كل أذكار هذه القائمة',
                    onPressed: () => _confirmResetCategory(category),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: isDark ? Colors.white12 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completedCount == totalCount ? Colors.green : AppColors.accentGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$completedCount / $totalCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Sheikh Al-Sha'rawi Post-Prayer Duaa Featured Card
        if (category.id == 'post_prayer') ...[
          SharawiPostPrayerDuaaCard(isDark: isDark),
          const SizedBox(height: 14),
        ],

        // Audio Recitation Card for this Category (FR-AUD-006)
        _buildAudioPlayerCardForCategory(category, isDark),
        const SizedBox(height: 14),

        // List of Dhikr Cards
        ...category.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildDhikrCard(item, index + 1, category.title, isDark);
        }),
        const SizedBox(height: 60), // bottom space for FAB
      ],
    );
  }

  Widget _buildAudioPlayerCardForCategory(DhikrCategory category, bool isDark) {
    final audioService = IslamicAudioService.instance;
    String trackId = 'adhkar_morning';
    if (category.id == 'evening') trackId = 'adhkar_evening';
    if (category.id == 'post_prayer') trackId = 'adhkar_post_prayer';
    if (category.id == 'sleep') trackId = 'adhkar_sleep';
    if (category.id == 'waking') trackId = 'adhkar_waking';
    if (category.id == 'home_mosque') trackId = 'adhkar_home_mosque';
    if (category.id == 'prophetic_duas' || category.id == 'duas') trackId = 'prophetic_duas';
    if (category.id == 'ruqyah' || category.id == 'distress_relief') trackId = 'ruqyah_shariah';

    final track = IslamicAudioService.allTracks.firstWhere(
      (t) => t.id == trackId,
      orElse: () => IslamicAudioService.allTracks.firstWhere((t) => t.type == IslamicAudioType.adhkar),
    );

    final isCurrent = audioService.currentTrack?.id == track.id;
    final isPlaying = isCurrent && audioService.isPlaying;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? const Color(0xFF1B3D2F) : const Color(0xFFE8F5E9))
            : (isDark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.accentGold : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: isCurrent ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => audioService.playTrack(track),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPlaying
                          ? [const Color(0xFFD4AF37), const Color(0xFFB89628)]
                          : [AppColors.primaryGreen, AppColors.secondaryGreen],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'استمع إلى ${category.title} بصوت خاشع 🎧',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (audioService.isDownloaded(track.id))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'أوفلاين ⚡',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green),
                            ),
                          )
                        else if (audioService.isDownloading(track.id))
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              value: audioService.getDownloadProgress(track.id).clamp(0.0, 1.0),
                              strokeWidth: 2,
                              color: AppColors.accentGold,
                            ),
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'بث مباشر 🌐',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueAccent),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.download_for_offline_outlined, size: 18, color: AppColors.primaryGreen),
                                tooltip: 'تحميل للاستماع دون إنترنت',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  final ok = await audioService.downloadTrack(track.id);
                                  if (ok && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('تم تنزيل ${category.title} بنجاح للاستماع دون إنترنت')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      track.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isCurrent) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                activeTrackColor: AppColors.primaryGreen,
                inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade300,
                thumbColor: AppColors.accentGold,
              ),
              child: Slider(
                value: audioService.position.inSeconds
                    .toDouble()
                    .clamp(0.0, (audioService.duration.inSeconds > 0 ? audioService.duration.inSeconds.toDouble() : 1.0)),
                max: audioService.duration.inSeconds > 0 ? audioService.duration.inSeconds.toDouble() : 1.0,
                onChanged: (val) {
                  audioService.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDhikrCard(DhikrItem item, int displayIndex, String categoryTitle, bool isDark) {
    final isCompleted = item.isCompleted;

    return Card(
      elevation: isCompleted ? 1 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : (isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      color: isCompleted
          ? (isDark ? const Color(0xFF1B2E1E) : const Color(0xFFF1F8F4))
          : (isDark ? AppColors.darkSurface : Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Dhikr number, Source, and Quick Actions
            Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: isCompleted
                      ? Colors.green
                      : AppColors.primaryGreen.withOpacity(0.15),
                  child: Text(
                    '$displayIndex',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.white : AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.source != null)
                  Expanded(
                    child: Text(
                      item.source!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.softGold : AppColors.secondaryGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'نسخ الذكر',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _copyDhikr(item, context),
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 18),
                  tooltip: 'مشاركة',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _shareDhikr(item, categoryTitle),
                ),
                if (item.currentCount > 0)
                  IconButton(
                    icon: const Icon(Icons.replay, size: 18, color: Colors.orange),
                    tooltip: 'تصفير العداد',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      AdhkarService.instance.resetDhikr(item);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Arabic Dhikr Text
            SelectableText(
              item.text,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontFamilyFallback: const ['Traditional Arabic', 'Amiri', 'Scheherazade New', 'serif'],
                fontSize: 19,
                height: 1.85,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),

            // Virtue Box (if available)
            if (item.virtue != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accentGold.withOpacity(0.1)
                      : AppColors.softGold.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentGold.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.stars_rounded, size: 16, color: AppColors.accentGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.virtue!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.amber[200] : const Color(0xFF7A5800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),

            // Interactive Large Tap Counter Button
            InkWell(
              onTap: () {
                AdhkarService.instance.incrementDhikr(item);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(isDark ? 0.25 : 0.15)
                      : AppColors.primaryGreen.withOpacity(isDark ? 0.2 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted ? Colors.green : AppColors.primaryGreen,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isCompleted) ...[
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'اكتمل بحمد الله (${item.targetCount} / ${item.targetCount})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.fingerprint_rounded, color: AppColors.primaryGreen, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'اضغط للعد: ${item.currentCount} من ${item.targetCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.accentGold : AppColors.primaryGreen,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'متبقي ${item.remaining}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.accentGold : AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
