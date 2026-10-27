import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/arab_countries.dart';
import '../../core/models/egyptian_heritage.dart';
import '../../core/services/egyptian_heritage_service.dart';
import '../../core/audio/fast_audio_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/ui/adaptive_screen_layouts.dart';
import 'widgets/egypt_adaptive_hub_view.dart';

class EgyptianHeritageScreen extends StatefulWidget {
  final int initialTabIndex;

  const EgyptianHeritageScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<EgyptianHeritageScreen> createState() => _EgyptianHeritageScreenState();
}

class _EgyptianHeritageScreenState extends State<EgyptianHeritageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final EgyptianHeritageService _service = EgyptianHeritageService.instance;
  final FastAudioService _audioService = FastAudioService.instance;

  String _selectedMubtahil = 'الكل';
  String _selectedFatwaCategory = 'الكل';
  String _mosqueQuery = '';
  String _fatwaQuery = '';
  bool _favoritesOnly = false;
  String? _playingId;
  bool _isBuffering = false;
  ScreenStructureMode _layoutMode = ScreenStructureMode.classic;
  bool _showHubOverview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    _service.init();
    _layoutMode = ScreenStructureMode.fromId(SettingsService.instance.screenLayoutMode);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudioPlay({
    required String id,
    required String title,
    required String primaryUrl,
    List<String> fallbackUrls = const [],
  }) async {
    if (_playingId == id && _audioService.player.playing) {
      await _audioService.stop();
      if (mounted) {
        setState(() {
          _playingId = null;
          _isBuffering = false;
        });
      }
      return;
    }

    setState(() {
      _playingId = id;
      _isBuffering = true;
    });

    final ok = await _audioService.playResilient(
      primaryUrl,
      fallbackUrls: fallbackUrls,
    );

    if (!mounted) return;
    setState(() {
      _isBuffering = false;
      if (!ok) {
        _playingId = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'جاري تشغيل: $title'
              : 'تعذر الاتصال بالبث الصوتي حالياً، يرجى التحقق من الإنترنت.',
          style: const TextStyle(fontFamily: 'Amiri'),
        ),
        backgroundColor: ok ? AppColors.primaryGreen : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFFDFBF7),
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Row(
            children: [
              Text('🇪🇬 ', style: TextStyle(fontSize: 20)),
              Expanded(
                child: Text(
                  'واحة التراث المصري وإذاعة القاهرة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: _showHubOverview ? 'عرض التبويبات التفصيلية' : 'عرض البوابة المهيكلة',
              icon: Icon(_showHubOverview ? Icons.tab_rounded : Icons.grid_view_rounded),
              onPressed: () => setState(() => _showHubOverview = !_showHubOverview),
            ),
            ScreenLayoutPopupButton(
              currentMode: _layoutMode,
              onChanged: (m) => setState(() {
                _layoutMode = m;
                _showHubOverview = true;
              }),
            ),
            IconButton(
              tooltip: _favoritesOnly ? 'عرض الكل' : 'المفضلة فقط',
              icon: Icon(
                _favoritesOnly
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _favoritesOnly ? AppColors.accentGold : Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _favoritesOnly = !_favoritesOnly;
                });
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppColors.accentGold,
            indicatorWeight: 3,
            labelColor: AppColors.accentGold,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.radio_rounded, size: 20),
                text: 'إذاعة القرآن (98.2 FM)',
              ),
              Tab(
                icon: Icon(Icons.music_note_rounded, size: 20),
                text: 'الابتهالات والشعراوي',
              ),
              Tab(
                icon: Icon(Icons.mosque_rounded, size: 20),
                text: 'مساجد مصر التاريخية',
              ),
              Tab(
                icon: Icon(Icons.gavel_rounded, size: 20),
                text: 'فتاوى دار الإفتاء',
              ),
            ],
          ),
        ),
        body: AnimatedBuilder(
          animation: _service,
          builder: (context, _) {
            if (_showHubOverview) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AdaptiveLayoutSwitcherBar(
                    currentMode: _layoutMode,
                    onModeChanged: (m) {
                      SettingsService.instance.setScreenLayoutMode(m.id);
                      setState(() => _layoutMode = m);
                    },
                  ),
                  const SizedBox(height: 12),
                  EgyptAdaptiveHubView(
                    mode: _layoutMode,
                    onSelectTab: (idx) {
                      setState(() {
                        _showHubOverview = false;
                        if (_tabController.length > 0) _tabController.animateTo(idx.clamp(0, _tabController.length - 1));
                      });
                    },
                  ),
                ],
              );
            }
            return TabBarView(
              controller: _tabController,
              children: [
                _buildRadioTab(isDark),
                _buildIbtihalatAndShaarawiTab(isDark),
                _buildHistoricMosquesTab(isDark),
                _buildDarAlIftaTab(isDark),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRadioTab(bool isDark) {
    final stations = _favoritesOnly
        ? _service.radioStations
            .where((s) => _service.isFavorite(s.id))
            .toList()
        : _service.radioStations;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'إذاعة القرآن الكريم من القاهرة (98.2 FM)',
          subtitle:
              'منذ ٢٥ مارس ١٩٦٤م — صوت مدرسة التلاوة المصرية الأصيلة وبرامج كبار العلماء والمبتهلين على مدار الساعة',
          icon: Icons.radio_rounded,
        ),
        const SizedBox(height: 16),
        if (stations.isEmpty)
          _buildEmptyState('لا توجد إذاعات مفضلة حالياً')
        else
          ...stations.map((station) => _buildRadioStationCard(station, isDark)),
      ],
    );
  }

  Widget _buildRadioStationCard(EgyptianRadioStation station, bool isDark) {
    final isPlaying = _playingId == station.id;
    final isFav = _service.isFavorite(station.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPlaying
              ? AppColors.accentGold
              : AppColors.primaryGreen.withValues(alpha: 0.2),
          width: isPlaying ? 2 : 1,
        ),
      ),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: station.accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    station.icon,
                    color: station.accentColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${station.frequencyLabel} • ${station.broadcaster}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'حفظ في المفضلة',
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => _service.toggleFavorite(station.id),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                    foregroundColor: isPlaying ? Colors.black87 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _toggleAudioPlay(
                    id: station.id,
                    title: station.name,
                    primaryUrl: station.streamUrl,
                    fallbackUrls: station.fallbackStreamUrls,
                  ),
                  icon: _isBuffering && isPlaying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black87,
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  label: Text(isPlaying ? 'إيقاف' : 'استماع'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              station.description,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            if (station.dailySchedule.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              const Text(
                'الخريطة البرامجية اليومية من القاهرة:',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(height: 8),
              ...station.dailySchedule.map(
                (slot) {
                  final parts = slot.split(' — ');
                  final timeText = parts.isNotEmpty ? parts.first : '';
                  final progText =
                      parts.length > 1 ? parts.sublist(1).join(' — ') : slot;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            timeText,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            progText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIbtihalatAndShaarawiTab(bool isDark) {
    final mubtahileen = _service.mubtahileenList;
    final filteredIbtihalat = _service
        .getIbtihalatByMubtahil(_selectedMubtahil)
        .where((i) => !_favoritesOnly || _service.isFavorite(i.id))
        .toList();

    final shaarawiItems = _favoritesOnly
        ? _service.shaarawiReflections
            .where((r) => _service.isFavorite(r.id))
            .toList()
        : _service.shaarawiReflections;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'مدرسة الابتهالات المصرية وخواطر الشعراوي',
          subtitle:
              'ابتهالات الفجر والسحر للشيخ النقشبندي وطوبار وعمران والفشني، مع درر وخواطر إمام الدعاة الشيخ محمد متولي الشعراوي',
          icon: Icons.music_note_rounded,
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: mubtahileen.map((name) {
              final selected = _selectedMubtahil == name;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(name),
                  selected: selected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedMubtahil = name;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'روائع الابتهالات والتواشيح المصرية',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        if (filteredIbtihalat.isEmpty)
          _buildEmptyState('لا توجد ابتهالات مطابقة للفلتر الحالي')
        else
          ...filteredIbtihalat.map((item) => _buildIbtihalCard(item, isDark)),
        const SizedBox(height: 20),
        const Text(
          'خواطر وأدعية الشيخ محمد متولي الشعراوي',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.accentGold,
          ),
        ),
        const SizedBox(height: 8),
        if (shaarawiItems.isEmpty)
          _buildEmptyState('لا توجد خواطر مفضلة حالياً')
        else
          ...shaarawiItems.map((item) => _buildShaarawiCard(item, isDark)),
      ],
    );
  }

  Widget _buildIbtihalCard(EgyptianIbtihalItem item, bool isDark) {
    final isPlaying = _playingId == item.id;
    final isFav = _service.isFavorite(item.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${item.mubtahil} • ${item.maqamOrStyle} (${item.occasion})',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => _service.toggleFavorite(item.id),
                ),
                IconButton(
                  tooltip: 'تشغيل الابتهال',
                  icon: Icon(
                    isPlaying
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                    size: 34,
                  ),
                  onPressed: () => _toggleAudioPlay(
                    id: item.id,
                    title: '${item.title} - ${item.mubtahil}',
                    primaryUrl: item.audioUrl,
                    fallbackUrls: item.fallbackAudioUrls,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.lyricsExcerpt,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.spiritualNote,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShaarawiCard(ShaarawiReflectionItem item, bool isDark) {
    final isPlaying = _playingId == item.id;
    final isFav = _service.isFavorite(item.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.topic,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'حفظ في المفضلة',
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => _service.toggleFavorite(item.id),
                ),
                IconButton(
                  tooltip: 'تشغيل أو إيقاف الصوت',
                  icon: Icon(
                    isPlaying
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_fill_rounded,
                    color: isPlaying ? AppColors.accentGold : AppColors.primaryGreen,
                    size: 30,
                  ),
                  onPressed: () => _toggleAudioPlay(
                    id: item.id,
                    title: item.title,
                    primaryUrl: item.audioUrl,
                    fallbackUrls: item.fallbackAudioUrls,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '«${item.surahOrAyah}»',
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 15,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.reflectionText,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '💡 خلاصة الخاطرة: ${item.keyLesson}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoricMosquesTab(bool isDark) {
    final currentPrayerData = PrayerService.instance.currentData;
    final userLat = currentPrayerData?.latitude ?? 30.0444;
    final userLng = currentPrayerData?.longitude ?? 31.2357;

    final mosques = _service
        .searchMosques(_mosqueQuery)
        .where((m) => !_favoritesOnly || _service.isFavorite(m.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'دليل مساجد مصر التاريخية ومآذن المحروسة',
          subtitle:
              'تعرف على تاريخ المساجد الكبرى في مصر، المسافة التقريبية من موقعك الحالي، مع إمكانية ضبط مواقيت الصلاة والقبلة على أي مسجد بلمسة واحدة',
          icon: Icons.mosque_rounded,
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _mosqueQuery = v),
          decoration: InputDecoration(
            hintText: 'ابحث عن مسجد أو محافظة أو قارئ (مثل: الأزهر، الحسين، الحصري)...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (mosques.isEmpty)
          _buildEmptyState('لا توجد مساجد مطابقة للبحث الحالي')
        else
          ...mosques.map((mosque) {
            final distKm = _service.calculateDistanceKm(
              fromLat: userLat,
              fromLng: userLng,
              toLat: mosque.latitude,
              toLng: mosque.longitude,
            );
            final isFav = _service.isFavorite(mosque.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? AppTheme.darkCard : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.mosque_rounded,
                          color: AppColors.primaryGreen,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mosque.name,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${mosque.governorate} • ${mosque.era} (${mosque.foundedYear})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${distKm.toStringAsFixed(1)} كم',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'حفظ في المفضلة',
                          icon: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.grey,
                          ),
                          onPressed: () => _service.toggleFavorite(mosque.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mosque.architecturalHighlight,
                      style: const TextStyle(fontSize: 13.5, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎙️ أشهر القراء والأعلام: ${mosque.famousReciters}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.my_location_rounded, size: 18),
                        label: const Text(
                          'ضبط مواقيت الصلاة والقبلة على موقع هذا المسجد',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await PrayerService.instance.setManualCity(
                            CityCoordinate(
                              mosque.name,
                              mosque.latitude,
                              mosque.longitude,
                              'egyptian',
                              'مصر',
                            ),
                          );
                          if (!mounted) return;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم ضبط المواقيت والقبلة على ${mosque.name} وفق الهيئة المصرية العامة للمساحة',
                                style: const TextStyle(fontFamily: 'Amiri'),
                              ),
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDarAlIftaTab(bool isDark) {
    final categories = _service.fatwaCategories;
    final fatwas = _service
        .searchFatwas(_fatwaQuery, category: _selectedFatwaCategory)
        .where((f) => !_favoritesOnly || _service.isFavorite(f.id))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroBanner(
          title: 'الفتاوى الميسرة — دار الإفتاء المصرية والأزهر الشريف',
          subtitle:
              'أحكام فقهية معاصرة تهم الأسرة المصرية في الزكاة، الذهب والشبكة، شهادات الادخار، ومواقيت الصلاة والسفر',
          icon: Icons.gavel_rounded,
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (v) => setState(() => _fatwaQuery = v),
          decoration: InputDecoration(
            hintText: 'ابحث في الفتاوى (مثل: شهادات، ذهب، شبكة، فجر، سفر)...',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((cat) {
              final selected = _selectedFatwaCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedFatwaCategory = cat;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (fatwas.isEmpty)
          _buildEmptyState('لا توجد فتاوى مطابقة للبحث الحالي')
        else
          ...fatwas.map((fatwa) {
            final isFav = _service.isFavorite(fatwa.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: isDark ? AppTheme.darkCard : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            fatwa.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'نسخ الفتوى',
                          icon: const Icon(Icons.copy_rounded, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    'السؤال: ${fatwa.question}\n\nالجواب: ${fatwa.rulingSummary}\n\nالمصدر: ${fatwa.sourceAuthority} (${fatwa.referenceNote})',
                              ),
                            ).catchError((_) {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ الفتوى إلى الحافظة'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'حفظ في المفضلة',
                          icon: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.grey,
                          ),
                          onPressed: () => _service.toggleFavorite(fatwa.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'س: ${fatwa.question}',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ج: ${fatwa.rulingSummary}',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '📜 المصدر: ${fatwa.sourceAuthority} — ${fatwa.referenceNote}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHeroBanner({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF0A3D2E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.accentGold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white70,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
