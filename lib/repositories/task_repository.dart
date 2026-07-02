import 'package:supervisa_task_manager/database/hive_service.dart';
import 'package:supervisa_task_manager/models/task.dart';

class TaskRepository {
  TaskRepository({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  final HiveService _hiveService;

  Future<List<Task>> getAll() async {
    final box = await _hiveService.box;
    return box.values.toList()
      ..sort((a, b) {
        final dateCmp = a.dueDate.compareTo(b.dueDate);
        if (dateCmp != 0) return dateCmp;
        return a.title.compareTo(b.title);
      });
  }

  Future<int> insert(Task task) async {
    final box = await _hiveService.box;
    final key = await box.add(task);
    await box.put(key, task.copyWith(id: key));
    return key;
  }

  Future<int> update(Task task) async {
    final box = await _hiveService.box;
    final id = task.id;
    if (id == null) return 0;
    final exists = box.containsKey(id);
    if (!exists) return 0;
    await box.put(id, task);
    return 1;
  }

  Future<int> delete(int id) async {
    final box = await _hiveService.box;
    final exists = box.containsKey(id);
    if (!exists) return 0;
    await box.delete(id);
    return 1;
  }

  Future<bool> existsTitle(String title, {int? excludeId}) async {
    final box = await _hiveService.box;
    return box.values.any((t) {
      if (excludeId != null && t.id == excludeId) return false;
      return t.title.toLowerCase() == title.toLowerCase();
    });
  }
}
