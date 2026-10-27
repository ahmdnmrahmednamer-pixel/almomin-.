import '../../../core/text/arabic_normalizer.dart';
import 'package:flutter/material.dart';
import '../../../core/services/khatma_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import 'khatma_helpers.dart';

/// Dialog to configure and launch a new Quran Khatma plan.
void showKhatmaNewPlanDialog(BuildContext context) {
  int selectedDays = 30;
  bool isCustom = false;
  bool splitByPrayer = true;
  bool startFromCurrent = false;
  bool reminderEnabled = true;
  TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);

  final titleController = TextEditingController(text: 'ختمة القرآن الكريم (٣٠ يوماً)');
  final customDaysController = TextEditingController(text: '45');
  final currentReadPage = SettingsService.instance.lastReadPageNumber;

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: SettingsService.instance.textDirection,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.auto_stories_rounded, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text('بدء ختمة قرآنية جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'عنوان الختمة',
                        filled: true,
                        fillColor: AppColors.primaryGreen.withOpacity(0.04),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('اختر المدة المخططة للختمة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('٣٠ يوماً (جزء يومياً)'),
                          selected: !isCustom && selectedDays == 30,
                          selectedColor: AppColors.accentGold.withOpacity(0.3),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                isCustom = false;
                                selectedDays = 30;
                                titleController.text = 'ختمة الشهر (٣٠ يوماً)';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('٦٠ يوماً (نصف جزء)'),
                          selected: !isCustom && selectedDays == 60,
                          selectedColor: AppColors.accentGold.withOpacity(0.3),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                isCustom = false;
                                selectedDays = 60;
                                titleController.text = 'ختمة الشهرين (٦٠ يوماً)';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('٩٠ يوماً (ربع جزء)'),
                          selected: !isCustom && selectedDays == 90,
                          selectedColor: AppColors.accentGold.withOpacity(0.3),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                isCustom = false;
                                selectedDays = 90;
                                titleController.text = 'ختمة الثلاثة أشهر (٩٠ يوماً)';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('١٥ يوماً (جزآن يومياً)'),
                          selected: !isCustom && selectedDays == 15,
                          selectedColor: AppColors.accentGold.withOpacity(0.3),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                isCustom = false;
                                selectedDays = 15;
                                titleController.text = 'ختمة النصف شهر (١٥ يوماً)';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('مدة مخصصة...'),
                          selected: isCustom,
                          selectedColor: AppColors.accentGold.withOpacity(0.3),
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                isCustom = true;
                                titleController.text = 'ختمة مخصصة (${customDaysController.text} يوماً)';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (isCustom) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('عدد الأيام: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 90,
                            child: TextField(
                              controller: customDaysController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (val) {
                                final days = ArabicNormalizer.tryParseInt(val) ?? 30;
                                titleController.text = 'ختمة مخصصة ($days يوماً)';
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('يوماً', style: TextStyle(color: AppColors.mutedText)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('البدء من موضع قراءتي الحالي بالمصحف', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('صفحة ${KhatmaFormatHelper.toArabicIndic(currentReadPage)} من ٦٠٤', style: const TextStyle(fontSize: 12, color: AppColors.mutedText)),
                      activeColor: AppColors.primaryGreen,
                      value: startFromCurrent,
                      onChanged: (val) {
                        setDialogState(() => startFromCurrent = val);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('تقسيم الورد على الصلوات الخمس', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('توزيع حصة اليوم على أوقات الصلاة المكتوبة', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                      activeColor: AppColors.primaryGreen,
                      value: splitByPrayer,
                      onChanged: (val) {
                        setDialogState(() => splitByPrayer = val);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('تفعيل التذكير اليومي بالورد', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('موعد التنبيه: ${KhatmaFormatHelper.formatTimeOfDay(reminderTime.hour, reminderTime.minute)}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryGreen)),
                      activeColor: AppColors.primaryGreen,
                      value: reminderEnabled,
                      onChanged: (val) {
                        setDialogState(() => reminderEnabled = val);
                      },
                    ),
                    if (reminderEnabled)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.access_time_rounded, size: 18),
                          label: const Text('تعديل وقت التنبيه'),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: reminderTime,
                            );
                            if (picked != null && ctx.mounted) {
                              setDialogState(() => reminderTime = picked);
                            }
                          },
                        ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    int finalDays = isCustom
                        ? (ArabicNormalizer.tryParseInt(customDaysController.text) ?? 30).clamp(1, 365)
                        : selectedDays;

                    await KhatmaService.instance.createPlan(
                      title: titleController.text.trim().isNotEmpty
                          ? titleController.text.trim()
                          : 'ختمة القرآن الكريم',
                      targetDays: finalDays,
                      splitByPrayer: splitByPrayer,
                      startingPage: startFromCurrent ? currentReadPage : 1,
                      reminderEnabled: reminderEnabled,
                      reminderHour: reminderTime.hour,
                      reminderMinute: reminderTime.minute,
                    );
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('بدء الختمة المباركة', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    Future.delayed(const Duration(milliseconds: 350), () {
      titleController.dispose();
      customDaysController.dispose();
    });
  });
}
