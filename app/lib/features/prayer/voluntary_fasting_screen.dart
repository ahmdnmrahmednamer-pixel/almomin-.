import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/voluntary_fasting_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

/// الميزة الجديدة ٢: شاشة مخطط الصيام التطوعي والأيام البيض والسنن الموسمية
class VoluntaryFastingScreen extends StatefulWidget {
  const VoluntaryFastingScreen({super.key});

  @override
  State<VoluntaryFastingScreen> createState() => _VoluntaryFastingScreenState();
}

class _VoluntaryFastingScreenState extends State<VoluntaryFastingScreen> {
  String _selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    VoluntaryFastingService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final service = VoluntaryFastingService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([service, SettingsService.instance]),
      builder: (context, _) {
        final filtered = _selectedCategory == 'الكل'
            ? VoluntaryFastingService.fastTypes
            : VoluntaryFastingService.fastTypes
                .where((f) => f.category == _selectedCategory)
                .toList();

        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.tr('voluntary_fasting')),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F5B45), Color(0xFF093E2F)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_twilight_rounded,
                              color: AppColors.accentGold, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'باب الريان — سجل صيام التطوع والسنن',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'إجمالي أيام الصيام التطوعي المسجلة: ${service.totalFastedDays} يوماً',
                                  style: const TextStyle(
                                    color: AppColors.softGold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '🤲 دعاء الإفطار النبوي: ${VoluntaryFastingService.iftarDua}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontFamily: 'Amiri',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Filter Dropdown & Suhoor Toggle
                AppDropdownField<String>(
                  label: 'تصنيف أيام الصيام المستحبة',
                  value: _selectedCategory,
                  prefixIcon: Icons.filter_list_rounded,
                  options: const [
                    AppDropdownOption(
                        value: 'الكل',
                        label: 'جميع أيام الصيام التطوعي (٧ سنن نبوية)'),
                    AppDropdownOption(
                        value: 'أسبوعي', label: 'الصيام الأسبوعي (الإثنين والخميس)'),
                    AppDropdownOption(
                        value: 'شهري',
                        label: 'الصيام الشهري (الأيام البيض ١٣ و١٤ و١٥)'),
                    AppDropdownOption(
                        value: 'موسمي',
                        label: 'الصيام الموسمي (الست من شوال • عرفة • عاشوراء)'),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.alarm_rounded,
                      color: AppColors.primaryGreen),
                  title: const Text('تذكير السحور وعقد نية صيام النافلة',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  subtitle: const Text(VoluntaryFastingService.intentionNote,
                      style: TextStyle(fontSize: 11.5)),
                  activeColor: AppColors.accentGold,
                  activeTrackColor: AppColors.primaryGreen,
                  value: service.suhoorReminderEnabled,
                  onChanged: (val) => service.toggleSuhoorReminder(val),
                ),
                const Divider(),

                // Fasting Cards
                ...filtered.map((fast) {
                  final count = service.getCountForType(fast.id);
                  final progress =
                      (count / fast.targetDaysPerPeriod).clamp(0.0, 1.0);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  fast.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15.5,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.accentGold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  fast.category,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '📅 الموعد: ${fast.scheduleRule}',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${fast.propheticVirtue}\n— [${fast.hadithSource}]',
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(6),
                            color: AppColors.primaryGreen,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الأيام المسجلة: $count / هدف الفترة: ${fast.targetDaysPerPeriod}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'إنقاص',
                                    icon: const Icon(
                                        Icons.remove_circle_outline_rounded),
                                    onPressed: count > 0
                                        ? () =>
                                            service.decrementFastCount(fast.id)
                                        : null,
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.check_circle_rounded,
                                        size: 16),
                                    label: const Text('صمتُ هذا اليوم'),
                                    onPressed: () =>
                                        service.logFastedDay(fast.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
