import '../../core/services/settings_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/models/surah.dart';
import '../../core/services/quran_repository.dart';
import '../../core/services/tafsir_service.dart';
import '../../core/audio/ayah_audio_player.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/app_dropdown_field.dart';

/// الميزة الثانية الجديدة: مقارن التفاسير المتوازي (المقارنة جنباً إلى جنب بين التفاسير التسعة المعتمدة)
class ComparativeTafsirScreen extends StatefulWidget {
  final int initialSurahId;
  final int initialAyahNumber;

  const ComparativeTafsirScreen({
    super.key,
    this.initialSurahId = 1,
    this.initialAyahNumber = 1,
  });

  @override
  State<ComparativeTafsirScreen> createState() => _ComparativeTafsirScreenState();
}

class _ComparativeTafsirScreenState extends State<ComparativeTafsirScreen> {
  List<Surah> _surahs = [];
  late int _selectedSurahId;
  late int _selectedAyahNumber;
  String _firstEditionId = 'muyassar';
  String _secondEditionId = 'ibn_kathir';
  String _thirdEditionId = 'shaarawi';
  bool _showThirdEdition = true;

  TafsirResult? _firstResult;
  TafsirResult? _secondResult;
  TafsirResult? _thirdResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedSurahId = widget.initialSurahId.clamp(1, 114);
    _selectedAyahNumber = widget.initialAyahNumber;
    _initData();
  }

  Future<void> _initData() async {
    final surahs = await QuranRepository.loadSurahs();
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
    });
    await _loadComparison();
  }

  Future<void> _loadComparison() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final r1 = await TafsirService.getTafsir(
      surahId: _selectedSurahId,
      ayahNumber: _selectedAyahNumber,
      editionId: _firstEditionId,
    );
    final r2 = await TafsirService.getTafsir(
      surahId: _selectedSurahId,
      ayahNumber: _selectedAyahNumber,
      editionId: _secondEditionId,
    );
    final r3 = await TafsirService.getTafsir(
      surahId: _selectedSurahId,
      ayahNumber: _selectedAyahNumber,
      editionId: _thirdEditionId,
    );
    if (!mounted) return;
    setState(() {
      _firstResult = r1;
      _secondResult = r2;
      _thirdResult = r3;
      _isLoading = false;
    });
  }

  Surah? get _currentSurah {
    if (_surahs.isEmpty) return null;
    return _surahs.firstWhere((s) => s.id == _selectedSurahId, orElse: () => _surahs.first);
  }

  String _buildCombinedShareText() {
    final sName = _currentSurah?.nameAr ?? 'السورة';
    final ayahText = _firstResult?.ayahText ?? '';
    final b = StringBuffer();
    b.writeln('﴿$ayahText﴾');
    b.writeln('[سورة $sName — الآية $_selectedAyahNumber]\n');
    if (_firstResult != null) {
      b.writeln('📘 أولاً: ${_firstResult!.editionName} (${_firstResult!.author}):');
      b.writeln(_firstResult!.tafsirText);
      b.writeln();
    }
    if (_secondResult != null) {
      b.writeln('📗 ثانياً: ${_secondResult!.editionName} (${_secondResult!.author}):');
      b.writeln(_secondResult!.tafsirText);
      b.writeln();
    }
    if (_showThirdEdition && _thirdResult != null) {
      b.writeln('📙 ثالثاً: ${_thirdResult!.editionName} (${_thirdResult!.author}):');
      b.writeln(_thirdResult!.tafsirText);
      b.writeln();
    }
    b.writeln('— مقارن التفاسير في تطبيق نور المؤمن');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surah = _currentSurah;
    final maxAyahs = surah?.ayahCount ?? 7;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('comparative_tafsir')),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'نسخ المقارنة التفسيرية',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _buildCombinedShareText())).catchError((_) {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ المقارنة التفسيرية إلى الحافظة')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'مشاركة المقارنة التفسيرية',
              onPressed: () {
                try {
                  Share.share(_buildCombinedShareText());
                } catch (_) {}
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Surah & Ayah Dropdown Selectors
            if (_surahs.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppDropdownField<int>(
                      label: 'اختر السورة الكريمة',
                      value: _selectedSurahId,
                      dense: true,
                      prefixIcon: Icons.menu_book_rounded,
                      options: _surahs
                          .map((s) => AppDropdownOption<int>(
                                value: s.id,
                                label: '${s.id}. سورة ${s.nameAr}',
                              ))
                          .toList(),
                      onChanged: (sId) {
                        setState(() {
                          _selectedSurahId = sId;
                          _selectedAyahNumber = 1;
                        });
                        _loadComparison();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: AppDropdownField<int>(
                      label: 'اختر الآية',
                      value: _selectedAyahNumber.clamp(1, maxAyahs),
                      dense: true,
                      options: List.generate(
                        maxAyahs,
                        (idx) => AppDropdownOption<int>(
                          value: idx + 1,
                          label: 'آية ${idx + 1}',
                        ),
                      ),
                      onChanged: (aNum) {
                        setState(() => _selectedAyahNumber = aNum);
                        _loadComparison();
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // 2. Dropdowns for Selecting Tafsir 1, Tafsir 2, and Tafsir 3
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'التفسير الأول للمقارنة',
                    value: _firstEditionId,
                    dense: true,
                    prefixIcon: Icons.looks_one_rounded,
                    options: TafsirService.availableEditions
                        .map((e) => AppDropdownOption<String>(value: e.id, label: e.nameAr))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _firstEditionId = val);
                      _loadComparison();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'التفسير الثاني للمقارنة',
                    value: _secondEditionId,
                    dense: true,
                    prefixIcon: Icons.looks_two_rounded,
                    options: TafsirService.availableEditions
                        .map((e) => AppDropdownOption<String>(value: e.id, label: e.nameAr))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _secondEditionId = val);
                      _loadComparison();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppDropdownField<String>(
                    label: 'التفسير الثالث (اختياري)',
                    value: _thirdEditionId,
                    dense: true,
                    prefixIcon: Icons.looks_3_rounded,
                    options: TafsirService.availableEditions
                        .map((e) => AppDropdownOption<String>(value: e.id, label: e.nameAr))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _thirdEditionId = val;
                        _showThirdEdition = true;
                      });
                      _loadComparison();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('إظهار الثالث'),
                  selected: _showThirdEdition,
                  selectedColor: AppColors.accentGold.withOpacity(0.3),
                  onSelected: (v) => setState(() => _showThirdEdition = v),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Ayah Display Card with Audio & Next/Previous Buttons
            if (_firstResult != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2520) : const Color(0xFFFBF9F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.accentGold, width: 1.4),
                ),
                child: Column(
                  children: [
                    Text(
                      _firstResult!.ayahText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        height: 2.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.chevron_right_rounded),
                          label: const Text('الآية السابقة'),
                          onPressed: _selectedAyahNumber > 1
                              ? () {
                                  setState(() => _selectedAyahNumber--);
                                  _loadComparison();
                                }
                              : null,
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.volume_up_rounded, size: 18),
                          label: const Text('استمع للآية'),
                          onPressed: () {
                            AyahAudioPlayer.instance.playAyah(
                              context,
                              _selectedSurahId,
                              _selectedAyahNumber,
                              surahName: surah?.nameAr,
                            );
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('الآية التالية'),
                          onPressed: _selectedAyahNumber < maxAyahs
                              ? () {
                                  setState(() => _selectedAyahNumber++);
                                  _loadComparison();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // 4. Comparative Tafsir Cards
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (_firstResult != null)
                _buildTafsirPaneCard(
                  badge: 'التفسير الأول',
                  result: _firstResult!,
                  accent: AppColors.primaryGreen,
                  isDark: isDark,
                ),
              if (_secondResult != null)
                _buildTafsirPaneCard(
                  badge: 'التفسير الثاني',
                  result: _secondResult!,
                  accent: const Color(0xFF0D5C46),
                  isDark: isDark,
                ),
              if (_showThirdEdition && _thirdResult != null)
                _buildTafsirPaneCard(
                  badge: 'التفسير الثالث',
                  result: _thirdResult!,
                  accent: const Color(0xFF8E6C18),
                  isDark: isDark,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTafsirPaneCard({
    required String badge,
    required TafsirResult result,
    required Color accent,
    required bool isDark,
  }) {
    return Semantics(
      container: true,
      label: '$badge: ${result.editionName}، للمؤلف ${result.author}: ${result.tafsirText}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.withOpacity(0.35), width: 1.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result.editionName,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'المؤلف: ${result.author}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.mutedText),
              ),
              const Divider(height: 18),
              Text(
                result.tafsirText,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 15.5, height: 1.85),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
