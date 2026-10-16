import 'package:flutter/material.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/theme/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  final TextEditingController _customPhraseController = TextEditingController();
  final TextEditingController _customTargetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _customPhraseController.dispose();
    _customTargetController.dispose();
    super.dispose();
  }

  void _onTapTasbih() async {
    _animController.forward().then((_) => _animController.reverse());
    AdhkarService.instance.incrementTasbih();
  }

  void _showCustomPhraseDialog() {
    _customPhraseController.text = AdhkarService.instance.selectedTasbihPhrase;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ذكر أو ورد مخصص'),
        content: TextField(
          controller: _customPhraseController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'اكتب الذكر هنا...',
            border: OutlineInputBorder(),
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              final text = _customPhraseController.text.trim();
              if (text.isNotEmpty) {
                AdhkarService.instance.setSelectedTasbihPhrase(text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showCustomTargetDialog() {
    _customTargetController.text = AdhkarService.instance.tasbihTarget > 0
        ? '${AdhkarService.instance.tasbihTarget}'
        : '33';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تحديد عدد التسبيحات المستهدف'),
        content: TextField(
          controller: _customTargetController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'مثال: 33، 100، 1000',
            border: OutlineInputBorder(),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              final val = int.tryParse(_customTargetController.text.trim());
              if (val != null && val > 0) {
                AdhkarService.instance.setTasbihTarget(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmResetSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تصفير عداد الجلسة'),
        content: const Text('هل تريد تصفير عداد التسبيح الحالي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              AdhkarService.instance.resetTasbih();
              Navigator.pop(ctx);
            },
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: AdhkarService.instance,
        builder: (context, _) {
          final count = AdhkarService.instance.tasbihCount;
          final target = AdhkarService.instance.tasbihTarget;
          final totalToday = AdhkarService.instance.tasbihTotalToday;
          final phrase = AdhkarService.instance.selectedTasbihPhrase;
          final haptic = AdhkarService.instance.hapticEnabled;

          // Compute cycle and progress
          final currentInCycle = target > 0 ? (count % target) : count;
          final progress = target > 0 ? (currentInCycle / target) : 0.0;
          final cyclesCompleted = target > 0 ? (count ~/ target) : 0;

          return Scaffold(
            appBar: AppBar(
              title: const Text('السبحة الإلكترونية الذكية'),
              actions: [
                IconButton(
                  icon: Icon(haptic ? Icons.vibration : Icons.smartphone_outlined),
                  tooltip: haptic ? 'الاهتزاز مفعل' : 'الاهتزاز معطل',
                  color: haptic ? AppColors.accentGold : Colors.white70,
                  onPressed: () {
                    AdhkarService.instance.toggleHaptic(!haptic);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(haptic ? 'تم تعطيل الاهتزاز' : 'تم تفعيل الاهتزاز'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تصفير العداد الحالي',
                  onPressed: _confirmResetSession,
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // 1. Famous Dhikr Pills Carousel
                  Container(
                    height: 52,
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        ...AdhkarService.famousTasbihPhrases.map((p) {
                          final isSelected = p == phrase;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                p,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.lightText),
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primaryGreen,
                              backgroundColor: isDark ? AppColors.darkSurface : Colors.grey[200],
                              onSelected: (val) {
                                if (val) {
                                  AdhkarService.instance.setSelectedTasbihPhrase(p);
                                }
                              },
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ActionChip(
                            avatar: const Icon(Icons.add, size: 16),
                            label: const Text('ذكر مخصص...'),
                            onPressed: _showCustomPhraseDialog,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Active Dhikr Card Display
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkSurface, const Color(0xFF1E2B24)]
                            : [AppColors.primaryGreen.withOpacity(0.08), AppColors.softGold.withOpacity(0.15)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accentGold.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            phrase,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamilyFallback: const ['Traditional Arabic', 'Amiri', 'serif'],
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.accentGold : AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.accentGold),
                          tooltip: 'تعديل الذكر',
                          onPressed: _showCustomPhraseDialog,
                        ),
                      ],
                    ),
                  ),

                  // 3. Target Selector (33, 100, Custom, Unlimited)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('الهدف: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        _buildTargetChip(label: '٣٣', value: 33, currentTarget: target),
                        const SizedBox(width: 6),
                        _buildTargetChip(label: '١٠٠', value: 100, currentTarget: target),
                        const SizedBox(width: 6),
                        _buildTargetChip(label: 'مفتوح', value: 0, currentTarget: target),
                        const SizedBox(width: 6),
                        ActionChip(
                          avatar: const Icon(Icons.tune, size: 14),
                          label: Text(target != 33 && target != 100 && target != 0 ? '$target' : 'مخصص'),
                          onPressed: _showCustomTargetDialog,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 4. Large Interactive Tactile Tasbih Button
                  GestureDetector(
                    onTap: _onTapTasbih,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [const Color(0xFF233D2D), AppColors.darkSurface]
                                : [AppColors.primaryGreen, const Color(0xFF132A20)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(isDark ? 0.4 : 0.35),
                              blurRadius: 28,
                              spreadRadius: 4,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppColors.accentGold.withOpacity(0.2),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.accentGold,
                            width: 3.5,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular Progress Indicator around the button
                            if (target > 0)
                              SizedBox(
                                width: 235,
                                height: 235,
                                child: CircularProgressIndicator(
                                  value: progress == 0.0 && count > 0 ? 1.0 : progress,
                                  strokeWidth: 5,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                                ),
                              ),

                            // Inside contents
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (target > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'الدورة: ${currentInCycle == 0 && count > 0 ? target : currentInCycle} / $target',
                                      style: const TextStyle(
                                        color: AppColors.softGold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                else
                                  const Text(
                                    'تسبيح مفتوح',
                                    style: TextStyle(color: AppColors.softGold, fontSize: 13),
                                  ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.touch_app, color: Colors.white70, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'المس للتسبيح',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 5. Bottom Stats Card (Cycles, Today's Total, Fast Reset)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                          title: 'الدورات المكتملة',
                          value: '$cyclesCompleted',
                          icon: Icons.done_all,
                          isDark: isDark,
                        ),
                        Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                        _buildStatColumn(
                          title: 'مجموع اليوم',
                          value: '$totalToday',
                          icon: Icons.calendar_today,
                          isDark: isDark,
                        ),
                        Container(height: 36, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                        IconButton(
                          icon: const Icon(Icons.restart_alt, color: Colors.orange),
                          tooltip: 'تصفير العداد',
                          onPressed: _confirmResetSession,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetChip({required String label, required int value, required int currentTarget}) {
    final isSelected = currentTarget == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentGold.withOpacity(0.35),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.grey[200],
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? AppColors.primaryGreen : (isDark ? Colors.white70 : AppColors.lightText),
      ),
      onSelected: (val) {
        if (val) {
          AdhkarService.instance.setTasbihTarget(value);
        }
      },
    );
  }

  Widget _buildStatColumn({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accentGold),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}
