import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

const _categories = ['Healthy', 'Design', 'Job', 'Education', 'Sport', 'Other'];

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'Other';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<PlatformFile> _pickedFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() => _pickedFiles.addAll(result.files));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();

    final task = Task(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      category: _selectedCategory,
      dueTime: _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : null,
      dueDate: _selectedDate,
      isDone: false,
      createdAt: DateTime.now(),
    );

    await provider.addTask(task);

    if (!mounted) return;

    // Subir archivos si hay y la tarea se creó correctamente
    if (_pickedFiles.isNotEmpty && provider.allTasks.isNotEmpty) {
      final createdTask = provider.allTasks.first;
      for (final file in _pickedFiles) {
        if (file.bytes != null) {
          await provider.uploadFileToTask(
            taskId: createdTask.id,
            fileName: file.name,
            fileBytes: file.bytes!,
          );
        }
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Adding Task',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Título
            _RoundedField(
              controller: _titleController,
              hint: 'Task Title',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required'
                  : null,
            ),

            const SizedBox(height: 12),

            // Descripción
            _RoundedField(
              controller: _descController,
              hint: 'Description',
              suffix: const Text('Not Required',
                  style: TextStyle(
                      color: AppColors.textGrey, fontSize: 12)),
              maxLines: 4,
            ),

            const SizedBox(height: 16),

            // Fecha
            _ActionRow(
              icon: Icons.calendar_today,
              label: _selectedDate == null
                  ? 'Select Date In Calendar'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              onTap: _pickDate,
            ),

            const SizedBox(height: 8),

            // Hora
            _ActionRow(
              icon: Icons.access_time,
              label: _selectedTime == null
                  ? 'Select Time'
                  : _selectedTime!.format(context),
              onTap: _pickTime,
            ),

            const SizedBox(height: 8),

            // Archivos
            _ActionRow(
              icon: Icons.add_circle_outline,
              label: _pickedFiles.isEmpty
                  ? 'Additional Files'
                  : '${_pickedFiles.length} file(s) selected',
              onTap: _pickFile,
            ),

            // Lista de archivos seleccionados
            if (_pickedFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              ..._pickedFiles.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(f.name,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _pickedFiles.remove(f)),
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Categorías
            Text('Choose Category',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories
                  .map((cat) => _CategoryChip(
                        label: cat,
                        selected: cat == _selectedCategory,
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 32),

            // Botón confirmar
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: provider.isLoading || provider.isUploading
                    ? null
                    : _submit,
                child: provider.isLoading || provider.isUploading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Confirm Adding',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets reutilizables ─────────────────────────────────────

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? suffix;
  final int maxLines;
  final String? Function(String?)? validator;

  const _RoundedField({
    required this.controller,
    required this.hint,
    this.suffix,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.textGrey, fontSize: 14),
        suffix: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textDark,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}