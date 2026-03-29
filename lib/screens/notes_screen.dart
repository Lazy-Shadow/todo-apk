import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import 'note_modal.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        final notes = noteProvider.filteredNotes;

        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_alt, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  noteProvider.searchQuery.isNotEmpty ? 'No notes found' : 'No notes yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              onTap: () => _showNoteModal(context, note: note),
              onDelete: () => _confirmDelete(context, noteProvider, note),
              onTogglePin: () => noteProvider.togglePin(note.id),
            );
          },
        );
      },
    );
  }

  void _showNoteModal(BuildContext context, {Note? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteModal(note: note),
    );
  }

  void _confirmDelete(BuildContext context, NoteProvider provider, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteNote(note.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
