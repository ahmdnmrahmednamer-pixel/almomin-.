import '../../core/services/settings_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/surah.dart';
import '../../core/models/ayah.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/quran_search_service.dart';
import '../../core/text/arabic_normalizer.dart';
import '../../core/theme/app_theme.dart';
import '../mushaf/surah_reader_screen.dart';
import '../mushaf/page_mode_mushaf_screen.dart';
import '../mushaf/widgets/tafsir_viewer_sheet.dart';

enum SearchScope {
  all,
  ayahs,
  surahs,
}

class QuranSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const QuranSearchScreen({super.key, this.initialQuery});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  SearchScope _scope = SearchScope.all;
  int? _selectedSurahFilter;
  List<Surah> _allSurahs = [];

  QuranReferenceMatch? _referenceMatch;
  Ayah? _referenceAyah;
  Surah? _referenceSurah;

  List<Surah> _surahResults = [];
  List<AyahSearchResult> _ayahResults = [];
  List<String> _history = [];

  bool _isLoading = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitial();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _controller.text = widget.initialQuery!;
      _onSearchChanged(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final surahs = await QuranRepository.loadSurahs();
    final hist = await QuranSearchService.instance.getSearchHistory();
    if (mounted) {
      setState(() {
        _allSurahs = surahs;
        _history = hist;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      setState(() {
        _currentQuery = '';
        _referenceMatch = null;
        _referenceAyah = null;
        _referenceSurah = null;
        _surahResults = [];
        _ayahResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentQuery = cleanQuery;
    });

    // 1. Check direct reference (2:255, البقرة 255, آية الكرسي)
    final refMatch = await QuranSearchService.instance.parseReference(cleanQuery);
    Ayah? refAyah;
    Surah? refSurah;
    if (refMatch != null) {
      refAyah = await QuranRepository.getAyah(refMatch.surahId, refMatch.ayahNumber);
      if (_allSurahs.isNotEmpty) {
        refSurah = _allSurahs.firstWhere(
          (s) => s.id == refMatch.surahId,
          orElse: () => _allSurahs.first,
        );
      }
    }

    // 2. Search Surahs
    final surahs = await QuranRepository.searchSurahs(cleanQuery);

    // 3. Search Ayahs
    final ayahs = await QuranSearchService.instance.searchAyahs(
      cleanQuery,
      surahFilter: _selectedSurahFilter,
      limit: 100,
    );

    // Save to history if search produced results
    if (cleanQuery.length >= 2 && (refMatch != null || surahs.isNotEmpty || ayahs.isNotEmpty)) {
      await QuranSearchService.instance.addToHistory(cleanQuery);
      final updatedHistory = await QuranSearchService.instance.getSearchHistory();
      if (mounted) {
        setState(() => _history = updatedHistory);
      }
    }

    if (mounted) {
      setState(() {
        _referenceMatch = refMatch;
        _referenceAyah = refAyah;
        _referenceSurah = refSurah;
        _surahResults = surahs;
        _ayahResults = ayahs;
        _isLoading = false;
      });
    }
  }

  void _selectHistoryItem(String item) {
    _controller.text = item;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: item.length));
    _executeSearch(item);
  }

  void _copyAyah(Ayah ayah, Surah surah) {
    final text = '﴿${ayah.textUthmani}﴾ [سورة ${surah.nameAr}: ${ayah.ayahNumber}]';
    Clipboard.setData(ClipboardData(text: text)).catchError((_) {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الآية الكريمة بنجاح')),
    );
  }

  void _shareAyah(Ayah ayah, Surah surah) {
    final text = '﴿${ayah.textUthmani}﴾\n[سورة ${surah.nameAr} — الآية ${ayah.ayahNumber} · صفحة ${ayah.page}]\n\nتمت المشاركة من تطبيق نور المؤمن';
    try {
      Share.share(text);
    } catch (_) {}
  }

  List<TextSpan> _buildHighlightedSpans(String text, String query) {
    if (query.trim().isEmpty) {
      return [TextSpan(text: text)];
    }

    final normQuery = ArabicNormalizer.normalize(query, loose: true);
    final words = text.split(' ');
    final List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final normWord = ArabicNormalizer.normalize(word, loose: true);
      final isMatch = normWord.contains(normQuery) || normQuery.contains(normWord);

      if (isMatch) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(
              color: Color(0xFFB78103),
              fontWeight: FontWeight.bold,
              backgroundColor: Color(0x33FFD700),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: '$word '));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final hasResults = _referenceMatch != null || _surahResults.isNotEmpty || _ayahResults.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث في القرآن الكريم'),
        actions: [
          if (_currentQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث البحث',
              onPressed: () => _executeSearch(_currentQuery),
            ),
        ],
      ),
      body: Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: widget.initialQuery == null,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                onSubmitted: _executeSearch,
                decoration: InputDecoration(
                  hintText: 'ابحث بآية، كلمة، سورة، أو مرجع (مثال: آية الكرسي، 2:255، الكهف)...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                        tooltip: 'إغلاق أو مسح',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _executeSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.08),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Scope & Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('الكل', style: TextStyle(fontSize: 12)),
                    selected: _scope == SearchScope.all,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: _scope == SearchScope.all ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                      fontWeight: _scope == SearchScope.all ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _scope = SearchScope.all),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(
                      'الآيات ${_ayahResults.isNotEmpty ? "(${_ayahResults.length})" : ""}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: _scope == SearchScope.ayahs,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: _scope == SearchScope.ayahs ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                      fontWeight: _scope == SearchScope.ayahs ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _scope = SearchScope.ayahs),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(
                      'السور ${_surahResults.isNotEmpty ? "(${_surahResults.length})" : ""}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: _scope == SearchScope.surahs,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: _scope == SearchScope.surahs ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                      fontWeight: _scope == SearchScope.surahs ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _scope = SearchScope.surahs),
                  ),
                  const Spacer(),
                  // Filter by Surah Button
                  PopupMenuButton<int?>(
                    tooltip: 'تصفية حسب السورة',
                    initialValue: _selectedSurahFilter,
                    icon: Icon(
                      Icons.filter_list,
                      color: _selectedSurahFilter != null ? AppColors.accentGold : AppColors.primaryGreen,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedSurahFilter = val);
                      if (_currentQuery.isNotEmpty) _executeSearch(_currentQuery);
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem<int?>(
                        value: null,
                        child: Text('كافة السور (بدون تصفية)'),
                      ),
                      const PopupMenuDivider(),
                      ..._allSurahs.map(
                        (s) => PopupMenuItem<int?>(
                          value: s.id,
                          child: Text('${s.id}. سورة ${s.nameAr}'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                          SizedBox(height: 12),
                          Text('جاري البحث في المصحف الشريف...', style: TextStyle(color: AppColors.lightText)),
                        ],
                      ),
                    )
                  : _currentQuery.isEmpty
                      ? _buildInitialState()
                      : !hasResults
                          ? _buildNoResultsState()
                          : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: AppColors.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text('سجل البحث الأخير', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              TextButton(
                onPressed: () async {
                  await QuranSearchService.instance.clearHistory();
                  if (!mounted) return;
                  setState(() => _history = []);
                },
                child: const Text('مسح السجل', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _history.map((item) {
              return InputChip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                backgroundColor: AppColors.primaryGreen.withOpacity(0.06),
                onPressed: () => _selectHistoryItem(item),
                onDeleted: () async {
                  await QuranSearchService.instance.removeFromHistory(item);
                  if (!mounted) return;
                  final updated = await QuranSearchService.instance.getSearchHistory();
                  if (!mounted) return;
                  setState(() => _history = updated);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        const Row(
          children: [
            Icon(Icons.star_outline, color: AppColors.accentGold, size: 20),
            SizedBox(width: 8),
            Text('عمليات بحث مقترحة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'آية الكرسي',
            'الرحمن الرحيم',
            'سورة الكهف',
            'خواتيم البقرة',
            'الله نور السماوات',
            'آية الدين',
            'سورة الملك',
            'سورة يس',
          ].map((item) {
            return ActionChip(
              avatar: const Icon(Icons.search, size: 16, color: AppColors.primaryGreen),
              label: Text(item, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.accentGold.withOpacity(0.12),
              onPressed: () => _selectHistoryItem(item),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Search Tips Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade300),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.accentGold, size: 20),
                  SizedBox(width: 8),
                  Text('إرشادات البحث الذكي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              SizedBox(height: 6),
              Text('• يمكنك البحث باسم السورة ورقم الآية: "البقرة 255" أو "18:10".', style: TextStyle(fontSize: 12, height: 1.5)),
              Text('• يمكنك البحث بأسماء الآيات الشهيرة: "آية الكرسي"، "آية الدين"، "خواتيم البقرة".', style: TextStyle(fontSize: 12, height: 1.5)),
              Text('• خوارزمية البحث تتجاهل التشكيل والهمزات والتاء المربوطة تلقائياً.', style: TextStyle(fontSize: 12, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.mutedText),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على نتائج لـ "$_currentQuery"',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'تأكد من كتابة الكلمة بصورة صحيحة أو جرب البحث بكلمة واحدة أو بدون (ال) التعريف.',
              style: TextStyle(color: AppColors.lightText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 1. Prominent Reference Match Card (FR-SRC-002)
        if (_referenceMatch != null && _referenceAyah != null && _referenceSurah != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.08),
                  AppColors.accentGold.withOpacity(0.12),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentGold, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.black, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _referenceMatch!.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryGreen),
                          ),
                          if (_referenceMatch!.aliasNote != null)
                            Text(
                              _referenceMatch!.aliasNote!,
                              style: const TextStyle(fontSize: 11, color: AppColors.lightText),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'صفحة ${_referenceAyah!.page}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '﴿${_referenceAyah!.textUthmani}﴾',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    height: 1.6,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.menu_book, size: 16),
                        label: const Text('فتح في المصحف', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageModeMushafScreen(initialPage: _referenceAyah!.page),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chrome_reader_mode_outlined, size: 16, color: AppColors.primaryGreen),
                        label: const Text('التفسير', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          TafsirViewerSheet.show(
                            context,
                            surah: _referenceSurah!,
                            ayah: _referenceAyah!,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // 2. Surah Results Section
        if ((_scope == SearchScope.all || _scope == SearchScope.surahs) && _surahResults.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.bookmark_outline, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                'نتائج السور (${_surahResults.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._surahResults.map((surah) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: Text('${surah.id}', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                ),
                title: Text('سورة ${surah.nameAr}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${surah.isMakki ? "مكية" : "مدنية"} · آياتها: ${surah.ayahCount} · صفحة ${surah.pageStart}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahReaderScreen(surah: surah),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // 3. Ayahs Results Section
        if ((_scope == SearchScope.all || _scope == SearchScope.ayahs) && _ayahResults.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.format_quote, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 6),
              Text(
                'نتائج الآيات (${_ayahResults.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
              ),
              if (_selectedSurahFilter != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('مصفى حسب السورة', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ..._ayahResults.map((result) {
            final ayah = result.ayah;
            final surah = result.surah;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Surah and Ayah Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'سورة ${surah.nameAr} : آية ${ayah.ayahNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'صفحة ${ayah.page} · جزء ${ayah.juz}',
                          style: const TextStyle(fontSize: 11, color: AppColors.lightText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Ayah Text with Highlighted Query Words (FR-SRC-003)
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 17,
                          height: 1.6,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                        children: _buildHighlightedSpans(ayah.textUthmani, result.query),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.chrome_reader_mode_outlined, size: 16, color: AppColors.primaryGreen),
                          label: const Text('التفسير', style: TextStyle(fontSize: 11.5, color: AppColors.primaryGreen)),
                          onPressed: () => TafsirViewerSheet.show(context, surah: surah, ayah: ayah),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.auto_stories_rounded, size: 16, color: AppColors.primaryGreen),
                          label: const Text('المصحف', style: TextStyle(fontSize: 11.5, color: AppColors.primaryGreen)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PageModeMushafScreen(initialPage: ayah.page),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16, color: AppColors.primaryGreen),
                          tooltip: 'نسخ الآية',
                          onPressed: () => _copyAyah(ayah, surah),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, size: 16, color: AppColors.primaryGreen),
                          tooltip: 'مشاركة الآية',
                          onPressed: () => _shareAyah(ayah, surah),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
