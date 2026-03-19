import '../../domain/entities/task_file.dart';

class TaskFileModel extends TaskFile {
  const TaskFileModel({
    required super.id,
    required super.taskId,
    required super.fileName,
    required super.storagePath,
    required super.createdAt,
  });

  factory TaskFileModel.fromJson(Map<String, dynamic> json) {
    return TaskFileModel(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      fileName: json['file_name'] as String,
      storagePath: json['storage_path'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'file_name': fileName,
      'storage_path': storagePath,
    };
  }
}