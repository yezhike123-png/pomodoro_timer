import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pomodoro_timer/app.dart';
import 'package:pomodoro_timer/providers/timer_provider.dart';
import 'package:pomodoro_timer/providers/settings_provider.dart';
import 'package:pomodoro_timer/providers/stats_provider.dart';

void main() {
  testWidgets('App 启动测试', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => StatsProvider()),
          ChangeNotifierProvider(create: (_) => TimerProvider()),
        ],
        child: const PomodoroApp(),
      ),
    );
    await tester.pump();
    // 验证首页标题存在
    expect(find.text('🍅 番茄计时器'), findsOneWidget);
    // 验证开始按钮存在
    expect(find.text('开始专注'), findsOneWidget);
  });
}
