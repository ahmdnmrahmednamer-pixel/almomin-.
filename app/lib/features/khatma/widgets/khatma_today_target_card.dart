import 'package:flutter/material.dart';
import '../../../core/services/khatma_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../mushaf/page_mode_mushaf_screen.dart';
import 'khatma_helpers.dart';

/// Today's reading target card and 5 prayers distribution checklist.
class KhatmaTodayTargetCard extends StatelessWidget {
  final KhatmaPlan plan;

  const KhatmaTodayTargetCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final prayers = [
      {'key': 'fajr', 'name': 'صلاة الفجر'},
      {'key': 'dhuhr', 'name': 'صلاة الظهر'},
      {'key': 'asr', 'name': 'صلاة العصر'},
      {'key': 'maghrib', 'name': 'صلاة المغرب'},
      {'key': 'isha', 'name': 'صلاة العشاء'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Today's Reading Target Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.today_rounded, color: AppColors.primaryGreen, size: 22),
                        SizedBox(width: 8),
                        Text('ورد اليوم القرآني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: plan.isBehindSchedule
                            ? Colors.orange.withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.isBehindSchedule ? 'بحاجة للتعويض' : 'على المسار الصحيح',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: plan.isBehindSchedule ? Colors.orange.shade800 : Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'المستهدف لليوم: صفحة ${KhatmaFormatHelper.toArabicIndic(plan.currentPage)} إلى صفحة ${KhatmaFormatHelper.toArabicIndic((plan.currentPage + plan.pagesPerDay).clamp(1, 604))}',
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.menu_book),
                        label: const Text('ابدأ قراءة ورد اليوم الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageModeMushafScreen(initialPage: plan.currentPage),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('أتممت الورد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await KhatmaService.instance.advancePages(plan.pagesPerDay);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تقبل الله! تم تقديم القراءة بمقدار ${KhatmaFormatHelper.toArabicIndic(plan.pagesPerDay)} صفحة.'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Prayers Breakdown Section
        if (plan.splitByPrayer) ...[
          const Text('تقسيم الورد على الصلوات الخمس:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...prayers.map((pray) {
            final key = pray['key']!;
            final name = pray['name']!;
            final isDone = plan.completedPrayersToday.contains(key);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? Colors.green : AppColors.mutedText,
                ),
                title: Text(name, style: TextStyle(fontWeight: isDone ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text('حصة الصلاة: ${KhatmaFormatHelper.toArabicIndic(plan.pagesPerPrayer)} صفحات بعد الفريضة'),
                trailing: TextButton(
                  onPressed: () => KhatmaService.instance.togglePrayerCompleted(key),
                  child: Text(isDone ? 'تم الإنجاز ✓' : 'تمت القراءة', style: TextStyle(color: isDone ? Colors.green : AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                ),
                onTap: () => KhatmaService.instance.togglePrayerCompleted(key),
              ),
            );
          }),
        ],
      ],
    );
  }
}
