import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settings, theme, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── 时长设置 ──
              _SectionTitle(title: '⏱️ 时长设置'),
              _TimeSlider(label: '专注时长', value: settings.focusMinutes,
                  min: 5, max: 60, step: 5, unit: '分钟',
                  onChanged: (v) => settings.setFocusMinutes(v)),
              _TimeSlider(label: '短休息时长', value: settings.shortBreakMinutes,
                  min: 1, max: 15, step: 1, unit: '分钟',
                  onChanged: (v) => settings.setShortBreakMinutes(v)),
              _TimeSlider(label: '长休息时长', value: settings.longBreakMinutes,
                  min: 5, max: 30, step: 5, unit: '分钟',
                  onChanged: (v) => settings.setLongBreakMinutes(v)),

              const Divider(height: 32),

              // ── 循环设置 ──
              _SectionTitle(title: '🔄 循环设置'),
              _TimeSlider(label: '长休息触发间隔', value: settings.longBreakInterval,
                  min: 2, max: 6, step: 1, unit: '个番茄',
                  onChanged: (v) => settings.setLongBreakInterval(v)),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 2, bottom: 8),
                child: Text(
                  '每完成 ${settings.longBreakInterval} 个番茄后，进入一次长休息',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),

              const Divider(height: 32),

              // ── 提醒设置 ──
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

              const Divider(height: 32),

              // ── 外观设置 ──
              _SectionTitle(title: '🎨 外观设置'),
              ...ThemeModeType.values.map((mode) => RadioListTile<ThemeModeType>(
                    title: Text(_themeLabel(mode)),
                    subtitle: Text(_themeDesc(mode)),
                    value: mode,
                    groupValue: theme.mode,
                    onChanged: (v) => theme.setMode(v!),
                    dense: true,
                  )),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(ThemeModeType mode) {
    switch (mode) {
      case ThemeModeType.light: return '浅色模式';
      case ThemeModeType.dark: return '深色模式';
      case ThemeModeType.system: return '跟随系统';
    }
  }

  String _themeDesc(ThemeModeType mode) {
    switch (mode) {
      case ThemeModeType.light: return '始终使用浅色主题';
      case ThemeModeType.dark: return '始终使用深色主题（省电护眼）';
      case ThemeModeType.system: return '自动跟随系统深色模式设置';
    }
  }
}

// ── 复用组件 ──

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _TimeSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String unit;
  final ValueChanged<int> onChanged;

  const _TimeSlider({required this.label, required this.value, required this.min,
      required this.max, required this.step, required this.unit, required this.onChanged});

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
              Text('$value $unit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary)),
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
