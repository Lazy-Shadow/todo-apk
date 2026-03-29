import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_modal.dart';

class TodosScreen extends StatelessWidget {
  const TodosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.filteredTasks;

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  taskProvider.searchQuery.isNotEmpty
                      ? 'No tasks found'
                      : taskProvider.filter == FilterType.completed
                          ? 'No completed tasks'
                          : taskProvider.filter == FilterType.active
                              ? 'No active tasks'
                              : 'No tasks yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(
                task: task,
                onToggle: () => taskProvider.toggleTask(task.id),
                onEdit: () => _showTaskModal(context, task: task),
                onDelete: () => _confirmDelete(context, taskProvider, task),
              ),
            );
          },
        );
      },
    );
  }

  void _showTaskModal(BuildContext context, {Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskModal(task: task),
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
