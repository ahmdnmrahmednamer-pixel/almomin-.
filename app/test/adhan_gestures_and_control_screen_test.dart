import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almomin/core/services/adhan_sensor_gesture_service.dart';
import 'package:almomin/core/notifications/prayer_notification_service.dart';
import 'package:almomin/core/services/islamic_audio_service.dart';
import 'package:almomin/core/services/prayer_tracker_service.dart';
import 'package:almomin/features/prayer/adhan_control_screen.dart';
import 'package:almomin/features/settings/settings_screen.dart';
import 'package:almomin/features/settings/widgets/settings_adhan_voice_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notif_shake_to_stop': true,
      'notif_flip_to_mute': true,
      'notif_overlay_window': true,
      'notif_selected_adhan': 'adhan_makkah',
      'notif_selected_iqamah': 'iqamah_full',
      'notif_vibrate_on_stop': true,
    });
    // Use an empty stream override in unit tests to avoid missing native hardware channels
    AdhanSensorGestureService.instance.accelerometerStreamOverride = const Stream<AccelerometerEvent>.empty();
    await AdhanSensorGestureService.instance.init();
    await PrayerNotificationService.instance.init();
    await PrayerTrackerService.instance.init();
  });

  tearDown(() {
    AdhanSensorGestureService.instance.stopListening();
  });

  group('AdhanSensorGestureService Unit & Persistence Tests', () {
    test('Initializes with default enabled states from preferences', () async {
      final service = AdhanSensorGestureService.instance;
      expect(service.isInitialized, isTrue);
      expect(service.shakeToStopEnabled, isTrue);
      expect(service.flipToMuteEnabled, isTrue);
      expect(service.overlayWindowEnabled, isTrue);
    });

    test('Toggling shake to stop updates state and persists', () async {
      final service = AdhanSensorGestureService.instance;
      await service.toggleShakeToStop(false);
      expect(service.shakeToStopEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_shake_to_stop'), isFalse);

      await service.toggleShakeToStop(true);
      expect(service.shakeToStopEnabled, isTrue);
      expect(prefs.getBool('notif_shake_to_stop'), isTrue);
    });

    test('Toggling flip to mute updates state and persists', () async {
      final service = AdhanSensorGestureService.instance;
      await service.toggleFlipToMute(false);
      expect(service.flipToMuteEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_flip_to_mute'), isFalse);

      await service.toggleFlipToMute(true);
      expect(service.flipToMuteEnabled, isTrue);
      expect(prefs.getBool('notif_flip_to_mute'), isTrue);
    });

    test('Toggling overlay window updates state and persists', () async {
      final service = AdhanSensorGestureService.instance;
      await service.toggleOverlayWindow(false);
      expect(service.overlayWindowEnabled, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_overlay_window'), isFalse);

      await service.toggleOverlayWindow(true);
      expect(service.overlayWindowEnabled, isTrue);
      expect(prefs.getBool('notif_overlay_window'), isTrue);
    });

    test('Start and stop listening manages callbacks cleanly', () {
      final service = AdhanSensorGestureService.instance;
      bool shakeTriggered = false;
      bool flipTriggered = false;

      service.startListening(
        onShake: () {
          shakeTriggered = true;
        },
        onFlip: () {
          flipTriggered = true;
        },
      );

      service.triggerSimulatedShake();
      expect(shakeTriggered, isTrue);

      service.triggerSimulatedFlip();
      expect(flipTriggered, isTrue);

      service.stopListening();
      expect(service.isListening, isFalse);
    });
  });

  group('PrayerNotificationService Background, Vibration & Mute Upgrades', () {
    test('stopAdhanAudio executes cleanly without exception', () {
      final service = PrayerNotificationService.instance;
      service.stopAdhanAudio();
      expect(IslamicAudioService.instance.isPlaying, isFalse);
    });

    test('isBatteryOptimizationIgnored returns a boolean status safely', () async {
      final service = PrayerNotificationService.instance;
      final ignored = await service.isBatteryOptimizationIgnored();
      expect(ignored, isA<bool>());
    });

    test('snoozeAdhan schedules without throwing exceptions', () async {
      final service = PrayerNotificationService.instance;
      await service.snoozeAdhan(5, 'الفجر');
      expect(true, isTrue);
    });

    test('Toggling vibrateOnStop persists correctly in preferences', () async {
      final service = PrayerNotificationService.instance;
      await service.toggleVibrateOnStop(false);
      expect(service.vibrateOnStop, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notif_vibrate_on_stop'), isFalse);

      await service.toggleVibrateOnStop(true);
      expect(service.vibrateOnStop, isTrue);
      expect(prefs.getBool('notif_vibrate_on_stop'), isTrue);
    });

    test('Temporary mute sets muteUntil and allows cancellation', () async {
      final service = PrayerNotificationService.instance;
      await service.muteForDuration(const Duration(hours: 2));
      expect(service.isTemporarilyMuted, isTrue);
      expect(service.muteUntil, isNotNull);

      await service.cancelTemporaryMute();
      expect(service.isTemporarilyMuted, isFalse);
      expect(service.muteUntil, isNull);
    });

    test('AdhanSoundMode includes vibrateOnly mode', () async {
      final service = PrayerNotificationService.instance;
      await service.setSoundMode(AdhanSoundMode.vibrateOnly);
      expect(service.soundMode, AdhanSoundMode.vibrateOnly);
    });
  });

  group('AdhanControlScreen Widget Rendering & Action Tests', () {
    testWidgets('Renders AdhanControlScreen with dedication, prayer title, and controls',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'العصر',
            isIqamah: false,
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check dedication
      expect(find.text('نداء الأذان المبارك — حيّ على الصلاة'), findsOneWidget);

      // Check prayer headline
      expect(find.text('الله أكبر.. حان الآن أذان العصر'), findsOneWidget);

      // Check stop button
      expect(find.text('إيقاف الأذان فوراً'), findsOneWidget);

      // Check gesture badges
      expect(find.textContaining('هز الهاتف للإيقاف'), findsOneWidget);
      expect(find.textContaining('اقلب الهاتف للكتم'), findsOneWidget);

      // Check secondary actions
      expect(find.text('استئناف'), findsOneWidget);
      expect(find.text('غفوة ٥ دقائق'), findsOneWidget);
      expect(find.text('بدء عداد الإقامة'), findsOneWidget);
      expect(find.text('دعاء الأذان 🤲'), findsOneWidget);
      expect(find.text('خيارات الأذان'), findsOneWidget);

      // Check Qibla card & Prayer Logger
      expect(find.textContaining('اتجاه القبلة نحو الكعبة المشرفة'), findsOneWidget);
      expect(find.textContaining('هل صليت العصر؟'), findsOneWidget);
      expect(find.text('جماعة بالمسجد 🕌'), findsOneWidget);
      expect(find.text('صليت حاضراً 🤲'), findsOneWidget);
    });

    testWidgets('Tapping manual stop button activates dedicated stop & serenity screen',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'الظهر',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Stop Button
      final stopBtn = find.text('إيقاف الأذان فوراً');
      expect(stopBtn, findsOneWidget);
      await tester.tap(stopBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Dedicated Stop View is displayed
      expect(find.text('تم إيقاف الأذان بنجاح ⏹️'), findsOneWidget);
      expect(find.textContaining('نسأل الله العظيم أن يتقبل صلاتكم وطاعتكم'), findsOneWidget);
      expect(find.textContaining('اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ'), findsOneWidget);
      expect(find.text('استئناف الأذان'), findsOneWidget);
      expect(find.text('العودة للتطبيق'), findsOneWidget);

      // Tap Resume to return to live player
      await tester.tap(find.text('استئناف الأذان'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('إيقاف الأذان فوراً'), findsOneWidget);
    });

    testWidgets('Tapping adhan options button opens multiple activation & dismissal modal',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'المغرب',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Adhan Options Button
      final optionsBtn = find.text('خيارات الأذان');
      expect(optionsBtn, findsOneWidget);
      await tester.tap(optionsBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify modal content
      expect(find.text('خيارات تفعيل وإيقاف الأذان والتنبيهات'), findsOneWidget);
      expect(find.text('تنبيه الأذان العام مفعّل'), findsOneWidget);
      expect(find.textContaining('كتم مؤقت'), findsOneWidget);
      expect(find.text('اهتزاز قوي فقط 📳 (بدون رنين)'), findsOneWidget);
      expect(find.text('الاهتزاز اللمسي عند الإيقاف 📳'), findsOneWidget);
    });

    testWidgets('Tapping prayer logger updates tracker and displays confirmation banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'الظهر',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap congregation prayer
      final masjidBtn = find.text('جماعة بالمسجد 🕌');
      expect(masjidBtn, findsOneWidget);
      await tester.tap(masjidBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify success feedback
      expect(find.textContaining('تقبل الله صلاتكم في جماعة'), findsWidgets);
      expect(find.textContaining('تم تسجيل أداء صلاة الظهر بنجاح'), findsOneWidget);
    });

    testWidgets('Tapping simulated shake stops adhan and shows feedback banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'المغرب',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap shake simulation badge
      final shakeBadge = find.textContaining('هز الهاتف للإيقاف');
      expect(shakeBadge, findsOneWidget);
      await tester.tap(shakeBadge);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('تم إيقاف الأذان بنجاح عبر هز الهاتف'), findsWidgets);
    });

    testWidgets('Tapping simulated flip mutes adhan and shows feedback banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'العشاء',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap flip simulation badge
      final flipBadge = find.textContaining('اقلب الهاتف للكتم');
      expect(flipBadge, findsOneWidget);
      await tester.tap(flipBadge);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('تم كتم الأذان بنجاح عند قلب الهاتف على وجهه'), findsWidgets);
    });

    testWidgets('Tapping Duaa button opens bottom sheet with authentic text and copy button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'الفجر',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final duaaButton = find.text('دعاء الأذان 🤲');
      expect(duaaButton, findsOneWidget);
      await tester.tap(duaaButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('دعاء ما بعد الأذان (الوسيلة)'), findsOneWidget);
      expect(find.textContaining('اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ'), findsOneWidget);
      expect(find.text('نسخ الدعاء المبارك'), findsOneWidget);
    });
  });

  group('SettingsScreen Gesture & Overlay Controls UI Tests', () {
    testWidgets('SettingsScreen displays new motion gestures and overlay switches',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll down to the gesture section
      final gestureTitle = find.text('إيماءات التحكم بالأذان ومستشعرات الحركة');
      await tester.scrollUntilVisible(
        gestureTitle,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(gestureTitle, findsOneWidget);
      expect(find.text('الظهور فوق التطبيقات وشاشة القفل'), findsOneWidget);
      expect(find.text('إيقاف الأذان عند هز الهاتف 📳'), findsOneWidget);
      expect(find.text('كتم الأذان عند قلب الهاتف على وجهه 📱'), findsOneWidget);
      expect(find.text('تجربة الشاشة'), findsOneWidget);
    });
  });

  group('Expanded High-Definition Adhan Audio Library Tests', () {
    test('All expanded Adhan tracks exist in IslamicAudioService with unique IDs and valid metadata', () {
      final adhanTracks = IslamicAudioService.allTracks
          .where((t) => t.type == IslamicAudioType.adhan)
          .toList();

      expect(adhanTracks.length, greaterThanOrEqualTo(30));

      final ids = adhanTracks.map((t) => t.id).toSet();
      expect(ids.length, equals(adhanTracks.length), reason: 'All track IDs must be unique');

      for (final track in adhanTracks) {
        expect(track.title.isNotEmpty, isTrue);
        expect(track.durationFormatted.isNotEmpty, isTrue);
        expect(track.quality.isNotEmpty, isTrue);
      }

      // Check key new voices exist
      expect(ids.contains('adhan_alqatami'), isTrue);
      expect(ids.contains('adhan_alzamil'), isTrue);
      expect(ids.contains('adhan_mansoor_alsalimi'), isTrue);
      expect(ids.contains('adhan_essam_bukhari'), isTrue);
      expect(ids.contains('adhan_farooq_hadrawi'), isTrue);
      expect(ids.contains('adhan_naif_feeda'), isTrue);
      expect(ids.contains('adhan_mustafa_ismail'), isTrue);
      expect(ids.contains('adhan_omran'), isTrue);
      expect(ids.contains('adhan_islam_sobhi'), isTrue);
      expect(ids.contains('adhan_wadih_alyamani'), isTrue);
      expect(ids.contains('adhan_idrees_abkar'), isTrue);
      expect(ids.contains('adhan_tunisia'), isTrue);
      expect(ids.contains('adhan_bosnia'), isTrue);
      expect(ids.contains('adhan_fajr_abdulbasit'), isTrue);
      expect(ids.contains('adhan_fajr_alqatami'), isTrue);
      expect(ids.contains('adhan_haza_albalushi'), isTrue);
    });

    test('getAdhanVoiceName resolves new muezzin keys properly', () {
      expect(getAdhanVoiceName('adhan_alqatami'), contains('ناصر القطامي'));
      expect(getAdhanVoiceName('adhan_alzamil'), contains('ماجد الزامل'));
      expect(getAdhanVoiceName('adhan_mansoor_alsalimi'), contains('منصور السالمي'));
      expect(getAdhanVoiceName('adhan_essam_bukhari'), contains('عصام بخاري'));
      expect(getAdhanVoiceName('adhan_farooq_hadrawi'), contains('فاروق حضراوي'));
      expect(getAdhanVoiceName('adhan_mustafa_ismail'), contains('مصطفى إسماعيل'));
      expect(getAdhanVoiceName('adhan_omran'), contains('محمد عمران'));
      expect(getAdhanVoiceName('adhan_islam_sobhi'), contains('إسلام صبحي'));
      expect(getAdhanVoiceName('adhan_wadih_alyamani'), contains('وديع اليمني'));
      expect(getAdhanVoiceName('adhan_idrees_abkar'), contains('إدريس أبكر'));
      expect(getAdhanVoiceName('adhan_tunisia'), contains('جامع الزيتونة'));
      expect(getAdhanVoiceName('adhan_bosnia'), contains('سراييفو'));
      expect(getAdhanVoiceName('adhan_fajr_alqatami'), contains('الفجر'));
      expect(getAdhanVoiceName('adhan_haza_albalushi'), contains('هزاع البلوشي'));
    });

    test('PrayerNotificationService allows setting both general adhan and Fajr-specific adhan', () async {
      final notifService = PrayerNotificationService.instance;
      await notifService.setSelectedAdhanVoice('adhan_alqatami');
      expect(notifService.selectedAdhanVoice, 'adhan_alqatami');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('notif_selected_adhan'), 'adhan_alqatami');

      await notifService.setSelectedFajrVoice('adhan_fajr_alqatami');
      expect(notifService.selectedFajrVoice, 'adhan_fajr_alqatami');
      expect(prefs.getString('notif_selected_fajr_adhan'), 'adhan_fajr_alqatami');
    });

    testWidgets('Tapping adhan options modal contains direct navigation to Adhan Audio Studio',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdhanControlScreen(
            prayerName: 'المغرب',
            autoPlay: false,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final optionsButton = find.text('خيارات الأذان');
      expect(optionsButton, findsOneWidget);
      await tester.tap(optionsButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('المكتبة الصوتية للأذان والمؤذنين'), findsOneWidget);
    });
  });
}
