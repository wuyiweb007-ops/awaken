import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_record.dart';

class StorageService {
  static const String _boxName = 'daily_records';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Save or update a DailyRecord (keyed by dateKey "YYYY-MM-DD")
  Future<void> saveRecord(DailyRecord record) async {
    await _box.put(record.dateKey, record.toJsonString());
  }

  /// Load by date key — returns empty record if not found
  DailyRecord loadRecord(String dateKey) {
    final raw = _box.get(dateKey);
    if (raw == null) return DailyRecord.empty(dateKey);
    try {
      return DailyRecord.fromJsonString(raw);
    } catch (_) {
      return DailyRecord.empty(dateKey);
    }
  }

  /// All stored date keys sorted descending (newest first)
  List<String> allDateKeys() {
    final keys = _box.keys.cast<String>().toList();
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }

  /// Delete everything
  Future<void> clearAll() async => _box.clear();
}
