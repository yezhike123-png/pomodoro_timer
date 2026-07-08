import 'package:flutter/material.dart';
import '../models/timer_state.dart';

/// 控制按钮组 —— 根据当前状态显示不同按钮
class ControlButtons extends StatelessWidget {
  final TimerState state;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onSkip;
  final VoidCallback onReset;
  final VoidCallback onConfirm;

  const ControlButtons({
    super.key,
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onSkip,
    required this.onReset,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case TimerState.idle:
        return _buildButton('开始专注', Icons.play_arrow, onStart);

      case TimerState.running:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconButton(Icons.pause, '暂停', onPause),
            const SizedBox(width: 32),
            _buildIconButton(Icons.skip_next, '跳过', onSkip),
          ],
        );

      case TimerState.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconButton(Icons.play_arrow, '继续', onResume),
            const SizedBox(width: 32),
            _buildIconButton(Icons.skip_next, '跳过', onSkip),
            const SizedBox(width: 32),
            _buildIconButton(Icons.refresh, '重置', onReset),
          ],
        );

      case TimerState.finished:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton('进入下一阶段', Icons.arrow_forward, onConfirm),
            const SizedBox(width: 16),
            _buildTextButton('重置', onReset),
          ],
        );
    }
  }

  /// 大按钮（主要操作）
  Widget _buildButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  /// 圆形图标按钮
  Widget _buildIconButton(
      IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 36),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  /// 纯文字按钮
  Widget _buildTextButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
