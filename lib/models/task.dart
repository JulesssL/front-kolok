import 'user.dart';
import 'kolok.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final String status; // 'todo', 'in_progress', 'done'
  final DateTime? dueDate;
  final User? assignedTo;
  final Kolok? kolok;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.assignedTo,
    this.kolok,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 'todo',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      assignedTo: json['assignedTo'] != null ? User.fromJson(json['assignedTo']) : null,
      kolok: json['kolok'] != null ? Kolok.fromJson(json['kolok']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'due_date': dueDate?.toIso8601String(),
      if (assignedTo != null) 'assignedTo': assignedTo!.toJson(),
    };
  }
}
