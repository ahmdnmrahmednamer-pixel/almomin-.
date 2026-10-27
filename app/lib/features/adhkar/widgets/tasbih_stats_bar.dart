import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom stats bar displaying completed cycles, today's total tasbih, and reset session button.
class TasbihStatsBar extends StatelessWidget {
  final int cyclesCompleted;
  final int totalToday;
  final bool isDark;
  final VoidCallback onReset;

  const TasbihStatsBar({
    super.key,
    required this.cyclesCompleted,
    required this.totalToday,
    required this.isDark,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatColumn(
              title: 'الدورات المكتملة',
              value: '$cyclesCompleted',
              icon: Icons.done_all,
              isDark: isDark,
            ),
          ),
          Container(height: 32, width: 1, color: isDark ? Colors.white12 : Colors.black12),
          Expanded(
            child: _buildStatColumn(
              title: 'مجموع اليوم',
              value: '$totalToday',
              icon: Icons.calendar_today,
              isDark: isDark,
            ),
          ),
          Container(height: 32, width: 1, color: isDark ? Colors.white12 : Colors.black12),
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.orange),
            tooltip: 'تصفير العداد',
            onPressed: onReset,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: AppColors.accentGold),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : AppColors.mutedText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.primaryGreen,
          ),
        ),
      ],
    );
  }
}
