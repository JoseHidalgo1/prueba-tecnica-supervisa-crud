import 'package:flutter/foundation.dart';
import 'package:supervisa_task_manager/database/database_service.dart';
import 'package:supervisa_task_manager/models/task.dart';

class TaskRepository {
  TaskRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<List<Task>> getAll() async {
    debugPrint('[REPO getAll] START');
    final db = await _databaseService.database;
    debugPrint('[REPO getAll] db obtained');

    final rows = await db.rawQuery('''
      SELECT id, title, description, due_date, priority, status
      FROM tasks
      ORDER BY due_date ASC, title ASC
    ''');
    debugPrint('[REPO getAll] rawQuery returned ${rows.length} rows');

    final tasks = rows.map((row) => Task.fromMap(row)).toList();
    debugPrint('[REPO getAll] mapped ${tasks.length} tasks');
    return tasks;
  }

  Future<int> insert(Task task) async {
    debugPrint('[REPO insert] getting database...');
    final db = await _databaseService.database;
    debugPrint('[REPO insert] database obtained');

    final map = task.toMap();
    map.remove('id');
    debugPrint('[REPO insert] map=$map');

    try {
      final id = await db.insert('tasks', map);
      debugPrint('[REPO insert] db.insert() succeeded, id=$id');
      return id;
    } catch (e, stack) {
      debugPrint('[REPO insert] db.insert() FAILED: $e\n$stack');
      rethrow;
    }
  }

  Future<int> update(Task task) async {
    final db = await _databaseService.database;
    final map = task.toMap();
    map.remove('id');
    return db.update(
      'tasks',
      map,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseService.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> existsTitle(String title, {int? excludeId}) async {
    final db = await _databaseService.database;

    if (excludeId != null) {
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM tasks WHERE LOWER(title) = LOWER(?) AND id != ?',
        [title, excludeId],
      );
      final count = result.first['count'] as num;
      return count > 0;
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE LOWER(title) = LOWER(?)',
      [title],
    );
    final count = result.first['count'] as num;
    return count > 0;
  }
}
