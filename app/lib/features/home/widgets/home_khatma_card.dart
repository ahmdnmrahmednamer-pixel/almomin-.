import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/khatma_service.dart';
import '../../khatma/khatma_screen.dart';

class HomeKhatmaCard extends StatelessWidget {
  const HomeKhatmaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: KhatmaService.instance,
      builder: (context, _) {
        final plan = KhatmaService.instance.activePlan;
        final hasPlan = KhatmaService.instance.hasActivePlan;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhatmaScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withOpacity(0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hasPlan ? plan!.title : 'مخطط الختمات والورد اليومي',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                            ),
                            if (hasPlan)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(plan!.progressPercentage * 100).toInt()}%',
                                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasPlan
                              ? 'ورد اليوم: صفحة ${plan!.currentPage} إلى ${(plan.currentPage + plan.pagesPerDay).clamp(1, 604)}'
                              : 'ابدأ خطتك لختم القرآن الكريم في ٣٠ أو ٦٠ يوماً مع تتبع الإنجاز',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.mutedText),
                        ),
                        if (hasPlan) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: plan!.progressPercentage.clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primaryGreen),
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
