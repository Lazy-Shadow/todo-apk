import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskModal extends StatefulWidget {
  final Task? task;

  const TaskModal({super.key, this.task});

  @override
  State<TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<TaskModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  int _priority = 0;
  DateTime? _dueDate;
  String? _dueTime;
  bool _showCalendar = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _categoryController = TextEditingController(text: widget.task?.category ?? '');
    _priority = widget.task?.priority ?? 0;
    _dueDate = widget.task?.dueDate;
    _dueTime = widget.task?.dueTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Task' : 'Add Task',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.folder),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityBtn(label: 'Low', priority: 0, selected: _priority, onTap: () => setState(() => _priority = 0)),
                const SizedBox(width: 8),
                _PriorityBtn(label: 'Medium', priority: 1, selected: _priority, onTap: () => setState(() => _priority = 1)),
                const SizedBox(width: 8),
                _PriorityBtn(label: 'High', priority: 2, selected: _priority, onTap: () => setState(() => _priority = 2)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _showCalendar = !_showCalendar),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(_dueDate != null
                        ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}${_dueTime != null ? ' $_dueTime' : ''}'
                        : 'No date'),
                    const Spacer(),
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() {
                          _dueDate = null;
                          _dueTime = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),
            if (_showCalendar) ...[
              const SizedBox(height: 8),
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _dueDate ?? DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(_dueDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _dueDate = selectedDay;
                    _showCalendar = false;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.3), shape: BoxShape.circle),
                ),
              ),
              if (_dueDate != null) ...[
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => _dueTime = value.isEmpty ? null : value,
                  decoration: InputDecoration(
                    labelText: 'Time (optional)',
                    hintText: 'e.g., 14:30',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEditing ? 'Update Task' : 'Add Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final provider = context.read<TaskProvider>();
    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      dueTime: _dueTime,
      isCompleted: widget.task?.isCompleted ?? false,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      provider.updateTask(task);
    } else {
      provider.addTask(task);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditing ? 'Task updated' : 'Task added')),
    );
  }
}

class _PriorityBtn extends StatelessWidget {
  final String label;
  final int priority;
  final int selected;
  final VoidCallback onTap;

  const _PriorityBtn({
    required this.label,
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.grey, Colors.orange, Colors.red];
    final isSelected = priority == selected;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors[priority].withValues(alpha: 0.1) : null,
            border: Border.all(color: isSelected ? colors[priority] : Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? colors[priority] : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
