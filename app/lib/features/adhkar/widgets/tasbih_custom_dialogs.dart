import '../../../core/text/arabic_normalizer.dart';
import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/services/adhkar_service.dart';
import '../../../core/theme/app_theme.dart';

/// Dialog to add or edit custom dhikr phrase.
void showTasbihCustomPhraseDialog(BuildContext context, {required TextEditingController controller}) {
  controller.text = AdhkarService.instance.selectedTasbihPhrase;
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: AlertDialog(
      title: const Text('إضافة ذكر أو ورد مخصص'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'اكتب الذكر هنا...',
          border: OutlineInputBorder(),
        ),
        textAlign: TextAlign.right,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              AdhkarService.instance.setSelectedTasbihPhrase(text);
            }
            Navigator.pop(ctx);
          },
          child: const Text('تأكيد'),
        ),
      ],
      ),
    ),
  );
}

/// Dialog to set custom tasbih target counter.
void showTasbihCustomTargetDialog(BuildContext context, {required TextEditingController controller}) {
  controller.text = AdhkarService.instance.tasbihTarget > 0
      ? '${AdhkarService.instance.tasbihTarget}'
      : '33';
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: AlertDialog(
      title: const Text('تحديد عدد التسبيحات المستهدف'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'مثال: 33، 100، 1000',
          border: OutlineInputBorder(),
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
          onPressed: () {
            final val = ArabicNormalizer.tryParseInt(controller.text);
            if (val != null && val > 0) {
              AdhkarService.instance.setTasbihTarget(val);
            }
            Navigator.pop(ctx);
          },
          child: const Text('حفظ'),
        ),
      ],
      ),
    ),
  );
}

/// Dialog to confirm resetting current tasbih session counter.
void confirmTasbihResetSession(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: AlertDialog(
      title: const Text('تصفير عداد الجلسة'),
      content: const Text('هل تريد تصفير عداد التسبيح الحالي؟'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
          onPressed: () {
            AdhkarService.instance.resetTasbih();
            Navigator.pop(ctx);
          },
          child: const Text('تصفير'),
        ),
      ],
      ),
    ),
  );
}
