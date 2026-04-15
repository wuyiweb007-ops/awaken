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

  TodayProvider(this._storage);

  late DailyRecord _record;
  bool _justSaved = false;

  DailyRecord get record => _record;
  bool get justSaved => _justSaved;

  void loadToday() {
    _record = _storage.loadRecord(todayKey());
    notifyListeners();
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
    final blocks = List<TimeBlock>.from(_record.planBlocks)
      ..add(TimeBlock(id: _uuid.v4()));
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
    final blocks = List<TimeBlock>.from(_record.actualBlocks)
      ..add(TimeBlock(id: _uuid.v4()));
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

  // ── SAVE DAY ────────────────────────────────────────────────

  Future<void> saveDay() async {
    final saved = _record.copyWith(isSaved: true, savedAt: DateTime.now());
    _record = saved;
    await _storage.saveRecord(saved);
    _justSaved = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), () {
      _justSaved = false;
      notifyListeners();
    });
  }

  // ── Internal ────────────────────────────────────────────────

  void _update(DailyRecord updated) {
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
    super.dispose();
  }
}
