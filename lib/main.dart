import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );

  // 初始化通知
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 加载数据
  final settingsProvider = SettingsProvider();
  final statsProvider = StatsProvider();
  final taskProvider = TaskProvider();
  await settingsProvider.loadSettings();
  await statsProvider.loadSessions();
  await taskProvider.loadTasks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: statsProvider),
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PomodoroApp(),
    ),
  );
}
