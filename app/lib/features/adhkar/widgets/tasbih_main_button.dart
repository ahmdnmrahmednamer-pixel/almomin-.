import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Tactile, responsive interactive Tasbih Button with animated ripple and circular progress.
class TasbihMainButton extends StatelessWidget {
  final VoidCallback onTap;
  final Animation<double> scaleAnimation;
  final int count;
  final int target;
  final int currentInCycle;
  final double progress;
  final bool isDark;
  final double buttonSize;
  final double ringSize;

  const TasbihMainButton({
    super.key,
    required this.onTap,
    required this.scaleAnimation,
    required this.count,
    required this.target,
    required this.currentInCycle,
    required this.progress,
    required this.isDark,
    required this.buttonSize,
    required this.ringSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('tasbih_main_button'),
      onTap: onTap,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isDark
                  ? [const Color(0xFF233D2D), AppColors.darkSurface]
                  : [AppColors.primaryGreen, const Color(0xFF132A20)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withOpacity(isDark ? 0.4 : 0.35),
                blurRadius: 28,
                spreadRadius: 4,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.accentGold.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: AppColors.accentGold,
              width: 3.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular Progress Indicator around the button
              if (target > 0)
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CircularProgressIndicator(
                    value: (progress == 0.0 && count > 0 ? 1.0 : progress).clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                  ),
                ),

              // Inside contents
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (target > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'الدورة: ${currentInCycle == 0 && count > 0 ? target : currentInCycle} / $target',
                          style: const TextStyle(
                            color: AppColors.softGold,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'تسبيح مفتوح',
                        style: TextStyle(color: AppColors.softGold, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 8),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white70, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'المس للتسبيح',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
