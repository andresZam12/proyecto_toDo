import '../entities/task.dart';
import '../entities/task_file.dart';

// Define QUÉ operaciones existen.
// La capa data decide CÓMO hacerlas.
abstract class TaskRepository {
  Future<List<Task>> getTodayTasks();
  Future<List<Task>> getAllTasks();
  Future<void> createTask(Task task);
  Future<void> toggleDone(String taskId, bool isDone);
  Future<void> deleteTask(String taskId);
  Future<List<TaskFile>> getFilesForTask(String taskId);
  Future<TaskFile> uploadFile({
    required String taskId,
    required String fileName,
    required List<int> fileBytes,
  });
}