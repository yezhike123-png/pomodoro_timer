import 'package:flutter/material.dart';

/// 番茄完成指示器 —— 小圆点，完成的高亮
class SessionIndicator extends StatelessWidget {
  final int completedCount;
  final int interval;

  const SessionIndicator({
    super.key,
    required this.completedCount,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    final currentCycle = completedCount % interval;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(interval, (i) {
        final isCompleted = i < currentCycle;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCompleted ? 14 : 10,
          height: isCompleted ? 14 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? const Color(0xFFE74C3C) : Colors.grey.withAlpha(50),
            boxShadow: isCompleted
                ? [BoxShadow(
                    color: const Color(0xFFE74C3C).withAlpha(40),
                    blurRadius: 4, spreadRadius: 1)]
                : null,
          ),
        );
      }),
    );
  }
}
