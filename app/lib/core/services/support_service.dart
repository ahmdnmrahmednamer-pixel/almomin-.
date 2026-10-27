import 'dart:io';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum SupportCategory {
  suggestion('اقتراح تطوير ميزة'),
  bugReport('إبلاغ عن مشكلة أو خطأ'),
  inquiry('استفسار عام أو ملاحظة'),
  appreciation('شكر ودعاء لمؤمن إبراهيم');

  final String titleAr;
  const SupportCategory(this.titleAr);
}

class SupportService {
  static const String developerEmail = 'ahmdnmrahmednamer@gmail.com';
  static const String appVersion = '1.2.0';
  static const String appBuild = '12';

  /// URL launcher delegate for testability
  static Future<bool> Function(Uri uri, {LaunchMode mode}) urlLauncher =
      (Uri uri, {LaunchMode mode = LaunchMode.externalApplication}) =>
          launchUrl(uri, mode: mode);

  /// Builds a formatted email subject
  static String buildEmailSubject({
    required String subject,
    required SupportCategory category,
  }) {
    final cleanSubject = subject.trim();
    return '[تطبيق نور المؤمن - ${category.titleAr}] $cleanSubject';
  }

  /// Builds a rich, structured email body including dedication and diagnostics
  static String buildEmailBody({
    required String content,
    required SupportCategory category,
    String? senderName,
    String? senderContact,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('السلام عليكم ورحمة الله وبركاته،');
    buffer.writeln();
    buffer.writeln(content.trim());
    buffer.writeln();
    buffer.writeln('--------------------------------------------------');
    buffer.writeln('📋 بيانات الرسالة والدعم الفني:');
    buffer.writeln('• التصنيف: ${category.titleAr}');
    if (senderName != null && senderName.trim().isNotEmpty) {
      buffer.writeln('• اسم الراسل: ${senderName.trim()}');
    }
    if (senderContact != null && senderContact.trim().isNotEmpty) {
      buffer.writeln('• وسيلة التواصل: ${senderContact.trim()}');
    }
    buffer.writeln('• إصدار تطبيق نور المؤمن: v$appVersion (Build $appBuild)');
    try {
      buffer.writeln('• نظام التشغيل: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
    } catch (_) {
      buffer.writeln('• نظام التشغيل: Android / Mobile Platform');
    }
    buffer.writeln('• تاريخ الإرسال: ${DateTime.now().toString().split('.').first}');
    buffer.writeln('--------------------------------------------------');
    buffer.writeln('تطبيق «نور المؤمن» — رفيقك اليومي للقرآن والعبادات');

    return buffer.toString();
  }

  /// Encodes query parameters safely for mailto RFC
  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Constructs the mailto Uri
  static Uri createMailtoUri({
    required String subject,
    required String body,
    String recipient = developerEmail,
  }) {
    return Uri(
      scheme: 'mailto',
      path: recipient,
      query: encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );
  }

  /// Launches the user's default email client
  static Future<bool> sendSupportEmail({
    required String subject,
    required String content,
    required SupportCategory category,
    String? senderName,
    String? senderContact,
  }) async {
    final formattedSubject = buildEmailSubject(
      subject: subject,
      category: category,
    );

    final formattedBody = buildEmailBody(
      content: content,
      category: category,
      senderName: senderName,
      senderContact: senderContact,
    );

    final uri = createMailtoUri(
      subject: formattedSubject,
      body: formattedBody,
      recipient: developerEmail,
    );

    try {
      return await urlLauncher(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Copies support email or full text to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text)).catchError((_) {});
  }
}
