import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/settings_service.dart';
import 'app_dropdown_field.dart';

/// أنماط هيكلة وعرض الشاشات المتعددة في الإصدار النهائي لتطبيق نور المؤمن
enum ScreenStructureMode {
  classic('classic', 'التخطيط الكلاسيكي', Icons.view_agenda_outlined),
  bentoGrid('bento', 'شبكة البطاقات الذكية', Icons.grid_view_rounded),
  magazine('magazine', 'تخطيط المجلة الموسعة', Icons.auto_awesome_mosaic_rounded),
  compact('compact', 'القائمة المدمجة السريعة', Icons.toc_rounded);

  final String id;
  final String labelAr;
  final IconData icon;

  const ScreenStructureMode(this.id, this.labelAr, this.icon);

  static ScreenStructureMode fromId(String? id) {
    for (final mode in ScreenStructureMode.values) {
      if (mode.id == id) return mode;
    }
    return ScreenStructureMode.classic;
  }
}

/// نموذج عنصر معياري قابل للعرض في أي نمط من أنماط الشاشات الأربعة
class StructuredScreenItem {
  final String id;
  final String title;
  final String subtitle;
  final String? badgeText;
  final String? category;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const StructuredScreenItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.category,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.trailing,
  });
}

/// شريط التبديل الفوري بين أنماط هيكلة الشاشة (يوضع في أعلى الشاشة أو داخل AppBar)
class AdaptiveLayoutSwitcherBar extends StatelessWidget {
  final ScreenStructureMode currentMode;
  final ValueChanged<ScreenStructureMode> onModeChanged;
  final String title;

  const AdaptiveLayoutSwitcherBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.title = 'نمط عرض الشاشة:',
  });

  @override
  Widget build(BuildContext context) {
    return AppDropdownField<ScreenStructureMode>(
      label: title,
      value: currentMode,
      dense: true,
      prefixIcon: Icons.dashboard_customize_rounded,
      options: ScreenStructureMode.values
          .map((mode) => AppDropdownOption<ScreenStructureMode>(
                value: mode,
                label: mode.labelAr,
                icon: mode.icon,
              ))
          .toList(),
      onChanged: onModeChanged,
    );
  }
}

/// زر أيقونة مدمج في AppBar لتغيير تخطيط الشاشة وحفظه في الإعدادات
class ScreenLayoutPopupButton extends StatelessWidget {
  final ScreenStructureMode currentMode;
  final ValueChanged<ScreenStructureMode> onChanged;

  const ScreenLayoutPopupButton({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ScreenStructureMode>(
      tooltip: 'تغيير هيكل وتخطيط الشاشة',
      icon: const Icon(Icons.dashboard_customize_rounded),
      initialValue: currentMode,
      onSelected: (mode) {
        SettingsService.instance.setScreenLayoutMode(mode.id);
        onChanged(mode);
      },
      itemBuilder: (context) => ScreenStructureMode.values.map((mode) {
        final isSelected = mode == currentMode;
        return PopupMenuItem<ScreenStructureMode>(
          value: mode,
          child: Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: Row(
              children: [
                Icon(
                  mode.icon,
                  size: 19,
                  color: isSelected ? AppColors.primaryGreen : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mode.labelAr,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primaryGreen : null,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: AppColors.primaryGreen,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// عارض متكيف يعرض قائمة من العناصر المهيكلية وفق النمط المختار (شبكي، مجلة، مدمج، كلاسيكي)
class AdaptiveStructuredCollectionView extends StatelessWidget {
  final ScreenStructureMode mode;
  final List<StructuredScreenItem> items;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AdaptiveStructuredCollectionView({
    super.key,
    required this.mode,
    required this.items,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (mode) {
      case ScreenStructureMode.bentoGrid:
        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.18,
          ),
          itemBuilder: (context, index) =>
              _buildBentoCard(items[index], isDark),
        );

      case ScreenStructureMode.magazine:
        return Column(
          children: [
            for (int i = 0; i < items.length; i++)
              _buildMagazineCard(items[i], isDark, isFeatured: i == 0),
          ],
        );

      case ScreenStructureMode.compact:
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _buildCompactTile(items[i], isDark),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 52,
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
              ],
            ],
          ),
        );

      case ScreenStructureMode.classic:
        return Column(
          children: items
              .map((item) => _buildClassicCard(item, isDark))
              .toList(),
        );
    }
  }

  Widget _buildBentoCard(StructuredScreenItem item, bool isDark) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.accentColor.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: item.accentColor.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.accentColor, size: 22),
                ),
                const Spacer(),
                if (item.badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.badgeText!,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: item.accentColor,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.35,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMagazineCard(
    StructuredScreenItem item,
    bool isDark, {
    bool isFeatured = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(isFeatured ? 18 : 14),
          decoration: BoxDecoration(
            gradient: isFeatured
                ? LinearGradient(
                    colors: [
                      item.accentColor,
                      item.accentColor.withValues(alpha: 0.82),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: isFeatured
                ? null
                : (isDark ? AppTheme.darkCard : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFeatured
                  ? AppColors.accentGold.withValues(alpha: 0.5)
                  : item.accentColor.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isFeatured ? 54 : 46,
                height: isFeatured ? 54 : 46,
                decoration: BoxDecoration(
                  color: isFeatured
                      ? Colors.white.withValues(alpha: 0.18)
                      : item.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  item.icon,
                  color: isFeatured ? Colors.white : item.accentColor,
                  size: isFeatured ? 28 : 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.category != null || item.badgeText != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          item.badgeText ?? item.category ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFeatured
                                ? AppColors.softGold
                                : item.accentColor,
                          ),
                        ),
                      ),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: isFeatured ? 18 : 16.5,
                        fontWeight: FontWeight.bold,
                        color: isFeatured ? Colors.white : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFeatured
                            ? Colors.white70
                            : (isDark ? Colors.white60 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: isFeatured ? Colors.white70 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTile(StructuredScreenItem item, bool isDark) {
    return ListTile(
      dense: true,
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Icon(item.icon, color: item.accentColor, size: 22),
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        item.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11.5),
      ),
      trailing: item.badgeText != null
          ? Text(
              item.badgeText!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: item.accentColor,
              ),
            )
          : const Icon(Icons.chevron_right_rounded, size: 18),
    );
  }

  Widget _buildClassicCard(StructuredScreenItem item, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: isDark ? AppTheme.darkCard : Colors.white,
      child: ListTile(
        onTap: item.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.accentColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.accentColor, size: 24),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          item.subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: item.trailing ??
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
      ),
    );
  }
}
