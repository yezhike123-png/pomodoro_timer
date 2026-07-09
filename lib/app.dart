import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';

/// 应用根组件
class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  // ── 共享配色 ──
  static const Color tomatoRed = Color(0xFFE74C3C);
  static const Color leafGreen = Color(0xFF2ECC71);
  static const Color oceanBlue = Color(0xFF3498DB);
  static const Color bgLight = Color(0xFFF5F6FA);
  static const Color cardLight = Colors.white;
  static const Color bgDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().flutterThemeMode;

    return MaterialApp(
      title: '番茄计时器',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/stats': (context) => const StatsScreen(),
      },
    );
  }

  // ── 浅色主题 ──
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tomatoRed,
      brightness: Brightness.light,
      surface: bgLight,
    ),
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF2C3E50),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardLight,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
  );

  // ── 深色主题 ──
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: tomatoRed,
      brightness: Brightness.dark,
      surface: bgDark,
    ),
    scaffoldBackgroundColor: bgDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white70,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
