import '../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/support_service.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _senderNameController = TextEditingController();
  final _senderContactController = TextEditingController();

  SupportCategory _selectedCategory = SupportCategory.suggestion;
  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _senderNameController.dispose();
    _senderContactController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final success = await SupportService.sendSupportEmail(
      subject: _subjectController.text,
      content: _messageController.text,
      category: _selectedCategory,
      senderName: _senderNameController.text,
      senderContact: _senderContactController.text,
    );

    setState(() => _isSending = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('جاري فتح تطبيق البريد الإلكتروني لإرسال رسالتك... جزاكم الله خيراً 🤲'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      _showFallbackDialog();
    }
  }

  void _copyEmailAddress() {
    SupportService.copyToClipboard(SupportService.developerEmail);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ البريد الإلكتروني للمطور إلى الحافظة: ${SupportService.developerEmail}'),
        backgroundColor: AppColors.primaryGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _copyFullMessage() {
    if (!_formKey.currentState!.validate()) return;

    final fullText = SupportService.buildEmailBody(
      content: _messageController.text,
      category: _selectedCategory,
      senderName: _senderNameController.text,
      senderContact: _senderContactController.text,
    );

    SupportService.copyToClipboard(
      'إلى: ${SupportService.developerEmail}\n'
      'الموضوع: ${SupportService.buildEmailSubject(subject: _subjectController.text, category: _selectedCategory)}\n\n'
      '$fullText',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرسالة بالكامل وعنوان البريد إلى الحافظة بنجاح'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _showFallbackDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: SettingsService.instance.textDirection,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.accentGold, size: 26),
              SizedBox(width: 8),
              Expanded(
                child: Text('فتح تطبيق البريد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تعذر فتح تطبيق البريد الإلكتروني تلقائياً على جهازك. يمكنك نسخ عنوان البريد ومحتوى الرسالة لإرسالها يدوياً عبر أي برنامج بريد تفضله:',
                style: TextStyle(height: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                ),
                child: SelectableText(
                  SupportService.developerEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _copyFullMessage();
              },
              child: const Text('نسخ الرسالة بالكامل', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _copyEmailAddress();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('نسخ البريد فقط'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الدعم والتواصل مع المطور'),
          actions: [
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              tooltip: 'نسخ بريد المطور',
              onPressed: _copyEmailAddress,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dedication & Welcome Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentGold.withOpacity(0.18),
                        AppColors.primaryGreen.withOpacity(0.08),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.volunteer_activism_rounded, color: AppColors.primaryGreen, size: 24),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تطبيق نور المؤمن — في خدمتكم دوماً لوجه الله تعالى',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تطبيق نور المؤمن مجاني تماماً وبدون أي إعلانات. يسعدنا ويشرفنا استقبال مقترحاتكم، ملاحظاتكم، أو الإبلاغ عن أي خطأ لتحسين التطبيق وخدمة المسلمين.',
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const Divider(height: 18),
                      InkWell(
                        onTap: _copyEmailAddress,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.email_outlined, color: AppColors.primaryGreen, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    SupportService.developerEmail,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'نسخ',
                                    style: TextStyle(
                                      color: AppColors.accentGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.copy_rounded, size: 14, color: AppColors.accentGold),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Category Selection
                const Text(
                  'نوع الرسالة:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SupportCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.titleAr),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12.5,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Subject Field
                const Text(
                  'عنوان الرسالة أو الموضوع:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectController,
                  textDirection: SettingsService.instance.textDirection,
                  decoration: InputDecoration(
                    hintText: 'مثال: اقتراح إضافة تنبيه قبل الصلاة بـ 10 دقائق',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى كتابة عنوان الرسالة أو الموضوع';
                    }
                    if (val.trim().length < 3) {
                      return 'عنوان الرسالة يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Message Body Field
                const Text(
                  'تفاصيل الرسالة أو الملاحظة:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  textDirection: SettingsService.instance.textDirection,
                  minLines: 5,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك، اقتراحك، أو وصف المشكلة هنا بالتفصيل...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى كتابة تفاصيل الرسالة';
                    }
                    if (val.trim().length < 5) {
                      return 'تفاصيل الرسالة قصيرة جداً (5 أحرف على الأقل)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Optional Sender Name / Contact
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اسمك (اختياري):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondaryGreen),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _senderNameController,
                            textDirection: SettingsService.instance.textDirection,
                            decoration: InputDecoration(
                              hintText: 'مثال: فاعل خير',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.secondaryGreen),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'وسيلة رد (اختياري):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondaryGreen),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _senderContactController,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'بريدك أو رقم هاتفك',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              prefixIcon: const Icon(Icons.contact_mail_outlined, size: 20, color: AppColors.secondaryGreen),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Send Button
                ElevatedButton.icon(
                  onPressed: _isSending ? null : _handleSend,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    _isSending ? 'جاري تجهيز الرسالة...' : 'إرسال الرسالة إلى المطور',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),

                const SizedBox(height: 10),

                // Copy Message Option
                OutlinedButton.icon(
                  onPressed: _copyFullMessage,
                  icon: const Icon(Icons.copy_all_rounded, color: AppColors.primaryGreen),
                  label: const Text(
                    'نسخ الرسالة بالكامل للحافظة',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
