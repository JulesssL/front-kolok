import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final IconData icon;
  final VoidCallback onTap;
  final Function(String, String) onStatusUpdate;
  final Function(String) onDelete;

  const TaskListItem({
    super.key,
    required this.task,
    required this.icon,
    required this.onTap,
    required this.onStatusUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isDone = task.status == 'done';
    String subtitle = task.description ?? (task.dueDate != null ? "Pour le ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}" : "Aucune description");
    
    return GestureDetector(
      onTap: onTap,
      child: Dismissible(
        key: Key(task.id),
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
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            onStatusUpdate(task.id, 'done');
            return false;
          }
          return true;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDelete(task.id);
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
                            task.title,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? Colors.grey : null),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, decoration: isDone ? TextDecoration.lineThrough : null),
                          ),
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
      ),
    );
  }
}
