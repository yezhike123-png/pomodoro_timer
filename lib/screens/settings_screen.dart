import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// 设置页面 —— 自定义时长、提醒开关等
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('设置'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- 时长设置 ---
              _SectionTitle(title: '⏱️ 时长设置'),
              _TimeSlider(
                label: '专注时长',
                value: settings.focusMinutes,
                min: 5,
                max: 60,
                step: 5,
                unit: '分钟',
                onChanged: (v) => settings.setFocusMinutes(v),
              ),
              _TimeSlider(
                label: '短休息时长',
                value: settings.shortBreakMinutes,
                min: 1,
                max: 15,
                step: 1,
                unit: '分钟',
                onChanged: (v) => settings.setShortBreakMinutes(v),
              ),
              _TimeSlider(
                label: '长休息时长',
                value: settings.longBreakMinutes,
                min: 5,
                max: 30,
                step: 5,
                unit: '分钟',
                onChanged: (v) => settings.setLongBreakMinutes(v),
              ),

              const Divider(height: 32),

              // --- 循环设置 ---
              _SectionTitle(title: '🔄 循环设置'),
              _TimeSlider(
                label: '长休息触发间隔',
                value: settings.longBreakInterval,
                min: 2,
                max: 6,
                step: 1,
                unit: '个番茄',
                onChanged: (v) => settings.setLongBreakInterval(v),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2, bottom: 8),
                child: Text(
                  '每完成 ${settings.longBreakInterval} 个番茄后，进入一次长休息',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),

              const Divider(height: 32),

              // --- 提醒设置 ---
              _SectionTitle(title: '🔔 提醒设置'),
              SwitchListTile(
                title: const Text('提示音'),
                subtitle: const Text('计时结束时播放提示音'),
                value: settings.soundEnabled,
                onChanged: (v) => settings.setSoundEnabled(v),
              ),
              SwitchListTile(
                title: const Text('系统通知'),
                subtitle: const Text('计时结束时发送系统通知'),
                value: settings.notificationEnabled,
                onChanged: (v) => settings.setNotificationEnabled(v),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 分区标题
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 时长滑块
class _TimeSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String unit;
  final ValueChanged<int> onChanged;

  const _TimeSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 15)),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ step,
            label: '$value $unit',
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
