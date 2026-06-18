import 'dart:convert';
import '../models/task.dart';
import '../core/network/api_client.dart';

class TaskService {
  Future<List<Task>> getTasks() async {
    final response = await apiClient.get('/tasks');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des tâches');
    }
  }

  Future<Task> createTask(String title, String? description, String? dueDate, String? assignedToId) async {
    final response = await apiClient.post(
      '/tasks',
      body: {
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'due_date': dueDate,
        if (assignedToId != null) 'assignedToId': assignedToId,
      },
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de la tâche');
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final response = await apiClient.patch(
      '/tasks/$taskId',
      body: {'status': status},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de la tâche');
    }
  }

  Future<void> deleteTask(String taskId) async {
    final response = await apiClient.delete('/tasks/$taskId');
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la tâche');
    }
  }
}
