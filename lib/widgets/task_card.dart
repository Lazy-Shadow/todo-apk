import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => onToggle(),
              activeColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      _PriorityBadge(priority: task.priority),
                    ],
                  ),
                  if (task.description != null && task.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (task.dueDate != null) _DueDateBadge(dueDate: task.dueDate!, dueTime: task.dueTime),
                      if (task.category != null && task.category!.isNotEmpty) _CategoryBadge(category: task.category!),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.grey, Colors.orange, Colors.red];
    final labels = ['Low', 'Medium', 'High'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors[priority].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        labels[priority],
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colors[priority],
        ),
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final String? dueTime;

  const _DueDateBadge({required this.dueDate, this.dueTime});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(DateTime(now.year, now.month, now.day));
    final color = isOverdue ? Colors.red : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${dueDate.day}/${dueDate.month}${dueTime != null ? ' $dueTime' : ''}',
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder, size: 12, color: Colors.purple),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(fontSize: 12, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}
