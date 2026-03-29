class Note {
  final String id;
  String title;
  String content;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        isPinned: json['isPinned'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}
