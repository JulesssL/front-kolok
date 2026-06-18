import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../settings/settings_screen.dart';
import '../../widgets/task_details_modal.dart';
import '../../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TaskProvider>().fetchTasks();
        context.read<ExpenseProvider>().fetchExpenses();
        context.read<ShoppingProvider>().fetchItems();
        context.read<ChatProvider>().fetchMessages();
      }
    });
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
      body: Consumer4<TaskProvider, ExpenseProvider, ShoppingProvider, ChatProvider>(
        builder: (context, taskProv, expenseProv, shoppingProv, chatProv, child) {
          final tasks = taskProv.tasks;
          final doneTasks = tasks.where((t) => t.status == 'done').length;
          final totalTasks = tasks.length;
          
          final pendingItems = shoppingProv.items.where((i) => !i.isBought).length;
          
          // Simple balance logic for now
          final totalExpenses = expenseProv.expenses.fold(0.0, (sum, e) => sum + e.amount);

          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<TaskProvider>().fetchTasks(),
                context.read<ExpenseProvider>().fetchExpenses(),
                context.read<ShoppingProvider>().fetchItems(),
                context.read<ChatProvider>().fetchMessages(),
              ]);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKolokStatusCard(doneTasks, totalTasks, totalExpenses, pendingItems),
                const SizedBox(height: 24),
                _buildSectionHeader("Mes tâches", ""),
                const SizedBox(height: 12),
                if (taskProv.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (tasks.isEmpty)
                  const Text("Aucune tâche pour le moment")
                else
                  ...tasks.take(3).map((t) => _buildTaskItem(t)),
                const SizedBox(height: 24),
                const Text(
                  "Fil d'actualité",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (chatProv.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (chatProv.messages.isEmpty)
                  const Text("Aucun message")
                else
                  ...chatProv.messages.take(3).map((m) => _buildFeedItem(m.sender?.name?[0].toUpperCase() ?? '?', m.content, "Aujourd'hui", m.sender?.avatarUrl)),
                const SizedBox(height: 80),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKolokStatusCard(int doneTasks, int totalTasks, double totalExpenses, int pendingItems) {
    String iconAsset = 'assets/images/smiley_orange.png';
    double taskCompletion = totalTasks == 0 ? 1.0 : doneTasks / totalTasks;
    
    if (taskCompletion == 1.0 && pendingItems == 0) {
      iconAsset = 'assets/images/smiley_green.png';
    } else if (taskCompletion < 0.5 && pendingItems >= 3) {
      iconAsset = 'assets/images/smiley_pink.png';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Statut de la Kolok",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Image.asset(iconAsset, width: 32, height: 32),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusIndicator("$doneTasks/$totalTasks", "Tâches", Theme.of(context).colorScheme.primary),
              _buildStatusIndicator("${totalExpenses.toStringAsFixed(0)}€", "Balance", Theme.of(context).colorScheme.primary),
              _buildStatusIndicator("$pendingItems", "Courses", Theme.of(context).colorScheme.primary),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    bool isDone = task.status == 'done';
    return GestureDetector(
      onTap: () {
        showTaskDetailsModal(context, task);
      },
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF4CE0B3).withOpacity(0.1) : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cleaning_services, color: isDone ? const Color(0xFF4CE0B3) : Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 14,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey.shade500 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedItem(String initial, String text, String time, String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: avatarUrl != null ? Colors.transparent : Theme.of(context).colorScheme.primary,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            radius: 18,
            child: avatarUrl == null ? Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
