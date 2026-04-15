class TodoItem {
  final String id;
  final String text;
  final String priority; // 'A' | 'B' | 'C' | ''

  const TodoItem({
    required this.id,
    required this.text,
    this.priority = '',
  });

  TodoItem copyWith({String? id, String? text, String? priority}) => TodoItem(
        id: id ?? this.id,
        text: text ?? this.text,
        priority: priority ?? this.priority,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'priority': priority,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: (json['id'] as String?) ?? '',
        text: (json['text'] as String?) ?? '',
        priority: (json['priority'] as String?) ?? '',
      );

  /// Cycles A → B → C → ''
  String get nextPriority {
    switch (priority) {
      case '':
        return 'A';
      case 'A':
        return 'B';
      case 'B':
        return 'C';
      default:
        return '';
    }
  }
}
