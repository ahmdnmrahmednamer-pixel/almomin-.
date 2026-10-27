import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/prayer_tracker_service.dart';
import '../../prayer/prayer_tracker_screen.dart';

class HomePrayerTrackerCard extends StatelessWidget {
  const HomePrayerTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PrayerTrackerService.instance,
      builder: (context, _) {
        final todayRecord = PrayerTrackerService.instance.todayRecord;
        final completed = todayRecord.completedObligatoryCount;
        final rawatib = todayRecord.completedRawatibRakats;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTrackerScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'سجل متابعة الصلوات والسنن الرواتب',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$completed / ٥ صلوات',
                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        completed == 5
                            ? 'تمت جميع الصلوات الخمس بحمد الله 🤲'
                            : 'أُديت $completed من ٥ صلوات · $rawatib من ١٢ ركعة راتبة',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedText),
                      ),
                      const Row(
                        children: [
                          Text(
                            'تسجيل الصلوات',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.secondaryGreen),
                          ),
                          SizedBox(width: 2),
                          Icon(Icons.chevron_left_rounded, size: 16, color: AppColors.secondaryGreen),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (completed / 5.0).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
