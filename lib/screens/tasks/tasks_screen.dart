import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../settings/settings_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedTabIndex = 0; // 0: Mon tour, 1: Planning
  String _selectedAssigneeFilter = 'all'; // 'all' or user.id
  String _selectedSort = 'due_date'; // 'due_date' or 'created'

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
        title: Text(
          "KOLOK",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
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
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshTasks,
              child: _selectedTabIndex == 0 ? _buildMyTurnView() : _buildPlanningView(),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: ElevatedButton.icon(
          onPressed: () => _showAddTaskModal(context),
          icon: const Icon(Icons.add, color: Color(0xFF2E3192)),
          label: const Text(
            "AJOUTER UNE TÂCHE",
            style: TextStyle(color: Color(0xFF2E3192), fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Color(0xFF2E3192)),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

  Widget _buildFilters() {
    final members = context.watch<AuthProvider>().currentUser?.kolok?.users ?? [];
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          ChoiceChip(
            label: const Text("Toutes"),
            selected: _selectedAssigneeFilter == 'all',
            onSelected: (val) => setState(() => _selectedAssigneeFilter = 'all'),
          ),
          const SizedBox(width: 8),
          ...members.map((m) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(m.name),
                selected: _selectedAssigneeFilter == m.id,
                onSelected: (val) => setState(() => _selectedAssigneeFilter = val ? m.id : 'all'),
              ),
            );
          }),
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
            ...filteredTasks.map((t) => _buildTaskCard(
              t.id,
              Icons.cleaning_services_outlined, 
              t.title, 
              t.description ?? (t.dueDate != null ? "Pour le ${DateFormat('dd/MM/yyyy').format(t.dueDate!)}" : "Aucune description"),
              t.status,
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
              final assignedName = t.assignedTo?.name ?? "Non assigné";
              final initial = assignedName.isNotEmpty ? assignedName[0].toUpperCase() : "?";
              return _buildPlanningItem(
                initial, 
                t.title, 
                assignedName, 
                t.dueDate != null ? "${t.dueDate!.day}/${t.dueDate!.month}" : "-", 
                Theme.of(context).colorScheme.primary
              );
            }),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(String id, IconData icon, String title, String subtitle, String status) {
    bool isDone = status == 'done';
    
    return Dismissible(
      key: Key(id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.check, color: Colors.white, size: 30),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<TaskProvider>().deleteTask(id);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tâche supprimée")));
        } else if (direction == DismissDirection.startToEnd) {
          context.read<TaskProvider>().updateTaskStatus(id, 'done');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tâche validée !")));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDone ? Colors.grey.shade100 : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 15,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (isDone) 
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
            if (!isDone) ...[
              Divider(height: 1, color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text("Glissez pour valider ou supprimer", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningItem(String initial, String taskName, String personName, String day, Color avatarColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarColor,
            radius: 18,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(taskName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(personName, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    String? selectedUserId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final members = context.watch<AuthProvider>().currentUser?.kolok?.users ?? [];
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ajouter une tâche",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Titre de la tâche",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description (optionnelle)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setModalState(() => selectedDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : "Date butoir"),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text("Assigner"),
                              value: selectedUserId,
                              items: members.map((m) {
                                return DropdownMenuItem(
                                  value: m.id,
                                  child: Text(m.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setModalState(() => selectedUserId = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("ANNULER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isNotEmpty) {
                              try {
                                await context.read<TaskProvider>().createTask(
                                  titleController.text, 
                                  descriptionController.text.isEmpty ? null : descriptionController.text, 
                                  selectedDate?.toIso8601String(),
                                  selectedUserId,
                                );
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3192),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("AJOUTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }
}
