import 'package:flutter/material.dart';
import '../../../../models/task.dart';

class PlanningItem extends StatelessWidget {
  final Task task;
  final Color avatarColor;
  final VoidCallback onTap;

  const PlanningItem({
    super.key,
    required this.task,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final assignedName = task.assignedTo?.name ?? "Non assigné";
    final initial = assignedName.isNotEmpty ? assignedName[0].toUpperCase() : "?";
    final day = task.dueDate != null ? "${task.dueDate!.day.toString().padLeft(2, '0')}/${task.dueDate!.month.toString().padLeft(2, '0')}" : "-";
    final avatarUrl = task.assignedTo?.avatarUrl;

    return GestureDetector(
      onTap: onTap,
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
            CircleAvatar(
              backgroundColor: avatarUrl != null ? Colors.transparent : avatarColor,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              radius: 18,
              child: avatarUrl == null ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        assignedName,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
