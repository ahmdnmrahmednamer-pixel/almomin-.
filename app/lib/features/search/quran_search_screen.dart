import 'package:flutter/material.dart';
import '../../core/models/surah.dart';
import '../../core/services/quran_repository.dart';
import '../../core/theme/app_theme.dart';
import '../mushaf/surah_reader_screen.dart';

class QuranSearchScreen extends StatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  State<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends State<QuranSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Surah> _results = [];
  bool _isLoading = false;

  void _onSearchChanged(String query) async {
    setState(() => _isLoading = true);
    final results = await QuranRepository.searchSurahs(query);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث في القرآن الكريم'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم السورة أو رقمها (مثال: الكهف، البقرة، 18)...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: _results.isEmpty
                    ? const Center(
                        child: Text('لم يتم العثور على نتائج تطابق بحثك', style: TextStyle(color: AppColors.mutedText)),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final surah = _results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                              child: Text('${surah.id}', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                            ),
                            title: Text('سورة ${surah.nameAr}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${surah.isMakki ? "مكية" : "مدنية"} — آياتها: ${surah.ayahCount} — صفحة ${surah.pageStart}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SurahReaderScreen(surah: surah),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
