import 'package:flutter/material.dart';
import '../../core/services/daily_wird_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/adaptive_screen_layouts.dart';

/// شاشة «الورد اليومي الذكي وخطة الطاعات المتكاملة» مع أنماط عرض متعددة
class DailyWirdScreen extends StatefulWidget {
  const DailyWirdScreen({super.key});

  @override
  State<DailyWirdScreen> createState() => _DailyWirdScreenState();
}

class _DailyWirdScreenState extends State<DailyWirdScreen> {
  final DailyWirdService _service = DailyWirdService.instance;
  late ScreenStructureMode _layoutMode;

  @override
  void initState() {
    super.initState();
    _service.init();
    _layoutMode = ScreenStructureMode.fromId(
      SettingsService.instance.screenLayoutMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الورد اليومي الذكي وخطة الطاعات'),
          actions: [
            ScreenLayoutPopupButton(
              currentMode: _layoutMode,
              onChanged: (m) => setState(() => _layoutMode = m),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _service,
          builder: (context, _) {
            final ratio = _service.getTodayCompletionRatio();
            final points = _service.getTodayPoints();
            final streak = _service.getCurrentStreakDays();
            final doneCount = _service.getCompletedToday().length;
            final totalCount = DailyWirdService.defaultTasks.length;

            final structuredTasks = DailyWirdService.defaultTasks.map((task) {
              final isDone = _service.isCompleted(task.id);
              return StructuredScreenItem(
                id: task.id,
                title: task.title,
                subtitle: '${task.timeSlot} • ${task.subtitle}',
                badgeText: isDone ? 'تم بحمد الله ✓' : '+${task.rewardPoints} نقطة',
                category: task.timeSlot,
                icon: isDone ? Icons.check_circle_rounded : task.icon,
                accentColor:
                    isDone ? AppColors.primaryGreen : AppColors.accentGold,
                onTap: () => _service.toggleTask(task.id),
                trailing: Checkbox(
                  value: isDone,
                  activeColor: AppColors.primaryGreen,
                  onChanged: (_) => _service.toggleTask(task.id),
                ),
              );
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary Progress Hero Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0D5C46), Color(0xFF083B2C)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: ratio.clamp(0.0, 1.0),
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.accentGold,
                                  ),
                                ),
                                Text(
                                  '${(ratio * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'إنجاز الورد اليومي والطاعات',
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'أنجزت $doneCount من $totalCount أوراد اليوم • الرصيد: $points نقطة • المواظبة: $streak يوم',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AdaptiveLayoutSwitcherBar(
                  currentMode: _layoutMode,
                  onModeChanged: (m) {
                    SettingsService.instance.setScreenLayoutMode(m.id);
                    setState(() => _layoutMode = m);
                  },
                ),
                const SizedBox(height: 14),
                AdaptiveStructuredCollectionView(
                  mode: _layoutMode,
                  items: structuredTasks,
                  shrinkWrap: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
