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
    _isLoading = true;
    notifyListeners();

    try {
      _allTasks = await _repository.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    final trimmed = task.copyWith(title: task.title.trim());
    _validate(trimmed);

    final exists = await _repository.existsTitle(trimmed.title);
    if (exists) {
      throw const ValidationException('Ya existe una tarea con ese título.');
    }

    try {
      await _repository.insert(trimmed);
    } on DatabaseException {
      throw const ValidationException('Ya existe una tarea con ese título.');
    }

    await loadTasks();
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
