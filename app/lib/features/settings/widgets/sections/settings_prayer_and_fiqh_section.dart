import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/prayer_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_dropdown_field.dart';
import '../../../prayer/widgets/arab_city_picker_modal.dart';
import 'settings_section_header.dart';

/// Refactored Section 3: Prayer Calculation, Fiqh Madhhab & Hijri Adjustment
class SettingsPrayerAndFiqhSection extends StatelessWidget {
  const SettingsPrayerAndFiqhSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SettingsService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: context.tr('section_prayer_fiqh'),
          icon: Icons.mosque_rounded,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppDropdownField<String>(
            label: context.tr('calc_method'),
            value: s.calculationMethod,
            prefixIcon: Icons.calculate_rounded,
            options: SettingsService.calculationMethods
                .map((m) => AppDropdownOption<String>(
                      value: m['id']!,
                      label: m['name']!,
                    ))
                .toList(),
            onChanged: (val) => s.setCalculationMethod(val),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: AppDropdownField<String>(
                  label: context.tr('fiqh_madhhab'),
                  value: s.fiqhMadhhab,
                  dense: true,
                  prefixIcon: Icons.balance_rounded,
                  options: const [
                    AppDropdownOption(
                        value: 'shafii_egypt',
                        label: 'الشافعي / دار الإفتاء المصرية'),
                    AppDropdownOption(value: 'hanafi', label: 'المذهب الحنفي'),
                    AppDropdownOption(value: 'maliki', label: 'المذهب المالكي'),
                    AppDropdownOption(value: 'hanbali', label: 'المذهب الحنبلي'),
                    AppDropdownOption(
                        value: 'comparative', label: 'الفقه المقارن العام'),
                  ],
                  onChanged: (val) => s.setFiqhMadhhab(val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppDropdownField<int>(
                  label: context.tr('hijri_adjust'),
                  value: s.hijriAdjustmentDays,
                  dense: true,
                  prefixIcon: Icons.nightlight_round,
                  options: const [
                    AppDropdownOption(value: -2, label: '-٢ يوم'),
                    AppDropdownOption(value: -1, label: '-١ يوم'),
                    AppDropdownOption(value: 0, label: 'فلكي (٠)'),
                    AppDropdownOption(value: 1, label: '+١ يوم'),
                    AppDropdownOption(value: 2, label: '+٢ يوم'),
                  ],
                  onChanged: (val) => s.setHijriAdjustmentDays(val),
                ),
              ),
            ],
          ),
        ),

        ListTile(
          leading: const Icon(Icons.location_city_rounded,
              color: AppColors.primaryGreen),
          title: const Text('اختيار الدولة والمدينة يدوياً (قوائم منسدلة)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
          subtitle: Text(
              PrayerService.instance.currentData?.locationName ?? 'القاهرة، مصر'),
          trailing: OutlinedButton.icon(
            icon: const Icon(Icons.my_location_rounded, size: 16),
            label: const Text('GPS'),
            onPressed: () => PrayerService.instance.requestGpsLocation(),
          ),
          onTap: () => showArabCityPickerModal(context),
        ),
        const Divider(),
      ],
    );
  }
}
