import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/tajweed_rule.dart';
import '../../core/services/tajweed_service.dart';
import '../../core/theme/app_theme.dart';

class RuleDetailScreen extends StatefulWidget {
  final TajweedRule rule;

  const RuleDetailScreen({super.key, required this.rule});

  @override
  State<RuleDetailScreen> createState() => _RuleDetailScreenState();
}

class _RuleDetailScreenState extends State<RuleDetailScreen> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = TajweedService.instance.isFavorite(widget.rule.id);
  }

  void _toggleFavorite() {
    setState(() {
      _isFav = !_isFav;
    });
    TajweedService.instance.toggleFavorite(widget.rule.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFav ? 'تمت إضافة الحكم للمفضلة' : 'تمت إزالة الحكم من المفضلة',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareRule() {
    final buffer = StringBuffer();
    buffer.writeln('📖 حكم تجويدي: ${widget.rule.arabicTitle}');
    buffer.writeln('📂 القسم: ${widget.rule.categoryName}');
    buffer.writeln('📝 التعريف: ${widget.rule.definition}');
    buffer.writeln('🔤 الحروف: ${widget.rule.letters.join('، ')}');
    buffer.writeln('🎙️ كيفية الأداء: ${widget.rule.howToPronounce}');
    if (widget.rule.poeticVerse.isNotEmpty) {
      buffer.writeln('\n📜 الشاهد الشعري (${widget.rule.poeticSource}):');
      buffer.writeln(widget.rule.poeticVerse);
    }
    buffer.writeln('\n💡 أمثلة قرآنية:');
    for (var ex in widget.rule.examples) {
      buffer.writeln('• ${ex.targetWord} في قوله تعالى: ﴿${ex.ayahSnippet}﴾ [سورة ${ex.surahName}: ${ex.ayahNumber}]');
    }
    buffer.writeln('\n(تطبيق نور المؤمن - أحكام التجويد والقرآن الكريم)');
    try {
      Share.share(buffer.toString());
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rule = widget.rule;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(rule.arabicTitle),
          actions: [
            IconButton(
              icon: Icon(
                _isFav ? Icons.bookmark : Icons.bookmark_border,
                color: _isFav ? AppColors.accentGold : Colors.white,
              ),
              tooltip: _isFav ? 'إزالة من المفضلة' : 'حفظ في المفضلة',
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'مشاركة الحكم',
              onPressed: _shareRule,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة عنوان الحكم والقسم
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkCard, const Color(0xFF1B3528)]
                        : [Colors.white, const Color(0xFFF1F8F5)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rule.ruleColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: rule.ruleColor.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: rule.ruleColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: rule.ruleColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 5, backgroundColor: rule.ruleColor),
                              const SizedBox(width: 6),
                              Text(
                                rule.categoryName,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: rule.ruleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rule.ruleColor.withOpacity(0.12),
                          ),
                          child: Icon(Icons.menu_book, color: rule.ruleColor, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      rule.arabicTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rule.summary,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // حروف الحكم أو علامته
              _buildSectionCard(
                title: 'حروف وعلامات الحكم',
                icon: Icons.sort_by_alpha,
                iconColor: rule.ruleColor,
                isDark: isDark,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: rule.letters.map((letter) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2822) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: rule.ruleColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: rule.ruleColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // التعريف التفصيلي
              _buildSectionCard(
                title: 'التعريف والبيان الاصطلاحي',
                icon: Icons.info_outline,
                iconColor: AppColors.secondaryGreen,
                isDark: isDark,
                child: Text(
                  rule.definition,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.6,
                    color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // كيفية الأداء الصوتي
              _buildSectionCard(
                title: 'كيفية الأداء والتطبيق العملي',
                icon: Icons.record_voice_over,
                iconColor: const Color(0xFF0288D1),
                isDark: isDark,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0288D1).withOpacity(isDark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0288D1).withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates, color: Color(0xFF0288D1), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          rule.howToPronounce,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.55,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.blue.shade100 : const Color(0xFF01579B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (rule.poeticVerse.isNotEmpty) ...[
                const SizedBox(height: 16),
                // الشاهد الشعري
                _buildSectionCard(
                  title: 'الشاهد من المنظومة',
                  icon: Icons.auto_stories,
                  iconColor: AppColors.accentGold,
                  isDark: isDark,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withOpacity(isDark ? 0.1 : 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.35)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          rule.poeticVerse,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            height: 1.8,
                            color: isDark ? AppColors.softGold : const Color(0xFF7B5E00),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '— ${rule.poeticSource}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // أمثلة قرآنية بالرسم العثماني
              _buildSectionCard(
                title: 'أمثلة من القرآن الكريم',
                icon: Icons.menu_book_rounded,
                iconColor: rule.ruleColor,
                isDark: isDark,
                child: Column(
                  children: rule.examples.map((ex) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2822) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: rule.ruleColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'الموضع: ${ex.targetWord}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: rule.ruleColor,
                                  ),
                                ),
                              ),
                              Text(
                                'سورة ${ex.surahName}: ${ex.ayahNumber}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '﴿ ${ex.ayahSnippet} ﴾',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.7,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ex.explanation,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // تذييل الصدقة الجارية
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'تطبيق نور المؤمن — تعلّم أحكام التجويد وإتقان التلاوة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
