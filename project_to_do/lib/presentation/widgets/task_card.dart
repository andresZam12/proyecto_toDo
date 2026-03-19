import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../pages/task_detail_page.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TaskProvider>();

    return GestureDetector(
      onTap: () => _goToDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Círculo check
            GestureDetector(
              onTap: () => provider.toggleTask(task.id, !task.isDone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: task.isDone ? AppColors.primary : AppColors.textGrey,
                    width: 2,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(width: 14),

            // Título
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: task.isDone ? AppColors.textGrey : AppColors.textDark,
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),

            // Badge de hora
            if (task.dueTime != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _timeColor(task.dueTime!).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _formatTime(task.dueTime!),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _timeColor(task.dueTime!),
                  ),
                ),
              ),
            ],

            // Botón eliminar
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmDelete(context, provider),
              child: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  // "08:00" → "8 A.M"
  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final suffix = hour < 12 ? 'A.M' : 'P.M';
    final display = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return '$display $suffix';
  }

  Color _timeColor(String time) {
    final hour = int.tryParse(time.split(':').first) ?? 0;
    if (hour < 12) return AppColors.primary;
    if (hour < 17) return Colors.orange;
    return Colors.blue;
  }

void _goToDetail(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
  );
}

  Future<void> _confirmDelete(
      BuildContext context, TaskProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.removeTask(task.id);
    }
  }
}