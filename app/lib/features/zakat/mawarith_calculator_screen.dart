import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/mawarith_calculator_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

class MawarithCalculatorScreen extends StatefulWidget {
  const MawarithCalculatorScreen({super.key});

  @override
  State<MawarithCalculatorScreen> createState() => _MawarithCalculatorScreenState();
}

class _MawarithCalculatorScreenState extends State<MawarithCalculatorScreen> {
  final TextEditingController _estateController = TextEditingController(text: '120000');
  final TextEditingController _debtsController = TextEditingController(text: '0');
  final TextEditingController _bequestController = TextEditingController(text: '0');

  String _spouseStatus = 'wife_1';
  bool _hasFather = true;
  bool _hasMother = true;
  int _sonsCount = 2;
  int _daughtersCount = 1;
  int _fullBrothersCount = 0;
  int _fullSistersCount = 0;

  @override
  void dispose() {
    _estateController.dispose();
    _debtsController.dispose();
    _bequestController.dispose();
    super.dispose();
  }

  double _parseNum(String text) {
    const arabicDigits = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    final sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      sb.write(arabicDigits[text[i]] ?? text[i]);
    }
    return double.tryParse(sb.toString().replaceAll(',', '').trim()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = MawarithCalculatorService.instance.calculate(
      grossEstate: _parseNum(_estateController.text),
      debtsAndFuneral: _parseNum(_debtsController.text),
      bequest: _parseNum(_bequestController.text),
      spouseStatus: _spouseStatus,
      hasFather: _hasFather,
      hasMother: _hasMother,
      sonsCount: _sonsCount,
      daughtersCount: _daughtersCount,
      fullBrothersCount: _fullBrothersCount,
      fullSistersCount: _fullSistersCount,
    );

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('mawarith_calc')),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'مشاركة بيان تقسيم الميراث الشرعي',
              onPressed: () {
                final lines = summary.shares
                    .map((s) => '• ${s.heirNameAr} (${s.count}): ${s.shareTypeAr} = ${s.totalAmount.toStringAsFixed(2)} (${s.percentage.toStringAsFixed(1)}%)')
                    .join('\n');
                try {
                  Share.share(
                  '⚖️ بيان تقسيم التركة الشرعي (تطبيق نور المؤمن):\n'
                  'صافي التركة القابلة للتوزيع: ${summary.netDistributableEstate.toStringAsFixed(2)}\n\n'
                  '$lines\n\n﴿فَرِيضَةً مِّنَ اللَّهِ إِنَّ اللَّهَ كَانَ عَلِيمًا حَكِيمًا﴾',
                );
                } catch (_) {}
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Estate & Deductions Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '١. بيانات التركة والحقوق المتعلقة بها',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _estateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'إجمالي قيمة التركة (الأموال والعقارات والذهب)',
                        prefixIcon: const Icon(Icons.account_balance_rounded, color: AppColors.primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _debtsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الديون وتجهيز الميت',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _bequestController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'الوصية (بحد أقصى ١/٣)',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Heirs Selection Card using Dropdowns
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '٢. تحديد الورثة الشرعيين (قوائم منسدلة)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    AppDropdownField<String>(
                      label: 'الزوج أو الزوجة',
                      value: _spouseStatus,
                      dense: true,
                      prefixIcon: Icons.family_restroom_rounded,
                      options: const [
                        AppDropdownOption(value: 'none', label: 'لا يوجد زوج أو زوجة'),
                        AppDropdownOption(value: 'husband', label: 'زوج (للمتوفاة)'),
                        AppDropdownOption(value: 'wife_1', label: 'زوجة واحدة (للمتوفى)'),
                        AppDropdownOption(value: 'wife_2', label: 'زوجتان (تشتركان في الفرض)'),
                        AppDropdownOption(value: 'wife_3', label: '٣ زوجات (يشتركن في الفرض)'),
                        AppDropdownOption(value: 'wife_4', label: '٤ زوجات (يشتركن في الفرض)'),
                      ],
                      onChanged: (val) => setState(() => _spouseStatus = val),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('الأب على قيد الحياة', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                            value: _hasFather,
                            activeColor: AppColors.primaryGreen,
                            onChanged: (v) => setState(() => _hasFather = v),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('الأم على قيد الحياة', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                            value: _hasMother,
                            activeColor: AppColors.primaryGreen,
                            onChanged: (v) => setState(() => _hasMother = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdownField<int>(
                            label: 'عدد الأبناء الذكور',
                            value: _sonsCount,
                            dense: true,
                            options: List.generate(
                              11,
                              (i) => AppDropdownOption(value: i, label: i == 0 ? 'لا يوجد (٠)' : '$i أبناء ذكور'),
                            ),
                            onChanged: (v) => setState(() => _sonsCount = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppDropdownField<int>(
                            label: 'عدد البنات',
                            value: _daughtersCount,
                            dense: true,
                            options: List.generate(
                              11,
                              (i) => AppDropdownOption(value: i, label: i == 0 ? 'لا يوجد (٠)' : '$i بنات'),
                            ),
                            onChanged: (v) => setState(() => _daughtersCount = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppDropdownField<int>(
                            label: 'عدد الإخوة الأشقاء',
                            value: _fullBrothersCount,
                            dense: true,
                            options: List.generate(
                              11,
                              (i) => AppDropdownOption(value: i, label: i == 0 ? 'لا يوجد (٠)' : '$i إخوة أشقاء'),
                            ),
                            onChanged: (v) => setState(() => _fullBrothersCount = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppDropdownField<int>(
                            label: 'عدد الأخوات الشقيقات',
                            value: _fullSistersCount,
                            dense: true,
                            options: List.generate(
                              11,
                              (i) => AppDropdownOption(value: i, label: i == 0 ? 'لا يوجد (٠)' : '$i أخوات شقيقات'),
                            ),
                            onChanged: (v) => setState(() => _fullSistersCount = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Results Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2E22), Color(0xFF1B4332)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.accentGold),
              ),
              child: Column(
                children: [
                  const Text(
                    'صافي التركة القابلة للتوزيع الشرعي',
                    style: TextStyle(color: AppColors.softGold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.netDistributableEstate.toStringAsFixed(2),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  if (summary.hasAwl)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '⚖️ ملاحظة فقهية: المسألة فيها (عَوْل) لزيادة مجموع الفروض على الواحد الصحيح.',
                        style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (summary.hasRadd)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '⚖️ ملاحظة فقهية: المسألة فيها (رَدّ) لبقاء فائض بعد الفروض وعدم وجود عاصب.',
                        style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Individual Heir Cards with Quranic Proofs
            ...summary.shares.map((share) {
              return Semantics(
                container: true,
                label: '${share.heirNameAr}: ${share.shareTypeAr}، النسبة ${share.percentage.toStringAsFixed(1)} بالمئة، المبلغ الإجمالي ${share.totalAmount.toStringAsFixed(2)}',
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.25)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${share.heirNameAr} (العدد: ${share.count})',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppColors.primaryGreen),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${share.percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الفرض / التعصيب: ${share.shareTypeAr}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي النصيب: ${share.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            if (share.count > 1)
                              Text(
                                'نصيب الفرد: ${share.amountPerPerson.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 13, color: isDark ? AppColors.softGold : const Color(0xFF5D4037)),
                              ),
                          ],
                        ),
                        const Divider(height: 16),
                        Text(
                          '📖 الدليل القرآني: ${share.quranicEvidence}',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.mutedText, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
