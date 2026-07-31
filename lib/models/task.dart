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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.assignedTo,
    this.kolok,
    this.createdAt,
    this.updatedAt,
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
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
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
