// Utilities for parsing and computing time-block durations.

/// Parses "HH:MM" to (hour, minute). Returns null on failure.
(int hour, int minute)? parseTime(String s) {
  final parts = s.trim().split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return (h, m);
}

/// Computes duration in hours between two "HH:MM" strings.
/// Returns null if parsing fails or end <= start.
double? blockDurationHours(String start, String end) {
  final s = parseTime(start);
  final e = parseTime(end);
  if (s == null || e == null) return null;
  final sm = s.$1 * 60 + s.$2;
  final em = e.$1 * 60 + e.$2;
  if (em <= sm) return null;
  return (em - sm) / 60.0;
}

/// Formats hours to "X.X小时"
String formatHours(double h) {
  if (h == 0) return '0 小时';
  return '${h.toStringAsFixed(1)} 小时';
}

/// Validates that a string matches HH:MM
bool isValidTime(String s) => parseTime(s) != null;
