import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';

class NoteProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Note> _notes = [];
  List<Activity> _activities = [];
  String _searchQuery = '';

  NoteProvider(this._storage);

  List<Note> get notes => _notes;

  List<Note> get filteredNotes {
    List<Note> result = _notes;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((n) =>
          n.title.toLowerCase().contains(query) ||
          n.content.toLowerCase().contains(query)).toList();
    }

    result.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadData() async {
    _notes = await _storage.loadNotes();
    _activities = await _storage.loadActivities();
    _sortNotes();
    notifyListeners();
  }

  void _sortNotes() {
    _notes.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
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

  Future<void> addNote(Note note) async {
    _notes.add(note);
    _logActivity('created', note.title, 'note', newData: note.toJson());
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      final oldNote = _notes[index];
      _notes[index] = note;
      _logActivity('updated', note.title, 'note',
          originalData: oldNote.toJson(), newData: note.toJson());
      _sortNotes();
      await _storage.saveNotes(_notes);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    final note = _notes.firstWhere((n) => n.id == id);
    _notes.removeWhere((n) => n.id == id);
    _logActivity('deleted', note.title, 'note', originalData: note.toJson());
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final note = _notes[index];
      final updated = note.copyWith(isPinned: !note.isPinned);
      _notes[index] = updated;
      _logActivity(updated.isPinned ? 'pinned' : 'unpinned', note.title, 'note',
          originalData: note.toJson(), newData: updated.toJson());
      _sortNotes();
      await _storage.saveNotes(_notes);
      notifyListeners();
    }
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Note> get recentNotes {
    final sorted = _notes.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }
}
