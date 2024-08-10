import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_management/Models/task.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();

  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textType,
        isCompleted $boolType
      )
    ''');
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Task> create(Task task) async {
    final db = await instance.database;

    final id = await db.insert('tasks', task.toJson());
    return task.copyWith(id: id);
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;

    const orderBy = 'id ASC';
    final result = await db.query('tasks', orderBy: orderBy);

    return result.map((json) => Task.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
