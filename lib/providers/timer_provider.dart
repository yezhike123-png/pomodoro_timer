import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_state.dart';
import '../models/timer_mode.dart';

/// 核心计时逻辑 —— 管理番茄钟的完整生命周期
class TimerProvider extends ChangeNotifier {
  // 当前状态
  TimerState _state = TimerState.idle;
  TimerMode _mode = TimerMode.focus;

  // 时间相关（单位：秒）
  int _totalSeconds = 25 * 60;      // 当前阶段总秒数
  int _remainingSeconds = 25 * 60;  // 剩余秒数

  // 计时器
  Timer? _ticker;        // 每秒刷新 UI 的定时器
  DateTime? _startTime;  // 计时开始的时间戳（用于后台恢复）

  // 番茄统计
  int _completedSessions = 0;  // 本轮已完成的番茄数（用于判断长休息）

  // 外部依赖（由外部注入或通过回调获取）
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _longBreakInterval = 4;
  bool _autoStartNext = false;

  // 回调
  VoidCallback? onTimerFinished;

  // --- Getter ---

  TimerState get state => _state;
  TimerMode get mode => _mode;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get completedSessions => _completedSessions;

  /// 进度：0.0 ~ 1.0（已过时间占比）
  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / _totalSeconds);
  }

  /// 格式化的剩余时间 "MM:SS"
  String get formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 当前阶段的显示文字
  String get modeLabel {
    switch (_mode) {
      case TimerMode.focus:
        return '专注中';
      case TimerMode.shortBreak:
        return '短休息';
      case TimerMode.longBreak:
        return '长休息';
    }
  }

  /// 当前阶段对应的颜色
  Color get modeColor {
    switch (_mode) {
      case TimerMode.focus:
        return const Color(0xFFE74C3C);   // 红色
      case TimerMode.shortBreak:
        return const Color(0xFF2ECC71);   // 绿色
      case TimerMode.longBreak:
        return const Color(0xFF3498DB);   // 蓝色
    }
  }

  // --- 设置同步 ---

  /// 从 SettingsProvider 同步设置参数
  void updateSettings({
    required int focusMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required int longBreakInterval,
    required bool autoStartNext,
  }) {
    _focusMinutes = focusMinutes;
    _shortBreakMinutes = shortBreakMinutes;
    _longBreakMinutes = longBreakMinutes;
    _longBreakInterval = longBreakInterval;
    _autoStartNext = autoStartNext;

    if (_state == TimerState.idle) {
      _totalSeconds = _focusMinutes * 60;
      _remainingSeconds = _totalSeconds;
      notifyListeners();
    }
  }

  // --- 计时控制 ---

  /// 开始计时（仅 idle 状态可用）
  void start() {
    if (_state != TimerState.idle) return;

    _startTime = DateTime.now();
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  /// 暂停（仅 running 状态可用）
  void pause() {
    if (_state != TimerState.running) return;

    _ticker?.cancel();
    _ticker = null;
    _state = TimerState.paused;
    notifyListeners();
  }

  /// 继续（仅 paused 状态可用）
  void resume() {
    if (_state != TimerState.paused) return;

    // 重新校准起始时间
    final elapsed = _totalSeconds - _remainingSeconds;
    _startTime = DateTime.now().subtract(Duration(seconds: elapsed));
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  /// 跳过当前阶段，直接进入下一阶段
  void skip() {
    _ticker?.cancel();
    _ticker = null;
    _handleFinished();
  }

  /// 重置到初始状态
  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _startTime = null;
    _state = TimerState.idle;
    _mode = TimerMode.focus;
    _totalSeconds = _focusMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _completedSessions = 0;
    notifyListeners();
  }

  /// 从后台恢复时调用 —— 根据时间戳重新计算剩余时间
  void recoverFromBackground() {
    if (_state != TimerState.running || _startTime == null) return;

    final now = DateTime.now();
    final elapsed = now.difference(_startTime!).inSeconds;

    if (elapsed >= _totalSeconds) {
      // 计时器在后台已到期
      _remainingSeconds = 0;
      _ticker?.cancel();
      _ticker = null;
      _handleFinished();
    } else {
      // 正常恢复
      _remainingSeconds = _totalSeconds - elapsed;
    }
    notifyListeners();
  }

  // --- 内部方法 ---

  /// 启动每秒刷新的定时器
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state != TimerState.running) return;

      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      }

      if (_remainingSeconds <= 0) {
        _ticker?.cancel();
        _ticker = null;
        _handleFinished();
      }
    });
  }

  /// 当前阶段结束，判断进入休息还是专注
  void _handleFinished() {
    _state = TimerState.finished;

    if (_mode == TimerMode.focus) {
      // 专注完成 → 番茄数 +1
      _completedSessions++;

      // 判断进入短休息还是长休息
      if (_completedSessions % _longBreakInterval == 0) {
        _mode = TimerMode.longBreak;
        _totalSeconds = _longBreakMinutes * 60;
      } else {
        _mode = TimerMode.shortBreak;
        _totalSeconds = _shortBreakMinutes * 60;
      }
    } else {
      // 休息完成 → 进入专注
      _mode = TimerMode.focus;
      _totalSeconds = _focusMinutes * 60;
    }

    _remainingSeconds = _totalSeconds;
    _state = TimerState.finished;

    // 触发回调
    onTimerFinished?.call();

    notifyListeners();

    // 自动流转：延迟 1.5 秒后自动开始下一阶段
    if (_autoStartNext) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (_state == TimerState.finished) {
          confirmFinished();
        }
      });
    }
  }

  /// 用户确认完成 → 进入下一阶段并自动开始
  void confirmFinished() {
    if (_state != TimerState.finished) return;

    _startTime = DateTime.now();
    _state = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
