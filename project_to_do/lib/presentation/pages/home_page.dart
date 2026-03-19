import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'add_task_page.dart';
import 'all_tasks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      provider.loadTodayTasks();
      provider.loadAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? const _HomeBody() : const AllTasksPage(),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          if (mounted) {
            context.read<TaskProvider>().loadTodayTasks();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ── Cuerpo principal ──────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await provider.loadTodayTasks();
              await provider.loadAllTasks();
            },
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good day! 👋',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textGrey)),
                        Text('My Tasks',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark)),
                      ],
                    ),
                    const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      radius: 22,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tarjeta semanal
                _WeeklyCard(provider: provider),

                const SizedBox(height: 24),

                // Encabezado tareas de hoy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Today Tasks',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '${provider.doneToday} of ${provider.totalToday}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textGrey),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Barra de progreso
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: provider.progressToday,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryLight,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de tareas
                if (provider.isLoading)
                  const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary))
                else if (provider.todayTasks.isEmpty)
                  _EmptyState()
                else
                  ...provider.todayTasks.map((t) => TaskCard(task: t)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Tarjeta semanal ───────────────────────────────────────────

class _WeeklyCard extends StatelessWidget {
  final TaskProvider provider;
  const _WeeklyCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final total = provider.allTasks.length;
    final done = provider.weeklyDone;
    final percent = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 45,
            lineWidth: 8,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Tasks',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Chip(label: '${provider.weeklyDone}',
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  _Chip(label: '${provider.weeklyPending}',
                      color: AppColors.overdue),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }
}

// ── Estado vacío ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline,
                size: 64,
                color: AppColors.primary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('No tasks for today!',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.textGrey)),
            const SizedBox(height: 4),
            Text('Tap + to add a new task',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}

// ── Barra de navegación ───────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.list_alt_rounded,
            label: 'All Tasks',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 48),
          _NavItem(
            icon: Icons.track_changes_rounded,
            label: 'Progress',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: selected ? AppColors.primary : AppColors.textGrey,
              size: 26),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color:
                      selected ? AppColors.primary : AppColors.textGrey)),
        ],
      ),
    );
  }
}