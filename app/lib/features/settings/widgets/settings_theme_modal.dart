import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';

void showSettingsThemeModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'مظهر التطبيق والوضع الليلي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر سمة الألوان ومستوى السواد الملائم لعينيك وجهازك',
                style: TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ...SettingsService.availableThemeModes.map((tm) {
                final isSelected = SettingsService.instance.themeMode == tm['id'];
                IconData icon;
                List<Color> gradientColors;
                switch (tm['id']) {
                  case 'light':
                    icon = Icons.wb_sunny_rounded;
                    gradientColors = [const Color(0xFFF7B733), const Color(0xFFFC4A1A)];
                    break;
                  case 'dark':
                    icon = Icons.dark_mode_rounded;
                    gradientColors = [const Color(0xFF2C3E50), const Color(0xFF1A1A24)];
                    break;
                  case 'oled':
                    icon = Icons.brightness_2_rounded;
                    gradientColors = [const Color(0xFF000000), const Color(0xFF1A1A1A)];
                    break;
                  case 'system':
                  default:
                    icon = Icons.brightness_auto_rounded;
                    gradientColors = [AppColors.primaryGreen, AppColors.secondaryGreen];
                    break;
                }

                return Material(
                  color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          shape: BoxShape.circle,
                          border: tm['id'] == 'oled' ? Border.all(color: AppColors.accentGold, width: 1) : null,
                        ),
                        child: Icon(
                          icon,
                          color: tm['id'] == 'light' ? Colors.white : (tm['id'] == 'oled' ? AppColors.accentGold : Colors.white),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        tm['name']!,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14.5,
                          color: isSelected ? AppColors.primaryGreen : null,
                        ),
                      ),
                      subtitle: Text(
                        tm['desc']!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isSelected ? AppColors.secondaryGreen : AppColors.mutedText,
                        ),
                      ),
                      trailing: isSelected
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('المحدد ✓', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 11.5)),
                            )
                          : null,
                      onTap: () async {
                        await SettingsService.instance.setThemeMode(tm['id']!);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم تفعيل: ${tm['name']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              backgroundColor: AppColors.primaryGreen,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}
