import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

import 'core/services/settings_service.dart';
import 'core/services/prayer_service.dart';
import 'core/services/adhkar_service.dart';
import 'core/notifications/prayer_notification_service.dart';
import 'core/services/khatma_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.init();
  await PrayerNotificationService.instance.init();
  await PrayerService.instance.init();
  await AdhkarService.instance.init();
  await KhatmaService.instance.init();
  runApp(
    const ProviderScope(
      child: AlMominApp(),
    ),
  );
}
