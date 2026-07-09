import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 提示音类型
enum SoundType { bell, chime, piano }

/// 白噪音类型
enum WhiteNoise { none, rain, forest, cafe }

/// 用户设置管理
class SettingsProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  int _focusMinutes = 25;
  int _shortBreakMinutes = 5;
  int _longBreakMinutes = 15;
  int _longBreakInterval = 4;
  bool _soundEnabled = true;
  bool _notificationEnabled = true;
  bool _autoStartNext = false;
  SoundType _soundType = SoundType.bell;
  WhiteNoise _whiteNoise = WhiteNoise.none;

  // Getters
  int get focusMinutes => _focusMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  int get longBreakInterval => _longBreakInterval;
  bool get soundEnabled => _soundEnabled;
  bool get notificationEnabled => _notificationEnabled;
  bool get autoStartNext => _autoStartNext;
  SoundType get soundType => _soundType;
  WhiteNoise get whiteNoise => _whiteNoise;

  String get whiteNoiseLabel {
    switch (_whiteNoise) {
      case WhiteNoise.none: return '关闭';
      case WhiteNoise.rain: return '🌧️ 雨声';
      case WhiteNoise.forest: return '🌲 森林';
      case WhiteNoise.cafe: return '☕ 咖啡厅';
    }
  }

  String get soundTypeLabel {
    switch (_soundType) {
      case SoundType.bell: return '🔔 铃声';
      case SoundType.chime: return '🎵 风铃';
      case SoundType.piano: return '🎹 钢琴';
    }
  }

  Future<void> loadSettings() async {
    final data = await _api.getSettings();
    _focusMinutes = data['focusMinutes'] ?? 25;
    _shortBreakMinutes = data['shortBreakMinutes'] ?? 5;
    _longBreakMinutes = data['longBreakMinutes'] ?? 15;
    _longBreakInterval = data['longBreakInterval'] ?? 4;
    _soundEnabled = data['soundEnabled'] ?? true;
    _notificationEnabled = data['notificationEnabled'] ?? true;
    _autoStartNext = data['autoStartNext'] ?? false;
    _soundType = _parseSoundType(data['soundType']);
    _whiteNoise = _parseWhiteNoise(data['whiteNoise']);
    notifyListeners();
  }

  SoundType _parseSoundType(String? v) {
    try { return SoundType.values.firstWhere((e) => e.name == v); }
    catch (_) { return SoundType.bell; }
  }

  WhiteNoise _parseWhiteNoise(String? v) {
    try { return WhiteNoise.values.firstWhere((e) => e.name == v); }
    catch (_) { return WhiteNoise.none; }
  }

  // 更新方法
  Future<void> setFocusMinutes(int v) async { _focusMinutes = v; notifyListeners(); await _api.updateSetting('focusMinutes', v); }
  Future<void> setShortBreakMinutes(int v) async { _shortBreakMinutes = v; notifyListeners(); await _api.updateSetting('shortBreakMinutes', v); }
  Future<void> setLongBreakMinutes(int v) async { _longBreakMinutes = v; notifyListeners(); await _api.updateSetting('longBreakMinutes', v); }
  Future<void> setLongBreakInterval(int v) async { _longBreakInterval = v; notifyListeners(); await _api.updateSetting('longBreakInterval', v); }
  Future<void> setSoundEnabled(bool v) async { _soundEnabled = v; notifyListeners(); await _api.updateSetting('soundEnabled', v); }
  Future<void> setNotificationEnabled(bool v) async { _notificationEnabled = v; notifyListeners(); await _api.updateSetting('notificationEnabled', v); }
  Future<void> setAutoStartNext(bool v) async { _autoStartNext = v; notifyListeners(); await _api.updateSetting('autoStartNext', v); }
  Future<void> setSoundType(SoundType v) async { _soundType = v; notifyListeners(); await _api.updateSetting('soundType', v.name); }
  Future<void> setWhiteNoise(WhiteNoise v) async { _whiteNoise = v; notifyListeners(); await _api.updateSetting('whiteNoise', v.name); }
}
