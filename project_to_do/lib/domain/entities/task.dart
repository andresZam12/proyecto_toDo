class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final String? dueTime;
  final DateTime? dueDate;
  final bool isDone;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.dueTime,
    this.dueDate,
    required this.isDone,
    required this.createdAt,
  });

  // Devuelve una copia de la tarea con algunos campos cambiados
  Task copyWith({
    String? title,
    String? description,
    String? category,
    String? dueTime,
    DateTime? dueDate,
    bool? isDone,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueTime: dueTime ?? this.dueTime,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }
}