import 'package:flutter/material.dart';
import '../../../core/services/egyptian_heritage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive_screen_layouts.dart';

/// عارض مهيكلي متكيف لأقسام التراث المصري الأربعة (يتيح التبديل بين التبويبات، الشبكة، المجلة، والقائمة المدمجة)
class EgyptAdaptiveHubView extends StatelessWidget {
  final ScreenStructureMode mode;
  final ValueChanged<int> onSelectTab;

  const EgyptAdaptiveHubView({
    super.key,
    required this.mode,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final service = EgyptianHeritageService.instance;

    final items = [
      StructuredScreenItem(
        id: 'eg_hub_radio',
        title: 'إذاعة القرآن الكريم من القاهرة (98.2 FM)',
        subtitle:
            '${EgyptianHeritageService.radioStations.length} محطات بث مباشر تشمل إذاعة القاهرة والخريطة البرامجية اليومية وأعلام التلاوة',
        badgeText: '98.2 FM',
        category: 'البث الإذاعي الحي',
        icon: Icons.radio_rounded,
        accentColor: AppColors.primaryGreen,
        onTap: () => onSelectTab(0),
      ),
      StructuredScreenItem(
        id: 'eg_hub_ibtihalat',
        title: 'مدرسة الابتهالات وخواطر الشيخ الشعراوي',
        subtitle:
            '${service.ibtihalat.length} ابتهالات خالدة (النقشبندي، طوبار، عمران، الفشني) + ${EgyptianHeritageService.shaarawiReflections.length} خواطر وأدعية للشعراوي',
        badgeText: 'صوتيات وكلمات',
        category: 'التراث الروحي',
        icon: Icons.music_note_rounded,
        accentColor: const Color(0xFFB88917),
        onTap: () => onSelectTab(1),
      ),
      StructuredScreenItem(
        id: 'eg_hub_mosques',
        title: 'دليل مساجد مصر التاريخية ومآذن المحروسة',
        subtitle:
            '${EgyptianHeritageService.historicMosques.length} مساجد تاريخية كبرى مع حساب المسافة بالكيلومتر وضبط المواقيت والقبلة بلمسة واحدة',
        badgeText: '١٠ مساجد',
        category: 'المعالم الإسلامية',
        icon: Icons.mosque_rounded,
        accentColor: const Color(0xFF0D5C46),
        onTap: () => onSelectTab(2),
      ),
      StructuredScreenItem(
        id: 'eg_hub_fatwas',
        title: 'موسوعة فتاوى دار الإفتاء المصرية والأزهر',
        subtitle:
            '${service.darAlIftaRulings.length} أبواب فقهية معاصرة تهم الأسرة المصرية في الشهادات البنكية، الذهب، الشبكة، والزكاة',
        badgeText: 'دار الإفتاء',
        category: 'الفتاوى المعتمدة',
        icon: Icons.gavel_rounded,
        accentColor: const Color(0xFF1F6E58),
        onTap: () => onSelectTab(3),
      ),
    ];

    return AdaptiveStructuredCollectionView(
      mode: mode,
      items: items,
    );
  }
}
