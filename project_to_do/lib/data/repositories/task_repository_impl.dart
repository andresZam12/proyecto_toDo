import '../../domain/entities/task.dart';
import '../../domain/entities/task_file.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;
  TaskRepositoryImpl(this._remote);

  @override
  Future<List<Task>> getTodayTasks() => _remote.getTodayTasks();

  @override
  Future<List<Task>> getAllTasks() => _remote.getAllTasks();

  @override
  Future<void> createTask(Task task) {
    final model = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      dueTime: task.dueTime,
      dueDate: task.dueDate,
      isDone: task.isDone,
      createdAt: task.createdAt,
    );
    return _remote.createTask(model);
  }

  @override
  Future<void> toggleDone(String taskId, bool isDone) =>
      _remote.toggleDone(taskId, isDone);

  @override
  Future<void> deleteTask(String taskId) => _remote.deleteTask(taskId);

  @override
  Future<List<TaskFile>> getFilesForTask(String taskId) =>
      _remote.getFilesForTask(taskId);

  @override
  Future<TaskFile> uploadFile({
    required String taskId,
    required String fileName,
    required List<int> fileBytes,
  }) =>
      _remote.uploadFile(
        taskId: taskId,
        fileName: fileName,
        fileBytes: fileBytes,
      );
}