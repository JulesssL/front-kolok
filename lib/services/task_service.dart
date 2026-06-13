import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/task.dart';

class TaskService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<List<Task>> getTasks() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des tâches');
    }
  }

  Future<Task> createTask(String title, String? description, String? dueDate) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/tasks');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'due_date': dueDate,
      }),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de la tâche');
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/tasks/$taskId');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de la tâche');
    }
  }
}
