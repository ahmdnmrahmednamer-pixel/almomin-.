import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/islamic_audio_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/tafsir_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_dropdown_field.dart';
import 'settings_section_header.dart';

/// Refactored Section 2: Quran, Recitation, Tafsir & Audio DSP Settings
class SettingsQuranAndAudioSection extends StatelessWidget {
  const SettingsQuranAndAudioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final s = SettingsService.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: context.tr('section_quran_audio'),
          icon: Icons.menu_book_rounded,
        ),

        // 1. Default Reciter Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppDropdownField<String>(
            label: context.tr('default_reciter'),
            value: s.selectedReciterId,
            prefixIcon: Icons.record_voice_over_rounded,
            options: SettingsService.availableReciters
                .map((r) => AppDropdownOption<String>(
                      value: r.id,
                      label: r.nameAr,
                      subtitle: r.style,
                    ))
                .toList(),
            onChanged: (val) => s.setSelectedReciter(val),
          ),
        ),

        // 2. Default Tafsir Dropdown (9 Editions)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppDropdownField<String>(
            label: context.tr('default_tafsir'),
            value: s.defaultTafsirEdition,
            prefixIcon: Icons.auto_stories_rounded,
            options: TafsirService.availableEditions
                .map((ed) => AppDropdownOption<String>(
                      value: ed.id,
                      label: ed.nameAr,
                    ))
                .toList(),
            onChanged: (val) => s.setDefaultTafsirEdition(val),
          ),
        ),

        // 3. Audio Clarity & Quality Preset Dropdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: AppDropdownField<String>(
            label: context.tr('audio_dsp_preset'),
            value: s.audioQualityPreset,
            prefixIcon: Icons.graphic_eq_rounded,
            options: AudioClarityPreset.values
                .map((p) => AppDropdownOption<String>(
                      value: p.id,
                      label: p.labelAr,
                    ))
                .toList(),
            onChanged: (val) => s.setAudioQualityPreset(val),
          ),
        ),

        // 4. Playback Speed & Ayah Repeat Dropdowns
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: AppDropdownField<double>(
                  label: context.tr('playback_speed'),
                  value: s.defaultPlaybackSpeed,
                  dense: true,
                  prefixIcon: Icons.speed_rounded,
                  options: const [
                    AppDropdownOption(value: 0.75, label: 'هادئة (0.75x)'),
                    AppDropdownOption(value: 1.0, label: 'طبيعية (1.0x)'),
                    AppDropdownOption(value: 1.25, label: 'متوسطة (1.25x)'),
                    AppDropdownOption(value: 1.5, label: 'حدر سريع (1.5x)'),
                  ],
                  onChanged: (val) => s.setDefaultPlaybackSpeed(val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppDropdownField<int>(
                  label: context.tr('ayah_repeat'),
                  value: s.ayahRepeatCount,
                  dense: true,
                  prefixIcon: Icons.repeat_one_rounded,
                  options: const [
                    AppDropdownOption(value: 1, label: 'مرة واحدة'),
                    AppDropdownOption(value: 2, label: 'مرتان (٢)'),
                    AppDropdownOption(value: 3, label: '٣ مرات للحفظ'),
                    AppDropdownOption(value: 5, label: '٥ مرات للتمكين'),
                    AppDropdownOption(value: 7, label: '٧ مرات للتثبيت'),
                  ],
                  onChanged: (val) => s.setAyahRepeatCount(val),
                ),
              ),
            ],
          ),
        ),

        // 5. Mushaf Font Size & Default Mode Dropdowns
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: AppDropdownField<double>(
                  label: context.tr('font_size'),
                  value: [18.0, 22.0, 24.0, 28.0, 32.0, 36.0]
                          .contains(s.mushafFontSize)
                      ? s.mushafFontSize
                      : 24.0,
                  dense: true,
                  prefixIcon: Icons.format_size_rounded,
                  options: const [
                    AppDropdownOption(value: 18.0, label: '١٨ نقطة (صغير)'),
                    AppDropdownOption(value: 22.0, label: '٢٢ نقطة (متوسط)'),
                    AppDropdownOption(value: 24.0, label: '٢٤ نقطة (قياسي)'),
                    AppDropdownOption(value: 28.0, label: '٢٨ نقطة (كبير)'),
                    AppDropdownOption(value: 32.0, label: '٣٢ نقطة (واضح جداً)'),
                    AppDropdownOption(value: 36.0, label: '٣٦ نقطة (كبير جداً)'),
                  ],
                  onChanged: (val) => s.setMushafFontSize(val),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppDropdownField<String>(
                  label: context.tr('mushaf_mode'),
                  value: s.mushafDefaultMode,
                  dense: true,
                  prefixIcon: Icons.menu_book_rounded,
                  options: const [
                    AppDropdownOption(
                        value: 'page', label: 'صفحات المصحف (٦٠٤)'),
                    AppDropdownOption(
                        value: 'text', label: 'القراءة النصية المتتابعة'),
                  ],
                  onChanged: (val) => s.setMushafDefaultMode(val),
                ),
              ),
            ],
          ),
        ),

        SwitchListTile(
          secondary: const Icon(Icons.playlist_play_rounded,
              color: AppColors.primaryGreen),
          title: Text(context.tr('auto_play_next'),
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
          subtitle: const Text(
              'متابعة التلاوة والاستماع تباعاً دون توقف بعد انتهاء كل آية',
              style: TextStyle(fontSize: 12)),
          activeColor: AppColors.accentGold,
          activeTrackColor: AppColors.primaryGreen,
          value: s.autoPlayNextAyah,
          onChanged: (val) => s.toggleAutoPlayNextAyah(val),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.brightness_high_rounded,
              color: AppColors.primaryGreen),
          title: Text(context.tr('keep_screen_on'),
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
          subtitle: const Text(
              'منع إطفاء الشاشة تلقائياً أثناء تلاوة القرآن ومتابعة الورد',
              style: TextStyle(fontSize: 12)),
          activeColor: AppColors.accentGold,
          activeTrackColor: AppColors.primaryGreen,
          value: s.keepScreenOn,
          onChanged: (val) => s.toggleKeepScreenOn(val),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.wifi_rounded, color: Colors.teal),
          title: Text(context.tr('wifi_only'),
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
          subtitle: const Text(
              'توفير باقة بيانات الجوال عند تنزيل السور الكاملة',
              style: TextStyle(fontSize: 12)),
          activeColor: AppColors.accentGold,
          activeTrackColor: AppColors.primaryGreen,
          value: s.downloadOverWifiOnly,
          onChanged: (val) => s.toggleDownloadOverWifiOnly(val),
        ),
        const Divider(),
      ],
    );
  }
}
