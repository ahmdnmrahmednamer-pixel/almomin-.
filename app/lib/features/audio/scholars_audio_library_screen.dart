import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/islamic_audio_service.dart';
import '../../core/services/scholar_audio_resolver_service.dart';
import '../../core/services/scholars_lectures_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';
import 'widgets/global_mini_player_bar.dart';

/// شاشة موسوعة الدروس والمحاضرات الصوتية الكبرى (١١٥ شيخاً وعالماً وداعية)
/// مدعومة بمحرك العزل الصوتي الصارم ١٠٠٪ وتعدد مصادر البث (IslamHouse + Islamway + Archive Metadata + Piped Audio)
class ScholarsAudioLibraryScreen extends StatefulWidget {
  final String? initialScholarId;
  final LectureContentCategory initialCategory;

  const ScholarsAudioLibraryScreen({
    super.key,
    this.initialScholarId,
    this.initialCategory = LectureContentCategory.all,
  });

  @override
  State<ScholarsAudioLibraryScreen> createState() =>
      _ScholarsAudioLibraryScreenState();
}

class _ScholarsAudioLibraryScreenState extends State<ScholarsAudioLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _regionFilter = 'all'; // 'all', 'egypt', 'arab_world', 'favorites'
  LectureContentCategory _selectedCategory = LectureContentCategory.all;
  String _selectedQuickScholarId = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = widget.initialCategory;
    if (widget.initialScholarId != null) {
      _selectedQuickScholarId = widget.initialScholarId!;
    }
    ScholarsLecturesService.instance.init();
    ScholarAudioResolverService.instance.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openScholarDetail(BuildContext context, ScholarProfile scholar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScholarDetailLecturesScreen(
          scholar: scholar,
          initialCategory: _selectedCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = ScholarsLecturesService.instance;
    final audioService = IslamicAudioService.instance;
    final resolverService = ScholarAudioResolverService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([
        service,
        audioService,
        resolverService,
        SettingsService.instance,
      ]),
      builder: (context, _) {
        final filteredScholars = service.filterScholars(
          regionFilter: _regionFilter,
          categoryFilter: _selectedCategory,
          query: _searchQuery,
        );

        final filteredLectures = service.searchLectures(
          query: _searchQuery,
          scholarId: _selectedQuickScholarId == 'all'
              ? null
              : _selectedQuickScholarId,
          category: _selectedCategory,
          regionFilter: _regionFilter,
        );

        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.tr('scholars_gatherings')),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentGold,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.people_alt_rounded),
                    text:
                        'الشيوخ والعلماء (${filteredScholars.length} من ${service.totalScholarsCount})',
                  ),
                  Tab(
                    icon: const Icon(Icons.library_music_rounded),
                    text:
                        'الدروس حسب المحتوى (${filteredLectures.length} مقطع)',
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const GlobalMiniPlayerBar(),
            body: Column(
              children: [
                // 1. Top Statistics & Filter Controls Card
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF132219)
                        : const Color(0xFFF3F8F5),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        decoration: InputDecoration(
                          hintText:
                              'ابحث باسم الشيخ (سمير مصطفى، نبيل العوضي، محمود الحسنات، الشعراوي...) أو عنوان الدرس...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: AppColors.primaryGreen),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                tooltip: 'إغلاق أو مسح',
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                )
                              : null,
                          isDense: true,
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF0D1912)
                                  : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: AppColors.primaryGreen.withOpacity(0.3)),
                          ),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                      const SizedBox(height: 10),

                      // Row of 2 Dropdowns: Region/School + Content Category
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdownField<String>(
                              label: 'مدرسة العلماء والبلد',
                              value: _regionFilter,
                              dense: true,
                              prefixIcon: Icons.public_rounded,
                              options: [
                                AppDropdownOption(
                                  value: 'all',
                                  label:
                                      'كل العلماء (${service.totalScholarsCount} شيخاً)',
                                ),
                                AppDropdownOption(
                                  value: 'egypt',
                                  label:
                                      'علماء ودعاة مصر 🇪🇬 (${service.egyptianScholarsCount})',
                                ),
                                AppDropdownOption(
                                  value: 'arab_world',
                                  label:
                                      'علماء العالم الإسلامي 🌍 (${service.arabWorldScholarsCount})',
                                ),
                                const AppDropdownOption(
                                  value: 'favorites',
                                  label: 'الشيوخ المفضلون ⭐',
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _regionFilter = val;
                                  _selectedQuickScholarId = 'all';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppDropdownField<LectureContentCategory>(
                              label: 'تقسيم الدروس حسب المحتوى',
                              value: _selectedCategory,
                              dense: true,
                              prefixIcon: Icons.category_rounded,
                              options: LectureContentCategory.values
                                  .map((c) =>
                                      AppDropdownOption<LectureContentCategory>(
                                        value: c,
                                        label: '${c.emoji} ${c.labelAr}',
                                      ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCategory = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Row of 2 Dropdowns: Quick Scholar Jump + Multi-Source Audio Engine Selector
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdownField<String>(
                              label: 'الانتقال السريع لأي شيخ (١١٥ شيخاً)',
                              value: _selectedQuickScholarId,
                              dense: true,
                              prefixIcon: Icons.record_voice_over_rounded,
                              options: [
                                const AppDropdownOption(
                                  value: 'all',
                                  label: 'جميع الشيوخ والدعاة (١١٥ عالماً)',
                                ),
                                ...service.allScholars.map(
                                  (s) => AppDropdownOption<String>(
                                    value: s.id,
                                    label: '${s.name} (${s.country})',
                                    subtitle: s.specialty,
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedQuickScholarId = val);
                                if (val != 'all') {
                                  final scholar = service.getScholarById(val);
                                  _openScholarDetail(context, scholar);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child:
                                AppDropdownField<ScholarAudioSourcePreference>(
                              label: 'محرك ومصدر البث الصوتي الموثق',
                              value: resolverService.sourcePreference,
                              dense: true,
                              prefixIcon: Icons.cloud_sync_rounded,
                              options: ScholarAudioSourcePreference.values
                                  .map(
                                    (pref) => AppDropdownOption<
                                        ScholarAudioSourcePreference>(
                                      value: pref,
                                      label: pref.labelAr,
                                      subtitle: pref.descriptionAr,
                                    ),
                                  )
                                  .toList(),
                              onChanged: (pref) {
                                resolverService.setSourcePreference(pref);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Main TabBarView
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // TAB 1: Scholars Directory (115 Scholars)
                      _buildScholarsTab(context, filteredScholars, service),

                      // TAB 2: Categorized Audio Lectures
                      _buildLecturesTab(
                          context, filteredLectures, service, audioService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScholarsTab(
    BuildContext context,
    List<ScholarProfile> scholars,
    ScholarsLecturesService service,
  ) {
    final featured = scholars.where((s) => s.isFeatured).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        if (featured.isNotEmpty && _searchQuery.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.stars_rounded,
                    color: AppColors.accentGold, size: 20),
                SizedBox(width: 6),
                Text(
                  'أبرز الشيوخ والعلماء والدعاة (وصول سريع):',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final s = featured[idx];
                final count = service.getLecturesForScholar(s.id).length;
                return InkWell(
                  onTap: () => _openScholarDetail(context, s),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 190,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F5B45), Color(0xFF093E2F)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mic_external_on_rounded,
                                color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          s.specialty,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.country,
                              style: const TextStyle(
                                color: AppColors.softGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count دروس',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Full Scholars Cards List
        ...scholars.map((scholar) {
          final lectures = service.getLecturesForScholar(
            scholar.id,
            category: _selectedCategory,
          );
          final isFav = service.isScholarFavorite(scholar.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openScholarDetail(context, scholar),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primaryGreen.withOpacity(0.12),
                          child: const Icon(
                            Icons.record_voice_over_rounded,
                            color: AppColors.primaryGreen,
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
                                      scholar.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      scholar.country,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${scholar.titleHonorific} • ${scholar.specialty}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'حفظ في المفضلة',
                          icon: Icon(
                            isFav
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isFav ? AppColors.accentGold : Colors.grey,
                          ),
                          onPressed: () =>
                              service.toggleScholarFavorite(scholar.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      scholar.bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...scholar.famousSeries.take(3).map((ser) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🎙️ $ser',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          );
                        }),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${lectures.length} مقاطع معزولة وموثقة ◀',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLecturesTab(
    BuildContext context,
    List<ScholarAudioLecture> lectures,
    ScholarsLecturesService service,
    IslamicAudioService audioService,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final lec = lectures[index];
        final isPlayingThis =
            audioService.currentTrack?.id == lec.id && audioService.isPlaying;

        return _LectureCardWidget(
          lecture: lec,
          isPlaying: isPlayingThis,
          isFavorite: service.isLectureFavorite(lec.id),
          onPlayTap: () {
            if (isPlayingThis) {
              audioService.pause();
            } else {
              service.playLecture(lec, customPlaylist: lectures);
            }
          },
          onFavoriteTap: () => service.toggleLectureFavorite(lec.id),
        );
      },
    );
  }
}

/// شاشة تفاصيل الشيخ ومقاطعه الصوتية المقسمة حسب المحتوى والتصنيف
class ScholarDetailLecturesScreen extends StatefulWidget {
  final ScholarProfile scholar;
  final LectureContentCategory initialCategory;

  const ScholarDetailLecturesScreen({
    super.key,
    required this.scholar,
    this.initialCategory = LectureContentCategory.all,
  });

  @override
  State<ScholarDetailLecturesScreen> createState() =>
      _ScholarDetailLecturesScreenState();
}

class _ScholarDetailLecturesScreenState
    extends State<ScholarDetailLecturesScreen> {
  late LectureContentCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    // فحص وتجهيز الروابط الصوتية الحقيقية المعزولة لهذا الشيخ من المصادر المتعددة
    ScholarAudioResolverService.instance.prewarmScholarAudio(widget.scholar.id);
  }

  @override
  Widget build(BuildContext context) {
    final service = ScholarsLecturesService.instance;
    final audioService = IslamicAudioService.instance;
    final resolverService = ScholarAudioResolverService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([
        service,
        audioService,
        resolverService,
        SettingsService.instance,
      ]),
      builder: (context, _) {
        final categoryCounts =
            service.getCategoryCountsForScholar(widget.scholar.id);
        final lectures = service.getLecturesForScholar(
          widget.scholar.id,
          category: _selectedCategory,
        );
        final isResolving =
            resolverService.isResolvingScholar(widget.scholar.id);

        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.scholar.name),
            ),
            bottomNavigationBar: const GlobalMiniPlayerBar(),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Scholar Bio Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F5B45), Color(0xFF093E2F)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                AppColors.accentGold.withOpacity(0.2),
                            child: const Icon(
                              Icons.mic_external_on_rounded,
                              color: AppColors.accentGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.scholar.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '${widget.scholar.titleHonorific} • ${widget.scholar.country}',
                                  style: const TextStyle(
                                    color: AppColors.softGold,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.scholar.bio,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isResolving
                                  ? Icons.sync_rounded
                                  : Icons.verified_user_rounded,
                              color: AppColors.accentGold,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isResolving
                                    ? 'جاري توثيق وجلب البث الصوتي المعزول لفضيلة ${widget.scholar.name}...'
                                    : 'عزل صوتي صارم ١٠٠٪ باسم ${widget.scholar.name} (${resolverService.sourcePreference.labelAr})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGold,
                            foregroundColor: Colors.black87,
                          ),
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: Text(
                            'تشغيل جميع دروس ${widget.scholar.name} بالتتابع (${lectures.length} درس)',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          onPressed: lectures.isEmpty
                              ? null
                              : () => service.playLecture(
                                    lectures.first,
                                    customPlaylist: lectures,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Content Category Filter Dropdown for this Scholar
                AppDropdownField<LectureContentCategory>(
                  label:
                      'تقسيم مقاطع ودروس ${widget.scholar.name} حسب المحتوى:',
                  value: categoryCounts.containsKey(_selectedCategory)
                      ? _selectedCategory
                      : LectureContentCategory.all,
                  prefixIcon: Icons.folder_special_rounded,
                  options: categoryCounts.entries
                      .map((e) => AppDropdownOption<LectureContentCategory>(
                            value: e.key,
                            label:
                                '${e.key.emoji} ${e.key.labelAr} (${e.value} دروس)',
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 10),

                // Audio Source Mirror Selector for this Scholar
                AppDropdownField<ScholarAudioSourcePreference>(
                  label:
                      'تبديل مصدر البث الصوتي لدروس ${widget.scholar.name}:',
                  value: resolverService.sourcePreference,
                  dense: true,
                  prefixIcon: Icons.dns_rounded,
                  options: ScholarAudioSourcePreference.values
                      .map(
                        (pref) =>
                            AppDropdownOption<ScholarAudioSourcePreference>(
                          value: pref,
                          label: pref.labelAr,
                          subtitle: pref.descriptionAr,
                        ),
                      )
                      .toList(),
                  onChanged: (pref) {
                    resolverService.setSourcePreference(pref);
                    resolverService.prewarmScholarAudio(widget.scholar.id);
                  },
                ),
                const SizedBox(height: 12),

                // Lectures List
                ...lectures.map((lec) {
                  final isPlayingThis =
                      audioService.currentTrack?.id == lec.id &&
                          audioService.isPlaying;
                  return _LectureCardWidget(
                    lecture: lec,
                    isPlaying: isPlayingThis,
                    isFavorite: service.isLectureFavorite(lec.id),
                    onPlayTap: () {
                      if (isPlayingThis) {
                        audioService.pause();
                      } else {
                        service.playLecture(lec, customPlaylist: lectures);
                      }
                    },
                    onFavoriteTap: () => service.toggleLectureFavorite(lec.id),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LectureCardWidget extends StatelessWidget {
  final ScholarAudioLecture lecture;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onPlayTap;
  final VoidCallback onFavoriteTap;

  const _LectureCardWidget({
    required this.lecture,
    required this.isPlaying,
    required this.isFavorite,
    required this.onPlayTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final sourceBadge = ScholarAudioResolverService.instance
        .getResolvedSourceBadge(lecture.id, lecture.scholarId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPlaying
              ? AppColors.primaryGreen
              : Colors.grey.withOpacity(0.2),
          width: isPlaying ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: onPlayTap,
                  borderRadius: BorderRadius.circular(24),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isPlaying
                        ? AppColors.accentGold
                        : AppColors.primaryGreen,
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lecture.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: isPlaying ? AppColors.primaryGreen : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '🎙️ ${lecture.scholarName} • 📚 ${lecture.seriesName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.accentGold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'حفظ في المفضلة',
                  icon: Icon(
                    isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isFavorite ? AppColors.primaryGreen : Colors.grey,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lecture.summary,
              style: const TextStyle(fontSize: 12.5, height: 1.45),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 13.5, color: AppColors.primaryGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'صوت معزول وموثق لـ ${lecture.scholarName} • $sourceBadge',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lecture.category.emoji} ${lecture.category.labelAr}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      lecture.durationFormatted,
                      style:
                          const TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.play_circle_outline_rounded,
                          size: 16),
                      label: Text(isPlaying ? 'قيد التشغيل' : 'استماع الآن'),
                      onPressed: onPlayTap,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
