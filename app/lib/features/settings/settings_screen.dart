import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/widgets/app_navigation_drawer.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/notifications/prayer_notification_service.dart';
import '../../core/services/adhan_sensor_gesture_service.dart';
import '../../core/services/prayer_service.dart';
import '../../core/services/settings_service.dart';
import 'widgets/sections/settings_adhan_and_sensors_section.dart';
import 'widgets/sections/settings_language_and_appearance_section.dart';
import 'widgets/sections/settings_prayer_and_fiqh_section.dart';
import 'widgets/sections/settings_quran_and_audio_section.dart';
import 'widgets/sections/settings_tools_and_about_section.dart';
import 'widgets/settings_language_modal.dart';

/// Refactored SettingsScreen composed of clean, modular, single-responsibility sections
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        SettingsService.instance,
        PrayerNotificationService.instance,
        PrayerService.instance,
        AdhanSensorGestureService.instance,
      ]),
      builder: (context, _) {
        final s = SettingsService.instance;

        return Directionality(
          textDirection: s.textDirection,
          child: Scaffold(
            drawer: const AppNavigationDrawer(),
            appBar: AppBar(
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: s.isArabic ? 'رجوع' : 'Back',
                      onPressed: () => Navigator.pop(context),
                    )
                  : Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded),
                        tooltip: s.isArabic ? 'القائمة الرئيسية' : 'Menu',
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
              title: Text(context.tr('settings_title')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.language_rounded),
                  tooltip: context.tr('app_language'),
                  onPressed: () => showSettingsLanguageModal(context),
                ),
                IconButton(
                  icon: const Icon(Icons.home_rounded),
                  tooltip: context.tr('nav_home'),
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: const [
                SettingsLanguageAndAppearanceSection(),
                SettingsQuranAndAudioSection(),
                SettingsPrayerAndFiqhSection(),
                SettingsAdhanAndSensorsSection(),
                SettingsToolsAndAboutSection(),
              ],
            ),
          ),
        );
      },
    );
  }
}
