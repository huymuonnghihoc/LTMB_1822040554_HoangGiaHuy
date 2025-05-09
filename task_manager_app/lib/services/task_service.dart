import '../models/task_model.dart';
import '../data/db_helper.dart';

class TaskService {
  // Hàm thêm công việc
  static Future<void> insertTask(TaskModel task) async {
    final db = await DBHelper().database;
    await db.insert('tasks', task.toMap());
  }

  // Hàm lấy tất cả công việc
  static Future<List<TaskModel>> getAllTasks() async {
    final db = await DBHelper().database;
    final maps = await db.query('tasks');
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  // Hàm cập nhật công việc
  static Future<void> updateTask(TaskModel task) async {
    final db = await DBHelper().database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Hàm xóa công việc
  static Future<void> deleteTask(String id) async {
    final db = await DBHelper().database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
