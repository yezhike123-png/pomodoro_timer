import 'package:flutter/material.dart';
import '../models/timer_state.dart';

/// 控制按钮组 —— 主按钮渐变 + 小按钮
class ControlButtons extends StatelessWidget {
  final TimerState state;
  final Color color;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  const ControlButtons({
    super.key,
    required this.state,
    required this.color,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onSkip,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state != TimerState.idle)
          _SmallButton(icon: Icons.refresh_rounded, label: '重置', onTap: onReset),
        if (state != TimerState.idle) const SizedBox(width: 24),

        // 主按钮（带动画切换）
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: _buildMainButton(key: state.name),
        ),

        if (state != TimerState.idle) const SizedBox(width: 24),
        if (state != TimerState.idle)
          _SmallButton(icon: Icons.skip_next_rounded, label: '跳过', onTap: onSkip),
      ],
    );
  }

  Widget _buildMainButton({required String key}) {
    switch (state) {
      case TimerState.idle:
        return _MainButton(key: const ValueKey('start'), icon: Icons.play_arrow_rounded,
            label: '开始专注', color: color, onTap: onStart);
      case TimerState.running:
        return _MainButton(key: const ValueKey('pause'), icon: Icons.pause_rounded,
            label: '暂停', color: color, onTap: onPause);
      case TimerState.paused:
        return _MainButton(key: const ValueKey('resume'), icon: Icons.play_arrow_rounded,
            label: '继续', color: color, onTap: onResume);
      case TimerState.finished:
        return _MainButton(key: const ValueKey('finished'), icon: Icons.check_rounded,
            label: '已完成', color: Colors.grey, onTap: () {});
    }
  }
}

/// 主按钮（大，带渐变和阴影）
class _MainButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MainButton({super.key, required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withAlpha(200)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: color.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}

/// 小按钮
class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).cardTheme.color,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 8),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Icon(icon, size: 24, color: Colors.grey.shade600),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
