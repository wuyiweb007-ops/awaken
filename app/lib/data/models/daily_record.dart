import 'dart:convert';
import 'todo_item.dart';
import 'time_block.dart';

class DailyRecord {
  final String dateKey;          // "YYYY-MM-DD"
  final List<TodoItem> todos;
  final List<TimeBlock> planBlocks;
  final List<TimeBlock> actualBlocks;
  final String reflection;
  final bool isSaved;            // user clicked "记下这一天"
  final DateTime? savedAt;

  const DailyRecord({
    required this.dateKey,
    this.todos = const [],
    this.planBlocks = const [],
    this.actualBlocks = const [],
    this.reflection = '',
    this.isSaved = false,
    this.savedAt,
  });

  factory DailyRecord.empty(String dateKey) => DailyRecord(dateKey: dateKey);

  DailyRecord copyWith({
    String? dateKey,
    List<TodoItem>? todos,
    List<TimeBlock>? planBlocks,
    List<TimeBlock>? actualBlocks,
    String? reflection,
    bool? isSaved,
    DateTime? savedAt,
  }) =>
      DailyRecord(
        dateKey: dateKey ?? this.dateKey,
        todos: todos ?? this.todos,
        planBlocks: planBlocks ?? this.planBlocks,
        actualBlocks: actualBlocks ?? this.actualBlocks,
        reflection: reflection ?? this.reflection,
        isSaved: isSaved ?? this.isSaved,
        savedAt: savedAt ?? this.savedAt,
      );

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'todos': todos.map((e) => e.toJson()).toList(),
        'planBlocks': planBlocks.map((e) => e.toJson()).toList(),
        'actualBlocks': actualBlocks.map((e) => e.toJson()).toList(),
        'reflection': reflection,
        'isSaved': isSaved,
        'savedAt': savedAt?.toIso8601String(),
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        dateKey: (json['dateKey'] as String?) ?? '',
        todos: (json['todos'] as List<dynamic>? ?? [])
            .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        planBlocks: (json['planBlocks'] as List<dynamic>? ?? [])
            .map((e) => TimeBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
        actualBlocks: (json['actualBlocks'] as List<dynamic>? ?? [])
            .map((e) => TimeBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
        reflection: (json['reflection'] as String?) ?? '',
        isSaved: (json['isSaved'] as bool?) ?? false,
        savedAt: json['savedAt'] != null
            ? DateTime.tryParse(json['savedAt'] as String)
            : null,
      );

  String toJsonString() => jsonEncode(toJson());

  factory DailyRecord.fromJsonString(String s) =>
      DailyRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);

  bool get isEmpty =>
      todos.isEmpty &&
      planBlocks.isEmpty &&
      actualBlocks.isEmpty &&
      reflection.isEmpty;
}
