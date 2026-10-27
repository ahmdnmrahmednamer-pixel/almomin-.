import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../core/services/hajj_umrah_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_dropdown_field.dart';

/// الميزة الجديدة ١: شاشة رفيق الحاج والمعتمر الذكي وعدّاد الطواف والسعي (٧ أشواط)
class HajjUmrahCompanionScreen extends StatefulWidget {
  const HajjUmrahCompanionScreen({super.key});

  @override
  State<HajjUmrahCompanionScreen> createState() =>
      _HajjUmrahCompanionScreenState();
}

class _HajjUmrahCompanionScreenState extends State<HajjUmrahCompanionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRitualType = 'umrah';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    HajjUmrahService.instance.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = HajjUmrahService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([service, SettingsService.instance]),
      builder: (context, _) {
        final steps = service.getStepsByType(_selectedRitualType);

        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.tr('hajj_umrah_companion')),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentGold,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.explore_rounded),
                    text: 'مناسك العمرة والحج خطوة بخطوة',
                  ),
                  Tab(
                    icon: Icon(Icons.radar_rounded),
                    text: 'عدّاد الطواف والسعي (٧ أشواط)',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Step-by-step Manasik
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AppDropdownField<String>(
                      label: 'اختر نوع النُّسُك لعرض خطواته وأحكامه',
                      value: _selectedRitualType,
                      prefixIcon: Icons.mosque_rounded,
                      options: const [
                        AppDropdownOption(
                          value: 'umrah',
                          label: 'مناسك العمرة المفردة (٥ خطوات مرتبة)',
                          subtitle: 'الإحرام • الطواف • ركعتا المقام • السعي • الحلق أو التقصير',
                        ),
                        AppDropdownOption(
                          value: 'hajj',
                          label: 'مناسك الحج المبرور (من يوم التروية إلى الوداع)',
                          subtitle: 'منى • عرفة • مزدلفة • يوم النحر • أيام التشريق',
                        ),
                      ],
                      onChanged: (val) => setState(() => _selectedRitualType = val),
                    ),
                    const SizedBox(height: 12),
                    ...steps.map((step) {
                      final isDone = service.completedStepIds.contains(step.id);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDone
                                ? AppColors.primaryGreen
                                : Colors.grey.withOpacity(0.25),
                            width: isDone ? 2 : 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isDone,
                                    activeColor: AppColors.primaryGreen,
                                    onChanged: (_) =>
                                        service.toggleStepCompleted(step.id),
                                  ),
                                  Expanded(
                                    child: Text(
                                      step.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen
                                          .withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      step.ruling,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '📍 الموضع: ${step.location}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                step.description,
                                style: const TextStyle(
                                    fontSize: 13.5, height: 1.5),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryGreen.withOpacity(0.07),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '🤲 الذكر والدعاء المأثور:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      step.propheticDua,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '💡 فائدة وسنّة: ${step.sunnahNotes}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                // Tab 2: Interactive 7-Lap Tawaf & Sa'i Counter
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCounterCard(
                      title: 'عدّاد طواف الكعبة المشرفة (٧ أشواط)',
                      currentLap: service.tawafLap,
                      lapsInfo: HajjUmrahService.tawafLaps,
                      onIncrement: service.incrementTawafLap,
                      onReset: service.resetTawaf,
                    ),
                    const SizedBox(height: 16),
                    _buildCounterCard(
                      title: 'عدّاد السعي بين الصفا والمروة (٧ أشواط)',
                      currentLap: service.saiLap,
                      lapsInfo: HajjUmrahService.saiLaps,
                      onIncrement: service.incrementSaiLap,
                      onReset: service.resetSai,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterCard({
    required String title,
    required int currentLap,
    required List<RitualLapInfo> lapsInfo,
    required VoidCallback onIncrement,
    required VoidCallback onReset,
  }) {
    final activeLapIndex = (currentLap == 0 ? 0 : currentLap - 1).clamp(0, 6);
    final lapData = lapsInfo[activeLapIndex];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('تصفير'),
                  onPressed: onReset,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (currentLap / 7.0).clamp(0.0, 1.0),
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: currentLap >= 7
                  ? AppColors.accentGold
                  : AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentLap >= 7
                      ? 'تم إتمام الأشواط السبعة بحمد الله! 🎉'
                      : 'الشوط المنجز: $currentLap من ٧ أشواط',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add_task_rounded),
                  label: Text(
                      currentLap >= 7 ? 'اكتمل (٧/٧)' : 'إتمام شوط (+١)'),
                  onPressed: currentLap >= 7 ? null : onIncrement,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'إرشاد ودعاء ${lapData.titleAr}:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lapData.specificGuidance,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lapData.recommendedDua,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
