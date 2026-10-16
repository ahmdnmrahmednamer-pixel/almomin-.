import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/surah.dart';
import '../../../core/models/ayah.dart';
import '../../../core/services/ayah_notes_service.dart';

/// Modal dialog for composing and editing Quranic reflections on an Ayah (FR-BKM-004)
class AyahNoteEditDialog extends StatefulWidget {
  final Surah surah;
  final Ayah ayah;

  const AyahNoteEditDialog({
    super.key,
    required this.surah,
    required this.ayah,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Surah surah,
    required Ayah ayah,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AyahNoteEditDialog(surah: surah, ayah: ayah),
    );
  }

  @override
  State<AyahNoteEditDialog> createState() => _AyahNoteEditDialogState();
}

class _AyahNoteEditDialogState extends State<AyahNoteEditDialog> {
  late final TextEditingController _controller;
  bool _isSaving = false;
  bool _hasExistingNote = false;

  @override
  void initState() {
    super.initState();
    final existing = AyahNotesService.instance.getNote(widget.surah.id, widget.ayah.ayahNumber);
    _hasExistingNote = existing != null;
    _controller = TextEditingController(text: existing?.noteText ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (_hasExistingNote) {
        await _delete();
      } else {
        Navigator.pop(context, false);
      }
      return;
    }

    setState(() => _isSaving = true);
    await AyahNotesService.instance.saveNote(
      surahId: widget.surah.id,
      surahName: widget.surah.nameAr,
      ayahNumber: widget.ayah.ayahNumber,
      ayahText: widget.ayah.textUthmani,
      noteText: text,
      pageNumber: widget.ayah.page,
    );
    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ خاطرتك وتدبرك لسورة ${widget.surah.nameAr} بنجاح ✓',
            textAlign: TextAlign.right,
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الخاطرة'),
          content: const Text('هل ترغب في حذف خاطرتك على هذه الآية الكريمة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await AyahNotesService.instance.deleteNote(widget.surah.id, widget.ayah.ayahNumber);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الخاطرة بنجاح', textAlign: TextAlign.right),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: bottomInset > 0 ? bottomInset + 16 : 24,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_note_rounded, color: AppColors.primaryGreen, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _hasExistingNote ? 'تعديل الخاطرة والتدبر' : 'تدوين خاطرة وتدبر',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                  Text(
                    'سورة ${widget.surah.nameAr} : ${widget.ayah.ayahNumber}',
                    style: const TextStyle(fontSize: 13, color: AppColors.mutedText, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ayah Quote Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2522) : AppColors.primaryGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                ),
                child: Text(
                  '﴿${widget.ayah.textUthmani}﴾',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, height: 1.8, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 14),

              // Reflection Text Field
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 5,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: 'اكتب خاطرتك، تدبرك، أو ما استوقف قلبك من هذه الآية الكريمة...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedText),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF242A27) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  if (_hasExistingNote) ...[
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'حذف الخاطرة',
                      onPressed: _delete,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check, size: 20),
                      label: Text(
                        _hasExistingNote ? 'تحديث التدبر' : 'حفظ التدبر',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
