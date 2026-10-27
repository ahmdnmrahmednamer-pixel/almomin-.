import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/prayer_service.dart';

void showSettingsCalculationMethodModal(BuildContext context) {
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
              const Text(
                'طريقة حساب مواقيت الصلاة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ...SettingsService.calculationMethods.map((m) {
                final isSelected = SettingsService.instance.calculationMethod == m['id'];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.accentGold : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB89628)])
                            : null,
                        color: isSelected ? null : AppColors.primaryGreen.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected ? Icons.check_rounded : Icons.calculate_rounded,
                        color: isSelected ? Colors.white : AppColors.primaryGreen,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      m['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        fontSize: 14.5,
                        color: isSelected ? AppColors.primaryGreen : null,
                      ),
                    ),
                    trailing: isSelected
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('المعتمدة ✓', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 11.5)),
                          )
                        : null,
                    onTap: () async {
                      await SettingsService.instance.setCalculationMethod(m['id']!);
                      PrayerService.instance.init();
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم تعديل طريقة الحساب إلى: ${m['name']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    },
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
