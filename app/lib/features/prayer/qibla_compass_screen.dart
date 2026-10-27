import '../../core/services/settings_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../core/services/prayer_service.dart';
import '../../core/theme/app_theme.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<MagnetometerEvent>? _magnetometerSub;
  double _deviceHeading = 0.0;
  double _smoothSin = 0.0;
  double _smoothCos = 1.0;
  bool _hasInitialSample = false;
  DateTime? _lastUiUpdateTime;
  bool _hasSensor = true;
  bool _wasAligned = false;
  late AnimationController _pulseController;
  DateTime? _lastIntenseVibeTime;

  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _initCompass();
  }

  void _triggerIntenseQiblaVibration() {
    final now = DateTime.now();
    if (_lastIntenseVibeTime != null &&
        now.difference(_lastIntenseVibeTime!).inMilliseconds < 1800) {
      return;
    }
    _lastIntenseVibeTime = now;

    // Distinct, powerful multi-pulse tactile vibration sequence (respecting hapticEnabled)
    if (SettingsService.instance.hapticEnabled) {
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 140), () {
        if (mounted) HapticFeedback.heavyImpact();
      });
      Future.delayed(const Duration(milliseconds: 280), () {
        if (mounted) HapticFeedback.vibrate();
      });
      Future.delayed(const Duration(milliseconds: 440), () {
        if (mounted) HapticFeedback.heavyImpact();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) HapticFeedback.vibrate();
      });
    }
  }

  void _initCompass() {
    try {
      _magnetometerSub?.cancel();
      _magnetometerSub = magnetometerEventStream().listen(
        (MagnetometerEvent event) {
          // Calculate raw heading in radians from magnetic field vector
          final rawRad = atan2(-event.x, event.y);

          // Circular low-pass filter on unit circle (sin/cos EMA) to prevent 0°/360° wrap-around spin & sensor jitter (Bug #11 fix)
          const double alpha = 0.18;
          if (!_hasInitialSample) {
            _smoothSin = sin(rawRad);
            _smoothCos = cos(rawRad);
            _hasInitialSample = true;
          } else {
            _smoothSin = (1 - alpha) * _smoothSin + alpha * sin(rawRad);
            _smoothCos = (1 - alpha) * _smoothCos + alpha * cos(rawRad);
          }

          double heading = atan2(_smoothSin, _smoothCos) * (180.0 / pi);
          if (heading < 0) {
            heading += 360.0;
          }

          if (mounted) {
            final qibla = PrayerService.instance.currentData?.qiblaDegrees ?? 136.0;
            final diff = (heading - qibla).abs() % 360.0;
            final isAligned = diff < 3.5 || diff > 356.5;

            if (isAligned && !_wasAligned) {
              _triggerIntenseQiblaVibration();
            }
            _wasAligned = isAligned;

            // Throttle UI rebuilds to ~25 FPS or >=0.4° angular change
            final now = DateTime.now();
            double deltaDeg = (heading - _deviceHeading).abs();
            if (deltaDeg > 180.0) deltaDeg = 360.0 - deltaDeg;
            if (_lastUiUpdateTime == null ||
                now.difference(_lastUiUpdateTime!).inMilliseconds >= 40 ||
                deltaDeg >= 0.4) {
              _lastUiUpdateTime = now;
              setState(() {
                _deviceHeading = heading;
                _hasSensor = true;
              });
            }
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() => _hasSensor = false);
          }
        },
        cancelOnError: false,
      );
    } catch (_) {
      setState(() => _hasSensor = false);
    }
  }

  @override
  void dispose() {
    _magnetometerSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateDistanceToKaaba(double lat, double lng) {
    const earthRadiusKm = 6371.0;
    final dLat = (kaabaLat - lat) * (pi / 180.0);
    final dLon = (kaabaLng - lng) * (pi / 180.0);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat * (pi / 180.0)) * cos(kaabaLat * (pi / 180.0)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerData = PrayerService.instance.currentData;
    final qiblaDegrees = prayerData?.qiblaDegrees ?? 136.0;
    final distanceKm = prayerData != null
        ? _calculateDistanceToKaaba(prayerData.latitude, prayerData.longitude)
        : 1288.0;

    // Angle of needle relative to device orientation
    final relativeAngle = (qiblaDegrees - _deviceHeading) * (pi / 180.0);
    final diffDegrees = (qiblaDegrees - _deviceHeading).abs() % 360;
    final isAligned = diffDegrees < 3.5 || diffDegrees > 356.5;

    return Directionality(
      textDirection: SettingsService.instance.textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بوصلة القبلة التفاعلية'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'إرشادات الدقة',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Directionality(
                    textDirection: SettingsService.instance.textDirection,
                    child: AlertDialog(
                    title: const Text('معايرة البوصلة'),
                    content: const Text(
                      'لضمان أعلى دقة لبوصلة القبلة:\n\n'
                      '١. أمسك الهاتف بشكل أفقي مستوٍ.\n'
                      '٢. ابتعد عن الأجهزة الكهربائية والمغناطيسية والأسطح المعدنية.\n'
                      '٣. حرك الهاتف ببطء في الهواء على شكل رقم 8 لمعايرة الحساس.',
                      style: TextStyle(height: 1.6),
                    ),
                    actions: [
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('حسناً'),
                      ),
                    ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Location and Bearing Summary Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAligned
                        ? [const Color(0xFF1B4332), const Color(0xFF2D6A4F)]
                        : (isDark
                            ? [AppColors.darkSurface, const Color(0xFF263238)]
                            : [AppColors.primaryGreen.withOpacity(0.08), AppColors.softGold.withOpacity(0.18)]),
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAligned ? AppColors.accentGold : AppColors.accentGold.withOpacity(0.4),
                    width: isAligned ? 2 : 1,
                  ),
                  boxShadow: isAligned
                      ? [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.4),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: isAligned ? AppColors.accentGold : AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              prayerData?.locationName ?? 'القاهرة، مصر',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isAligned ? Colors.white : (isDark ? Colors.white : AppColors.primaryGreen),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'المسافة إلى مكة: ${distanceKm.toStringAsFixed(0)} كم',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAligned ? AppColors.softGold : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'زاوية القبلة: ${qiblaDegrees.toStringAsFixed(1)}°',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isAligned ? AppColors.accentGold : AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الاتجاه: ${_getDirectionLabel(qiblaDegrees)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isAligned ? Colors.white70 : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Alignment Banner with Intense Vibration Indication
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: isAligned
                      ? const LinearGradient(
                          colors: [Color(0xFF0F513A), Color(0xFF1B4332)],
                        )
                      : null,
                  color: isAligned
                      ? null
                      : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isAligned ? AppColors.accentGold : Colors.transparent,
                    width: isAligned ? 2.0 : 1.0,
                  ),
                  boxShadow: isAligned
                      ? [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAligned ? Icons.vibration : Icons.explore_outlined,
                      color: isAligned ? AppColors.accentGold : AppColors.accentGold,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isAligned
                            ? 'أنت الآن باتجاه القبلة المشرفة بدقة 🕋 (اهتزاز تأكيدي نشط)'
                            : 'حرك الهاتف حتى يشير السهم الذهبي للأعلى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isAligned ? Colors.white : (isDark ? Colors.white70 : AppColors.lightText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Interactive Compass Rose Dial
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Compass Rose Rotating with Device Heading
                    Transform.rotate(
                      angle: -_deviceHeading * (pi / 180.0),
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          border: Border.all(
                            color: isAligned ? AppColors.accentGold : (isDark ? Colors.white24 : Colors.black12),
                            width: isAligned ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isAligned
                                  ? AppColors.accentGold.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Cardinal Directions: N, E, S, W
                            const Positioned(
                              top: 10,
                              child: Text('ش', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                            ),
                            const Positioned(
                              bottom: 10,
                              child: Text('ج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const Positioned(
                              right: 12,
                              child: Text('ق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const Positioned(
                              left: 12,
                              child: Text('غ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),

                            // Intermediate Degrees Ticks
                            ...List.generate(12, (index) {
                              final angle = index * 30.0;
                              return Transform.rotate(
                                angle: angle * (pi / 180.0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: index % 3 == 0 ? 3 : 1.5,
                                    height: index % 3 == 0 ? 14 : 8,
                                    margin: const EdgeInsets.only(top: 28),
                                    color: index == 0 ? Colors.red : (isDark ? Colors.white38 : Colors.black26),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Qibla Pointer Needle (Pointing relative to device)
                    Transform.rotate(
                      angle: relativeAngle,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kaaba Icon at the tip of the needle
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isAligned ? AppColors.accentGold : AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentGold.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Text('🕋', style: TextStyle(fontSize: 18)),
                          ),
                          // Gold Indicator Needle
                          CustomPaint(
                            size: const Size(20, 100),
                            painter: _QiblaNeedlePainter(isAligned: isAligned),
                          ),
                          const SizedBox(height: 100), // balance center
                        ],
                      ),
                    ),

                    // Center Hub Pivot
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAligned ? AppColors.accentGold : AppColors.primaryGreen,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Real-time Sensor Status & Degree Readout
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompassStat(
                      title: 'اتجاه الهاتف',
                      value: '${_deviceHeading.toStringAsFixed(0)}°',
                      isDark: isDark,
                    ),
                    Container(height: 30, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                    _buildCompassStat(
                      title: 'زاوية القبلة',
                      value: '${qiblaDegrees.toStringAsFixed(0)}°',
                      isDark: isDark,
                      highlight: true,
                    ),
                    Container(height: 30, width: 1, color: isDark ? Colors.white12 : Colors.black12),
                    _buildCompassStat(
                      title: 'حالة الحساس',
                      value: _hasSensor ? 'نشط 🧭' : 'محاكاة 📱',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getDirectionLabel(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'الشمال';
    if (deg >= 22.5 && deg < 67.5) return 'شمال شرق';
    if (deg >= 67.5 && deg < 112.5) return 'الشرق';
    if (deg >= 112.5 && deg < 157.5) return 'جنوب شرق';
    if (deg >= 157.5 && deg < 202.5) return 'الجنوب';
    if (deg >= 202.5 && deg < 247.5) return 'جنوب غرب';
    if (deg >= 247.5 && deg < 292.5) return 'الغرب';
    return 'شمال غرب';
  }

  Widget _buildCompassStat({
    required String title,
    required String value,
    required bool isDark,
    bool highlight = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white60 : AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight
                ? AppColors.accentGold
                : (isDark ? Colors.white : AppColors.primaryGreen),
          ),
        ),
      ],
    );
  }
}

class _QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;

  _QiblaNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAligned ? const Color(0xFFD4AF37) : const Color(0xFF1B4332)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0) // tip
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.8)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Subtle edge highlight
    final borderPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
