import 'package:sqflite/sqflite.dart';
import '../models/user_model.dart';
import 'db_helper.dart';

class UserDao {
  Future<void> insertUser(UserModel user) async {
    final db = await DBHelper().database;
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await DBHelper().database;
    final result = await db.query('users',
        where: 'username = ?', whereArgs: [username], limit: 1);
    if (result.isNotEmpty) return UserModel.fromMap(result.first);
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await DBHelper().database;
    final result = await db.query('users');
    return result.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<void> updateUser(UserModel user) async {
    final db = await DBHelper().database;
    await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteUser(String id) async {
    final db = await DBHelper().database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
