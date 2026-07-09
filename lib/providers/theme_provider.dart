import 'package:flutter/material.dart';

/// 主题模式
enum ThemeModeType { light, dark, system }

/// 深色/浅色主题管理
class ThemeProvider extends ChangeNotifier {
  ThemeModeType _mode = ThemeModeType.system;

  ThemeModeType get mode => _mode;
  bool get isDark => _mode == ThemeModeType.dark;

  void setMode(ThemeModeType mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggle() {
    _mode = _mode == ThemeModeType.dark ? ThemeModeType.light : ThemeModeType.dark;
    notifyListeners();
  }

  /// 根据模式返回 Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (_mode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }

  String get label {
    switch (_mode) {
      case ThemeModeType.light:
        return '浅色';
      case ThemeModeType.dark:
        return '深色';
      case ThemeModeType.system:
        return '跟随系统';
    }
  }
}
