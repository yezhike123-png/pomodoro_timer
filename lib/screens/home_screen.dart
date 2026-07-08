import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_state.dart';
import '../models/timer_mode.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../widgets/circular_timer.dart';
import '../widgets/control_buttons.dart';
import '../widgets/session_indicator.dart';

/// 主页面 —— 番茄钟的核心界面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // 监听 App 生命周期（切后台 → 回前台）
    WidgetsBinding.instance.addObserver(this);

    // 设置计时完成回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = context.read<TimerProvider>();
      timerProvider.onTimerFinished = _onTimerFinished;

      // 同步设置到计时器
      final settings = context.read<SettingsProvider>();
      timerProvider.updateSettings(
        focusMinutes: settings.focusMinutes,
        shortBreakMinutes: settings.shortBreakMinutes,
        longBreakMinutes: settings.longBreakMinutes,
        longBreakInterval: settings.longBreakInterval,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioService.dispose();
    super.dispose();
  }

  /// App 从后台回到前台时，恢复计时器状态
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<TimerProvider>().recoverFromBackground();
    }
  }

  /// 计时完成时的处理
  void _onTimerFinished() {
    final timerProvider = context.read<TimerProvider>();
    final settings = context.read<SettingsProvider>();
    final mode = timerProvider.mode;
    final isFocus = mode == TimerMode.focus;

    // 1. 播放提示音
    if (settings.soundEnabled) {
      _audioService.playTimerEndSound();
    }

    // 2. 发送本地通知
    if (settings.notificationEnabled) {
      final title = isFocus ? '专注完成！☕' : '休息结束！💪';
      final body = isFocus
          ? '太棒了，休息一会儿吧～'
          : '休息好了，继续加油！';
      _notificationService.showTimerEndNotification(
        title: title,
        body: body,
      );
    }

    // 3. 如果是专注完成，记录到统计（通过 API 存到 MySQL）
    if (isFocus) {
      context.read<StatsProvider>().addSession(
        durationMinutes: settings.focusMinutes,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timer, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('🍅 番茄计时器'),
            centerTitle: true,
            actions: [
              // 统计按钮
              IconButton(
                icon: const Icon(Icons.bar_chart),
                tooltip: '统计',
                onPressed: () {
                  Navigator.pushNamed(context, '/stats');
                },
              ),
              // 设置按钮
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: '设置',
                onPressed: () async {
                  await Navigator.pushNamed(context, '/settings');
                  // 从设置页返回后，同步设置
                  if (mounted) {
                    timer.updateSettings(
                      focusMinutes: settings.focusMinutes,
                      shortBreakMinutes: settings.shortBreakMinutes,
                      longBreakMinutes: settings.longBreakMinutes,
                      longBreakInterval: settings.longBreakInterval,
                    );
                  }
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 圆形进度计时器
                  CircularTimer(
                    progress: timer.progress,
                    timeText: timer.formattedTime,
                    modeLabel: timer.modeLabel,
                    color: timer.modeColor,
                  ),

                  const SizedBox(height: 48),

                  // 控制按钮
                  ControlButtons(
                    state: timer.state,
                    onStart: timer.start,
                    onPause: timer.pause,
                    onResume: timer.resume,
                    onSkip: timer.skip,
                    onReset: timer.reset,
                    onConfirm: timer.confirmFinished,
                  ),

                  const SizedBox(height: 32),

                  // 番茄完成指示器（只在专注模式且非空闲时显示）
                  if (timer.mode == TimerMode.focus ||
                      timer.state != TimerState.idle)
                    SessionIndicator(
                      completedCount: timer.completedSessions,
                      longBreakInterval: settings.longBreakInterval,
                      color: timer.modeColor,
                    ),

                  // 显示当前是第几个番茄
                  if (timer.completedSessions > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '已完成 ${timer.completedSessions} 个番茄',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
