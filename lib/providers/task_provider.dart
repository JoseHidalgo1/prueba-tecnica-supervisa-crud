import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:supervisa_task_manager/models/task.dart';
import 'package:supervisa_task_manager/repositories/task_repository.dart';

class ValidationException implements Exception {
  const ValidationException(this.message);

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

class TaskProvider extends ChangeNotifier {
  TaskProvider({TaskRepository? taskRepository})
      : _repository = taskRepository ?? TaskRepository();

  final TaskRepository _repository;

  List<Task> _allTasks = [];
  TaskPriority? _priorityFilter;
  TaskStatus? _statusFilter;
  bool _isLoading = false;

  List<Task> get tasks => _applyFilters();
  TaskPriority? get priorityFilter => _priorityFilter;
  TaskStatus? get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  bool get hasTasks => tasks.isNotEmpty;
  bool get hasActiveFilters =>
      _priorityFilter != null || _statusFilter != null;

  Future<void> loadTasks() async {
    debugPrint('[PROVIDER loadTasks] START');
    _isLoading = true;
    notifyListeners();
    debugPrint('[PROVIDER loadTasks] isLoading=true, notified');

    try {
      _allTasks = await _repository.getAll();
      debugPrint('[PROVIDER loadTasks] _repository.getAll() returned ${_allTasks.length} tasks');
    } catch (e, stack) {
      debugPrint('[PROVIDER loadTasks] ERROR: $e\n$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[PROVIDER loadTasks] END isLoading=false');
    }
  }

  Future<void> addTask(Task task) async {
    debugPrint('[PROVIDER addTask] START — title="${task.title}"');

    final trimmed = task.copyWith(title: task.title.trim());
    debugPrint('[PROVIDER addTask] trimmed title="${trimmed.title}"');

    _validate(trimmed);
    debugPrint('[PROVIDER addTask] _validate() OK');

    debugPrint('[PROVIDER addTask] checking existsTitle...');
    final exists = await _repository.existsTitle(trimmed.title);
    debugPrint('[PROVIDER addTask] existsTitle result=$exists');
    if (exists) {
      debugPrint('[PROVIDER addTask] title already exists — throwing');
      throw const ValidationException('Ya existe una tarea con ese título.');
    }

    try {
      debugPrint('[PROVIDER addTask] calling _repository.insert()...');
      final id = await _repository.insert(trimmed);
      debugPrint('[PROVIDER addTask] _repository.insert() returned id=$id');
    } on DatabaseException catch (e) {
      debugPrint('[PROVIDER addTask] DatabaseException caught: $e');
      throw const ValidationException('Ya existe una tarea con ese título.');
    } catch (e, stack) {
      debugPrint('[PROVIDER addTask] UNEXPECTED error during insert: $e\n$stack');
      rethrow;
    }

    debugPrint('[PROVIDER addTask] calling loadTasks()...');
    await loadTasks();
    debugPrint('[PROVIDER addTask] loadTasks() completed');
  }

  Future<void> updateTask(Task task) async {
    final trimmed = task.copyWith(title: task.title.trim());
    _validate(trimmed);

    final exists =
        await _repository.existsTitle(trimmed.title, excludeId: trimmed.id);
    if (exists) {
      throw const ValidationException('Ya existe una tarea con ese título.');
    }

    try {
      final affected = await _repository.update(trimmed);
      if (affected == 0) {
        throw const ValidationException(
            'No se encontró la tarea a actualizar.');
      }
    } on DatabaseException {
      throw const ValidationException('Ya existe una tarea con ese título.');
    }

    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    final affected = await _repository.delete(id);
    if (affected == 0) {
      throw const ValidationException('No se encontró la tarea a eliminar.');
    }
    await loadTasks();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _priorityFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  List<Task> _applyFilters() {
    var result = _allTasks.toList();

    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }

    return result;
  }

  void _validate(Task task) {
    if (task.title.isEmpty) {
      throw const ValidationException('El título es obligatorio.');
    }
    if (task.title.length > 150) {
      throw const ValidationException(
          'El título debe tener máximo 150 caracteres.');
    }
    if (task.description.length > 1000) {
      throw const ValidationException(
          'La descripción debe tener máximo 1000 caracteres.');
    }
  }
}
