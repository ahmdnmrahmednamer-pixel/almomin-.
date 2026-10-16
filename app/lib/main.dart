import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

import 'core/services/settings_service.dart';
import 'core/services/prayer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService.instance.init();
  PrayerService.instance.init();
  runApp(
    const ProviderScope(
      child: AlMominApp(),
    ),
  );
}
