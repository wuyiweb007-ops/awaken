import '../../data/models/daily_record.dart';
import '../../data/models/time_block.dart';
import '../../data/models/todo_item.dart';
import 'date_helpers.dart';

String _timeBlockLine(TimeBlock b) {
  final hasTime = b.startTime.isNotEmpty || b.endTime.isNotEmpty;
  final span = hasTime ? '${b.startTime}-${b.endTime}' : '';
  final desc = b.description.trim();
  if (span.isEmpty) return desc.isEmpty ? '（空）' : desc;
  if (desc.isEmpty) return span;
  return '$span  $desc';
}

String _todoLine(TodoItem t) {
  final text = t.text.trim();
  if (text.isEmpty) return '';
  final p = t.priority.isEmpty ? '' : '[${t.priority}] ';
  return '$p$text';
}

/// 将当日记录格式化为纯文本，用于分享/导出。
String formatDailyRecordForExport(DailyRecord record) {
  final buf = StringBuffer();
  buf.writeln('觉醒笔记');
  buf.writeln(dateKeyToDisplay(record.dateKey));
  buf.writeln();

  buf.writeln('【待办】');
  final todoLines =
      record.todos.map(_todoLine).where((s) => s.isNotEmpty).toList();
  if (todoLines.isEmpty) {
    buf.writeln('（无）');
  } else {
    for (final line in todoLines) {
      buf.writeln(line);
    }
  }
  buf.writeln();

  buf.writeln('【计划】');
  if (record.planBlocks.isEmpty) {
    buf.writeln('（无）');
  } else {
    for (final b in record.planBlocks) {
      buf.writeln(_timeBlockLine(b));
    }
  }
  buf.writeln();

  buf.writeln('【实际】');
  if (record.actualBlocks.isEmpty) {
    buf.writeln('（无）');
  } else {
    for (final b in record.actualBlocks) {
      buf.writeln(_timeBlockLine(b));
    }
  }
  buf.writeln();

  buf.writeln('【省察感悟】');
  final ref = record.reflection.trim();
  buf.writeln(ref.isEmpty ? '（无）' : ref);

  return buf.toString();
}
