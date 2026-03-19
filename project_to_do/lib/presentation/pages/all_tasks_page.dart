import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.loadAllTasks,
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'All Tasks',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (provider.isLoading)
                const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primary),
                )
              else if (provider.allTasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'No tasks yet. Tap + to add one!',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
                )
              else
                ...provider.allTasks.map((t) => TaskCard(task: t)),
            ],
          ),
        );
      },
    );
  }
}