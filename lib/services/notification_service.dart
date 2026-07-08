import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 本地通知服务 —— 计时器结束时弹出系统通知
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化通知插件（App 启动时调用）
  Future<void> initialize() async {
    // Android 配置
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS 配置
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
  }

  /// 显示计时结束通知
  Future<void> showTimerEndNotification({
    required String title,
    required String body,
  }) async {
    // Android 通知详情
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_timer_channel', // 通知渠道 ID
      '番茄计时器',              // 通知渠道名称（用户可在系统设置中看到）
      channelDescription: '计时器结束提醒',
      importance: Importance.high,
      priority: Priority.high,
    );

    // iOS / macOS 通知详情
    const darwinDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      0,          // 通知 ID（固定 0，后续通知会覆盖）
      title,
      body,
      details,
    );
  }
}
