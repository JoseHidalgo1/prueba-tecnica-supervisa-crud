import 'package:hive_ce/hive_ce.dart';

import 'package:supervisa_task_manager/models/task.dart';
import 'package:supervisa_task_manager/models/task_adapter.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  static const _boxName = 'tasks';

  Box<Task>? _box;

  static bool _adaptersRegistered = false;

  Future<Box<Task>> get box async {
    if (_box != null) return _box!;
    _box = await Hive.openBox<Task>(_boxName);
    return _box!;
  }

  static void registerAdapters() {
    if (_adaptersRegistered) return;
    Hive.registerAdapter(TaskAdapter());
    _adaptersRegistered = true;
  }

  Future<void> clear() async {
    final b = await box;
    await b.clear();
  }

  void resetForTesting() {
    _box = null;
  }
}
