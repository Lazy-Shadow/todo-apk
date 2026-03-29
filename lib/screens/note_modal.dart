import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteModal extends StatefulWidget {
  final Note? note;

  const NoteModal({super.key, this.note});

  @override
  State<NoteModal> createState() => _NoteModalState();
}

class _NoteModalState extends State<NoteModal> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Note' : 'New Note',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (isEditing)
                      IconButton(
                        onPressed: () {
                          final provider = context.read<NoteProvider>();
                          provider.togglePin(widget.note!.id);
                        },
                        icon: Icon(
                          widget.note!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          color: widget.note!.isPinned ? Colors.purple : Colors.grey,
                        ),
                      ),
                    if (isEditing)
                      IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    minLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Start writing...',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Note'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty && _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title or content')),
      );
      return;
    }

    final provider = context.read<NoteProvider>();
    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      isPinned: widget.note?.isPinned ?? false,
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEditing) {
      provider.updateNote(note);
    } else {
      provider.addNote(note);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditing ? 'Note updated' : 'Note saved')),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = context.read<NoteProvider>();
              provider.deleteNote(widget.note!.id);
              Navigator.pop(ctx);
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
