import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

void showTaskDetailsModal(BuildContext context, Task task) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TaskDetailsModal(task: task),
  );
}

class _TaskDetailsModal extends StatelessWidget {
  final Task task;

  const _TaskDetailsModal({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final assignedName = task.assignedTo?.name ?? "Non assigné";
    final initial = assignedName.isNotEmpty ? assignedName[0].toUpperCase() : "?";
    final avatarUrl = task.assignedTo?.avatarUrl;
    final isDone = task.status == 'done';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Faite", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("À faire", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: avatarUrl != null ? Colors.transparent : Theme.of(context).colorScheme.primary,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  radius: 20,
                  child: avatarUrl == null
                      ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Assigné à", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(assignedName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.dueDate != null) ...[
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade500, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Échéance", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        "${task.dueDate!.day.toString().padLeft(2, '0')}/${task.dueDate!.month.toString().padLeft(2, '0')}/${task.dueDate!.year}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (task.description != null && task.description!.isNotEmpty) ...[
              const Text("Description", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(task.description!),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 16),
            if (!isDone)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<TaskProvider>().updateTaskStatus(task.id, 'done');
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("MARQUER COMME FAITE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  context.read<TaskProvider>().deleteTask(task.id);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Supprimer la tâche", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
