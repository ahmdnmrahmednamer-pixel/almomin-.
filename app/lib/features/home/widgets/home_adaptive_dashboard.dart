import 'package:flutter/material.dart';
import '../../../core/services/daily_wird_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';
import '../../library/screens/asma_allah_shamail_screen.dart';
import '../../library/screens/fiqh_library_screen.dart';
import '../../library/screens/islamic_history_screen.dart';
import '../../library/screens/quran_sciences_screen.dart';
import '../../library/screens/unified_library_search_screen.dart';
import '../../studio/daawah_card_studio_screen.dart';
import '../../wird/daily_wird_screen.dart';

/// لوحة الوصول المتكيفة في الصفحة الرئيسية (تدمج الورد اليومي، البحث الموسوعي، والمكتبات الجديدة مع مبدل تخطيط الشاشة)
class HomeAdaptiveDashboardBanner extends StatelessWidget {
  final ScreenStructureMode currentMode;
  final ValueChanged<ScreenStructureMode> onModeChanged;

  const HomeAdaptiveDashboardBanner({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    void push(Widget page) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }

    final hubItems = [
      StructuredScreenItem(
        id: 'home_wird',
        title: 'الورد اليومي الذكي',
        subtitle: 'خطة الطاعات اليومية والسنن الرواتب والأذكار',
        badgeText:
            '${(DailyWirdService.instance.getTodayCompletionRatio() * 100).round()}%',
        category: 'المتابعة اليومية',
        icon: Icons.task_alt_rounded,
        accentColor: AppColors.primaryGreen,
        onTap: () => push(const DailyWirdScreen()),
      ),
      StructuredScreenItem(
        id: 'home_fiqh',
        title: 'موسوعة الفقه الميسر',
        subtitle: 'فقه العبادات والمعاملات على المذاهب الأربعة',
        badgeText: '٤ مذاهب',
        category: 'الفقه المقارن',
        icon: Icons.balance_rounded,
        accentColor: const Color(0xFF0D5C46),
        onTap: () => push(const FiqhLibraryScreen()),
      ),
      StructuredScreenItem(
        id: 'home_quran_sciences',
        title: 'علوم القرآن وأسباب النزول',
        subtitle: 'أسباب النزول، المكي والمدني، وفضائل ومقاصد السور',
        badgeText: 'علوم القرآن',
        category: 'التدبر القرآني',
        icon: Icons.menu_book_rounded,
        accentColor: const Color(0xFF1F6E58),
        onTap: () => push(const QuranSciencesScreen()),
      ),
      StructuredScreenItem(
        id: 'home_asma_shamail',
        title: 'أسماء الله والشمائل النبوية',
        subtitle: 'تدبر الأسماء الحسنى والدعاء بها وشمائل النبي ﷺ',
        badgeText: '٩٩ اسماً',
        category: 'الإيمان والتزكية',
        icon: Icons.stars_rounded,
        accentColor: const Color(0xFFB88917),
        onTap: () => push(const AsmaAllahShamailScreen()),
      ),
      StructuredScreenItem(
        id: 'home_history',
        title: 'التاريخ الإسلامي والصحابة',
        subtitle: 'السيرة والغزوات والخلفاء الراشدون وأعلام الأمة',
        badgeText: 'السيرة والأعلام',
        category: 'التاريخ الإسلامي',
        icon: Icons.history_edu_rounded,
        accentColor: const Color(0xFF6B4C35),
        onTap: () => push(const IslamicHistoryScreen()),
      ),
      StructuredScreenItem(
        id: 'home_studio',
        title: 'استوديو البطاقات والبحث الشامل',
        subtitle: 'تصميم بطاقات الآيات والبحث الموحد في ١٠ مكتبات',
        badgeText: 'أدوات ذكية',
        category: 'المشاركة والبحث',
        icon: Icons.palette_rounded,
        accentColor: const Color(0xFF1565C0),
        onTap: () => push(const DaawahCardStudioScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveLayoutSwitcherBar(
          currentMode: currentMode,
          onModeChanged: (mode) {
            SettingsService.instance.setScreenLayoutMode(mode.id);
            onModeChanged(mode);
          },
          title: 'هيكل عرض الشاشة:',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.library_books_rounded,
              size: 18,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'الموسوعات العلمية والورد اليومي الذكي',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.manage_search_rounded, size: 17),
              label: const Text('بحث شامل في ١٠ مكتبات', style: TextStyle(fontSize: 12)),
              onPressed: () => push(const UnifiedLibrarySearchScreen()),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AdaptiveStructuredCollectionView(
          mode: currentMode,
          items: hubItems,
        ),
      ],
    );
  }
}
