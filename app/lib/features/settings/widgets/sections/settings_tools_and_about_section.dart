import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../adhkar/widgets/sharawi_post_prayer_card.dart';
import '../../../audio/widgets/islamic_audio_player_sheet.dart';
import '../../../backup/backup_restore_screen.dart';
import '../../../home/momen_duaa_screen.dart';
import '../../../khatma/khatma_screen.dart';
import '../../../onboarding/onboarding_screen.dart';
import '../../../prayer/battery_reliability_screen.dart';
import '../../contact_support_screen.dart';
import '../settings_about_modal.dart';
import 'settings_section_header.dart';

/// Refactored Section 5: Tools, Backup & Application Information
class SettingsToolsAndAboutSection extends StatelessWidget {
  const SettingsToolsAndAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(
          title: context.tr('section_tools_about'),
          icon: Icons.build_circle_outlined,
        ),
        ListTile(
          leading: const Icon(Icons.auto_stories_rounded,
              color: AppColors.accentGold),
          title: const Text('مخطط الختمات والورد القرآني',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const KhatmaScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.library_music_rounded,
              color: AppColors.primaryGreen),
          title: const Text(
              'المكتبة الصوتية الفائقة (الأذان والأدعية والابتهالات HD)',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => IslamicAudioPlayerSheet.show(context),
        ),
        ListTile(
          leading: const Icon(Icons.record_voice_over_rounded,
              color: AppColors.accentGold),
          title: const Text('دعاء الشيخ الشعراوي بعد الأذان والصلاة',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => showSharawiPostPrayerModal(context),
        ),
        ListTile(
          leading:
              const Icon(Icons.bolt_rounded, color: AppColors.primaryGreen),
          title: const Text('دليل تثبيت الأذان وإعدادات البطارية',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BatteryReliabilityScreen())),
        ),
        ListTile(
          leading:
              const Icon(Icons.backup_rounded, color: AppColors.primaryGreen),
          title: Text(context.tr('backup_restore'),
              style: const TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const BackupRestoreScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.volunteer_activism_rounded,
              color: AppColors.accentGold),
          title: const Text('دعاء لمؤمن إبراهيم رحمهُ الله (صدقة جارية)',
              style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('فتح شاشة الإهداء والدعاء للمرحوم بإذن الله',
              style: TextStyle(fontSize: 12)),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const MomenDuaaScreen(isFromInsideApp: true))),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.school_rounded, color: AppColors.primaryGreen),
          title: const Text('إظهار شاشات شرح البرنامج عند الفتح',
              style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('تفعيل عرض الجولة التعريفية عند بدء التشغيل',
              style: TextStyle(fontSize: 12)),
          value: SettingsService.instance.showTutorialScreens,
          onChanged: (val) => SettingsService.instance.setShowTutorialScreens(val),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline_rounded,
              color: AppColors.primaryGreen),
          title: const Text('عرض شاشات شرح استخدام البرنامج',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const OnboardingScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.support_agent_rounded,
              color: AppColors.primaryGreen),
          title: const Text('الدعم والتواصل مع المطور',
              style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('إرسال اقتراح، ملاحظة، أو إبلاغ عن مشكلة بريدياً للمطور',
              style: TextStyle(fontSize: 12)),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ContactSupportScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline_rounded,
              color: AppColors.accentGold),
          title: Text('${context.tr('about_app')} (الإصدار السابع v7.0)',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          onTap: () => showSettingsAboutModal(context),
        ),
      ],
    );
  }
}
