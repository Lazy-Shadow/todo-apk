class Activity {
  final String id;
  final String type;
  final String title;
  final String itemType;
  final Map<String, dynamic>? originalData;
  final Map<String, dynamic>? newData;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.itemType,
    this.originalData,
    this.newData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'itemType': itemType,
        'originalData': originalData,
        'newData': newData,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'],
        type: json['type'],
        title: json['title'],
        itemType: json['itemType'],
        originalData: json['originalData'],
        newData: json['newData'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
