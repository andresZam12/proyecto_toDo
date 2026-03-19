import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_keys.dart';
import '../models/task_file_model.dart';
import '../models/task_model.dart';

// Todas las llamadas directas a Supabase viven aquí.
// Nada más toca esta clase excepto el repositorio.
class TaskRemoteDataSource {
  final SupabaseClient _client;
  TaskRemoteDataSource(this._client);

  // ── Tareas ────────────────────────────────────────────────

  Future<List<TaskModel>> getTodayTasks() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final rows = await _client
        .from(SupabaseKeys.tasksTable)
        .select()
        .eq('due_date', today)
        .order('created_at');
    return rows.map((r) => TaskModel.fromJson(r)).toList();
  }

  Future<List<TaskModel>> getAllTasks() async {
    final rows = await _client
        .from(SupabaseKeys.tasksTable)
        .select()
        .order('created_at', ascending: false);
    return rows.map((r) => TaskModel.fromJson(r)).toList();
  }

  Future<void> createTask(TaskModel task) async {
    await _client.from(SupabaseKeys.tasksTable).insert(task.toJson());
  }

  Future<void> toggleDone(String taskId, bool isDone) async {
    await _client
        .from(SupabaseKeys.tasksTable)
        .update({'is_done': isDone})
        .eq('id', taskId);
  }

  Future<void> deleteTask(String taskId) async {
    await _client
        .from(SupabaseKeys.tasksTable)
        .delete()
        .eq('id', taskId);
  }

  // ── Archivos ──────────────────────────────────────────────

  Future<List<TaskFileModel>> getFilesForTask(String taskId) async {
    final rows = await _client
        .from(SupabaseKeys.taskFilesTable)
        .select()
        .eq('task_id', taskId)
        .order('created_at');
    return rows.map((r) => TaskFileModel.fromJson(r)).toList();
  }

  // Cómo funciona la subida de archivos:
  // 1. Se sube el archivo binario al bucket de Storage
  // 2. Se guarda la ruta en la tabla task_files
  // Así siempre podemos reconstruir la URL pública
  Future<TaskFileModel> uploadFile({
    required String taskId,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    // Ruta única dentro del bucket para evitar colisiones
    final storagePath =
        'tasks/$taskId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // Paso 1: subir al Storage
    await _client.storage
        .from(SupabaseKeys.filesBucket)
        .uploadBinary(storagePath, fileBytes as dynamic);

    // Paso 2: guardar referencia en la base de datos
    final row = await _client
        .from(SupabaseKeys.taskFilesTable)
        .insert({
          'task_id': taskId,
          'file_name': fileName,
          'storage_path': storagePath,
        })
        .select()
        .single();

    return TaskFileModel.fromJson(row);
  }
}