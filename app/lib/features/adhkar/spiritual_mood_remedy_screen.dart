import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/spiritual_mood_remedy_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

/// الميزة الجديدة ٣: شاشة المستشار الإيماني ودواء القلوب بالقرآن والأدعية حسب الحالة الشعورية
class SpiritualMoodRemedyScreen extends StatelessWidget {
  const SpiritualMoodRemedyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SpiritualMoodRemedyService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([service, SettingsService.instance]),
      builder: (context, _) {
        final remedy = service.currentRemedy;
        final progress = service.activeDhikrProgress;
        final target = remedy.recommendedDhikrCount;

        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.tr('spiritual_mood_remedy')),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'مشاركة الوصفة الإيمانية',
                  onPressed: () {
                    try {
                      Share.share(
                      '${remedy.emoji} ${remedy.moodTitle}\n\n'
                      '📖 الآية الشافية: ${remedy.quranAyah} (${remedy.surahReference})\n\n'
                      '🤲 الدعاء النبوي: ${remedy.propheticDua}\n'
                      '— تطبيق نور المؤمن',
                    );
                    } catch (_) {}
                  },
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Mood Selector Dropdown
                AppDropdownField<String>(
                  label: 'بماذا يشعر قلبك الآن؟ (اختر الحالة الشعورية)',
                  value: service.selectedMoodId,
                  prefixIcon: Icons.favorite_rounded,
                  options: SpiritualMoodRemedyService.allRemedies
                      .map((r) => AppDropdownOption<String>(
                            value: r.id,
                            label: '${r.emoji} ${r.moodTitle}',
                            subtitle: r.shortSummary,
                          ))
                      .toList(),
                  onChanged: (val) => service.selectMood(val),
                ),
                const SizedBox(height: 16),

                // 1. Quranic Remedy Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(remedy.emoji,
                                style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    remedy.moodTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  Text(
                                    remedy.shortSummary,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 22),
                        const Text(
                          '📖 الآية القرآنية الشافية:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.accentGold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          remedy.quranAyah,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          remedy.surahReference,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '💡 إشراقة تدبرية: ${remedy.ayahReflection}',
                          style: const TextStyle(fontSize: 13.5, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Prophetic Supplication Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🤲 الدعاء النبوي المأثور:',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remedy.propheticDua,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 17,
                            height: 1.65,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '📚 المصدر: ${remedy.hadithSource}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Practical 3-Step Action Plan
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌿 خطوات عملية فورية لسكينة القلب:',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...remedy.practicalSteps.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 11,
                                  backgroundColor: AppColors.primaryGreen,
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(
                                        fontSize: 13.5, height: 1.45),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Built-in Interactive Remedy Tasbih Counter
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '📿 ورد الذكر العلاجي الفوري:',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14.5,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            TextButton(
                              onPressed: service.resetDhikr,
                              child: const Text('تصفير'),
                            ),
                          ],
                        ),
                        Text(
                          remedy.recommendedDhikr,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: (progress / target).clamp(0.0, 1.0),
                          minHeight: 9,
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'التكرار: $progress / $target',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.touch_app_rounded),
                              label: Text(progress >= target
                                  ? 'تم الورد بحمد الله ✓'
                                  : 'سبّح الآن (+١)'),
                              onPressed: progress >= target
                                  ? null
                                  : service.incrementDhikr,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
