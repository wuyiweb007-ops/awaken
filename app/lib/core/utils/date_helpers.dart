import 'package:intl/intl.dart';

const List<String> _weekdays = ['一', '二', '三', '四', '五', '六', '日'];

String formatDate(DateTime date) {
  final fmt = DateFormat('yyyy-MM-dd');
  final wd = _weekdays[date.weekday - 1];
  return '${fmt.format(date)} 周$wd';
}

String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

String dateKeyToDisplay(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return key;
  final date = DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
  return formatDate(date);
}

DateTime keyToDate(String key) {
  final parts = key.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

bool isToday(String key) => key == dateKey(DateTime.now());
bool isYesterday(String key) =>
    key == dateKey(DateTime.now().subtract(const Duration(days: 1)));

/// Returns 'YYYY-MM-DD' for today
String todayKey() => dateKey(DateTime.now());
