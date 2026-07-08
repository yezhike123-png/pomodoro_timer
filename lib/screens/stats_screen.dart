import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';

/// 统计页面 —— 展示番茄完成数据
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, stats, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('📊 统计'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 三列数据卡片
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.today,
                        label: '今日番茄',
                        value: '${stats.todayCount}',
                        color: const Color(0xFFE74C3C),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.calendar_view_week,
                        label: '本周番茄',
                        value: '${stats.weekCount}',
                        color: const Color(0xFF2ECC71),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        label: '累计专注',
                        value: stats.formattedTotalTime,
                        color: const Color(0xFF3498DB),
                        isTime: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 历史记录列表
                if (stats.sessions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            '还没有番茄记录\n开始你的第一个番茄吧！🍅',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '最近记录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            itemCount: stats.sessions.length,
                            itemBuilder: (context, index) {
                              final session = stats.sessions[index];
                              final mins = (session['durationMinutes'] as int?) ?? 0;
                              final dateStr = (session['date'] as String?) ?? '';
                              final date = DateTime.tryParse(dateStr) ?? DateTime.now();
                              return ListTile(
                                leading: const Icon(Icons.check_circle,
                                    color: Color(0xFFE74C3C)),
                                title: Text('专注 $mins 分钟'),
                                trailing: Text(
                                  _formatDate(date),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 格式化日期显示
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays} 天前';

    return '${date.month}/${date.day}';
  }
}

/// 统计数据卡片
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isTime;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isTime ? 14 : 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
