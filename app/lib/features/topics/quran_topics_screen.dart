import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../core/models/quran_topic.dart';
import '../../core/services/quran_topic_service.dart';
import '../../core/theme/app_theme.dart';
import 'topic_detail_screen.dart';

class QuranTopicsScreen extends StatefulWidget {
  final TopicCategory? initialCategory;

  const QuranTopicsScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<QuranTopicsScreen> createState() => _QuranTopicsScreenState();
}

class _QuranTopicsScreenState extends State<QuranTopicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TopicCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    QuranTopicService.instance.init();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTopicCard(QuranTopic topic) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: topic.primaryColor.withOpacity(0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicDetailScreen(topicId: topic.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: topic.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(topic.icon, color: topic.primaryColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            topic.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: topic.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${topic.ayahCount} آيات',
                            style: TextStyle(
                              color: topic.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        topic.category.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      topic.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTopics = QuranTopicService.instance.searchTopics(
      _searchQuery,
      category: _selectedCategory,
    );
    final featuredTopic = QuranTopicService.instance.getFeaturedTopic();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفهرس الموضوعي لآيات القرآن'),
      ),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث في موضوعات القرآن، الآيات، أو السور...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                        tooltip: 'إغلاق أو مسح',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1B231D) : Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
              ),
            ),

            // Horizontal Category Filter Chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: FilterChip(
                      selected: _selectedCategory == null,
                      label: Text('الكل (${QuranTopicService.instance.totalTopicsCount})'),
                      onSelected: (_) => setState(() => _selectedCategory = null),
                      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryGreen,
                    ),
                  ),
                  ...TopicCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final count = QuranTopicService.instance.getTopicsByCategory(cat).length;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                        selected: isSelected,
                        avatar: Icon(cat.icon, size: 16, color: isSelected ? AppColors.primaryGreen : Colors.grey),
                        label: Text('${cat.label} ($count)'),
                        onSelected: (_) => setState(() => _selectedCategory = isSelected ? null : cat),
                        selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                        checkmarkColor: AppColors.primaryGreen,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Featured Topic Banner (shown when search is empty)
            if (_searchQuery.isEmpty && _selectedCategory == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wb_twilight_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'موضوع اليوم القرآني المختار',
                              style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              featuredTopic.title,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentGold,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('تصفح الآيات'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopicDetailScreen(topicId: featuredTopic.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Topics List
            Expanded(
              child: filteredTopics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد موضوعات مطابقة للبحث',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 20),
                      itemCount: filteredTopics.length,
                      itemBuilder: (context, index) => _buildTopicCard(filteredTopics[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
