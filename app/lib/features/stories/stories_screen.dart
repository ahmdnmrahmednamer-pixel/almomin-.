import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../core/models/prophet_story.dart';
import '../../core/services/stories_service.dart';
import '../../core/theme/app_theme.dart';
import '../audio/downloads_manager_screen.dart';
import 'story_detail_screen.dart';
import 'widgets/prophet_story_player_sheet.dart';

enum StoryFilterType {
  all,
  uluAlAzm,
  downloaded,
  favorites,
}

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  StoryFilterType _activeFilter = StoryFilterType.all;
  String _selectedScholarId = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    StoriesService.instance.init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProphetAudioStory> _getFilteredStories() {
    final service = StoriesService.instance;
    List<ProphetAudioStory> list;

    if (_searchQuery.isNotEmpty) {
      list = service.searchStories(_searchQuery);
    } else {
      list = service.getAllStories();
    }

    if (_selectedScholarId != 'all') {
      list = list.where((s) => s.scholarId == _selectedScholarId).toList();
    }

    switch (_activeFilter) {
      case StoryFilterType.all:
        break;
      case StoryFilterType.uluAlAzm:
        list = list.where((s) => s.isUluAlAzm).toList();
        break;
      case StoryFilterType.downloaded:
        list = list.where((s) => service.isDownloaded(s.id)).toList();
        break;
      case StoryFilterType.favorites:
        list = list.where((s) => service.isFavorite(s.id)).toList();
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storyOfTheDay = StoriesService.instance.getStoryOfTheDay();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قصص الأنبياء الصوتية', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_done_rounded),
              tooltip: 'مركز التنزيلات والاستماع دون إنترنت',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadsManagerScreen()),
                );
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: StoriesService.instance,
          builder: (context, _) {
            final stories = _getFilteredStories();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Dedication & Audio Series Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.headphones_rounded, color: AppColors.accentGold, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'سلسلة قصص الأنبياء كاملة',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'بصوت فضيلة الشيخ نبيل العوضي — قابلة للاستماع والتحميل أوفلاين',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Search Input Field
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم نبي، قصة، عبرة، أو سورة...',
                      hintStyle: TextStyle(fontSize: 13.5, color: isDark ? Colors.white60 : AppColors.mutedText),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                            tooltip: 'إغلاق أو مسح',
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Advanced Filter Chips (Categories)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'جميع القصص (${StoriesService.instance.totalStoriesCount})',
                        isSelected: _activeFilter == StoryFilterType.all,
                        onTap: () => setState(() => _activeFilter = StoryFilterType.all),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'أولو العزم من الرسل',
                        isSelected: _activeFilter == StoryFilterType.uluAlAzm,
                        onTap: () => setState(() => _activeFilter = StoryFilterType.uluAlAzm),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'محملة أوفلاين ⚡ (${StoriesService.instance.getDownloadedStories().length})',
                        isSelected: _activeFilter == StoryFilterType.downloaded,
                        onTap: () => setState(() => _activeFilter = StoryFilterType.downloaded),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'المفضلة ⭐ (${StoriesService.instance.favoriteIds.length})',
                        isSelected: _activeFilter == StoryFilterType.favorites,
                        onTap: () => setState(() => _activeFilter = StoryFilterType.favorites),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Scholar Selection Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: StoriesService.instance.getAvailableScholars().map((sc) {
                      final isSelected = _selectedScholarId == sc['id'];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: FilterChip(
                          avatar: Icon(
                            sc['id'] == 'all' ? Icons.group_rounded : Icons.person_rounded,
                            size: 15,
                            color: isSelected ? Colors.white : AppColors.primaryGreen,
                          ),
                          label: Text(
                            sc['name']!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryGreen,
                          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryGreen : (isDark ? Colors.white12 : Colors.grey.shade300),
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedScholarId = sc['id']!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Daily Story Spotlight (when no search is active)
                if (_searchQuery.isEmpty && _activeFilter == StoryFilterType.all && _selectedScholarId == 'all') ...[
                  _buildDailyStoryCard(context, storyOfTheDay, isDark),
                  const SizedBox(height: 16),
                ],

                // Result Counter Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة القصص الصوتية (${stories.length})',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                      ),
                      if (StoriesService.instance.getDownloadedStories().isNotEmpty)
                        Text(
                          'المساحة المستخدمة: ${StoriesService.instance.formattedTotalDownloadedStorage}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Stories Audio List
                if (stories.isEmpty)
                  _buildEmptyState(isDark)
                else
                  ...stories.map((story) => _buildStoryAudioCard(context, story, isDark)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryGreen.withOpacity(0.18),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        fontSize: 12.5,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primaryGreen : null,
      ),
    );
  }

  Widget _buildDailyStoryCard(BuildContext context, ProphetAudioStory story, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.accentGold, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'قصة اليوم المختارة',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB8860B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${story.duration} • ${story.formattedSize}',
                      style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  story.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  story.summary,
                  style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white70 : Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'صوت: ${story.narrator}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.mutedText),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                      label: const Text('استمع الآن', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => ProphetStoryPlayerSheet.show(context, story),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryAudioCard(BuildContext context, ProphetAudioStory story, bool isDark) {
    final service = StoriesService.instance;
    final isDownloaded = service.isDownloaded(story.id);
    final isDownloading = service.isDownloading(story.id);
    final downloadProgress = service.getDownloadProgress(story.id);
    final isFav = service.isFavorite(story.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDownloaded
              ? Colors.green.withOpacity(0.3)
              : (isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon / Avatar
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: story.isUluAlAzm
                          ? AppColors.accentGold.withOpacity(0.18)
                          : AppColors.primaryGreen.withOpacity(0.1),
                      child: Icon(
                        story.isUluAlAzm ? Icons.auto_awesome : Icons.record_voice_over_rounded,
                        color: story.isUluAlAzm ? const Color(0xFFB8860B) : AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Narrator
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  story.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                              ),
                              if (story.isUluAlAzm)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'أولو العزم',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB8860B),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            story.subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Favorite Button
                    IconButton(
                      tooltip: 'حفظ في المفضلة',
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isFav ? AppColors.accentGold : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () => service.toggleFavorite(story.id),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Meta row: Duration, Size, Offline indicator
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: AppColors.mutedText),
                    const SizedBox(width: 4),
                    Text(story.duration, style: const TextStyle(fontSize: 11.5, color: AppColors.mutedText)),
                    const SizedBox(width: 12),
                    const Icon(Icons.sd_storage_outlined, size: 14, color: AppColors.mutedText),
                    const SizedBox(width: 4),
                    Text(story.formattedSize, style: const TextStyle(fontSize: 11.5, color: AppColors.mutedText)),
                    const Spacer(),
                    if (isDownloaded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.offline_pin_rounded, color: Colors.green, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'أوفلاين ⚡',
                              style: TextStyle(color: Colors.green, fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const Divider(height: 18),

                // Action buttons: Play & Download
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('استماع للقصة', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => ProphetStoryPlayerSheet.show(context, story),
                    ),
                    Row(
                      children: [
                        if (isDownloading)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.clamp(0.0, 1.0),
                                    strokeWidth: 2,
                                    color: AppColors.accentGold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(downloadProgress * 100).toInt()}%',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        else if (isDownloaded)
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            tooltip: 'حذف التنزيل لتوفير المساحة',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => Directionality(
                                  textDirection: SettingsService.instance.textDirection,
                                  child: AlertDialog(
                                    title: const Text('حذف القصة المحملة'),
                                    content: Text('هل تريد حذف ملف ${story.title} لتوفير ${story.formattedSize}؟'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                        onPressed: () => Navigator.pop(ctx, true),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              if (confirm == true && mounted) {
                                await service.deleteDownloadedStory(story.id);
                              }
                            },
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.primaryGreen),
                            tooltip: 'تحميل القصة للاستماع دون إنترنت',
                            onPressed: () async {
                              final ok = await service.downloadStory(story.id);
                              if (ok && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('تم تنزيل ${story.characterName} بنجاح للاستماع دون إنترنت')),
                                );
                              }
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, size: 20),
                          tooltip: 'تفاصيل القصة والعبر والدعاء',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => StoryDetailScreen(story: story)),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          const Text(
            'لم يتم العثور على أي قصة مطابقة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرب كتابة اسم نبي آخر، أو إلغاء فلتر البحث',
            style: TextStyle(fontSize: 13, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }
}
