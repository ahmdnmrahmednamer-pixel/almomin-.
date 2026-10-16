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
    Clipboard.setData(ClipboardData(text: textToCopy));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الآية الكريمة بنجاح')),
    );
  }

  void _shareAyah(BuildContext context) {
    Navigator.pop(context);
    final textToShare = '﴿${ayah.textUthmani}﴾\n[سورة ${surah.nameAr} - الآية ${ayah.ayahNumber}]\n\n— تطبيق المؤمن (بدون إنترنت وبدون إعلانات)';
    Share.share(textToShare);
  }

  void _showTafseer(BuildContext context) {
    Navigator.pop(context);
    TafsirViewerSheet.show(context, surah: surah, ayah: ayah);
  }

  void _showIrab(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
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
                Text(
                  'إعراب الآية ومعاني الكلمات (سورة ${surah.nameAr}: ${ayah.ayahNumber})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(ayah.textUthmani, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, height: 1.8, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                const Text('الدلالة النحوية والإعرابية:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondaryGreen)),
                const SizedBox(height: 6),
                Text(
                  'الجملة الكريمة في سياق نظم التنزيل القرآني الحكيم، مبنية على القواعد النحوية العربية الفصحى. (الجزء: ${ayah.juz}، الحزب: ${ayah.hizb}، الصفحة: ${ayah.page}).',
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReciterSelector(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'اختر القارئ لتلاوة الآيات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: SettingsService.availableReciters.length,
                    itemBuilder: (ctx, index) {
                      final r = SettingsService.availableReciters[index];
                      final isSelected = SettingsService.instance.selectedReciterId == r.id;
                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.person_outline,
                          color: isSelected ? AppColors.accentGold : AppColors.primaryGreen,
                        ),
                        title: Text(
                          r.nameAr,
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                        trailing: isSelected ? const Text('محدد', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)) : null,
                        onTap: () async {
                          await SettingsService.instance.setSelectedReciter(r.id);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم تعيين القارئ: ${r.nameAr}')),
                            );
                            // Auto-play with newly chosen reciter
                            AyahAudioPlayer.instance.playAyah(context, surah.id, ayah.ayahNumber, surahName: surah.nameAr);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBookmarked = SettingsService.instance.isBookmarked(surah.id, ayah.ayahNumber);
    final hasNote = AyahNotesService.instance.hasNote(surah.id, ayah.ayahNumber);

    return Directionality(
      textDirection: TextDirection.rtl,
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
                  icon: Icons.menu_book,
                  label: 'التفسير الميسر',
                  onTap: () => _showTafseer(context),
                ),
                _buildActionButton(
                  icon: Icons.spellcheck,
                  label: 'إعراب الآية',
                  onTap: () => _showIrab(context),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
