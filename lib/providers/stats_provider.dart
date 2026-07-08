import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 统计数据管理 —— 通过后端 API 读写
class StatsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _sessions = [];

  List<Map<String, dynamic>> get sessions => List.unmodifiable(_sessions);

  /// 今日完成的番茄数
  int get todayCount {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return _sessions.where((s) {
      final dateStr = (s['date'] as String?) ?? '';
      return dateStr.startsWith(todayStr);
    }).length;
  }

  /// 本周完成的番茄数
  int get weekCount {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr =
        '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
    return _sessions.where((s) {
      final dateStr = (s['date'] as String?) ?? '';
      return dateStr.compareTo(mondayStr) >= 0;
    }).length;
  }

  /// 累计专注时长（分钟）
  int get totalFocusMinutes {
    int total = 0;
    for (final s in _sessions) {
      total += (s['durationMinutes'] as int?) ?? 0;
    }
    return total;
  }

  /// 格式化累计时长
  String get formattedTotalTime {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) {
      return '$hours 小时 $minutes 分钟';
    }
    return '$minutes 分钟';
  }

  /// 添加一条番茄完成记录
  Future<void> addSession({required int durationMinutes}) async {
    final now = DateTime.now();
    _sessions.insert(0, {
      'date': now.toIso8601String(),
      'durationMinutes': durationMinutes,
    });
    notifyListeners();
    // 同步到后端
    await _api.addSession(durationMinutes: durationMinutes);
  }

  /// 从后端加载历史记录
  Future<void> loadSessions() async {
    _sessions = await _api.getSessions();
    notifyListeners();
  }
}
