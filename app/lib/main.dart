import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/today_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();

  final storage = StorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(notifications)..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => TodayProvider(storage)..loadToday(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(storage),
        ),
      ],
      child: const GongziApp(),
    ),
  );
}
