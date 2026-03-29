import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<dynamic> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final storage = StorageService();
    await storage.init();
    final activities = await storage.loadActivities();
    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _ActivityItem(
          type: activity.type,
          title: activity.title,
          itemType: activity.itemType,
          timestamp: activity.timestamp,
        );
      },
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String type;
  final String title;
  final String itemType;
  final DateTime timestamp;

  const _ActivityItem({
    required this.type,
    required this.title,
    required this.itemType,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon();
    final color = _getColor();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          '${_capitalize(type)} $itemType • ${_formatTime(timestamp)}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case 'created':
        return Icons.add_circle;
      case 'updated':
        return Icons.edit;
      case 'deleted':
        return Icons.delete;
      case 'completed':
        return Icons.check_circle;
      case 'uncompleted':
        return Icons.undo;
      case 'pinned':
        return Icons.push_pin;
      case 'unpinned':
        return Icons.push_pin_outlined;
      default:
        return Icons.info;
    }
  }

  Color _getColor() {
    switch (type) {
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      case 'deleted':
        return Colors.red;
      case 'completed':
        return Colors.green;
      case 'uncompleted':
        return Colors.orange;
      case 'pinned':
        return Colors.purple;
      case 'unpinned':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return '${time.day}/${time.month}/${time.year}';
  }
}
