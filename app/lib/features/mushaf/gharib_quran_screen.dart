import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../core/services/gharib_quran_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_theme.dart';

/// الميزة الجديدة ٤: شاشة معجم غريب القرآن والمفردات القرآنية التفاعلي مع اختبار المعاني
class GharibQuranScreen extends StatefulWidget {
  const GharibQuranScreen({super.key});

  @override
  State<GharibQuranScreen> createState() => _GharibQuranScreenState();
}

class _GharibQuranScreenState extends State<GharibQuranScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _quizScore = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    GharibQuranService.instance.init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _answerQuestion(int optionIndex, GharibWordEntry question) {
    if (_selectedOptionIndex != null) return;
    setState(() {
      _selectedOptionIndex = optionIndex;
      if (optionIndex == question.correctOptionIndex) {
        _quizScore++;
        GharibQuranService.instance.recordQuizScore(_quizScore);
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _selectedOptionIndex = null;
      if (_currentQuestionIndex < GharibQuranService.allWords.length - 1) {
        _currentQuestionIndex++;
      } else {
        _currentQuestionIndex = 0;
        _quizScore = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = GharibQuranService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([service, SettingsService.instance]),
      builder: (context, _) {
        final words = service.searchWords(_searchQuery);
        final quizWord = GharibQuranService.allWords[_currentQuestionIndex];

        return Directionality(
          textDirection: SettingsService.instance.textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.tr('gharib_quran_dict')),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentGold,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.menu_book_rounded),
                    text: 'معجم غريب القرآن والجذور',
                  ),
                  Tab(
                    icon: Icon(Icons.quiz_rounded),
                    text: 'اختبر فهمك لكلمات القرآن',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Dictionary
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText:
                              'ابحث بالكلمة القرآنية أو الجذر اللغوي أو اسم السورة...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          isDense: true,
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          final w = words[index];
                          final isMastered =
                              service.masteredWordIds.contains(w.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen
                                              .withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          w.word,
                                          style: const TextStyle(
                                            fontFamily: 'Amiri',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'الجذر اللغوي: (${w.root})',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                                color: AppColors.accentGold,
                                              ),
                                            ),
                                            Text(
                                              'سورة ${w.surahName} (${w.surahNumber}:${w.ayahNumber}) • الجزء ${w.juzNumber}',
                                              style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isMastered
                                              ? Icons.verified_rounded
                                              : Icons.check_circle_outline_rounded,
                                          color: isMastered
                                              ? AppColors.primaryGreen
                                              : Colors.grey,
                                        ),
                                        tooltip: 'تم إتقان المفردة',
                                        onPressed: () =>
                                            service.toggleMastered(w.id),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    w.ayahSnippet,
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '✅ المعنى البياني: ${w.meaningAr}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '🌍 English: ${w.meaningEn}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '💎 لطيفة بلاغية: ${w.rhetoricalNote}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Tab 2: Interactive Quiz
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'السؤال ${_currentQuestionIndex + 1} من ${GharibQuranService.allWords.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                Text(
                                  'النتيجة الحالية: $_quizScore | أعلى نتيجة: ${service.quizBestScore}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentGold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text(
                              'ما معنى الكلمة القرآنية الكريمة في الآية التالية؟',
                              style: TextStyle(
                                  fontSize: 13.5, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                '« ${quizWord.word} »',
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Center(
                              child: Text(
                                '${quizWord.ayahSnippet} [سورة ${quizWord.surahName}: ${quizWord.ayahNumber}]',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...quizWord.quizOptions
                                .asMap()
                                .entries
                                .map((entry) {
                              final idx = entry.key;
                              final text = entry.value;
                              final isAnswered = _selectedOptionIndex != null;
                              final isCorrect =
                                  idx == quizWord.correctOptionIndex;
                              final isSelected = idx == _selectedOptionIndex;

                              Color? tileColor;
                              if (isAnswered) {
                                if (isCorrect) {
                                  tileColor =
                                      Colors.green.withOpacity(0.15);
                                } else if (isSelected) {
                                  tileColor = Colors.red.withOpacity(0.15);
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: tileColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isAnswered && isCorrect
                                        ? Colors.green
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(
                                    text,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                  trailing: isAnswered && isCorrect
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : null,
                                  onTap: () =>
                                      _answerQuestion(idx, quizWord),
                                ),
                              );
                            }),
                            if (_selectedOptionIndex != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                '💡 ${quizWord.rhetoricalNote}',
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.primaryGreen),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text('السؤال التالي'),
                                  onPressed: _nextQuestion,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
}
