import 'package:sqflite/sqflite.dart';
import '../../models/user.dart';
import '../local/db_helper.dart';

class UserRepository {
  Future<AppUser?> getByUsername(String username) async {
    final db = await DBHelper.instance.database;
    final res = await db.query('users', where: 'username = ?', whereArgs: [username]);
    if (res.isEmpty) return null;
    return AppUser.fromMap(res.first);
    }

  Future<int> create(AppUser user) async {
    final db = await DBHelper.instance.database;
    return db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
  }
}
