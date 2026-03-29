import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../providers/weather_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WeatherCard(),
          const SizedBox(height: 16),
          _StatsCards(),
          const SizedBox(height: 16),
          _RecentTasks(),
          const SizedBox(height: 16),
          _RecentNotes(),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weather, _) {
        final current = weather.getCurrentWeather();
        final info = weather.getWeatherInfo(current['code'] as int? ?? 0);

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _getIconData(info['icon'] as String? ?? 'sunny'),
                      size: 48,
                      color: Color(info['color'] as int? ?? 0xFFFFC107),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current['temperature'] ?? '--'}°C',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          info['desc'] as String? ?? 'Loading...',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.purple.shade300),
                    const SizedBox(width: 4),
                    Text(
                      weather.locationName,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'partly_cloudy_day':
        return Icons.cloud;
      case 'foggy':
        return Icons.foggy;
      case 'rainy':
        return Icons.water_drop;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'shower':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'cloud':
      default:
        return Icons.cloud;
    }
  }
}

class _StatsCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _StatCard(
                  title: 'Total Tasks',
                  value: taskProvider.totalCount,
                  icon: Icons.task_alt,
                  color: Colors.blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(
                  title: 'Unfinished',
                  value: taskProvider.activeCount,
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(
                  title: 'Finished',
                  value: taskProvider.completedCount,
                  icon: Icons.check_circle,
                  color: Colors.green,
                )),
                const SizedBox(width: 12),
                Expanded(child: Consumer<NoteProvider>(
                  builder: (context, noteProvider, _) => _StatCard(
                    title: 'Total Notes',
                    value: noteProvider.notes.length,
                    icon: Icons.note,
                    color: Colors.purple,
                  ),
                )),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 40),
        ],
      ),
    );
  }
}

class _RecentTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, _) {
                final tasks = taskProvider.recentTasks;
                if (tasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No tasks yet', style: TextStyle(color: Colors.grey))),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: task.isCompleted,
                        activeColor: Colors.purple,
                        onChanged: (_) => taskProvider.toggleTask(task.id),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      subtitle: task.description != null && task.description!.isNotEmpty
                          ? Text(task.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<NoteProvider>(
              builder: (context, noteProvider, _) {
                final notes = noteProvider.recentNotes;
                if (notes.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No notes yet', style: TextStyle(color: Colors.grey))),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(note.isPinned ? Icons.push_pin : Icons.note, color: Colors.purple),
                      title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                      subtitle: Text(note.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
