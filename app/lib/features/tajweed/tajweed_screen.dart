import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../core/models/tajweed_rule.dart';
import '../../core/services/tajweed_service.dart';
import '../../core/theme/app_theme.dart';
import 'rule_detail_screen.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  TajweedCategory? _selectedCategory; // null means 'all'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    TajweedService.instance.init();
    TajweedService.instance.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    TajweedService.instance.removeListener(_onServiceUpdate);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TajweedRule> get _filteredRules {
    List<TajweedRule> list = TajweedService.instance.getAllRules();

    if (_selectedCategory != null) {
      list = list.where((r) => r.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      list = TajweedService.instance.searchRules(_searchQuery);
      if (_selectedCategory != null) {
        list = list.where((r) => r.category == _selectedCategory).toList();
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('أحكام التجويد وضبط المصحف'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accentGold,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
            tabs: const [
              Tab(icon: Icon(Icons.menu_book, size: 20), text: 'أحكام التجويد'),
              Tab(icon: Icon(Icons.palette, size: 20), text: 'دليل الألوان'),
              Tab(icon: Icon(Icons.bookmark, size: 20), text: 'المحفوظات'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: أحكام وقواعد التجويد الشاملة
            _buildRulesTab(isDark),

            // Tab 2: دليل الترميز اللوني لمصحف التجويد
            _buildColorGuideTab(isDark),

            // Tab 3: الأحكام المفضلة المحفوظة
            _buildFavoritesTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesTab(bool isDark) {
    final rules = _filteredRules;

    return Column(
      children: [
        // شريط البحث
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'ابحث عن حكم، حرف، أو مثال قرآني...',
              prefixIcon: const Icon(Icons.search, color: AppColors.secondaryGreen),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                    tooltip: 'إغلاق أو مسح',
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? AppColors.darkCard : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),

        // شريط تصفية الأقسام
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildCategoryChip(null, 'الكل', isDark),
              _buildCategoryChip(TajweedCategory.nunTanween, 'النون والتنوين', isDark),
              _buildCategoryChip(TajweedCategory.meemSakinah, 'الميم الساكنة', isDark),
              _buildCategoryChip(TajweedCategory.madd, 'أحكام المدود', isDark),
              _buildCategoryChip(TajweedCategory.qalqalah, 'القلقلة', isDark),
              _buildCategoryChip(TajweedCategory.waqfMarks, 'علامات الوقف', isDark),
              _buildCategoryChip(TajweedCategory.raaLaam, 'الراء واللام', isDark),
              _buildCategoryChip(TajweedCategory.makhaarij, 'المخارج والصفات', isDark),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // قائمة الأحكام
        Expanded(
          child: rules.isEmpty
              ? _buildEmptyState(
                  icon: Icons.search_off,
                  message: 'لم يتم العثور على أي أحكام مطابقة لبحثك',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return _buildRuleCard(rule, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(TajweedCategory? category, String label, bool isDark) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade800),
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primaryGreen,
        backgroundColor: isDark ? AppColors.darkCard : const Color(0xFFEEEEEE),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }

  Widget _buildRuleCard(TajweedRule rule, bool isDark) {
    final isFav = TajweedService.instance.isFavorite(rule.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.ruleColor.withOpacity(0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RuleDetailScreen(rule: rule)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: rule.ruleColor.withOpacity(0.18),
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: rule.ruleColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          rule.arabicTitle,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'حفظ في المفضلة',
                      icon: Icon(
                        isFav ? Icons.bookmark : Icons.bookmark_border,
                        color: isFav ? AppColors.accentGold : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        TajweedService.instance.toggleFavorite(rule.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rule.summary,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
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
                        rule.categoryName,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: rule.ruleColor,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'التفاصيل والأمثلة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: rule.ruleColor,
                          ),
                        ),
                        Icon(Icons.chevron_left, size: 18, color: rule.ruleColor),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorGuideTab(bool isDark) {
    final colors = TajweedService.instance.getColorGuide();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        // مقدمة التلوين المعتمد
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_stories, color: AppColors.primaryGreen, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'الترميز اللوني لمصحف التجويد الملون',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'اعتمدت مصاحف التجويد الملونة نظاماً موحداً من الألوان يساعد القارئ على تطبيق أحكام التلاوة تلقائياً بمجرد النظر إلى لون الحرف أثناء القراءة.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...colors.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withOpacity(0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.durationOrEffect,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.rules.map((r) {
                    return Chip(
                      label: Text(r, style: TextStyle(fontSize: 11, color: isDark ? Colors.white : Colors.black87)),
                      backgroundColor: isDark ? const Color(0xFF263228) : const Color(0xFFF0F4F1),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 10),
        Center(
          child: Text(
            '«خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ» (رواه البخاري)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFavoritesTab(bool isDark) {
    final favRules = TajweedService.instance.getFavoriteRules();

    if (favRules.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bookmark_border,
        message: 'لم تحفظ أي أحكام في المفضلة بعد.\nاضغط على علامة الحفظ في أي حكم لتتمكن من مراجعته هنا بسهولة.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: favRules.length,
      itemBuilder: (context, index) {
        final rule = favRules[index];
        return _buildRuleCard(rule, isDark);
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
