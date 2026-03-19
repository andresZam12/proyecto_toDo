import '../../domain/entities/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.category,
    super.dueTime,
    super.dueDate,
    required super.isDone,
    required super.createdAt,
  });

  // Convierte el JSON que llega de Supabase → TaskModel
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Other',
      // Supabase devuelve time como "HH:mm:ss", tomamos solo "HH:mm"
      dueTime: json['due_time'] != null
          ? (json['due_time'] as String).substring(0, 5)
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      isDone: json['is_done'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convierte TaskModel → Map para INSERT/UPDATE en Supabase
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'due_time': dueTime,
      'due_date': dueDate?.toIso8601String().split('T').first,
      'is_done': isDone,
    };
  }
}