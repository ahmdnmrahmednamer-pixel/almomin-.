import 'package:flutter/material.dart';
import '../../../core/services/asma_allah_shamail_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';

/// شاشة موسوعة أسماء الله الحسنى والشمائل المحمدية مع أنماط عرض متعددة
class AsmaAllahShamailScreen extends StatefulWidget {
  const AsmaAllahShamailScreen({super.key});

  @override
  State<AsmaAllahShamailScreen> createState() => _AsmaAllahShamailScreenState();
}

class _AsmaAllahShamailScreenState extends State<AsmaAllahShamailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AsmaAllahShamailService _service = AsmaAllahShamailService.instance;
  String _searchQuery = '';
  late ScreenStructureMode _layoutMode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _layoutMode = ScreenStructureMode.fromId(
      SettingsService.instance.screenLayoutMode,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDetailModal(BuildContext context, String title, String subtitle, String body, String footer, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(body, style: const TextStyle(fontSize: 14, height: 1.6)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  footer,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asmaItems = _service
        .searchAsma(_searchQuery)
        .map(
          (a) => StructuredScreenItem(
            id: 'asma_${a.number}',
            title: a.nameAr,
            subtitle: a.meaningSummary,
            badgeText: '#${a.number}',
            category: 'أسماء الله الحسنى',
            icon: Icons.stars_rounded,
            accentColor: const Color(0xFFB88917),
            onTap: () => _showDetailModal(
              context,
              a.nameAr,
              a.quranicReference,
              '${a.meaningSummary}\n\nأثر الإيمان بالاسم: ${a.tadabburAndImpact}',
              '🤲 الدعاء بهذا الاسم: ${a.duaaWithThisName}',
              isDark,
            ),
          ),
        )
        .toList();

    final shamailItems = _service
        .searchShamail(_searchQuery)
        .map(
          (s) => StructuredScreenItem(
            id: s.id,
            title: s.title,
            subtitle: s.hadithText,
            badgeText: s.category,
            category: s.category,
            icon: Icons.favorite_rounded,
            accentColor: AppColors.primaryGreen,
            onTap: () => _showDetailModal(
              context,
              s.title,
              s.narratorAndSource,
              s.hadithText,
              '🌿 السنة العملية في حياتك: ${s.practicalSunnah}',
              isDark,
            ),
          ),
        )
        .toList();

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أسماء الله الحسنى والشمائل المحمدية'),
          actions: [
            ScreenLayoutPopupButton(
              currentMode: _layoutMode,
              onChanged: (m) => setState(() => _layoutMode = m),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accentGold,
            tabs: const [
              Tab(icon: Icon(Icons.stars_rounded, size: 18), text: 'أسماء الله الحسنى وتدبرها'),
              Tab(icon: Icon(Icons.favorite_rounded, size: 18), text: 'الشمائل والأخلاق النبوية'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  AdaptiveLayoutSwitcherBar(
                    currentMode: _layoutMode,
                    onModeChanged: (m) {
                      SettingsService.instance.setScreenLayoutMode(m.id);
                      setState(() => _layoutMode = m);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث في أسماء الله الحسنى أو الشمائل النبوية...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkCard : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AdaptiveStructuredCollectionView(
                        mode: _layoutMode,
                        items: asmaItems,
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AdaptiveStructuredCollectionView(
                        mode: _layoutMode,
                        items: shamailItems,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
