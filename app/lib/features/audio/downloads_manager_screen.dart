import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/audio_download_service.dart';
import '../../core/services/settings_service.dart';

class DownloadsManagerScreen extends StatefulWidget {
  const DownloadsManagerScreen({super.key});

  @override
  State<DownloadsManagerScreen> createState() => _DownloadsManagerScreenState();
}

class _DownloadsManagerScreenState extends State<DownloadsManagerScreen> {
  String? _selectedReciterFilter;

  @override
  void initState() {
    super.initState();
    AudioDownloadService.instance.init();
  }

  Future<void> _confirmDeleteSurah(DownloadedSurahInfo info) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد حذف التنزيل'),
          content: Text(
            'هل ترغب في حذف ملف تلاوة ${info.surahName} بصوت ${info.reciterName} من ذاكرة الهاتف لتوفير ${info.formattedSize}؟',
          ),
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
      final ok = await AudioDownloadService.instance.deleteDownloadedSurah(
        info.reciterId,
        info.surahId,
      );
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف ${info.surahName} وتحرير المساحة بنجاح', textAlign: TextAlign.right),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف جميع التلاوات المحملة'),
          content: const Text(
            'هل أنت متأكد من حذف كافة السور والتلاوات المحملة وتحرير كامل المساحة المستهلكة على الهاتف؟\n(يمكنك إعادة تحميلها في أي وقت).',
          ),
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
              child: const Text('نعم، حذف الكل'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await AudioDownloadService.instance.deleteAllDownloads();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف جميع التنزيلات بنجاح', textAlign: TextAlign.right),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة التنزيلات والمساحة'),
          centerTitle: true,
        ),
        body: AnimatedBuilder(
          animation: AudioDownloadService.instance,
          builder: (context, _) {
            final downloadedList =
                AudioDownloadService.instance.getDownloadedSurahsList(_selectedReciterFilter);
            final totalBytes = AudioDownloadService.instance.totalStorageUsedBytes;
            final formattedTotal = AudioDownloadService.instance.formattedTotalStorage;
            final allDownloads = AudioDownloadService.instance.getDownloadedSurahsList();

            // Extract unique reciters who have downloads
            final availableReciterIds = allDownloads.map((e) => e.reciterId).toSet().toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Noble Dedication Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.volunteer_activism_rounded, color: Color(0xFFD4AF37), size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'صدقة جارية عن روح المرحوم بإذن الله: مؤمن إبراهيم رحمه الله',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Storage Overview Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                                  child: const Icon(Icons.sd_storage_rounded,
                                      color: AppColors.primaryGreen, size: 22),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'المساحة المستهلكة على الهاتف',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              formattedTotal,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'إجمالي الملفات: ${allDownloads.length} سورة محملة',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                            if (allDownloads.isNotEmpty)
                              TextButton.icon(
                                icon: const Icon(Icons.delete_sweep_rounded,
                                    size: 18, color: Colors.redAccent),
                                label: const Text('حذف الكل',
                                    style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                onPressed: _confirmDeleteAll,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Reciters Filter Chips
                if (availableReciterIds.length > 1) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('جميع القراء'),
                          selected: _selectedReciterFilter == null,
                          onSelected: (_) => setState(() => _selectedReciterFilter = null),
                        ),
                        const SizedBox(width: 8),
                        ...availableReciterIds.map((rid) {
                          final reciter = SettingsService.availableReciters.firstWhere(
                            (r) => r.id == rid,
                            orElse: () => SettingsService.availableReciters.first,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(reciter.nameAr),
                              selected: _selectedReciterFilter == rid,
                              onSelected: (_) => setState(() => _selectedReciterFilter = rid),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Downloaded Surahs List or Empty State
                if (downloadedList.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_download_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 14),
                        const Text(
                          'لا توجد سور محملة حالياً',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يمكنك تحميل أي سورة للاستماع إليها بدون إنترنت بالضغط على زر التحميل في شاشة التلاوات 🎧',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'السور المحملة (${downloadedList.length})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'جاهزة للاستماع أوفلاين ✓',
                        style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...downloadedList.map((info) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.offline_pin_rounded,
                              color: Colors.green, size: 22),
                        ),
                        title: Text(
                          info.surahName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'بصوت ${info.reciterName} · ${info.formattedSize}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Colors.redAccent, size: 22),
                          tooltip: 'حذف من الهاتف',
                          onPressed: () => _confirmDeleteSurah(info),
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
