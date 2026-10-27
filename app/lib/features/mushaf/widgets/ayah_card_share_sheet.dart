import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/tafsir_service.dart';
import '../../../core/services/ayah_card_service.dart';
import 'ayah_card_widget.dart';

class AyahCardShareSheet extends StatefulWidget {
  final Surah surah;
  final Ayah ayah;

  const AyahCardShareSheet({
    super.key,
    required this.surah,
    required this.ayah,
  });

  static void show(BuildContext context, {required Surah surah, required Ayah ayah}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AyahCardShareSheet(surah: surah, ayah: ayah),
    );
  }

  @override
  State<AyahCardShareSheet> createState() => _AyahCardShareSheetState();
}

class _AyahCardShareSheetState extends State<AyahCardShareSheet> {
  final GlobalKey _boundaryKey = GlobalKey();

  AyahCardTheme _selectedTheme = AyahCardTheme.availableThemes.first;
  double _fontSize = 22.0;
  bool _includeTafsir = true;
  bool _includeSurahHeader = true;
  bool _includeDedication = true;

  String? _tafsirText;
  bool _isLoadingTafsir = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchTafsir();
  }

  Future<void> _fetchTafsir() async {
    try {
      final res = await TafsirService.getTafsir(
        surahId: widget.surah.id,
        ayahNumber: widget.ayah.ayahNumber,
        editionId: 'muyassar',
      );
      if (mounted) {
        setState(() {
          _tafsirText = res.tafsirText;
          _isLoadingTafsir = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingTafsir = false);
      }
    }
  }

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      await AyahCardService.shareCard(
        context: context,
        boundaryKey: _boundaryKey,
        surah: widget.surah,
        ayah: widget.ayah,
        tafsirText: _includeTafsir ? _tafsirText : null,
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _copyAyahText() {
    final text = AyahCardService.formatShareCaption(
      surah: widget.surah,
      ayah: widget.ayah,
      tafsirText: _includeTafsir ? _tafsirText : null,
    );
    Clipboard.setData(ClipboardData(text: text)).catchError((_) {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ نص الآية الكريمة والتفسير بنجاح'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle Bar & Title
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.brush_rounded, color: AppColors.accentGold, size: 20),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تصميم بطاقة الآية الدعوية',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: 'إغلاق أو مسح',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Preview Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'معاينة البطاقة:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (_isLoadingTafsir)
                          const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 6),
                              Text('تحميل التفسير...', style: TextStyle(fontSize: 12, color: AppColors.mutedText)),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Centered Live Card Preview wrapped in RepaintBoundary
                    Center(
                      child: RepaintBoundary(
                        key: _boundaryKey,
                        child: AyahIslamicCardWidget(
                          surah: widget.surah,
                          ayah: widget.ayah,
                          theme: _selectedTheme,
                          fontSize: _fontSize,
                          includeTafsir: _includeTafsir,
                          includeSurahHeader: _includeSurahHeader,
                          includeDedication: _includeDedication,
                          tafsirText: _tafsirText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 1. Theme Selector
                    const Text(
                      'سمة ولون البطاقة:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AyahCardTheme.availableThemes.map((t) {
                          final isSelected = t.id == _selectedTheme.id;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              selected: isSelected,
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: t.borderColor, width: 1.5),
                                      gradient: t.gradient,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(t.nameAr),
                                ],
                              ),
                              selectedColor: AppColors.primaryGreen.withOpacity(0.15),
                              side: BorderSide(
                                color: isSelected ? AppColors.primaryGreen : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              onSelected: (_) {
                                setState(() => _selectedTheme = t);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Font Size Selector
                    const Text(
                      'حجم خط الآية الكريمة:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSizeOption(label: 'صغير', size: 18.0),
                        const SizedBox(width: 8),
                        _buildSizeOption(label: 'متوسط', size: 22.0),
                        const SizedBox(width: 8),
                        _buildSizeOption(label: 'كبير', size: 26.0),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Content Switches
                    Material(
                      color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              dense: true,
                              title: const Text('تضمين التفسير الميسر للآية', style: TextStyle(fontSize: 13.5)),
                              subtitle: const Text('إظهار بيان موجز لمعنى الآية الكريمة أسفل النص', style: TextStyle(fontSize: 11.5)),
                              value: _includeTafsir,
                              activeColor: AppColors.primaryGreen,
                              onChanged: (val) => setState(() => _includeTafsir = val),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              dense: true,
                              title: const Text('ترويسة اسم السورة ورقم الآية', style: TextStyle(fontSize: 13.5)),
                              value: _includeSurahHeader,
                              activeColor: AppColors.primaryGreen,
                              onChanged: (val) => setState(() => _includeSurahHeader = val),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              dense: true,
                              title: const Text('إهداء الأجر ودعاء للمرحوم مؤمن إبراهيم', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                              subtitle: const Text('إهداء الأجر ودعاء للمرحوم في أسفل البطاقة', style: TextStyle(fontSize: 11.5)),
                              value: _includeDedication,
                              activeColor: AppColors.primaryGreen,
                              onChanged: (val) => setState(() => _includeDedication = val),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _handleShare,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.share_rounded, size: 20),
                      label: Text(
                        _isSharing ? 'جارٍ إعداد البطاقة...' : 'مشاركة البطاقة كصورة',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: _copyAyahText,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('نسخ', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeOption({required String label, required double size}) {
    final isSelected = _fontSize == size;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _fontSize = size),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : Colors.grey.withOpacity(0.3),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryGreen : AppColors.mutedText,
            ),
          ),
        ),
      ),
    );
  }
}
