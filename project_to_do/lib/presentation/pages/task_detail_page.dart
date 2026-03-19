import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_file.dart';
import '../providers/task_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadFilesForTask(widget.task.id);
    });
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: false, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    if (!mounted) return;
    await context.read<TaskProvider>().uploadFileToTask(
          taskId: widget.task.id,
          fileName: file.name,
          fileBytes: file.bytes!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info de la tarea
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                if (widget.task.description != null) ...[
                  const SizedBox(height: 8),
                  Text(widget.task.description!,
                      style: const TextStyle(
                          color: AppColors.textGrey)),
                ],
                const SizedBox(height: 12),
                _InfoRow(
                    icon: Icons.category_outlined,
                    text: widget.task.category),
                if (widget.task.dueDate != null)
                  _InfoRow(
                    icon: Icons.calendar_today,
                    text:
                        '${widget.task.dueDate!.day}/${widget.task.dueDate!.month}/${widget.task.dueDate!.year}',
                  ),
                if (widget.task.dueTime != null)
                  _InfoRow(
                      icon: Icons.access_time,
                      text: widget.task.dueTime!),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sección de archivos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attached Files',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed:
                    provider.isUploading ? null : _pickAndUpload,
                icon: const Icon(Icons.upload_file,
                    color: AppColors.primary),
                label: const Text('Upload',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),

          if (provider.isUploading)
            const LinearProgressIndicator(
                color: AppColors.primary),

          const SizedBox(height: 8),

          if (provider.currentFiles.isEmpty)
            const Text('No files attached yet.',
                style: TextStyle(color: AppColors.textGrey))
          else
            ...provider.currentFiles
                .map((f) => _FileItem(file: f)),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(text,
              style:
                  const TextStyle(color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _FileItem extends StatelessWidget {
  final TaskFile file;
  const _FileItem({required this.file});

  @override
  Widget build(BuildContext context) {
    final supabaseUrl = dotenv.env['SUPABASE_URL']!;
    final url = file.publicUrl(supabaseUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.fileName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text(url,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textGrey),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}