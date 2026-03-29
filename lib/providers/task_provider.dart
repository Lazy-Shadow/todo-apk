import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';

enum FilterType { all, active, completed }

class TaskProvider extends ChangeNotifier {
  final StorageService _storage;
  Map<String, Task> _tasks = {};
  List<Activity> _activities = [];
  FilterType _filter = FilterType.all;
  String _searchQuery = '';

  TaskProvider(this._storage);

  List<Task> get tasks => _tasks.values.toList();

  List<Task> get filteredTasks {
    List<Task> result = tasks;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) =>
          t.title.toLowerCase().contains(query) ||
          (t.description?.toLowerCase().contains(query) ?? false)).toList();
    }

    if (_filter == FilterType.active) {
      result = result.where((t) => !t.isCompleted).toList();
    } else if (_filter == FilterType.completed) {
      result = result.where((t) => t.isCompleted).toList();
    }

    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (b.priority != a.priority) return b.priority - a.priority;
      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

  int get totalCount => _tasks.length;
  int get activeCount => _tasks.values.where((t) => !t.isCompleted).length;
  int get completedCount => _tasks.values.where((t) => t.isCompleted).length;

  FilterType get filter => _filter;
  String get searchQuery => _searchQuery;

  void setFilter(FilterType f) {
    _filter = f;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadData() async {
    final tasks = await _storage.loadTasks();
    _tasks = {for (var t in tasks) t.id: t};
    _activities = await _storage.loadActivities();
    notifyListeners();
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  void _logActivity(String type, String title, String itemType,
      {Map<String, dynamic>? originalData, Map<String, dynamic>? newData}) {
    final activity = Activity(
      id: _generateId(),
      type: type,
      title: title,
      itemType: itemType,
      originalData: originalData,
      newData: newData,
      timestamp: DateTime.now(),
    );
    _activities.insert(0, activity);
    if (_activities.length > 100) {
      _activities = _activities.sublist(0, 100);
    }
    _storage.saveActivities(_activities);
  }

  Future<void> addTask(Task task) async {
    _tasks[task.id] = task;
    _logActivity('created', task.title, 'task', newData: task.toJson());
    await _storage.saveTasks(tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final oldTask = _tasks[task.id];
    _tasks[task.id] = task;
    _logActivity('updated', task.title, 'task',
        originalData: oldTask?.toJson(), newData: task.toJson());
    await _storage.saveTasks(tasks);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    final task = _tasks[id];
    if (task != null) {
      _logActivity('deleted', task.title, 'task', originalData: task.toJson());
      _tasks.remove(id);
      await _storage.saveTasks(tasks);
      notifyListeners();
    }
  }

  Future<void> toggleTask(String id) async {
    final task = _tasks[id];
    if (task != null) {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      _tasks[id] = updated;
      _logActivity(
          updated.isCompleted ? 'completed' : 'uncompleted',
          task.title,
          'task',
          originalData: task.toJson(),
          newData: updated.toJson());
      await _storage.saveTasks(tasks);
      notifyListeners();
    }
  }

  Task? getTaskById(String id) => _tasks[id];

  List<Task> get recentTasks {
    final sorted = tasks.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }
}
