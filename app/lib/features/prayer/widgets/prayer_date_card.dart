import 'package:flutter/material.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/theme/app_theme.dart';
import '../hijri_calendar_screen.dart';

/// Card showing Hijri & Gregorian dates with quick link to the Hijri Calendar screen.
class PrayerDateCard extends StatelessWidget {
  const PrayerDateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hijriStr = HijriDateHelper.getHijriDateString();
    final gregStr = HijriDateHelper.getGregorianDateString();
    final dayStr = HijriDateHelper.getDayOfWeek();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.6), width: 1.4),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dayStr,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('المناسبات', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryGreen),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hijriStr,
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.primaryGreen, height: 1.3),
              ),
              const SizedBox(height: 4),
              Text(
                gregStr,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
