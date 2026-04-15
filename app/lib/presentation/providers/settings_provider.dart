import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/notification_service.dart';

enum AppThemeMode { light, dark, system }

class SettingsProvider extends ChangeNotifier {
  final NotificationService _notifService;

  SettingsProvider(this._notifService);

  AppThemeMode _themeMode = AppThemeMode.system;
  bool _morningEnabled = false;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 30);
  bool _eveningEnabled = false;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 30);
  int _defaultTab = 0; // 0 = today, 1 = history

  AppThemeMode get themeMode => _themeMode;
  bool get morningEnabled => _morningEnabled;
  TimeOfDay get morningTime => _morningTime;
  bool get eveningEnabled => _eveningEnabled;
  TimeOfDay get eveningTime => _eveningTime;
  int get defaultTab => _defaultTab;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final tm = prefs.getString('themeMode') ?? 'system';
    _themeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == tm,
      orElse: () => AppThemeMode.system,
    );
    _morningEnabled = prefs.getBool('morningEnabled') ?? false;
    _morningTime = TimeOfDay(
      hour: prefs.getInt('morningHour') ?? 7,
      minute: prefs.getInt('morningMinute') ?? 30,
    );
    _eveningEnabled = prefs.getBool('eveningEnabled') ?? false;
    _eveningTime = TimeOfDay(
      hour: prefs.getInt('eveningHour') ?? 21,
      minute: prefs.getInt('eveningMinute') ?? 30,
    );
    _defaultTab = prefs.getInt('defaultTab') ?? 0;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> setMorningEnabled(bool enabled) async {
    _morningEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('morningEnabled', enabled);
    if (enabled) {
      await _notifService.scheduleMorning(_morningTime);
    } else {
      await _notifService.cancelMorning();
    }
  }

  Future<void> setMorningTime(TimeOfDay t) async {
    _morningTime = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('morningHour', t.hour);
    await prefs.setInt('morningMinute', t.minute);
    if (_morningEnabled) await _notifService.scheduleMorning(t);
  }

  Future<void> setEveningEnabled(bool enabled) async {
    _eveningEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('eveningEnabled', enabled);
    if (enabled) {
      await _notifService.scheduleEvening(_eveningTime);
    } else {
      await _notifService.cancelEvening();
    }
  }

  Future<void> setEveningTime(TimeOfDay t) async {
    _eveningTime = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('eveningHour', t.hour);
    await prefs.setInt('eveningMinute', t.minute);
    if (_eveningEnabled) await _notifService.scheduleEvening(t);
  }

  Future<void> setDefaultTab(int tab) async {
    _defaultTab = tab;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultTab', tab);
  }
}
