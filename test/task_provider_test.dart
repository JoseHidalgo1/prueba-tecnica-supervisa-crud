import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

import 'package:supervisa_task_manager/database/hive_service.dart';
import 'package:supervisa_task_manager/models/task.dart';
import 'package:supervisa_task_manager/providers/task_provider.dart';

void main() {
  setUpAll(() async {
    Hive.init('test_provider_dir');
    HiveService.registerAdapters();
  });

  tearDownAll(() async {
    await Hive.deleteFromDisk();
  });

  group('TaskProvider CRUD', () {
    late TaskProvider provider;

    setUp(() async {
      await HiveService.instance.clear();
      HiveService.instance.resetForTesting();
      provider = TaskProvider();
    });

    Future<void> createTask({
      String title = 'Test task',
      String description = 'Test description',
      TaskPriority priority = TaskPriority.alta,
    }) async {
      final task = Task(
        title: title,
        description: description,
        dueDate: DateTime(2026, 7, 15),
        priority: priority,
        status: TaskStatus.pendiente,
      );
      await provider.addTask(task);
    }

    test('addTask creates a task and appears in list', () async {
      await createTask(title: 'Mi primera tarea');

      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'Mi primera tarea');
    });

    test('addTask trims title', () async {
      await createTask(title: '  Tarea con espacios  ');

      expect(provider.tasks.first.title, 'Tarea con espacios');
    });

    test('addTask rejects duplicate title', () async {
      await createTask(title: 'Tarea única');

      expect(
        () => createTask(title: 'Tarea única'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('addTask rejects empty title', () async {
      expect(
        () => createTask(title: '   '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('updateTask modifies existing task', () async {
      await createTask(title: 'Original');
      final task = provider.tasks.first;

      final updated = task.copyWith(
        title: 'Modificado',
        priority: TaskPriority.baja,
      );
      await provider.updateTask(updated);

      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'Modificado');
      expect(provider.tasks.first.priority, TaskPriority.baja);
    });

    test('deleteTask removes task from list', () async {
      await createTask(title: 'Para borrar');
      expect(provider.tasks.length, 1);

      await provider.deleteTask(provider.tasks.first.id!);
      expect(provider.tasks.length, 0);
    });

    test('deleteTask throws for nonexistent id', () async {
      expect(
        () => provider.deleteTask(9999),
        throwsA(isA<ValidationException>()),
      );
    });

    test('tasks persist across provider instances', () async {
      await createTask(title: 'Persistente');

      final titles1 = provider.tasks.map((t) => t.title).toList();

      HiveService.instance.resetForTesting();
      final provider2 = TaskProvider();
      await provider2.loadTasks();

      final titles2 = provider2.tasks.map((t) => t.title).toList();
      expect(titles2, titles1);
    });

    test('filters work correctly', () async {
      await createTask(title: 'Alta prioridad');
      await createTask(title: 'Baja prioridad', priority: TaskPriority.baja);

      final tasks = provider.tasks;
      expect(tasks.length, 2);

      provider.setPriorityFilter(TaskPriority.alta);
      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'Alta prioridad');

      provider.clearFilters();
      expect(provider.tasks.length, 2);
    });

    test('multiple tasks are sorted by dueDate then title', () async {
      final later = Task(
        title: 'Z later',
        dueDate: DateTime(2026, 8, 1),
      );
      final earlier = Task(
        title: 'A earlier',
        dueDate: DateTime(2026, 6, 1),
      );
      final sameDateA = Task(
        title: 'A same date',
        dueDate: DateTime(2026, 7, 15),
      );
      final sameDateB = Task(
        title: 'B same date',
        dueDate: DateTime(2026, 7, 15),
      );

      await provider.addTask(later);
      await provider.addTask(earlier);
      await provider.addTask(sameDateB);
      await provider.addTask(sameDateA);

      final titles = provider.tasks.map((t) => t.title).toList();
      expect(titles, [
        'A earlier',
        'A same date',
        'B same date',
        'Z later',
      ]);
    });
  });
}
