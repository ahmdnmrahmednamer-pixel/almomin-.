import 'package:flutter/material.dart';
import '../../../core/services/khatma_service.dart';
import '../../../core/theme/app_theme.dart';
import 'khatma_completion_duaa_sheet.dart';
import 'khatma_helpers.dart';

/// Active Khatma header card with circular progress, milestone stats, completion banner, and smart catch-up.
class KhatmaProgressHeaderCard extends StatelessWidget {
  final KhatmaPlan plan;

  const KhatmaProgressHeaderCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final percent = (plan.progressPercentage * 100).toStringAsFixed(1);

    return Column(
      children: [
        // Completed Banner if finished
        if (plan.isCompleted) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB89628)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGold.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.celebration_rounded, color: Colors.white, size: 36),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'هنيئاً لك ختم كتاب الله المبارك! 🎉',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'اضغط هنا لقراءة دعاء الختم المأثور وإهداء الثواب',
                        style: TextStyle(color: Colors.white, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => showKhatmaCompletionDuaaSheet(context),
                  child: const Text('دعاء الختم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],

        // Main Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'المدة: ${KhatmaFormatHelper.toArabicIndic(plan.targetDays)} يوماً',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Circular Progress Bar
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: plan.progressPercentage.clamp(0.0, 1.0),
                      strokeWidth: 10,
                      backgroundColor: Colors.white24,
                      color: AppColors.accentGold,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'صفحة ${KhatmaFormatHelper.toArabicIndic(plan.currentPage)} / ٦٠٤',
                        style: const TextStyle(color: AppColors.softGold, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Milestone Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('المتبقي', '${KhatmaFormatHelper.toArabicIndic(plan.remainingPages)} صفحة'),
                  _buildStatItem('ورد اليوم', '${KhatmaFormatHelper.toArabicIndic(plan.pagesPerDay)} صفحة'),
                  _buildStatItem('الأيام المتبقية', '${KhatmaFormatHelper.toArabicIndic(plan.daysRemaining)} يوماً'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Smart Catch-up Card if Behind Schedule
        if (plan.isBehindSchedule && !plan.isCompleted) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade700.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_fix_high_rounded, color: Colors.amber.shade800, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الجدولة التعويضية الذكية',
                        style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'متأخر ${KhatmaFormatHelper.toArabicIndic(plan.pagesBehind)} صفحة',
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'لا تشعر بأي ضغط! يمكنك إعادة جدولة الصفحات المتبقية (${KhatmaFormatHelper.toArabicIndic(plan.remainingPages)} صفحة) على الأيام المتبقية ليكون وردك اليومي ${KhatmaFormatHelper.toArabicIndic(plan.adjustedPagesPerDay)} صفحة بسلاسة.',
                  style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.mutedText),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('تطبيق الجدولة التعويضية الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  onPressed: () async {
                    await KhatmaService.instance.applyCatchUpPace();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تمت إعادة جدولة الورد بنجاح! وفقك الله لإتمام الختمة المباركة.'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.softGold, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
