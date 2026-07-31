import 'package:flutter/material.dart';

enum ActivityType {
  taskDone,
  expenseAdded,
  shoppingAdded,
}

class KolokActivity {
  final String id;
  final ActivityType type;
  final String description;
  final DateTime date;
  final String? userInitial;
  final String? userAvatarUrl;

  KolokActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    this.userInitial,
    this.userAvatarUrl,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.taskDone:
        return Icons.cleaning_services;
      case ActivityType.expenseAdded:
        return Icons.attach_money;
      case ActivityType.shoppingAdded:
        return Icons.shopping_basket;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.taskDone:
        return const Color(0xFF4CE0B3); // Greenish
      case ActivityType.expenseAdded:
        return const Color(0xFFFF6B6B); // Reddish/Pinkish
      case ActivityType.shoppingAdded:
        return const Color(0xFFFCA311); // Orange/Yellowish
    }
  }
}
