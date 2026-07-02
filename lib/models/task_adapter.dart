import 'package:hive_ce/hive_ce.dart';

import 'package:supervisa_task_manager/models/task.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <dynamic>[];
    for (var i = 0; i < numFields; i++) {
      fields.add(reader.read());
    }
    return Task(
      id: fields[0] as int?,
      title: fields[1] as String,
      description: fields[2] as String,
      dueDate: fields[3] as DateTime,
      priority: TaskPriority.values[fields[4] as int],
      status: TaskStatus.values[fields[5] as int],
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeByte(6);
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.description);
    writer.write(obj.dueDate);
    writer.write(obj.priority.index);
    writer.write(obj.status.index);
  }
}
