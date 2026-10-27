import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/zakat_calculation.dart';
import '../../core/services/zakat_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';
import '../egypt/egyptian_heritage_screen.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  // Controllers for text inputs
  late final TextEditingController _cashController;
  late final TextEditingController _gold24Controller;
  late final TextEditingController _gold21Controller;
  late final TextEditingController _gold18Controller;
  late final TextEditingController _silverController;
  late final TextEditingController _tradeGoodsController;
  late final TextEditingController _debtsReceivableController;
  late final TextEditingController _debtsPayableController;
  late final TextEditingController _goldPriceController;
  late final TextEditingController _silverPriceController;

  late ZakatCalculation _calc;

  @override
  void initState() {
    super.initState();
    _calc = ZakatService.instance.calculation;

    _cashController = TextEditingController(text: _formatInitial(_calc.cashOnHand));
    _gold24Controller = TextEditingController(text: _formatInitial(_calc.gold24Grams));
    _gold21Controller = TextEditingController(text: _formatInitial(_calc.gold21Grams));
    _gold18Controller = TextEditingController(text: _formatInitial(_calc.gold18Grams));
    _silverController = TextEditingController(text: _formatInitial(_calc.silverGrams));
    _tradeGoodsController = TextEditingController(text: _formatInitial(_calc.tradeGoods));
    _debtsReceivableController = TextEditingController(text: _formatInitial(_calc.debtsReceivable));
    _debtsPayableController = TextEditingController(text: _formatInitial(_calc.debtsPayable));
    _goldPriceController = TextEditingController(text: _formatInitial(_calc.goldPricePerGram24));
    _silverPriceController = TextEditingController(text: _formatInitial(_calc.silverPricePerGram));
  }

  String _formatInitial(double val) {
    if (val <= 0) return '';
    return val % 1 == 0 ? val.toInt().toString() : val.toString();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _gold24Controller.dispose();
    _gold21Controller.dispose();
    _gold18Controller.dispose();
    _silverController.dispose();
    _tradeGoodsController.dispose();
    _debtsReceivableController.dispose();
    _debtsPayableController.dispose();
    _goldPriceController.dispose();
    _silverPriceController.dispose();
    super.dispose();
  }

  double _parse(String text) {
    const arabicDigits = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
      '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
      '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
      '٫': '.', '،': '',
    };
    final sb = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      sb.write(arabicDigits[ch] ?? ch);
    }
    final clean = sb.toString().replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }


  void _addGoldPreset({double g24 = 0, double g21 = 0}) {
    if (g24 > 0) {
      final cur = _parse(_gold24Controller.text);
      _gold24Controller.text = _formatInitial(cur + g24);
    }
    if (g21 > 0) {
      final cur = _parse(_gold21Controller.text);
      _gold21Controller.text = _formatInitial(cur + g21);
    }
    _onValuesChanged();
  }

  void _onValuesChanged() {
    setState(() {
      _calc = _calc.copyWith(
        cashOnHand: _parse(_cashController.text),
        gold24Grams: _parse(_gold24Controller.text),
        gold21Grams: _parse(_gold21Controller.text),
        gold18Grams: _parse(_gold18Controller.text),
        silverGrams: _parse(_silverController.text),
        tradeGoods: _parse(_tradeGoodsController.text),
        debtsReceivable: _parse(_debtsReceivableController.text),
        debtsPayable: _parse(_debtsPayableController.text),
        goldPricePerGram24: _parse(_goldPriceController.text) > 0 ? _parse(_goldPriceController.text) : _calc.goldPricePerGram24,
        silverPricePerGram: _parse(_silverPriceController.text) > 0 ? _parse(_silverPriceController.text) : _calc.silverPricePerGram,
      );
    });
    ZakatService.instance.updateCalculation(_calc);
  }

  void _resetAll() {
    setState(() {
      _cashController.clear();
      _gold24Controller.clear();
      _gold21Controller.clear();
      _gold18Controller.clear();
      _silverController.clear();
      _tradeGoodsController.clear();
      _debtsReceivableController.clear();
      _debtsPayableController.clear();
      _calc = ZakatCalculation(
        currency: _calc.currency,
        goldPricePerGram24: _calc.goldPricePerGram24,
        silverPricePerGram: _calc.silverPricePerGram,
        nisabBasis: _calc.nisabBasis,
      );
    });
    ZakatService.instance.reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إعادة تعيين حاسبة الزكاة')),
    );
  }

  void _shareZakatSummary() {
    final currency = _calc.currency;
    final totalWealth = _calc.netZakatableWealth.toStringAsFixed(2);
    final nisab = _calc.nisabThresholdValue.toStringAsFixed(2);
    final zakat = _calc.zakatDue.toStringAsFixed(2);
    final status = _calc.isNisabReached ? 'بلغ النصاب الشرعي وتجب فيه الزكاة (2.5%)' : 'لم يبلغ النصاب بعد';

    final text = '''
🕌 حساب الزكاة الشرعية — تطبيق نور المؤمن
حساب دقيق ومطابق للمعايير الفقهية المعتمدة

• وعاء الزكاة الصافي: $totalWealth $currency
• قيمة النصاب الشرعي (${_calc.nisabBasis == ZakatNisabBasis.gold ? "85 جم ذهب 24" : "595 جم فضة"}): $nisab $currency
• حالة النصاب: $status
• مقدار الزكاة الواجبة (2.5%): $zakat $currency

﴿وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ﴾
— تم الحساب بواسطة تطبيق نور المؤمن (بدون إعلانات وبدون تتبع)
''';

    try {
      Share.share(text, subject: 'تقرير حساب الزكاة الشرعية');
    } catch (_) {}
  }

  Future<void> _pickHawlDate() async {
    final now = DateTime.now();
    final initialDate = _calc.hawlDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _calc = _calc.copyWith(hawlDate: picked);
      });
      await ZakatService.instance.setHawlDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حاسبة الزكاة الشرعية الذكية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'مشاركة التقرير',
              onPressed: _shareZakatSummary,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة تعيين',
              onPressed: _resetAll,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'عن الحاسبة والإهداء',
              onPressed: () => _showDedicationDialog(context),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Noble Dedication Banner for Momin Ibrahim
            _buildDedicationBanner(context),
            const SizedBox(height: 12),

            // Live Output Summary Card
            _buildResultCard(isDark),
            const SizedBox(height: 16),

            // Nisab Settings & Currency Bar
            _buildSettingsCard(isDark),
            const SizedBox(height: 16),

            // Section 1: Cash & Bank Accounts
            _buildSectionCard(
              title: 'السيولة النقدية والأرصدة البنكية',
              icon: Icons.account_balance_wallet_outlined,
              isDark: isDark,
              children: [
                _buildInputField(
                  controller: _cashController,
                  label: 'الأموال النقدية والودائع والحسابات الجارية (${_calc.currency})',
                  hint: '0',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Section 2: Gold & Silver
            _buildSectionCard(
              title: 'الذهب والفضة المدخرة',
              icon: Icons.diamond_outlined,
              isDark: isDark,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _gold24Controller,
                        label: 'ذهب عيار 24 (جرام)',
                        hint: '0',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInputField(
                        controller: _gold21Controller,
                        label: 'ذهب عيار 21 (جرام)',
                        hint: '0',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _gold18Controller,
                        label: 'ذهب عيار 18 (جرام)',
                        hint: '0',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInputField(
                        controller: _silverController,
                        label: 'فضة خالصة (جرام)',
                        hint: '0',
                      ),
                    ),
                  ],
                ),
                if (_calc.totalPureGoldGrams > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'معادل الذهب الخالص عيار 24: ${_calc.totalPureGoldGrams.toStringAsFixed(2)} جرام',
                    style: const TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 12),
                const Text(
                  'إضافة سريعة للسبائك والجنيه الذهب في السوق المصري 🇪🇬:',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.monetization_on_outlined, size: 16),
                      label: const Text('+ جنيه ذهب (8 جم عيار 21)', style: TextStyle(fontSize: 12)),
                      onPressed: () => _addGoldPreset(g21: 8.0),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.auto_awesome_outlined, size: 16),
                      label: const Text('+ أونصة ذهب (31.1 جم عيار 24)', style: TextStyle(fontSize: 12)),
                      onPressed: () => _addGoldPreset(g24: 31.1),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.view_in_ar_rounded, size: 16),
                      label: const Text('+ سبيكة 10 جم (عيار 24)', style: TextStyle(fontSize: 12)),
                      onPressed: () => _addGoldPreset(g24: 10.0),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.gavel_rounded, size: 16),
                      label: const Text('فتاوى دار الإفتاء في الذهب والشهادات', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EgyptianHeritageScreen(initialTabIndex: 3),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Section 3: Trade Goods
            _buildSectionCard(
              title: 'عروض التجارة والاستثمارات',
              icon: Icons.storefront_outlined,
              isDark: isDark,
              children: [
                _buildInputField(
                  controller: _tradeGoodsController,
                  label: 'قيمة البضائع والمخزون المعد للبيع بسعر السوق الحالي (${_calc.currency})',
                  hint: '0',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Section 4: Debts Receivable & Payable
            _buildSectionCard(
              title: 'الديون والالتزامات المالية',
              icon: Icons.swap_horiz_rounded,
              isDark: isDark,
              children: [
                _buildInputField(
                  controller: _debtsReceivableController,
                  label: 'ديون مرجوة السداد لك عند الآخرين (تضاف للوعاء)',
                  hint: '0',
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  controller: _debtsPayableController,
                  label: 'ديون والتزامات حالّة واجبة السداد عليك فوراً (تخصم من الوعاء)',
                  hint: '0',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sharia Advisory Notice
            _buildShariaNoticeCard(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDedicationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.volunteer_activism, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حاسبة الزكاة الشرعية — نماء وطهارة للمال',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryGreen),
                ),
                Text(
                  '﴿خُذْ مِنْ أَمْوَالِهِمْ صَدَقَةً تُطَهِّرُهُمْ وَتُزَكِّيهِم بِهَا﴾',
                  style: TextStyle(fontSize: 11, color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: AppColors.accentGold, size: 20),
            onPressed: () => _showDedicationDialog(context),
            tooltip: 'دعاء لمؤمن إبراهيم',
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(bool isDark) {
    final reached = _calc.isNisabReached;
    final currency = _calc.currency;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: reached ? AppColors.accentGold : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: reached
                ? [AppColors.primaryGreen.withOpacity(0.08), AppColors.accentGold.withOpacity(0.12)]
                : [Colors.grey.withOpacity(0.06), Colors.grey.withOpacity(0.1)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ملخص الحساب الشرعي',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: reached ? Colors.green.shade700 : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    reached ? 'بلغ النصاب الشرعي ✓' : 'لم يبلغ النصاب بعد',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Two-column details: Net Wealth & Nisab
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('صافي وعاء الزكاة:', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                      const SizedBox(height: 2),
                      Text(
                        '${_calc.netZakatableWealth.toStringAsFixed(2)} $currency',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'قيمة النصاب (${_calc.nisabBasis == ZakatNisabBasis.gold ? "85 جم ذهب" : "595 جم فضة"}):',
                        style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_calc.nisabThresholdValue.toStringAsFixed(2)} $currency',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Big Zakat Amount Due
            Column(
              children: [
                const Text(
                  'مقدار الزكاة الواجب إخراجها (2.5% — ربع العشر)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondaryGreen),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_calc.zakatDue.toStringAsFixed(2)} $currency',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: reached ? AppColors.primaryGreen : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hawl (One Hijri Year) Reminder Button
            InkWell(
              onTap: _pickHawlDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.primaryGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _calc.hawlDate != null
                              ? 'موعد حولان الحول: ${_calc.hawlDate!.year}/${_calc.hawlDate!.month}/${_calc.hawlDate!.day}'
                              : 'تحديد موعد حولان الحول الهجري',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryGreen),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                const Text('إعدادات النصاب والأسعار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                // Currency Picker Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ZakatService.supportedCurrencies.contains(_calc.currency)
                          ? _calc.currency
                          : ZakatService.supportedCurrencies.first,
                      isDense: true,
                      items: ZakatService.supportedCurrencies.map((c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _calc = _calc.copyWith(currency: val);
                          });
                          ZakatService.instance.updateCalculation(_calc);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Nisab Basis Dropdown Switcher
            AppDropdownField<ZakatNisabBasis>(
              label: 'معيار حساب النصاب الشرعي',
              value: _calc.nisabBasis,
              dense: true,
              prefixIcon: Icons.monetization_on_outlined,
              options: const [
                AppDropdownOption(
                  value: ZakatNisabBasis.gold,
                  label: 'نصاب الذهب الخالص (85 جرام عيار 24 — المعتمد بدار الإفتاء)',
                  icon: Icons.monetization_on_outlined,
                ),
                AppDropdownOption(
                  value: ZakatNisabBasis.silver,
                  label: 'نصاب الفضة الخالصة (595 جرام فضة — الأحوط للفقراء)',
                  icon: Icons.savings_outlined,
                ),
              ],
              onChanged: (basis) {
                setState(() {
                  _calc = _calc.copyWith(nisabBasis: basis);
                });
                ZakatService.instance.updateCalculation(_calc);
              },
            ),
            const SizedBox(height: 12),

            // Gold and Silver Price per gram
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _goldPriceController,
                    label: 'سعر جرام ذهب 24 (${_calc.currency})',
                    hint: '3800',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField(
                    controller: _silverPriceController,
                    label: 'سعر جرام الفضة (${_calc.currency})',
                    hint: '45',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        hintText: hint,
        filled: true,
        fillColor: AppColors.primaryGreen.withOpacity(0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: (_) => _onValuesChanged(),
    );
  }

  Widget _buildShariaNoticeCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: AppColors.primaryGreen, size: 18),
              SizedBox(width: 6),
              Text(
                'تنبيه فقهي استرشادي:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryGreen),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '• تجب الزكاة إذا بلغ المال الصافي النصاب (ما يعادل 85 جرام ذهب خالص أو 595 جرام فضة) وحال عليه الحول الهجري (عام هجري كامل).\n• نسبة الزكاة هي 2.5% (ربع العشر) عن كل عام هجري.\n• هذه الحاسبة أداة مساعدة؛ في المسائل المعقدة كالمشاركات الاستثمارية والشركات المساهمة يُرجى استشارة دار الإفتاء والعلماء الثقات.',
            style: TextStyle(fontSize: 11.5, height: 1.6, color: AppColors.mutedText),
          ),
        ],
      ),
    );
  }

  void _showDedicationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.volunteer_activism, color: AppColors.accentGold),
              SizedBox(width: 8),
              Expanded(
                child: Text('فضل الزكاة والإنفاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الزكاة ركن الإسلام الثالث، طهارة للأموال ونماء وبركة في الرزق، وتطبيق نور المؤمن متاح مجاناً لوجه الله تعالى دون أي إعلانات.',
                style: TextStyle(height: 1.6, fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '«اللهم اجعل كل زكاة تُحسب وتُخرج عبر هذا التطبيق في ميزان حسنات عبادك الصالحين، وبركة في أموالهم، وطهرة لأنفسهم.. آمين يا رب العالمين.»',
                style: TextStyle(fontWeight: FontWeight.bold, height: 1.7, color: AppColors.primaryGreen, fontSize: 13.5),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('آمين يا رب العالمين', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
