import '../entities/task.dart';
import '../entities/task_file.dart';
import '../repositories/task_repository.dart';

// Cada caso de uso tiene un solo método execute()
// Así la UI solo llama lo que necesita, nada más

class GetTodayTasksUseCase {
  final TaskRepository _repo;
  GetTodayTasksUseCase(this._repo);
  Future<List<Task>> execute() => _repo.getTodayTasks();
}

class GetAllTasksUseCase {
  final TaskRepository _repo;
  GetAllTasksUseCase(this._repo);
  Future<List<Task>> execute() => _repo.getAllTasks();
}

class CreateTaskUseCase {
  final TaskRepository _repo;
  CreateTaskUseCase(this._repo);
  Future<void> execute(Task task) => _repo.createTask(task);
}

class ToggleDoneUseCase {
  final TaskRepository _repo;
  ToggleDoneUseCase(this._repo);
  Future<void> execute(String taskId, bool isDone) =>
      _repo.toggleDone(taskId, isDone);
}

class DeleteTaskUseCase {
  final TaskRepository _repo;
  DeleteTaskUseCase(this._repo);
  Future<void> execute(String taskId) => _repo.deleteTask(taskId);
}

class GetFilesForTaskUseCase {
  final TaskRepository _repo;
  GetFilesForTaskUseCase(this._repo);
  Future<List<TaskFile>> execute(String taskId) =>
      _repo.getFilesForTask(taskId);
}

class UploadFileUseCase {
  final TaskRepository _repo;
  UploadFileUseCase(this._repo);
  Future<TaskFile> execute({
    required String taskId,
    required String fileName,
    required List<int> fileBytes,
  }) =>
      _repo.uploadFile(
        taskId: taskId,
        fileName: fileName,
        fileBytes: fileBytes,
      );
}