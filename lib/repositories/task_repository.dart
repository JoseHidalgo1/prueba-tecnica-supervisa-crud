import 'package:supervisa_task_manager/database/database_service.dart';
import 'package:supervisa_task_manager/models/task.dart';

class TaskRepository {
  TaskRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  Future<List<Task>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.rawQuery('''
      SELECT id, title, description, due_date, priority, status
      FROM tasks
      ORDER BY due_date ASC, title ASC
    ''');

    return rows.map((row) => Task.fromMap(row)).toList();
  }

  Future<int> insert(Task task) async {
    final db = await _databaseService.database;
    final map = task.toMap();
    map.remove('id');
    return db.insert('tasks', map);
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
