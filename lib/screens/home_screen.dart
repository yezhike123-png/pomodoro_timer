import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_mode.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart' show SettingsProvider, WhiteNoise;
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../widgets/circular_timer.dart';
import '../widgets/control_buttons.dart';
import '../widgets/session_indicator.dart';
import '../widgets/task_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationService _notificationService = NotificationService();
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    // 同步设置到计时器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncSettings();
    });
  }

  void _syncSettings() {
    final settings = context.read<SettingsProvider>();
    context.read<TimerProvider>().updateSettings(
      focusMinutes: settings.focusMinutes,
      shortBreakMinutes: settings.shortBreakMinutes,
      longBreakMinutes: settings.longBreakMinutes,
      longBreakInterval: settings.longBreakInterval,
      autoStartNext: settings.autoStartNext,
    );
  }

  void _startNoiseIfNeeded() {
    final settings = context.read<SettingsProvider>();
    final timer = context.read<TimerProvider>();
    if (settings.whiteNoise != WhiteNoise.none && timer.mode == TimerMode.focus) {
      _audioService.startWhiteNoise(settings.whiteNoise.name);
    }
  }

  void _onTimerFinished() {
    final timerProvider = context.read<TimerProvider>();
    final settings = context.read<SettingsProvider>();
    final taskProvider = context.read<TaskProvider>();
    final mode = timerProvider.mode;
    final isFocus = mode == TimerMode.focus;

    if (settings.soundEnabled) {
      _audioService.playTimerEndSound(soundType: settings.soundType.name);
    }

    // 停止白噪音（专注结束时）
    _audioService.stopWhiteNoise();

    if (settings.notificationEnabled) {
      final title = isFocus ? '专注完成！☕' : '休息结束！💪';
      final body = isFocus ? '太棒了，休息一会儿吧～' : '休息好了，继续加油！';
      _notificationService.showTimerEndNotification(title: title, body: body);
    }

    if (isFocus) {
      context.read<StatsProvider>().addSession(durationMinutes: settings.focusMinutes);
      // 关联到当前任务
      if (taskProvider.currentTaskId != null) {
        taskProvider.incrementPomodoro(taskProvider.currentTaskId!);
      }
    }
  }

  void _showQuickAddTask() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('添加任务', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '输入任务名称...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    context.read<TaskProvider>().addTask(controller.text.trim());
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('添加'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerProvider = context.watch<TimerProvider>();
    final settings = context.watch<SettingsProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final mode = timerProvider.mode;
    final state = timerProvider.state;
    final remaining = timerProvider.remainingSeconds;
    final total = timerProvider.totalSeconds;
    final completedCount = timerProvider.completedSessions;

    // 当前模式信息
    final modeLabel = mode == TimerMode.focus
        ? '专注中'
        : mode == TimerMode.shortBreak
            ? '短休息'
            : '长休息';
    final modeColor = mode == TimerMode.focus
        ? const Color(0xFFE74C3C)
        : mode == TimerMode.shortBreak
            ? const Color(0xFF2ECC71)
            : const Color(0xFF3498DB);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── 顶栏 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 主题切换
                  IconButton(
                    icon: Icon(themeProvider.isDark ? Icons.light_mode : Icons.dark_mode),
                    onPressed: () => themeProvider.toggle(),
                    tooltip: '切换主题',
                  ),
                  // 标题
                  Text(
                    '🍅 番茄计时器',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bar_chart_rounded),
                        onPressed: () => Navigator.pushNamed(context, '/stats'),
                        tooltip: '统计',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded),
                        onPressed: () => Navigator.pushNamed(context, '/settings'),
                        tooltip: '设置',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 任务选择 ──
            TaskPicker(
              currentTask: taskProvider.currentTask,
              tasks: taskProvider.pendingTasks,
              onSelect: (task) => taskProvider.selectTask(task?.id),
              onAdd: _showQuickAddTask,
            ),
            const SizedBox(height: 8),

            // ── 模式标签 ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: modeColor.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                modeLabel,
                style: TextStyle(
                  color: modeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 圆形进度条 ──
            Expanded(
              child: Center(
                child: CircularTimer(
                  progress: total > 0 ? remaining / total : 0,
                  remainingSeconds: remaining,
                  color: modeColor,
                  size: 260,
                ),
              ),
            ),

            // ── 番茄指示器 ──
            SessionIndicator(
              completedCount: completedCount,
              interval: settings.longBreakInterval,
            ),
            const SizedBox(height: 16),

            // ── 控制按钮 ──
            ControlButtons(
              state: state,
              color: modeColor,
              onStart: () {
                timerProvider.start();
                _startNoiseIfNeeded();
              },
              onPause: () {
                timerProvider.pause();
                _audioService.stopWhiteNoise();
              },
              onResume: () {
                timerProvider.start();
                _startNoiseIfNeeded();
              },
              onSkip: () {
                timerProvider.skip();
                _onTimerFinished();
              },
              onReset: () {
                timerProvider.reset();
                _audioService.stopWhiteNoise();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
