import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/prayer_service.dart';
import '../../prayer/prayer_screen.dart';

class HomeNextPrayerCard extends StatelessWidget {
  final PrayerData? prayerData;

  const HomeNextPrayerCard({
    super.key,
    required this.prayerData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrayerScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerData?.nextPrayer != null
                        ? 'الصلاة القادمة: ${prayerData!.nextPrayer!.name}'
                        : 'الصلاة القادمة: الظهر',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondaryGreen),
                      const SizedBox(width: 4),
                      ValueListenableBuilder<Duration>(
                        valueListenable: PrayerService.instance.countdownNotifier,
                        builder: (context, duration, _) {
                          final effectiveDuration = duration == Duration.zero && prayerData != null
                              ? prayerData!.timeToNextPrayer
                              : duration;
                          return Text(
                            prayerData != null
                                ? 'متبقي ${PrayerService.instance.formatCountdown(effectiveDuration)}'
                                : 'جاري الحساب...',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.access_time_filled, color: AppColors.primaryGreen, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
