import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/ui/app_dropdown_field.dart';

/// Opens the Refactored Multi-Language & Translation Selector Bottom Sheet (6 Languages)
void showSettingsLanguageModal(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final settings = SettingsService.instance;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          final currentCode = settings.languageCode;

          return Directionality(
            textDirection: settings.textDirection,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.86,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14221A) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.accentGold.withOpacity(0.3)),
                          ),
                          child: const Icon(
                            Icons.language_rounded,
                            color: AppColors.primaryGreen,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('app_language'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('select_language'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق أو مسح',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Scrollable list of all 6 languages + translation controls
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ...AppLanguage.values.map((lang) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildLanguageCard(
                                context: context,
                                code: lang.code,
                                flagEmoji: lang.flagEmoji,
                                primaryTitle: lang.nativeName,
                                secondaryTitle: lang.englishName,
                                description: lang.description,
                                isSelected: currentCode == lang.code,
                                isDark: isDark,
                                onTap: () async {
                                  if (settings.hapticEnabled) HapticFeedback.selectionClick();
                                  await settings.setLanguage(lang.code);
                                },
                              ),
                            );
                          }),
                          const Divider(height: 20),
                          AppDropdownField<String>(
                            label: context.tr('quran_translation_lang'),
                            value: settings.quranTranslationEdition,
                            prefixIcon: Icons.translate_rounded,
                            options: QuranTranslationEdition
                                .availableTranslations
                                .map((t) => AppDropdownOption<String>(
                                      value: t.id,
                                      label: settings.isArabic
                                          ? t.nameAr
                                          : t.nameNative,
                                      subtitle: t.author,
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                settings.setQuranTranslationEdition(val),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            secondary: const Icon(Icons.subtitles_rounded,
                                color: AppColors.primaryGreen),
                            title: Text(
                              context.tr('bilingual_mode'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                            subtitle: Text(
                              context.tr('bilingual_mode_sub'),
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            activeColor: AppColors.accentGold,
                            activeTrackColor: AppColors.primaryGreen,
                            value: settings.bilingualDisplayEnabled,
                            onChanged: (val) =>
                                settings.toggleBilingualDisplay(val),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildLanguageCard({
  required BuildContext context,
  required String code,
  required String flagEmoji,
  required String primaryTitle,
  required String secondaryTitle,
  required String description,
  required bool isSelected,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryGreen.withOpacity(isDark ? 0.25 : 0.12)
            : (isDark ? const Color(0xFF1B2C22) : const Color(0xFFF7FAF8)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryGreen
              : (isDark ? const Color(0xFF2C4537) : const Color(0xFFE2EBE5)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1E16) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.accentGold
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              flagEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      primaryTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primaryGreen : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '($secondaryTitle)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryGreen : Colors.transparent,
              border: Border.all(
                color:
                    isSelected ? AppColors.primaryGreen : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 15, color: Colors.white)
                : null,
          ),
        ],
      ),
    ),
  );
}
