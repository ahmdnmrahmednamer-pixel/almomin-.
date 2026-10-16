import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/tafsir_service.dart';
import '../../../core/services/quran_repository.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/audio/ayah_audio_player.dart';

class TafsirViewerSheet extends StatefulWidget {
  final Surah surah;
  final Ayah initialAyah;

  const TafsirViewerSheet({
    super.key,
    required this.surah,
    required this.initialAyah,
  });

  static void show(BuildContext context, {required Surah surah, required Ayah ayah}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TafsirViewerSheet(surah: surah, initialAyah: ayah),
    );
  }

  @override
  State<TafsirViewerSheet> createState() => _TafsirViewerSheetState();
}

class _TafsirViewerSheetState extends State<TafsirViewerSheet> {
  late int _currentAyahNumber;
  String _selectedEditionId = 'muyassar';
  double _fontSize = 16.0;
  bool _isLoading = true;
  TafsirResult? _tafsirResult;

  @override
  void initState() {
    super.initState();
    _currentAyahNumber = widget.initialAyah.ayahNumber;
    _fontSize = (SettingsService.instance.mushafFontSize * 0.7).clamp(14.0, 26.0);
    _loadTafsir();
  }

  void _loadTafsir() async {
    setState(() => _isLoading = true);
    final res = await TafsirService.getTafsir(
      surahId: widget.surah.id,
      ayahNumber: _currentAyahNumber,
      editionId: _selectedEditionId,
    );
    if (mounted) {
      setState(() {
        _tafsirResult = res;
        _isLoading = false;
      });
    }
  }

  void _goToPreviousAyah() {
    if (_currentAyahNumber > 1) {
      setState(() => _currentAyahNumber--);
      _loadTafsir();
    }
  }

  void _goToNextAyah() {
    if (_currentAyahNumber < widget.surah.ayahCount) {
      setState(() => _currentAyahNumber++);
      _loadTafsir();
    }
  }

  void _copyTafsir() {
    if (_tafsirResult == null) return;
    final text = _tafsirResult!.formatForShare(widget.surah.nameAr);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ نص الآية والتفسير المعتمد إلى الحافظة'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareTafsir() {
    if (_tafsirResult == null) return;
    final text = _tafsirResult!.formatForShare(widget.surah.nameAr);
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B201E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Sheet Top Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryGreen, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'سورة ${widget.surah.nameAr} — الآية $_currentAyahNumber',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.format_size, size: 20),
                        tooltip: 'تغيير حجم خط التفسير',
                        onPressed: () {
                          setState(() {
                            _fontSize = _fontSize >= 24.0 ? 14.0 : _fontSize + 2.0;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        tooltip: 'نسخ التفسير',
                        onPressed: _copyTafsir,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, size: 20),
                        tooltip: 'مشاركة التفسير',
                        onPressed: _shareTafsir,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        tooltip: 'إغلاق',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tafsir Editions Horizontal Selector
            Container(
              height: 42,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: TafsirService.availableEditions.map((ed) {
                  final isSelected = ed.id == _selectedEditionId;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        ed.nameAr.split('(').first.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      onSelected: (val) {
                        if (val && ed.id != _selectedEditionId) {
                          setState(() => _selectedEditionId = ed.id);
                          _loadTafsir();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Ayah Text Container
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232A26) : const Color(0xFFF9F7F1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.accentGold.withOpacity(0.6), width: 1.2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _tafsirResult?.ayahText ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 19,
                                  height: 2.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.primaryGreen,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    ),
                                    icon: const Icon(Icons.play_circle_outline, size: 18),
                                    label: const Text('استمع للآية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      AyahAudioPlayer.instance.playAyah(
                                        context,
                                        widget.surah.id,
                                        _currentAyahNumber,
                                        surahName: widget.surah.nameAr,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Edition details card
                        Row(
                          children: [
                            const Icon(Icons.auto_stories, color: AppColors.secondaryGreen, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _tafsirResult?.editionName ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondaryGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تأليف: ${_tafsirResult?.author ?? ""}',
                          style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
                        ),
                        const SizedBox(height: 12),

                        // Exegesis Content Text
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            _tafsirResult?.tafsirText ?? '',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: _fontSize,
                              height: 1.9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),

            // Bottom Navigation: Previous Ayah / Next Ayah
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2522) : Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      label: const Text('الآية السابقة'),
                      onPressed: _currentAyahNumber > 1 ? _goToPreviousAyah : null,
                    ),
                    Text(
                      'الآية $_currentAyahNumber من ${widget.surah.ayahCount}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextButton.icon(
                        icon: const Icon(Icons.arrow_back_ios, size: 14),
                        label: const Text('الآية التالية'),
                        onPressed: _currentAyahNumber < widget.surah.ayahCount ? _goToNextAyah : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
