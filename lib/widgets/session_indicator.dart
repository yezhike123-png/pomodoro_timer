import 'package:flutter/material.dart';

/// 番茄完成指示器 —— 一排小圆点，表示本轮完成了几个番茄
class SessionIndicator extends StatelessWidget {
  final int completedCount;   // 已完成番茄数
  final int longBreakInterval; // 长休息触发间隔（默认 4）
  final Color color;

  const SessionIndicator({
    super.key,
    required this.completedCount,
    required this.longBreakInterval,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 当前周期内的番茄数（取余）
    final currentCycle = completedCount % longBreakInterval;
    // 如果 completedCount % longBreakInterval == 0 且 > 0，说明刚完成一轮
    final displayCount = currentCycle == 0 && completedCount > 0
        ? longBreakInterval
        : currentCycle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(longBreakInterval, (index) {
        final isFilled = index < displayCount;
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : Colors.grey.shade200,
            border: Border.all(
              color: isFilled ? color : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}
