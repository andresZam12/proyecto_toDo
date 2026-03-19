import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_file.dart';
import '../../domain/usecases/task_usecases.dart';

class TaskProvider extends ChangeNotifier {
  final GetTodayTasksUseCase _getTodayTasks;
  final GetAllTasksUseCase _getAllTasks;
  final CreateTaskUseCase _createTask;
  final ToggleDoneUseCase _toggleDone;
  final DeleteTaskUseCase _deleteTask;
  final GetFilesForTaskUseCase _getFiles;
  final UploadFileUseCase _uploadFile;

  TaskProvider({
    required GetTodayTasksUseCase getTodayTasks,
    required GetAllTasksUseCase getAllTasks,
    required CreateTaskUseCase createTask,
    required ToggleDoneUseCase toggleDone,
    required DeleteTaskUseCase deleteTask,
    required GetFilesForTaskUseCase getFiles,
    required UploadFileUseCase uploadFile,
  })  : _getTodayTasks = getTodayTasks,
        _getAllTasks = getAllTasks,
        _createTask = createTask,
        _toggleDone = toggleDone,
        _deleteTask = deleteTask,
        _getFiles = getFiles,
        _uploadFile = uploadFile;

  // ── Estado ────────────────────────────────────────────────

  List<Task> todayTasks = [];
  List<Task> allTasks = [];
  List<TaskFile> currentFiles = [];
  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;

  // ── Getters para la pantalla principal ────────────────────

  int get doneToday => todayTasks.where((t) => t.isDone).length;
  int get totalToday => todayTasks.length;
  double get progressToday =>
      totalToday == 0 ? 0 : doneToday / totalToday;
  int get weeklyDone => allTasks.where((t) => t.isDone).length;
  int get weeklyPending => allTasks.where((t) => !t.isDone).length;

  // ── Cargar tareas ─────────────────────────────────────────

  Future<void> loadTodayTasks() async {
    _setLoading(true);
    try {
      todayTasks = await _getTodayTasks.execute();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllTasks() async {
    _setLoading(true);
    try {
      allTasks = await _getAllTasks.execute();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Crear tarea ───────────────────────────────────────────

  Future<void> addTask(Task task) async {
    _setLoading(true);
    try {
      await _createTask.execute(task);
      await loadTodayTasks();
      await loadAllTasks();
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Marcar como hecha ─────────────────────────────────────

  Future<void> toggleTask(String taskId, bool isDone) async {
    try {
      await _toggleDone.execute(taskId, isDone);
      // Actualiza la lista local sin volver a consultar Supabase
      todayTasks = todayTasks
          .map((t) => t.id == taskId ? t.copyWith(isDone: isDone) : t)
          .toList();
      allTasks = allTasks
          .map((t) => t.id == taskId ? t.copyWith(isDone: isDone) : t)
          .toList();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ── Eliminar tarea ────────────────────────────────────────

  Future<void> removeTask(String taskId) async {
    _setLoading(true);
    try {
      await _deleteTask.execute(taskId);
      todayTasks.removeWhere((t) => t.id == taskId);
      allTasks.removeWhere((t) => t.id == taskId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Archivos ──────────────────────────────────────────────

  Future<void> loadFilesForTask(String taskId) async {
    try {
      currentFiles = await _getFiles.execute(taskId);
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> uploadFileToTask({
    required String taskId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    isUploading = true;
    notifyListeners();
    try {
      final newFile = await _uploadFile.execute(
        taskId: taskId,
        fileName: fileName,
        fileBytes: fileBytes,
      );
      currentFiles = [...currentFiles, newFile];
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  // ── Helper ────────────────────────────────────────────────

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}