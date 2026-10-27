import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing accelerometer and motion sensor gestures
/// specifically for Adhan & Iqamah control (Shake-to-Stop & Flip-to-Mute),
/// as well as Android System Alert Window (Display over other apps) permissions.
class AdhanSensorGestureService extends ChangeNotifier {
  static final AdhanSensorGestureService instance = AdhanSensorGestureService._internal();
  AdhanSensorGestureService._internal();

  bool _isInitialized = false;
  bool _shakeToStopEnabled = true;
  bool _flipToMuteEnabled = true;
  bool _overlayWindowEnabled = true;
  bool _isListening = false;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  final List<DateTime> _shakeSpikes = [];
  DateTime? _lastShakeTriggerTime;
  DateTime? _lastFlipTriggerTime;
  DateTime? _faceDownStartTime;
  bool _wasFaceUp = true;

  VoidCallback? _onShakeCallback;
  VoidCallback? _onFlipCallback;
  Stream<AccelerometerEvent>? accelerometerStreamOverride;

  bool get isInitialized => _isInitialized;
  bool get shakeToStopEnabled => _shakeToStopEnabled;
  bool get flipToMuteEnabled => _flipToMuteEnabled;
  bool get overlayWindowEnabled => _overlayWindowEnabled;
  bool get isListening => _isListening;

  Future<void> init({bool forceReload = false}) async {
    if (_isInitialized && !forceReload) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _shakeToStopEnabled = prefs.getBool('notif_shake_to_stop') ?? true;
      _flipToMuteEnabled = prefs.getBool('notif_flip_to_mute') ?? true;
      _overlayWindowEnabled = prefs.getBool('notif_overlay_window') ?? true;
    } catch (e) {
      debugPrint('AdhanSensorGestureService init prefs error: $e');
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleShakeToStop(bool enabled) async {
    _shakeToStopEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_shake_to_stop', enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleFlipToMute(bool enabled) async {
    _flipToMuteEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_flip_to_mute', enabled);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> toggleOverlayWindow(bool enabled) async {
    _overlayWindowEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_overlay_window', enabled);
    } catch (_) {}
    notifyListeners();
  }

  /// Checks the current system alert window permission status
  Future<bool> checkOverlayPermission() async {
    try {
      return await Permission.systemAlertWindow.isGranted;
    } catch (e) {
      debugPrint('checkOverlayPermission error: $e');
      return false;
    }
  }

  /// Requests the user to grant display over other apps permission
  Future<bool> requestOverlayPermission() async {
    try {
      final status = await Permission.systemAlertWindow.request();
      notifyListeners();
      return status.isGranted;
    } catch (e) {
      debugPrint('requestOverlayPermission error: $e');
      return false;
    }
  }

  /// Starts listening to device accelerometer sensors for shake and flip gestures.
  /// Only active when needed (e.g. while Adhan is ringing or control screen is visible)
  /// to ensure ZERO background battery consumption.
  void startListening({
    VoidCallback? onShake,
    VoidCallback? onFlip,
  }) {
    if (_isListening) {
      _onShakeCallback = onShake ?? _onShakeCallback;
      _onFlipCallback = onFlip ?? _onFlipCallback;
      return;
    }

    _onShakeCallback = onShake;
    _onFlipCallback = onFlip;
    _shakeSpikes.clear();
    _lastShakeTriggerTime = null;
    _lastFlipTriggerTime = null;
    _faceDownStartTime = null;
    _wasFaceUp = true;

    try {
      _accelSub?.cancel();
      final stream = accelerometerStreamOverride ?? accelerometerEventStream();
      _accelSub = stream.listen(
        _handleAccelerometerEvent,
        onError: (err) {
          debugPrint('accelerometerEventStream error: $err');
        },
        cancelOnError: false,
      );
      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Could not start accelerometer stream: $e');
      _isListening = false;
      notifyListeners();
    }
  }

  /// Stops listening to accelerometer events and frees sensor hardware.
  void stopListening() {
    _accelSub?.cancel();
    _accelSub = null;
    _isListening = false;
    _onShakeCallback = null;
    _onFlipCallback = null;
    _shakeSpikes.clear();
    notifyListeners();
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();
    final double x = event.x;
    final double y = event.y;
    final double z = event.z;

    // 1. Shake Detection Algorithm
    // Calculate total net acceleration magnitude deviation from standard gravity (9.81 m/s^2)
    final double totalAccel = sqrt(x * x + y * y + z * z);
    final double deltaG = (totalAccel - 9.81).abs();

    if (_shakeToStopEnabled && deltaG > 11.0) {
      // Cooldown check: prevent rapid repeated triggers within 2 seconds
      if (_lastShakeTriggerTime == null ||
          now.difference(_lastShakeTriggerTime!).inMilliseconds > 2000) {
        // Retain recent spikes within the last 650 ms
        _shakeSpikes.removeWhere((t) => now.difference(t).inMilliseconds > 650);
        _shakeSpikes.add(now);

        // Require at least 2 consecutive energetic spikes for confirmed intentional shake
        if (_shakeSpikes.length >= 2) {
          _lastShakeTriggerTime = now;
          _shakeSpikes.clear();
          try {
            HapticFeedback.heavyImpact();
          } catch (_) {}
          _onShakeCallback?.call();
        }
      }
    }

    // 2. Flip Face-Down Detection Algorithm
    // When phone is placed flat face-down:
    // Z axis points down towards screen (< -6.8 m/s^2), and X/Y are near zero (< 4.5)
    final bool isFaceDown = z < -6.8 && x.abs() < 4.5 && y.abs() < 4.5;
    final bool isFaceUp = z > 3.5;

    if (isFaceUp) {
      _wasFaceUp = true;
    }

    if (_flipToMuteEnabled && _wasFaceUp && isFaceDown) {
      if (_lastFlipTriggerTime == null ||
          now.difference(_lastFlipTriggerTime!).inMilliseconds > 2000) {
        _faceDownStartTime ??= now;
        // Require steady face-down orientation for at least 220 ms to prevent false triggers during movement
        if (now.difference(_faceDownStartTime!).inMilliseconds >= 220) {
          _lastFlipTriggerTime = now;
          _wasFaceUp = false;
          _faceDownStartTime = null;
          try {
            HapticFeedback.mediumImpact();
          } catch (_) {}
          _onFlipCallback?.call();
        }
      }
    } else if (!isFaceDown) {
      _faceDownStartTime = null;
    }
  }

  /// Direct event processing hook for unit test physics verification
  void handleAccelerometerEventForTesting(AccelerometerEvent event) {
    _handleAccelerometerEvent(event);
  }

  /// Manually simulates a shake event for unit testing & preview demonstrations
  void triggerSimulatedShake() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
    _onShakeCallback?.call();
  }

  /// Manually simulates a flip face-down event for unit testing & preview demonstrations
  void triggerSimulatedFlip() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
    _onFlipCallback?.call();
  }
}
