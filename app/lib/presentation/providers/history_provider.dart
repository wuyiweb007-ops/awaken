import 'package:flutter/material.dart';
import '../../data/models/daily_record.dart';
import '../../data/services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService _storage;

  HistoryProvider(this._storage);

  /// Loads a record by date key. Always returns a record (may be empty).
  DailyRecord loadRecord(String dateKey) => _storage.loadRecord(dateKey);

  /// All stored date keys sorted descending
  List<String> get allKeys => _storage.allDateKeys();

  /// Nearest key that has a non-empty record, starting from daysAgo.
  /// Returns null if none found.
  String? nearestWithRecord(int fromDaysAgo) {
    for (int i = fromDaysAgo; i < 365; i++) {
      final date = DateTime.now().subtract(Duration(days: i + 1));
      final key = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      final rec = _storage.loadRecord(key);
      if (!rec.isEmpty) return key;
    }
    return null;
  }
}
