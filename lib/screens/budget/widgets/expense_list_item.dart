import 'package:flutter/material.dart';

class ExpenseListItem extends StatelessWidget {
  final String initial;
  final String name;
  final String description;
  final String amount;
  final Color amountColor;
  final Color avatarColor;
  final VoidCallback onTap;

  const ExpenseListItem({
    super.key,
    required this.initial,
    required this.name,
    required this.description,
    required this.amount,
    required this.amountColor,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: avatarColor,
              radius: 18,
              child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(description, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chevron_right, color: amountColor, size: 16),
            )
          ],
        ),
      ),
    );
  }
}
