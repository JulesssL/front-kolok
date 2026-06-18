import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tasks = await _taskService.getTasks();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTask(String title, String? description, String? dueDate, String? assignedToId) async {
    try {
      final newTask = await _taskService.createTask(title, description, dueDate, assignedToId);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _taskService.updateTaskStatus(taskId, status);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final t = _tasks[index];
        _tasks[index] = Task(
          id: t.id,
          title: t.title,
          description: t.description,
          status: status,
          dueDate: t.dueDate,
          assignedTo: t.assignedTo,
          kolok: t.kolok,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
