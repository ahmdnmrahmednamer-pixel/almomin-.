import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive_screen_layouts.dart';
import '../../../../core/ui/app_dropdown_field.dart';
import '../settings_language_modal.dart';
import 'settings_section_header.dart';

/// Refactored Section 1: Multi-Language Switcher (6 Languages), Quran Translation, Theme & Layout
class SettingsLanguageAndAppearanceSection extends StatelessWidget {
  const SettingsLanguageAndAppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SettingsService.instance;
    final isAr = s.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: context.tr('section_language_appearance'),
          icon: Icons.language_rounded,
        ),

        // Quick Language Switcher Banner + 6-Language Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.10),
                  AppColors.accentGold.withOpacity(0.08),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.translate_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('app_language'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: Text(
                        isAr ? 'معاينة اللغات' : 'Languages Sheet',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => showSettingsLanguageModal(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppDropdownField<String>(
                  label: context.tr('select_language'),
                  value: s.languageCode,
                  prefixIcon: Icons.language_rounded,
                  options: AppLanguage.values
                      .map((lang) => AppDropdownOption<String>(
                            value: lang.code,
                            label:
                                '${lang.flagEmoji} ${lang.nativeName} (${lang.englishName})',
                            subtitle: lang.description,
                          ))
                      .toList(),
                  onChanged: (val) => s.setLanguage(val),
                ),
                const SizedBox(height: 10),
                AppDropdownField<String>(
                  label: context.tr('quran_translation_lang'),
                  value: s.quranTranslationEdition,
                  dense: true,
                  prefixIcon: Icons.menu_book_rounded,
                  options: QuranTranslationEdition.availableTranslations
                      .map((t) => AppDropdownOption<String>(
                            value: t.id,
                            label: isAr ? t.nameAr : t.nameNative,
                            subtitle: t.author,
                          ))
                      .toList(),
                  onChanged: (val) => s.setQuranTranslationEdition(val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  secondary: const Icon(
                    Icons.subtitles_rounded,
                    color: AppColors.primaryGreen,
                  ),
                  title: Text(
                    context.tr('bilingual_mode'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: Text(
                    context.tr('bilingual_mode_sub'),
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  activeColor: AppColors.accentGold,
                  activeTrackColor: AppColors.primaryGreen,
                  value: s.bilingualDisplayEnabled,
                  onChanged: (val) => s.toggleBilingualDisplay(val),
                ),
              ],
            ),
          ),
        ),

        // Theme Mode ListTile & Modal
        ListTile(
          leading: const Icon(
            Icons.brightness_medium_rounded,
            color: AppColors.primaryGreen,
          ),
          title: const Text(
            'مظهر التطبيق والوضع الليلي (Dark & OLED)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(s.themeModeName),
          trailing: const Icon(Icons.chevron_left_rounded),
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('الوضع الليلي الفاخر (OLED أسود نقي)'),
                      onTap: () {
                        Navigator.pop(ctx);
                        s.setThemeMode('oled');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'تم تفعيل: الوضع الليلي الفاخر (OLED أسود نقي)'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text('الوضع الداكن الهادئ'),
                      onTap: () {
                        Navigator.pop(ctx);
                        s.setThemeMode('dark');
                      },
                    ),
                    ListTile(
                      title: const Text('الوضع الفاتح (النهاري)'),
                      onTap: () {
                        Navigator.pop(ctx);
                        s.setThemeMode('light');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppDropdownField<String>(
            label: context.tr('screen_layout'),
            value: s.screenLayoutMode,
            dense: true,
            prefixIcon: Icons.dashboard_customize_rounded,
            options: ScreenStructureMode.values
                .map((m) => AppDropdownOption<String>(
                      value: m.id,
                      label: m.labelAr,
                    ))
                .toList(),
            onChanged: (val) => s.setScreenLayoutMode(val),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
