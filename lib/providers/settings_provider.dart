import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 用户设置管理 —— 通过后端 API 读写，多端共享数据
class SettingsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // 默认值
  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _longBreakInterval = 4;
  bool _soundEnabled = true;
  bool _notificationEnabled = true;

  // Getter
  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  int get longBreakInterval => _longBreakInterval;
  bool get soundEnabled => _soundEnabled;
  bool get notificationEnabled => _notificationEnabled;

  /// 从后端加载设置（App 启动时调用一次）
  Future<void> loadSettings() async {
    final data = await _api.getSettings();
    _focusMinutes = data['focusMinutes'] ?? 25;
    _shortBreakMinutes = data['shortBreakMinutes'] ?? 5;
    _longBreakMinutes = data['longBreakMinutes'] ?? 15;
    _longBreakInterval = data['longBreakInterval'] ?? 4;
    _soundEnabled = data['soundEnabled'] ?? true;
    _notificationEnabled = data['notificationEnabled'] ?? true;
    notifyListeners();
  }

  /// 更新专注时长（分钟）
  Future<void> setFocusMinutes(int minutes) async {
    _focusMinutes = minutes;
    notifyListeners();
    await _api.updateSetting('focusMinutes', minutes);
  }

  /// 更新短休息时长（分钟）
  Future<void> setShortBreakMinutes(int minutes) async {
    _shortBreakMinutes = minutes;
    notifyListeners();
    await _api.updateSetting('shortBreakMinutes', minutes);
  }

  /// 更新长休息时长（分钟）
  Future<void> setLongBreakMinutes(int minutes) async {
    _longBreakMinutes = minutes;
    notifyListeners();
    await _api.updateSetting('longBreakMinutes', minutes);
  }

  /// 更新长休息触发间隔
  Future<void> setLongBreakInterval(int interval) async {
    _longBreakInterval = interval;
    notifyListeners();
    await _api.updateSetting('longBreakInterval', interval);
  }

  /// 开关提示音
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    await _api.updateSetting('soundEnabled', enabled);
  }

  /// 开关通知
  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
    notifyListeners();
    await _api.updateSetting('notificationEnabled', enabled);
  }
}
