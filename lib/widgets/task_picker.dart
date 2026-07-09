import 'package:flutter/material.dart';
import '../providers/task_provider.dart';

/// 顶部任务选择器 —— 下拉菜单 + 快捷添加
class TaskPicker extends StatelessWidget {
  final TaskItem? currentTask;
  final List<TaskItem> tasks;
  final ValueChanged<TaskItem?> onSelect;
  final VoidCallback onAdd;

  const TaskPicker({
    super.key,
    required this.currentTask,
    required this.tasks,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => _showTaskSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.task_alt_rounded,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  currentTask != null
                      ? '${currentTask!.title}  🍅×${currentTask!.pomodoroCount}'
                      : '点击选择任务（可选）',
                  style: TextStyle(
                    fontSize: 14,
                    color: currentTask != null ? null : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (currentTask != null)
                GestureDetector(
                  onTap: () => onSelect(null),
                  child: const Icon(Icons.close, size: 18, color: Colors.grey),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.45,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽条
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('选择任务', style: Theme.of(ctx).textTheme.titleMedium),
            ),
            // 无任务选项
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('不关联任务'),
              selected: currentTask == null,
              onTap: () {
                onSelect(null);
                Navigator.pop(ctx);
              },
            ),
            const Divider(indent: 16, endIndent: 16),
            // 任务列表
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('暂无任务，点击下方添加', style: TextStyle(color: Colors.grey)),
              ),
            ...tasks.map((task) => ListTile(
                  leading: Icon(
                    task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.completed ? Colors.green : Colors.grey,
                  ),
                  title: Text(task.title,
                      style: task.completed
                          ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
                          : null),
                  trailing: Text('🍅×${task.pomodoroCount}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  selected: currentTask?.id == task.id,
                  onTap: task.completed
                      ? null
                      : () {
                          onSelect(task);
                          Navigator.pop(ctx);
                        },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
