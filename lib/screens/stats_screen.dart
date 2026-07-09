import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, stats, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('📊 统计')),
          body: stats.sessions.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('还没有番茄记录\n开始你的第一个番茄吧！🍅',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ]))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── 数据卡片 ──
                    Row(children: [
                      Expanded(child: _Card(icon: Icons.today, label: '今日', value: '${stats.todayCount}',
                          color: const Color(0xFFE74C3C))),
                      const SizedBox(width: 10),
                      Expanded(child: _Card(icon: Icons.calendar_view_week, label: '本周', value: '${stats.weekCount}',
                          color: const Color(0xFF2ECC71))),
                      const SizedBox(width: 10),
                      Expanded(child: _Card(icon: Icons.timer, label: '累计', value: stats.formattedTotalTime,
                          color: const Color(0xFF3498DB), compact: true)),
                    ]),

                    const SizedBox(height: 24),
                    Text('本周番茄趋势', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),

                    // ── 柱状图 ──
                    SizedBox(
                      height: 200,
                      child: BarChart(_buildBarData(stats)),
                    ),

                    const SizedBox(height: 24),
                    Text('最近记录', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),

                    // ── 历史列表 ──
                    ...stats.sessions.take(10).map((s) {
                      final mins = (s['durationMinutes'] as int?) ?? 0;
                      final dateStr = (s['date'] as String?) ?? '';
                      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                      return ListTile(
                        leading: const Icon(Icons.check_circle, color: Color(0xFFE74C3C), size: 22),
                        title: Text('专注 $mins 分钟'),
                        trailing: Text(_fmtDate(date),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        dense: true,
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }

  BarChartData _buildBarData(StatsProvider stats) {
    final now = DateTime.now();
    // 本周一到周日
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final dayData = <int, int>{};
    for (final s in stats.sessions) {
      final d = DateTime.tryParse((s['date'] as String?) ?? '');
      if (d != null && d.isAfter(monday.subtract(const Duration(days: 1)))) {
        final key = d.weekday;
        dayData[key] = (dayData[key] ?? 0) + 1;
      }
    }

    final maxY = dayData.values.isEmpty ? 1.0
        : (dayData.values.reduce((a, b) => a > b ? a : b) + 1).toDouble();

    return BarChartData(
      maxY: maxY < 4 ? 4 : maxY,
      barGroups: weekDays.map((d) {
        final count = dayData[d.weekday] ?? 0;
        final isToday = d.weekday == now.weekday;
        return BarChartGroupData(
          x: d.weekday - 1,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: isToday ? const Color(0xFFE74C3C) : const Color(0xFFE74C3C).withAlpha(120),
              width: 24,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, _) {
            const labels = ['一', '二', '三', '四', '五', '六', '日'];
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(labels[v.toInt()], style: const TextStyle(fontSize: 12)),
            );
          },
        )),
        leftTitles: AxisTitles(sideTitles: SideTitles(
          showTitles: true, reservedSize: 24,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11)),
        )),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: true, drawVerticalLine: false,
          horizontalInterval: 1, getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withAlpha(30), strokeWidth: 1)),
      borderData: FlBorderData(show: false),
    );
  }

  String _fmtDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${d.month}/${d.day}';
  }
}

class _Card extends StatelessWidget {
  final IconData icon; final String label, value; final Color color; final bool compact;
  const _Card({required this.icon, required this.label, required this.value,
      required this.color, this.compact = false});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(children: [
          Icon(icon, color: color, size: 24), const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: compact ? 16 : 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ])),
  );
}
