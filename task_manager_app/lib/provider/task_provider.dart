import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => _tasks;

  Future<void> fetchTasks() async {
    _tasks = await TaskService.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(TaskModel task) async {
    await TaskService.insertTask(task);
    _tasks.add(task);
    notifyListeners();
  }
}
