// Representa un archivo adjunto a una tarea
class TaskFile {
  final String id;
  final String taskId;
  final String fileName;
  final String storagePath;
  final DateTime createdAt;

  const TaskFile({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.storagePath,
    required this.createdAt,
  });

  // Construye la URL pública para ver o descargar el archivo
  String publicUrl(String supabaseUrl) =>
      '$supabaseUrl/storage/v1/object/public/task-files/$storagePath';
}