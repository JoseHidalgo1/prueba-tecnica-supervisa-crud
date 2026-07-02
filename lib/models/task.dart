enum TaskPriority {
  alta,
  media,
  baja;

  String get label {
    switch (this) {
      case TaskPriority.alta:
        return 'Alta';
      case TaskPriority.media:
        return 'Media';
      case TaskPriority.baja:
        return 'Baja';
    }
  }
}

enum TaskStatus {
  pendiente,
  enProgreso,
  completada;

  String get label {
    switch (this) {
      case TaskStatus.pendiente:
        return 'Pendiente';
      case TaskStatus.enProgreso:
        return 'En progreso';
      case TaskStatus.completada:
        return 'Completada';
    }
  }
}

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;

  const Task({
    this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = TaskPriority.media,
    this.status = TaskStatus.pendiente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      priority: TaskPriority.values.byName(map['priority'] as String),
      status: TaskStatus.values.byName(map['status'] as String),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, priority: ${priority.name}, status: ${status.name})';
  }
}
