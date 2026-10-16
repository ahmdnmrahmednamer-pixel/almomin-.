import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/backup_restore_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/khatma_service.dart';
import '../../core/services/adhkar_service.dart';
import '../../core/services/prayer_service.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  final TextEditingController _importController = TextEditingController();
  bool _replaceMode = true;
  bool _isProcessing = false;
  BackupValidationResult? _validationResult;

  int _bookmarksCount = 0;
  int _khatmaPage = 1;
  bool _hasKhatma = false;
  int _tasbihTotal = 0;
  String _currentCity = 'القاهرة، مصر';

  @override
  void initState() {
    super.initState();
    _loadCurrentStats();
    _importController.addListener(_onImportTextChanged);
  }

  @override
  void dispose() {
    _importController.removeListener(_onImportTextChanged);
    _importController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bookmarksCount = SettingsService.instance.bookmarks.length;
      _hasKhatma = KhatmaService.instance.hasActivePlan;
      _khatmaPage = KhatmaService.instance.activePlan?.currentPage ?? 1;
      _tasbihTotal = AdhkarService.instance.tasbihTotalToday;
      _currentCity = prefs.getString('last_city') ?? 'القاهرة، مصر';
    });
  }

  void _onImportTextChanged() {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      if (_validationResult != null) {
        setState(() => _validationResult = null);
      }
      return;
    }
    final res = BackupRestoreService.instance.validateBackup(text);
    setState(() => _validationResult = res);
  }

  Future<void> _exportAndShare() async {
    setState(() => _isProcessing = true);
    try {
      final success = await BackupRestoreService.instance.shareBackupFile();
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تجهيز النسخة الاحتياطية بنجاح 📤', textAlign: TextAlign.right),
            backgroundColor: Color(0xFF1B4D3E),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تصدير الملف، يمكنك نسخ النص يدوياً', textAlign: TextAlign.right),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _copyJsonToClipboard() async {
    setState(() => _isProcessing = true);
    try {
      final json = await BackupRestoreService.instance.exportBackupJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ بيانات النسخة الاحتياطية إلى الحافظة بنجاح 📋', textAlign: TextAlign.right),
          backgroundColor: Color(0xFF1B4D3E),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      _importController.text = data.text!;
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الحافظة لا تحتوي على نص', textAlign: TextAlign.right),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _confirmAndRestore() async {
    if (_validationResult == null || !_validationResult!.isValid) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _replaceMode ? 'تأكيد الاستبدال الكامل' : 'تأكيد الدمج الذكي',
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _replaceMode
              ? 'هل أنت متأكد من استبدال جميع بيانات التطبيق الحالية (العلامات، الختمة، الإعدادات) ببيانات النسخة الاحتياطية؟'
              : 'سيتم دمج العلامات المرجعية والتقدم بدون حذف بياناتك الحالية. هل ترغب في المتابعة؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _replaceMode ? Colors.redAccent : const Color(0xFF1B4D3E),
              foregroundColor: Colors.white,
            ),
            child: Text(_replaceMode ? 'نعم، استبدل' : 'نعم، ادمج'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final success = await BackupRestoreService.instance.restoreBackup(
        _validationResult!.rawData!,
        replaceMode: _replaceMode,
      );

      if (!mounted) return;
      if (success) {
        await _loadCurrentStats();
        _importController.clear();
        setState(() => _validationResult = null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت استعادة البيانات بنجاح تام ولله الحمد 🕌', textAlign: TextAlign.right),
            backgroundColor: Color(0xFF1B4D3E),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ أثناء استعادة البيانات', textAlign: TextAlign.right),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
          title: const Text('النسخ الاحتياطي والاستعادة'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث الإحصائيات',
              onPressed: _loadCurrentStats,
            ),
          ],
        ),
        body: ListView(
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
                  Icon(Icons.volunteer_activism_rounded, color: Color(0xFFD4AF37), size: 24),
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

            // Section 1: Current Stats Overview
            Text(
              'حالة البيانات الحالية على هذا الجهاز',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.bookmark_added_rounded,
                    title: 'العلامات المرجعية',
                    value: '$_bookmarksCount علامة',
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.menu_book_rounded,
                    title: 'الختمة الحالية',
                    value: _hasKhatma ? 'ص $_khatmaPage / 604' : 'لا توجد ختمة',
                    color: const Color(0xFF1B4D3E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'تسبيح اليوم',
                    value: '$_tasbihTotal تسبيحة',
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatTile(
                    icon: Icons.location_on_rounded,
                    title: 'المدينة المحددة',
                    value: _currentCity,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 2: Export Backup
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B4D3E).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF1B4D3E)),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'تصدير نسخة احتياطية (FR-BKM-003)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'احفظ بياناتك وانقلها إلى أي هاتف آخر أو احتفظ بها في Google Drive أو واتساب.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share_rounded),
                        label: const Text(
                          'مشاركة / حفظ ملف النسخة (.json)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B4D3E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isProcessing ? null : _exportAndShare,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('نسخ كود النسخة الاحتياطية إلى الحافظة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1B4D3E),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isProcessing ? null : _copyJsonToClipboard,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Import & Restore
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.cloud_download_rounded, color: Colors.amber.shade800),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'استعادة نسخة سابقة',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'الصق كود النسخة الاحتياطية المستخرجة سابقاً لاسترجاع بياناتك:',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),

                    // Mode Selection
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('استبدال كامل', style: TextStyle(fontSize: 13)),
                            value: true,
                            groupValue: _replaceMode,
                            activeColor: const Color(0xFF1B4D3E),
                            onChanged: (v) => setState(() => _replaceMode = v ?? true),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('دمج ذكي', style: TextStyle(fontSize: 13)),
                            value: false,
                            groupValue: _replaceMode,
                            activeColor: const Color(0xFF1B4D3E),
                            onChanged: (v) => setState(() => _replaceMode = v ?? false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // JSON Input Field
                    TextField(
                      controller: _importController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: 'الصق محتوى ملف النسخة الاحتياطية (JSON) هنا...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste_rounded),
                          tooltip: 'لصق من الحافظة',
                          onPressed: _pasteFromClipboard,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Validation result preview
                    if (_validationResult != null) ...[
                      _buildValidationPreviewCard(_validationResult!),
                      const SizedBox(height: 12),
                    ],

                    // Confirm Restore Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download_done_rounded),
                        label: Text(
                          _replaceMode ? 'استبدال واستعادة البيانات 📥' : 'دمج واستعادة البيانات 📥',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _validationResult?.isValid == true
                              ? (_replaceMode ? Colors.orange.shade800 : const Color(0xFF1B4D3E))
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: (_validationResult?.isValid == true && !_isProcessing)
                            ? _confirmAndRestore
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationPreviewCard(BackupValidationResult res) {
    if (!res.isValid) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                res.errorMessage ?? 'ملف غير صالح',
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'النسخة صالحة ومطابقة لسلامة البيانات ✓',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('• تاريخ إنشاء النسخة: ${res.createdAt?.split('T').first ?? 'غير محدد'}',
              style: const TextStyle(fontSize: 12)),
          Text('• عدد العلامات المرجعية: ${res.bookmarksCount}',
              style: const TextStyle(fontSize: 12)),
          Text('• الختمة: ${res.hasKhatma ? "صفحة ${res.khatmaPage}" : "لا توجد"}',
              style: const TextStyle(fontSize: 12)),
          if (res.city != null)
            Text('• المدينة المحددة: ${res.city}', style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
