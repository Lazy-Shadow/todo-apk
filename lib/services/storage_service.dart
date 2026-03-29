import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/note.dart';
import '../models/activity.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _notesKey = 'notes';
  static const String _activitiesKey = 'activities';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Tasks
  Future<List<Task>> loadTasks() async {
    final String? data = _prefs.getString(_tasksKey);
    if (data == null) return [];
    try {
      final List<dynamic> parsed = jsonDecode(data);
      return parsed.map((e) => Task.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final String data = jsonEncode(tasks.map((e) => e.toJson()).toList());
    await _prefs.setString(_tasksKey, data);
  }

  // Notes
  Future<List<Note>> loadNotes() async {
    final String? data = _prefs.getString(_notesKey);
    if (data == null) return [];
    try {
      final List<dynamic> parsed = jsonDecode(data);
      return parsed.map((e) => Note.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final String data = jsonEncode(notes.map((e) => e.toJson()).toList());
    await _prefs.setString(_notesKey, data);
  }

  // Activities
  Future<List<Activity>> loadActivities() async {
    final String? data = _prefs.getString(_activitiesKey);
    if (data == null) return [];
    try {
      final List<dynamic> parsed = jsonDecode(data);
      return parsed.map((e) => Activity.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final String data = jsonEncode(activities.map((e) => e.toJson()).toList());
    await _prefs.setString(_activitiesKey, data);
  }
}
