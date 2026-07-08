import 'timer_mode.dart';

/// 一个番茄钟完成记录
class PomodoroSession {
  final DateTime date;        // 完成日期
  final TimerMode mode;       // 当时是什么模式（通常为 focus）
  final int durationMinutes;  // 专注时长（分钟）
  final String? taskTitle;    // 关联的任务名称（可选，第二阶段用）

  PomodoroSession({
    required this.date,
    required this.mode,
    required this.durationMinutes,
    this.taskTitle,
  });

  /// 从 JSON 反序列化（用于 SharedPreferences 存储）
  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      date: DateTime.parse(json['date'] as String),
      mode: TimerMode.values.firstWhere((m) => m.name == json['mode']),
      durationMinutes: json['durationMinutes'] as int,
      taskTitle: json['taskTitle'] as String?,
    );
  }

  /// 序列化为 JSON（用于 SharedPreferences 存储）
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'mode': mode.name,
      'durationMinutes': durationMinutes,
      'taskTitle': taskTitle,
    };
  }
}
