import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TokenService {
  static const String _dbName = 'agriconnect.db';
  static const String _tableName = 'tokens';
  static Database? _database;

  // Initialize database
  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            token TEXT NOT NULL,
            user_id INTEGER,
            created_at TEXT NOT NULL
          )
          ''');
      },
    );
  }

  // Get database instance
  static Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  // Save token
  static Future<void> saveToken(String token, {int? userId}) async {
    final db = await database;
    await db.delete(_tableName); // Clear old tokens
    await db.insert(_tableName, {
      'token': token,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get token
  static Future<String?> getToken() async {
    final db = await database;
    final result = await db.query(_tableName);
    if (result.isNotEmpty) {
      return result.first['token'] as String;
    }
    return null;
  }

  // Delete token
  static Future<void> deleteToken() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Check if token exists
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null;
  }

  // Close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
    }
  }
}
