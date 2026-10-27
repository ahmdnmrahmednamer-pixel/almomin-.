import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/ayah_notes_service.dart';
import '../../../core/audio/ayah_audio_player.dart';
import 'tafsir_viewer_sheet.dart';
import 'ayah_note_edit_dialog.dart';
import 'ayah_linguistics_sheet.dart';
import 'ayah_card_share_sheet.dart';
import '../memorization_screen.dart';
import '../../settings/widgets/settings_reciter_modal.dart';

class AyahActionSheet extends StatelessWidget {
  final Surah surah;
  final Ayah ayah;

  const AyahActionSheet({
    super.key,
    required this.surah,
    required this.ayah,
  });

  static void show(BuildContext context, {required Surah surah, required Ayah ayah}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahActionSheet(surah: surah, ayah: ayah),
    );
  }

  void _copyAyah(BuildContext context) {
    final textToCopy = '﴿${ayah.textUthmani}﴾ [سورة ${surah.nameAr}: ${ayah.ayahNumber}]';
    Clipboard.setData(ClipboardData(text: textToCopy)).catchError((_) {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الآية الكريمة بنجاح')),
    );
  }

  void _shareAyah(BuildContext context) {
    Navigator.pop(context);
    final textToShare = '﴿${ayah.textUthmani}﴾\n[سورة ${surah.nameAr} - الآية ${ayah.ayahNumber}]\n\n— تطبيق نور المؤمن (بدون إنترنت وبدون إعلانات)';
    try {
      Share.share(textToShare);
    } catch (_) {}
  }

  void _showTafseer(BuildContext context) {
    Navigator.pop(context);
    TafsirViewerSheet.show(context, surah: surah, ayah: ayah);
  }

  void _showLinguistics(BuildContext context, {int initialTab = 0}) {
    Navigator.pop(context);
    AyahLinguisticsSheet.show(
      context,
      surah: surah,
      ayah: ayah,
      initialTabIndex: initialTab,
    );
  }

  void _showCardShare(BuildContext context) {
    Navigator.pop(context);
    AyahCardShareSheet.show(context, surah: surah, ayah: ayah);
  }

  void _showReciterSelector(BuildContext context) {
    Navigator.pop(context);
    showSettingsReciterModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBookmarked = SettingsService.instance.isBookmarked(surah.id, ayah.ayahNumber);
    final hasNote = AyahNotesService.instance.hasNote(surah.id, ayah.ayahNumber);

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سورة ${surah.nameAr} — آية ${ayah.ayahNumber}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                Text(
                  'صفحة ${ayah.page} · جزء ${ayah.juz}',
                  style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ayah.textUthmani,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.8, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 8,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.play_circle_outline,
                  label: 'استماع للآية',
                  onTap: () {
                    Navigator.pop(context);
                    AyahAudioPlayer.instance.playAyah(context, surah.id, ayah.ayahNumber, surahName: surah.nameAr);
                  },
                ),
                _buildActionButton(
                  icon: Icons.person_search_outlined,
                  label: 'تغيير القارئ',
                  onTap: () => _showReciterSelector(context),
                ),
                _buildActionButton(
                  icon: Icons.auto_stories_rounded,
                  label: 'معاني الكلمات',
                  color: AppColors.primaryGreen,
                  onTap: () => _showLinguistics(context, initialTab: 0),
                ),
                _buildActionButton(
                  icon: Icons.history_edu_rounded,
                  label: 'أسباب النزول',
                  color: AppColors.primaryGreen,
                  onTap: () => _showLinguistics(context, initialTab: 1),
                ),
                _buildActionButton(
                  icon: Icons.spellcheck_rounded,
                  label: 'إعراب الآية',
                  color: AppColors.primaryGreen,
                  onTap: () => _showLinguistics(context, initialTab: 2),
                ),
                _buildActionButton(
                  icon: Icons.menu_book_rounded,
                  label: 'التفسير والشروح',
                  onTap: () => _showTafseer(context),
                ),
                _buildActionButton(
                  icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  label: isBookmarked ? 'محفوظة' : 'إشارة مرجعية',
                  color: isBookmarked ? AppColors.accentGold : AppColors.primaryGreen,
                  onTap: () async {
                    Navigator.pop(context);
                    final added = await SettingsService.instance.toggleBookmark(surah.id, ayah.ayahNumber);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(added ? 'تمت إضافة الآية للمفضلة والمرجعيات' : 'تم حذف الآية من المرجعيات')),
                      );
                    }
                  },
                ),
                _buildActionButton(
                  icon: hasNote ? Icons.rate_review : Icons.rate_review_outlined,
                  label: hasNote ? 'تعديل الخاطرة' : 'تدبر وخاطرة',
                  color: hasNote ? AppColors.accentGold : AppColors.primaryGreen,
                  onTap: () {
                    Navigator.pop(context);
                    AyahNoteEditDialog.show(context, surah: surah, ayah: ayah);
                  },
                ),
                _buildActionButton(
                  icon: Icons.repeat_one_rounded,
                  label: 'تحفيظ وتكرار',
                  color: AppColors.secondaryGreen,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemorizationScreen(
                          initialSurahId: surah.id,
                          initialFromAyah: ayah.ayahNumber,
                          initialToAyah: (ayah.ayahNumber + 2).clamp(1, surah.ayahCount),
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.brush_rounded,
                  label: 'بطاقة دعوية (صورة)',
                  color: AppColors.accentGold,
                  onTap: () => _showCardShare(context),
                ),
                _buildActionButton(
                  icon: Icons.copy,
                  label: 'نسخ الآية',
                  onTap: () => _copyAyah(context),
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'مشاركة',
                  onTap: () => _shareAyah(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.primaryGreen,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 86,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.25), width: 1.2),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color, height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
