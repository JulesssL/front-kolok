import 'package:flutter/material.dart';

class ShoppingListItem extends StatelessWidget {
  final String name;
  final String initial;
  final String? avatarUrl;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const ShoppingListItem({
    super.key,
    required this.name,
    required this.initial,
    required this.avatarUrl,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E3192),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? Colors.grey.shade500 : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: avatarUrl != null ? Colors.transparent : Theme.of(context).colorScheme.primary,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            radius: 14,
            child: avatarUrl == null ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)) : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
