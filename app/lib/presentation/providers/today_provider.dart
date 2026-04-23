import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/daily_record.dart';
import '../../data/models/time_block.dart';
import '../../data/models/todo_item.dart';
import '../../data/services/storage_service.dart';

class TodayProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();
  Timer? _saveDebounce;
  Timer? _midnightTimer;

  TodayProvider(this._storage);

  late DailyRecord _record;

  /// 撤销栈，最多保存 30 步
  final List<DailyRecord> _undoStack = [];
  static const int _maxUndo = 30;

  DailyRecord get record => _record;
  bool get canUndo => _undoStack.isNotEmpty;

  void loadToday() {
    _record = _storage.loadRecord(todayKey());
    _undoStack.clear();
    notifyListeners();
    _scheduleMidnightArchive();
  }

  /// 撤销上一步操作
  void undo() {
    if (_undoStack.isEmpty) return;
    _record = _undoStack.removeLast();
    notifyListeners();
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 800), () {
      _storage.saveRecord(_record);
    });
  }

  // ── Midnight auto-archive ────────────────────────────────────

  void _scheduleMidnightArchive() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final msUntilMidnight = tomorrow.difference(now).inMilliseconds + 1000;
    _midnightTimer = Timer(Duration(milliseconds: msUntilMidnight), () {
      _archiveAndReset();
    });
  }

  void _archiveAndReset() {
    // 将当前记录标记为已归档并保存
    final archived = _record.copyWith(isSaved: true, savedAt: DateTime.now());
    _storage.saveRecord(archived);
    // 加载新的一天（空白记录）
    _record = _storage.loadRecord(todayKey());
    _undoStack.clear();
    notifyListeners();
    _scheduleMidnightArchive();
  }

  // ── TODO operations ─────────────────────────────────────────

  void addTodo() {
    final todos = List<TodoItem>.from(_record.todos)
      ..add(TodoItem(id: _uuid.v4(), text: ''));
    _update(_record.copyWith(todos: todos));
  }

  void updateTodoText(String id, String text) {
    final todos = _record.todos
        .map((t) => t.id == id ? t.copyWith(text: text) : t)
        .toList();
    _update(_record.copyWith(todos: todos));
  }

  void cycleTodoPriority(String id) {
    final todos = _record.todos.map((t) {
      if (t.id != id) return t;
      return t.copyWith(priority: t.nextPriority);
    }).toList();
    _update(_record.copyWith(todos: todos));
  }

  void removeTodo(String id) {
    final todos = _record.todos.where((t) => t.id != id).toList();
    _update(_record.copyWith(todos: todos));
  }

  /// Send a todo item into the plan section as a new TimeBlock
  void sendTodoPlan(TodoItem todo) {
    final block = TimeBlock(
      id: _uuid.v4(),
      description: todo.text,
    );
    final planBlocks = List<TimeBlock>.from(_record.planBlocks)..add(block);
    _update(_record.copyWith(planBlocks: planBlocks));
  }

  // ── PLAN block operations ───────────────────────────────────

  void addPlanBlock() {
    // 新块的开始时间默认等于上一条计划块的结束时间，方便连续录入
    final lastEndTime = _record.planBlocks.isNotEmpty
        ? _record.planBlocks.last.endTime
        : '';
    final blocks = List<TimeBlock>.from(_record.planBlocks)
      ..add(TimeBlock(id: _uuid.v4(), startTime: lastEndTime));
    _update(_record.copyWith(planBlocks: blocks));
  }

  void updatePlanBlock(String id, {String? startTime, String? endTime, String? description}) {
    final blocks = _record.planBlocks.map((b) {
      if (b.id != id) return b;
      return b.copyWith(
        startTime: startTime,
        endTime: endTime,
        description: description,
      );
    }).toList();
    _update(_record.copyWith(planBlocks: blocks));
  }

  void removePlanBlock(String id) {
    final blocks = _record.planBlocks.where((b) => b.id != id).toList();
    _update(_record.copyWith(planBlocks: blocks));
  }

  /// Copy a plan block into the actual section
  void movePlanToActual(TimeBlock plan) {
    final actual = TimeBlock(
      id: _uuid.v4(),
      startTime: plan.startTime,
      endTime: plan.endTime,
      description: plan.description.isEmpty
          ? plan.description
          : '完成${plan.description}',
      sourcePlanId: plan.id,
    );
    final actuals = List<TimeBlock>.from(_record.actualBlocks)..add(actual);
    _update(_record.copyWith(actualBlocks: actuals));
  }

  // ── ACTUAL block operations ─────────────────────────────────

  void addActualBlock() {
    // 新块的开始时间默认等于上一条实际块的结束时间，方便连续录入
    final lastEndTime = _record.actualBlocks.isNotEmpty
        ? _record.actualBlocks.last.endTime
        : '';
    final blocks = List<TimeBlock>.from(_record.actualBlocks)
      ..add(TimeBlock(id: _uuid.v4(), startTime: lastEndTime));
    _update(_record.copyWith(actualBlocks: blocks));
  }

  void updateActualBlock(String id, {String? startTime, String? endTime, String? description}) {
    final blocks = _record.actualBlocks.map((b) {
      if (b.id != id) return b;
      return b.copyWith(
        startTime: startTime,
        endTime: endTime,
        description: description,
      );
    }).toList();
    _update(_record.copyWith(actualBlocks: blocks));
  }

  void removeActualBlock(String id) {
    final blocks = _record.actualBlocks.where((b) => b.id != id).toList();
    _update(_record.copyWith(actualBlocks: blocks));
  }

  // ── REFLECTION ──────────────────────────────────────────────

  void updateReflection(String text) {
    _update(_record.copyWith(reflection: text));
  }

  // ── SAVE TO HISTORY ─────────────────────────────────────────

  /// 手动将今日记录存入历史（不重置今日数据，仅标记 isSaved = true）
  void saveToHistory() {
    final saved = _record.copyWith(isSaved: true, savedAt: DateTime.now());
    _record = saved;
    notifyListeners();
    _storage.saveRecord(saved);
  }

  // ── Internal ────────────────────────────────────────────────

  void _update(DailyRecord updated, {bool pushUndo = true}) {
    if (pushUndo) {
      _undoStack.add(_record);
      if (_undoStack.length > _maxUndo) _undoStack.removeAt(0);
    }
    _record = updated;
    notifyListeners();
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 800), () {
      _storage.saveRecord(_record);
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }
}
