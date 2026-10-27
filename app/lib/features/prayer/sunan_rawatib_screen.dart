import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/sunan_rawatib_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

class SunanRawatibScreen extends StatefulWidget {
  const SunanRawatibScreen({super.key});

  @override
  State<SunanRawatibScreen> createState() => _SunanRawatibScreenState();
}

class _SunanRawatibScreenState extends State<SunanRawatibScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'all'; // 'all', 'rawatib', 'nawafil'

  @override
  void initState() {
    super.initState();
    SunanRawatibService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('متتبع السنن الرواتب والنوافل (١٢ ركعة)'),
        ),
        body: AnimatedBuilder(
          animation: SunanRawatibService.instance,
          builder: (context, _) {
            final s = SunanRawatibService.instance;
            final rawatibRakahs = s.getCompletedRawatibRakahs(date: _selectedDate);
            final totalRakahs = s.getTotalCompletedRakahs(date: _selectedDate);
            final houseBuilt = s.isHouseInParadiseCompleted(date: _selectedDate);
            final weeklyHouses = s.getWeeklyParadiseHousesCount();

            final filteredItems = SunanRawatibService.allSunan.where((item) {
              if (_selectedFilter == 'rawatib') return item.isRawatib12;
              if (_selectedFilter == 'nawafil') return !item.isRawatib12;
              return true;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Hero Card: House in Paradise Progress (12 Rak'ahs)
                Semantics(
                  container: true,
                  label: 'تقدم السنن الرواتب لليوم: $rawatibRakahs من 12 ركعة، إجمالي النوافل $totalRakahs ركعة',
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: houseBuilt
                            ? [const Color(0xFF0F5B45), const Color(0xFF1B4332), const Color(0xFFB88917)]
                            : [const Color(0xFF0F2E22), const Color(0xFF1B4332)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: houseBuilt ? AppColors.accentGold : AppColors.accentGold.withOpacity(0.4),
                        width: houseBuilt ? 2.0 : 1.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.22),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                houseBuilt ? Icons.verified_rounded : Icons.mosque_rounded,
                                color: AppColors.accentGold,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    houseBuilt
                                        ? 'هنيئاً! أتممت ١٢ ركعة راتبة اليوم (بيت في الجنة بإذن الله) 🌟'
                                        : 'مشروع بناء بيت في الجنة (السنن الرواتب ١٢ ركعة)',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'قال ﷺ: «ما من عبد مسلم يصلي لله كل يوم ثنتي عشرة ركعة تطوعاً غير الفريضة إلا بنى الله له بيتاً في الجنة» [رواه مسلم]',
                                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: (rawatibRakahs / 12.0).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الرواتب المؤكدة: $rawatibRakahs / ١٢ ركعة',
                              style: const TextStyle(color: AppColors.softGold, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'إجمالي ركعات اليوم: $totalRakahs ركعة · أسبوعك: $weeklyHouses/٧ أيام',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Dropdown Selector for Filtering Rawatib vs Nawafil
                AppDropdownField<String>(
                  label: 'اختر قسم السنن والنوافل من القائمة المنسدلة',
                  value: _selectedFilter,
                  dense: true,
                  prefixIcon: Icons.filter_list_rounded,
                  options: const [
                    AppDropdownOption(
                      value: 'all',
                      label: 'جميع السنن الرواتب والنوافل اليومية (١٠ سنن)',
                      icon: Icons.mosque_rounded,
                    ),
                    AppDropdownOption(
                      value: 'rawatib',
                      label: 'السنن الرواتب المؤكدة فقط (١٢ ركعة — بيت في الجنة)',
                      icon: Icons.stars_rounded,
                    ),
                    AppDropdownOption(
                      value: 'nawafil',
                      label: 'نوافل الضحى والوتر وسنة العصر والوضوء',
                      icon: Icons.wb_sunny_rounded,
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedFilter = val),
                ),
                const SizedBox(height: 12),

                // 3. Sunnah Checklist Cards
                ...filteredItems.map((item) {
                  final done = s.isCompleted(item.id, date: _selectedDate);
                  return Semantics(
                    container: true,
                    label: '${item.titleAr}، عدد الركعات ${item.rakahs}، الحالة: ${done ? "تمت صلاتها" : "لم تسجل بعد"}',
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: done ? AppColors.accentGold : Colors.grey.withOpacity(0.2),
                          width: done ? 1.6 : 1.0,
                        ),
                      ),
                      color: done
                          ? (isDark ? const Color(0xFF172A21) : const Color(0xFFF2F9F5))
                          : null,
                      child: CheckboxListTile(
                        value: done,
                        activeColor: AppColors.primaryGreen,
                        checkColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.titleAr,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isRawatib12
                                    ? AppColors.accentGold.withOpacity(0.22)
                                    : AppColors.primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${item.rakahs} ركعات',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '⏰ الوقت: ${item.timingAr}',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryGreen, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.hadithVirtue,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : AppColors.mutedText,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                        onChanged: (_) => s.toggleSunnah(item.id, date: _selectedDate),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
