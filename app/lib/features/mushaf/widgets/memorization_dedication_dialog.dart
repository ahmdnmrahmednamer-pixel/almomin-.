import '../../../core/services/settings_service.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Dedication dialog for Momen Ibrahim (رحمه الله).
void showMemorizationDedicationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.volunteer_activism, color: AppColors.accentGold),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'إهداء ودعاء مبارك',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إهداء هذا العمل القرآني ودعاء خالص لروح المرحوم بإذن الله تعالى: مؤمن إبراهيم رحمه الله تعالى رحمة واسعة.',
              style: TextStyle(height: 1.6, fontSize: 14),
            ),
            SizedBox(height: 12),
            Text(
              '«اللهم اجعل كل آية تُتلى، وكل حرف يُحفظ في ميزان حسنات مؤمن إبراهيم، ونوراً وضياءً له في قبره، وشفيعاً له يوم القيامة، واجمعنا به في الفردوس الأعلى من الجنة بلا حساب ولا سابق عذاب.»',
              style: TextStyle(fontWeight: FontWeight.bold, height: 1.7, color: AppColors.primaryGreen, fontSize: 13.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('آمين يا رب العالمين', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}
