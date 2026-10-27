import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/kaffarah_fidyah_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

/// الميزة الجديدة ٥: شاشة حاسبة زكاة الفطر وفدية الصيام وكفارة اليمين والنذر
class KaffarahFidyahScreen extends StatefulWidget {
  const KaffarahFidyahScreen({super.key});

  @override
  State<KaffarahFidyahScreen> createState() => _KaffarahFidyahScreenState();
}

class _KaffarahFidyahScreenState extends State<KaffarahFidyahScreen> {
  String _selectedCalcMode = 'zakat_fitr';
  int _countInput = 4; // Family members, missed days, or oaths count
  double _costPerUnitEgp = 50.0;

  @override
  Widget build(BuildContext context) {
    final service = KaffarahFidyahService.instance;

    KaffarahCalculationResult result;
    if (_selectedCalcMode == 'zakat_fitr') {
      result = service.calculateZakatAlFitr(
        familyMembersCount: _countInput,
        valuePerPersonEgp: _costPerUnitEgp,
      );
    } else if (_selectedCalcMode == 'fidyah_fasting') {
      result = service.calculateFastingFidyah(
        missedDaysCount: _countInput,
        mealCostPerDayEgp: _costPerUnitEgp,
      );
    } else {
      result = service.calculateOathKaffarah(
        oathsCount: _countInput,
        mealCostPerPoorPersonEgp: _costPerUnitEgp,
      );
    }

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('kaffarah_fidyah_calc')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Calculation Mode Dropdown
            AppDropdownField<String>(
              label: 'اختر نوع الحاسبة الفقهية الشرعية',
              value: _selectedCalcMode,
              prefixIcon: Icons.calculate_rounded,
              options: const [
                AppDropdownOption(
                  value: 'zakat_fitr',
                  label: '١. حاسبة زكاة الفطر (بالصاع النبوي وبالقيمة النقدية)',
                  subtitle: 'صاع نبوي (٢.٥ كجم) عن كل فرد من أفراد الأسرة',
                ),
                AppDropdownOption(
                  value: 'fidyah_fasting',
                  label: '٢. حاسبة فدية الصيام للعاجز عجزاً دائماً',
                  subtitle: 'إطعام مسكين عن كل يوم أفطره الشيخ الكبير أو المريض المزمن',
                ),
                AppDropdownOption(
                  value: 'kaffarah_oath',
                  label: '٣. حاسبة كفارة اليمين المنعقدة وكفارة النذر',
                  subtitle: 'إطعام ١٠ مساكين أو كسوتهم، فمن لم يجد فصيام ٣ أيام',
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedCalcMode = val;
                  if (val == 'zakat_fitr') {
                    _countInput = 4;
                    _costPerUnitEgp = 50.0;
                  } else if (val == 'fidyah_fasting') {
                    _countInput = 30;
                    _costPerUnitEgp = 45.0;
                  } else {
                    _countInput = 1;
                    _costPerUnitEgp = 60.0;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Inputs Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCalcMode == 'zakat_fitr'
                          ? 'عدد أفراد الأسرة المزكّى عنهم: $_countInput أفراد'
                          : _selectedCalcMode == 'fidyah_fasting'
                              ? 'عدد أيام الإفطار: $_countInput يوماً'
                              : 'عدد الأيمان المحلوفة: $_countInput يمين',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    Slider(
                      value: _countInput
                          .toDouble()
                          .clamp(1.0, _selectedCalcMode == 'fidyah_fasting' ? 30.0 : 20.0),
                      min: 1,
                      max: _selectedCalcMode == 'fidyah_fasting' ? 30 : 20,
                      divisions:
                          (_selectedCalcMode == 'fidyah_fasting' ? 29 : 19),
                      activeColor: AppColors.primaryGreen,
                      label: '$_countInput',
                      onChanged: (val) =>
                          setState(() => _countInput = val.round()),
                    ),
                    const SizedBox(height: 8),
                    AppDropdownField<double>(
                      label: _selectedCalcMode == 'zakat_fitr'
                          ? 'قيمة الفرد الواحد نقداً (حسب مستوى القوت)'
                          : 'تكلفة إطعام المسكين الواحد (وجبة مشبعة)',
                      value: [35.0, 45.0, 50.0, 60.0, 75.0, 100.0]
                              .contains(_costPerUnitEgp)
                          ? _costPerUnitEgp
                          : 50.0,
                      prefixIcon: Icons.payments_rounded,
                      options: const [
                        AppDropdownOption(
                            value: 35.0, label: '٣٥ جنيهاً (الحد الأدنى المعتمد)'),
                        AppDropdownOption(
                            value: 45.0, label: '٤٥ جنيهاً (متوسط اقتصادي)'),
                        AppDropdownOption(
                            value: 50.0, label: '٥٠ جنيهاً (متوسط قياسي)'),
                        AppDropdownOption(
                            value: 60.0, label: '٦٠ جنيهاً (وسط فوق المعتاد)'),
                        AppDropdownOption(
                            value: 75.0, label: '٧٥ جنيهاً (إطعام كريم)'),
                        AppDropdownOption(
                            value: 100.0,
                            label: '١٠٠ جنيه (سعة وإحسان للفقراء)'),
                      ],
                      onChanged: (val) =>
                          setState(() => _costPerUnitEgp = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.35), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.summaryTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const Divider(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricBox(
                          label: 'القيمة النقدية الإجمالية',
                          value:
                              '${result.totalCashAmountEgp.toStringAsFixed(0)} ج.م',
                          icon: Icons.monetization_on_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricBox(
                          label: 'المقدار العيني من الطعام',
                          value:
                              '${result.totalFoodWeightKg.toStringAsFixed(1)} كجم',
                          icon: Icons.grain_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '📌 البيان الشرعي والبديل: ${result.alternativeFastOption}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '📖 الدليل الشرعي:\n${result.shariahEvidence}',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14.5,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 ملاحظة فقهية: ${result.fiqhNotes}',
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
