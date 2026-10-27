import 'package:flutter/material.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/notifications/prayer_notification_service.dart';
import '../../../core/theme/app_theme.dart';

/// Renders the list of daily prayer cards with icons, formatted times, next-indicator, and notification toggles.
class PrayerTimesCard extends StatelessWidget {
  final PrayerData? data;
  final bool isDark;

  const PrayerTimesCard({
    super.key,
    required this.data,
    required this.isDark,
  });

  static IconData getPrayerIcon(String name) {
    switch (name) {
      case 'الفجر':
        return Icons.wb_twilight_rounded;
      case 'الشروق':
        return Icons.wb_sunny_rounded;
      case 'الظهر':
        return Icons.wb_sunny_outlined;
      case 'العصر':
        return Icons.wb_cloudy_rounded;
      case 'المغرب':
        return Icons.brightness_medium_rounded;
      case 'العشاء':
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_filled_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: data!.prayers.map((p) {
        final isNotifOn = PrayerNotificationService.instance.isPrayerEnabled(p.name);
        final prayerIcon = getPrayerIcon(p.name);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: p.isNext ? 3 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: p.isNext ? AppColors.accentGold : Colors.transparent,
              width: p.isNext ? 1.8 : 0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Distinct Prayer Icon Container
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: p.isNext
                          ? [const Color(0xFFD4AF37), const Color(0xFFB89628)]
                          : (isDark
                              ? [const Color(0xFF22362C), const Color(0xFF192821)]
                              : [AppColors.primaryGreen.withOpacity(0.12), AppColors.emeraldLight.withOpacity(0.1)]),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: p.isNext
                        ? [
                            BoxShadow(
                              color: AppColors.accentGold.withOpacity(0.35),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    prayerIcon,
                    color: p.isNext ? Colors.white : AppColors.primaryGreen,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Prayer Name & Next Indicator
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          fontWeight: p.isNext ? FontWeight.w900 : FontWeight.w800,
                          fontSize: 16.5,
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                      ),
                      if (p.isNext) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('القادمة', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ],
                  ),
                ),
                // Formatted Time & Distinct Notification Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      p.formattedTime,
                      style: TextStyle(
                        color: p.isNext ? AppColors.primaryGreen : (isDark ? Colors.white : AppColors.lightText),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: isNotifOn
                          ? AppColors.accentGold.withOpacity(0.18)
                          : (isDark ? Colors.white10 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          final curr = PrayerNotificationService.instance.isPrayerEnabled(p.name);
                          PrayerNotificationService.instance.togglePrayer(p.name, !curr);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isNotifOn ? AppColors.accentGold : (isDark ? Colors.white24 : Colors.grey.shade300),
                              width: 1.2,
                            ),
                          ),
                          child: Icon(
                            isNotifOn ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
                            size: 19,
                            color: isNotifOn ? AppColors.accentGold : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
