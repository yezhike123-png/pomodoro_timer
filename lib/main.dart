import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/timer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/stats_provider.dart';
import 'services/notification_service.dart';

/// 应用入口 —— 初始化 Provider、加载设置、初始化通知插件
void main() async {
  // 确保 Flutter 绑定已初始化（async main 需要）
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化通知插件
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 2. 加载本地设置
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  // 3. 加载统计数据
  final statsProvider = StatsProvider();
  await statsProvider.loadSessions();

  // 4. 启动应用
  runApp(
    MultiProvider(
      providers: [
        // 设置 Provider
        ChangeNotifierProvider.value(value: settingsProvider),
        // 统计 Provider
        ChangeNotifierProvider.value(value: statsProvider),
        // 计时器 Provider
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const PomodoroApp(),
    ),
  );
}
