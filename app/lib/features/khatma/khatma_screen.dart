import 'package:flutter/material.dart';
import '../../core/services/khatma_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../mushaf/page_mode_mushaf_screen.dart';

class KhatmaScreen extends StatefulWidget {
  const KhatmaScreen({super.key});

  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  @override
  void initState() {
    super.initState();
    KhatmaService.instance.init();
  }

  void _showNewPlanDialog() {
    int selectedDays = 30;
    bool splitByPrayer = true;
    final titleController = TextEditingController(text: 'ختمة القرآن الكريم (٣٠ يوماً)');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('بدء ختمة قرآنية جديدة'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'عنوان الختمة',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('اختر المدة المخططة للختمة:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('٣٠ يوماً (جزء يومياً)'),
                            selected: selectedDays == 30,
                            selectedColor: AppColors.accentGold.withOpacity(0.3),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  selectedDays = 30;
                                  titleController.text = 'ختمة الشهر (٣٠ يوماً)';
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('٦٠ يوماً (نصف جزء)'),
                            selected: selectedDays == 60,
                            selectedColor: AppColors.accentGold.withOpacity(0.3),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  selectedDays = 60;
                                  titleController.text = 'ختمة الشهرين (٦٠ يوماً)';
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('٩٠ يوماً (ربع جزء)'),
                            selected: selectedDays == 90,
                            selectedColor: AppColors.accentGold.withOpacity(0.3),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  selectedDays = 90;
                                  titleController.text = 'ختمة الثلاثة أشهر (٩٠ يوماً)';
                                });
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('١٥ يوماً (جزآن يومياً)'),
                            selected: selectedDays == 15,
                            selectedColor: AppColors.accentGold.withOpacity(0.3),
                            onSelected: (val) {
                              if (val) {
                                setDialogState(() {
                                  selectedDays = 15;
                                  titleController.text = 'ختمة النصف شهر (١٥ يوماً)';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('تقسيم الورد على الصلوات الخمس'),
                        subtitle: Text(
                          selectedDays == 30
                              ? 'حوالي ٤ صفحات بعد كل صلاة مكتوبة'
                              : 'توزيع حصة اليوم على أوقات الصلاة',
                          style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                        ),
                        activeColor: AppColors.primaryGreen,
                        value: splitByPrayer,
                        onChanged: (val) {
                          setDialogState(() => splitByPrayer = val);
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await KhatmaService.instance.createPlan(
                        title: titleController.text.trim().isNotEmpty
                            ? titleController.text.trim()
                            : 'ختمة القرآن الكريم',
                        targetDays: selectedDays,
                        splitByPrayer: splitByPrayer,
                        startingPage: SettingsService.instance.lastReadPageNumber,
                      );
                      if (context.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('بدء الختمة المباركة'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmCancelPlan() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إلغاء الختمة الحالية'),
          content: const Text('هل أنت متأكد من رغبتك في إلغاء الختمة الحالية والبدء من جديد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('تراجع'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                await KhatmaService.instance.cancelPlan();
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  String _toArabicIndic(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicDigits[digit] : char;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مخطط الختمات والورد القرآني'),
          actions: [
            AnimatedBuilder(
              animation: KhatmaService.instance,
              builder: (context, _) {
                if (KhatmaService.instance.hasActivePlan) {
                  return IconButton(
                    icon: const Icon(Icons.restart_alt_rounded),
                    tooltip: 'إعادة ضبط / إلغاء الختمة',
                    onPressed: _confirmCancelPlan,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: KhatmaService.instance,
          builder: (context, _) {
            final plan = KhatmaService.instance.activePlan;

            if (plan == null) {
              return _buildEmptyState(isDark);
            }

            return _buildActivePlanView(plan, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories_rounded, size: 72, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              'ابدأ ختمتك القرآنية المباركة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'خطط لقراءة القرآن الكريم في المدة التي تناسبك مع تقسيم ذكي للصفحات ومتابعة الإنجاز بعد كل صلاة مكتوبة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.mutedText, height: 1.6),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('إنشاء خطة ختمة جديدة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _showNewPlanDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlanView(KhatmaPlan plan, bool isDark) {
    final percent = (plan.progressPercentage * 100).toStringAsFixed(1);
    final prayers = [
      {'key': 'fajr', 'name': 'صلاة الفجر'},
      {'key': 'dhuhr', 'name': 'صلاة الظهر'},
      {'key': 'asr', 'name': 'صلاة العصر'},
      {'key': 'maghrib', 'name': 'صلاة المغرب'},
      {'key': 'isha', 'name': 'صلاة العشاء'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'المدة: ${_toArabicIndic(plan.targetDays)} يوماً',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Circular Progress Bar
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: plan.progressPercentage,
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
                        'صفحة ${_toArabicIndic(plan.currentPage)} / ٦٠٤',
                        style: const TextStyle(color: AppColors.softGold, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Milestone Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('المتبقي', '${_toArabicIndic(plan.remainingPages)} صفحة'),
                  _buildStatItem('ورد اليوم', '${_toArabicIndic(plan.pagesPerDay)} صفحة'),
                  _buildStatItem('الأيام المتبقية', '${_toArabicIndic(plan.daysRemaining)} يوماً'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

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
                  'المستهدف لليوم: صفحة ${_toArabicIndic(plan.currentPage)} إلى صفحة ${_toArabicIndic((plan.currentPage + plan.pagesPerDay).clamp(1, 604))}',
                  style: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('ابدأ قراءة ورد اليوم الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PageModeMushafScreen(initialPage: plan.currentPage),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

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
                subtitle: Text('حصة الصلاة: ${_toArabicIndic(plan.pagesPerPrayer)} صفحات بعد الفريضة'),
                trailing: TextButton(
                  onPressed: () => KhatmaService.instance.togglePrayerCompleted(key),
                  child: Text(isDone ? 'تم الإنجاز' : 'تمت القراءة', style: TextStyle(color: isDone ? Colors.green : AppColors.primaryGreen)),
                ),
                onTap: () => KhatmaService.instance.togglePrayerCompleted(key),
              ),
            );
          }),
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
