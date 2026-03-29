class Task {
  final String id;
  String title;
  String? description;
  String? category;
  int priority;
  DateTime? dueDate;
  String? dueTime;
  bool isCompleted;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.priority = 0,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: json['category'],
        priority: json['priority'] ?? 0,
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        dueTime: json['dueTime'],
        isCompleted: json['isCompleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? priority,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    DateTime? createdAt,
  }) =>
      Task(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        priority: priority ?? this.priority,
        dueDate: dueDate ?? this.dueDate,
        dueTime: dueTime ?? this.dueTime,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
      );
}
