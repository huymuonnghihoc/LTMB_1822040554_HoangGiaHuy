import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import 'db_helper.dart';

class TaskDao {
  Future<void> insertTask(TaskModel task) async {
    final db = await DBHelper().database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await DBHelper().database;
    final result = await db.query('tasks');
    return result.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<List<TaskModel>> getTasksByUser(String userId) async {
    final db = await DBHelper().database;
    final result =
    await db.query('tasks', where: 'createdBy = ?', whereArgs: [userId]);
    return result.map((e) => TaskModel.fromMap(e)).toList();
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await DBHelper().database;
    await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await DBHelper().database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
Future<List<TaskModel>> searchTasks(String keyword) async {
  final db = await DBHelper().database;
  final result = await db.query(
    'tasks',
    where: 'title LIKE ? OR description LIKE ?',
    whereArgs: ['%$keyword%', '%$keyword%'],
  );
  return result.map((e) => TaskModel.fromMap(e)).toList();
}

Future<List<TaskModel>> filterTasks({String? status, int? priority}) async {
  final db = await DBHelper().database;
  final where = <String>[];
  final args = <dynamic>[];

  if (status != null) {
    where.add('status = ?');
    args.add(status);
  }
  if (priority != null) {
    where.add('priority = ?');
    args.add(priority);
  }

  final result = await db.query('tasks',
      where: where.isNotEmpty ? where.join(' AND ') : null,
      whereArgs: args);
  return result.map((e) => TaskModel.fromMap(e)).toList();
}
