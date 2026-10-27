import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';

void showSettingsFontSizeModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: StatefulBuilder(
          builder: (ctx, setLocalState) {
            final currentSize = SettingsService.instance.mushafFontSize;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'حجم خط المصحف الشريف',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: currentSize,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('أ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Slider(
                          value: currentSize.clamp(18.0, 38.0),
                          min: 18.0,
                          max: 38.0,
                          divisions: 10,
                          activeColor: AppColors.primaryGreen,
                          inactiveColor: AppColors.accentGold.withOpacity(0.4),
                          onChanged: (val) {
                            setLocalState(() {});
                            SettingsService.instance.setMushafFontSize(val);
                          },
                        ),
                      ),
                      const Text('أ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${currentSize.toInt()} نقطة', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryGreen, fontSize: 13)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
