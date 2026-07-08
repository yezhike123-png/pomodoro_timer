import 'dart:math';
import 'package:flutter/material.dart';

/// 圆形进度计时器 —— 用 CustomPainter 画圆弧 + 中间显示时间
class CircularTimer extends StatelessWidget {
  final double progress;   // 0.0 ~ 1.0
  final String timeText;   // "MM:SS"
  final String modeLabel;  // "专注中" / "短休息" / "长休息"
  final Color color;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.timeText,
    required this.modeLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    // 限制最大最小尺寸，适配桌面和手机
    final diameter = size.clamp(200.0, 350.0);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环（灰色底圈）
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _CircularProgressPainter(
              progress: 1.0, // 满圈
              color: Colors.grey.shade200,
              strokeWidth: 12,
            ),
          ),
          // 进度圆弧（彩色）
          CustomPaint(
            size: Size(diameter, diameter),
            painter: _CircularProgressPainter(
              progress: progress,
              color: color,
              strokeWidth: 12,
            ),
          ),
          // 中间文字
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                modeLabel,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: diameter / 5.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 自定义画笔 —— 画圆弧
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 从顶部 (-pi/2) 开始，顺时针画圆弧
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,                          // 起始角度（12 点钟方向）
      2 * pi * progress.clamp(0.0, 1.0), // 扫描角度
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
