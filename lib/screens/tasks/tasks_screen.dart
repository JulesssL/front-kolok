import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/task_details_modal.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/add_task_modal.dart';
import 'widgets/task_list_item.dart';
import 'widgets/planning_item.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedTabIndex = 0; // 0: Mon tour, 1: Planning
  String _selectedAssigneeFilter = 'all'; // 'all' or user.id
  final String _selectedSort = 'due_date'; // 'due_date' or 'created'

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TaskProvider>().fetchTasks();
      }
    });
  }

  Future<void> _refreshTasks() async {
    await context.read<TaskProvider>().fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo_text_blue.png',
          width: 90,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTaskModal(),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: Consumer<AuthProvider>(
                builder: (context, authProv, child) {
                  final avatarUrl = authProv.currentUser?.avatarUrl;
                  if (avatarUrl != null) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(Icons.person_outline, color: Colors.grey.shade700),
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTasks,
              child: _selectedTabIndex == 0 ? _buildMyTurnView() : _buildPlanningView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0 ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "Mon tour",
                    style: TextStyle(
                      color: _selectedTabIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1 ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "Planning",
                    style: TextStyle(
                      color: _selectedTabIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredTasks(TaskProvider taskProv) {
    var filtered = taskProv.tasks.where((t) {
      if (_selectedAssigneeFilter != 'all') {
        if (t.assignedTo?.id != _selectedAssigneeFilter) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (_selectedSort == 'due_date') {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0; 
    });
    
    return filtered;
  }

  Widget _buildMyTurnView() {
    return Consumer<TaskProvider>(
      builder: (context, taskProv, child) {
        if (taskProv.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final filteredTasks = _getFilteredTasks(taskProv);

        if (filteredTasks.isEmpty) {
          return const Center(child: Text("Aucune tâche"));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            ...filteredTasks.map((t) => TaskListItem(
              task: t,
              icon: Icons.cleaning_services_outlined,
              onTap: () => showTaskDetailsModal(context, t),
              onStatusUpdate: (id, status) => context.read<TaskProvider>().updateTaskStatus(id, status),
              onDelete: (id) => context.read<TaskProvider>().deleteTask(id),
            )),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildPlanningView() {
    return Consumer<TaskProvider>(
      builder: (context, taskProv, child) {
        if (taskProv.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredTasks = _getFilteredTasks(taskProv);

        if (filteredTasks.isEmpty) {
          return const Center(child: Text("Aucune tâche"));
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    "Toutes les tâches",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...filteredTasks.map((t) {
              return PlanningItem(
                task: t,
                avatarColor: Theme.of(context).colorScheme.primary,
                onTap: () => showTaskDetailsModal(context, t),
              );
            }),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}
