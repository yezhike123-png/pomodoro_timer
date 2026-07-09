import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 任务数据
class TaskItem {
  final int id;
  final String title;
  final bool completed;
  final int pomodoroCount;

  TaskItem({
    required this.id,
    required this.title,
    this.completed = false,
    this.pomodoroCount = 0,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      pomodoroCount: json['pomodoroCount'] as int? ?? 0,
    );
  }
}

/// 任务管理 Provider
class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<TaskItem> _tasks = [];
  int? _currentTaskId;

  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  int? get currentTaskId => _currentTaskId;

  /// 当前选中的任务
  TaskItem? get currentTask {
    if (_currentTaskId == null) return null;
    try {
      return _tasks.firstWhere((t) => t.id == _currentTaskId);
    } catch (_) {
      return null;
    }
  }

  /// 未完成的任务
  List<TaskItem> get pendingTasks =>
      _tasks.where((t) => !t.completed).toList();

  /// 加载任务列表
  Future<void> loadTasks() async {
    final data = await _api.getTasks();
    _tasks = data.map((j) => TaskItem.fromJson(j)).toList();
    notifyListeners();
  }

  /// 创建任务
  Future<void> addTask(String title) async {
    final result = await _api.createTask(title);
    if (result != null) {
      _tasks.insert(0, TaskItem.fromJson(result));
      notifyListeners();
    }
  }

  /// 删除任务
  Future<void> deleteTask(int id) async {
    await _api.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    if (_currentTaskId == id) _currentTaskId = null;
    notifyListeners();
  }

  /// 切换完成状态
  Future<void> toggleTask(int id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _api.updateTask(id, completed: !task.completed);
    final idx = _tasks.indexWhere((t) => t.id == id);
    _tasks[idx] = TaskItem(
      id: task.id,
      title: task.title,
      completed: !task.completed,
      pomodoroCount: task.pomodoroCount,
    );
    notifyListeners();
  }

  /// 选择当前任务
  void selectTask(int? id) {
    _currentTaskId = id;
    notifyListeners();
  }

  /// 完成一个番茄后 +1
  Future<void> incrementPomodoro(int taskId) async {
    await _api.incrementTaskPomodoro(taskId);
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _tasks[idx] = TaskItem(
        id: _tasks[idx].id,
        title: _tasks[idx].title,
        completed: _tasks[idx].completed,
        pomodoroCount: _tasks[idx].pomodoroCount + 1,
      );
      notifyListeners();
    }
  }
}
