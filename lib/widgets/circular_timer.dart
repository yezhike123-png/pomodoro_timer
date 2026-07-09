import 'dart:math';
import 'package:flutter/material.dart';

/// 圆形进度计时器 —— 渐变描边 + 阴影 + 时间显示
class CircularTimer extends StatelessWidget {
  final double progress;
  final int remainingSeconds;
  final Color color;
  final double size;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.remainingSeconds,
    required this.color,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final strokeWidth = size * 0.045;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: Colors.grey.withAlpha(30),
              strokeWidth: strokeWidth,
            ),
          ),
          // 渐变进度圆环
          CustomPaint(
            size: Size(size, size),
            painter: _GradientRingPainter(
              progress: progress,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          // 时间文字
          Text(
            timeText,
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// 纯色圆环（背景）
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      progress * 2 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => progress != o.progress;
}

/// 渐变圆环（进度）
class _GradientRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _GradientRingPainter({required this.progress, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      colors: [color.withAlpha(180), color, color.withAlpha(200)],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, progress * 2 * pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter o) =>
      progress != o.progress || color != o.color;
}
