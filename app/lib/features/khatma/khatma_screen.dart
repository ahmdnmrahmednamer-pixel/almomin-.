import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../core/services/khatma_service.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/khatma_completion_duaa_sheet.dart';
import 'widgets/khatma_manual_adjust_dialogs.dart';
import 'widgets/khatma_new_plan_dialog.dart';
import 'widgets/khatma_progress_header_card.dart';
import 'widgets/khatma_today_target_card.dart';

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
    showKhatmaNewPlanDialog(context);
  }

  void _showManualPageAdjustDialog(KhatmaPlan plan) {
    showKhatmaManualPageAdjustDialog(context, plan);
  }

  void _showReminderSettingsDialog(KhatmaPlan plan) {
    showKhatmaReminderSettingsDialog(context, plan);
  }

  void _showCompletionDuaaDialog() {
    showKhatmaCompletionDuaaSheet(context);
  }

  void _confirmCancelPlan() {
    confirmCancelKhatmaPlan(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مخطط الختمات والورد القرآني'),
          actions: [
            AnimatedBuilder(
              animation: KhatmaService.instance,
              builder: (context, _) {
                final plan = KhatmaService.instance.activePlan;
                if (plan != null) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_active_outlined),
                        tooltip: 'إعدادات التذكير بالورد',
                        onPressed: () => _showReminderSettingsDialog(plan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded),
                        tooltip: 'تعديل موضع الصفحة يدوياً',
                        onPressed: () => _showManualPageAdjustDialog(plan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded),
                        tooltip: 'إعادة ضبط / إلغاء الختمة',
                        onPressed: _confirmCancelPlan,
                      ),
                    ],
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'خطط لقراءة كتاب الله الكريم في المدة التي تناسبك مع تقسيم ذكي للصفحات، إعادة جدولة تعويضية عند التأخر، وتنبيه يومي لطيف بالورد.',
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Progress Header Card & Catch-up Card
        KhatmaProgressHeaderCard(plan: plan),

        // 2. Today's Reading Target Card & Prayers Distribution
        KhatmaTodayTargetCard(plan: plan),

        // 3. Dedicated Button for Duaa Khatm Al-Quran anytime
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: AppColors.accentGold.withOpacity(0.6)),
          ),
          icon: const Icon(Icons.menu_book_rounded, color: AppColors.accentGold),
          label: const Text(
            'قراءة دعاء ختم القرآن الكريم وإهداء الثواب',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          onPressed: _showCompletionDuaaDialog,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
