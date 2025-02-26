import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rabbit_health.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final directory = await getApplicationDocumentsDirectory(); // Use path_provider
    final path = join(directory.path, fileName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rabbits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        about TEXT,  -- Nullable column added
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE health_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rabbit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT,
        recommendation TEXT,
        FOREIGN KEY (rabbit_id) REFERENCES rabbits(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE feces_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        health_status_id INTEGER NOT NULL,
        time TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (health_status_id) REFERENCES health_status(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        feces_record_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        FOREIGN KEY (feces_record_id) REFERENCES feces_records(id) ON DELETE CASCADE
      )
    ''');
  }

  // ✅ Insert Rabbit
  Future<int> insertRabbit(Map<String, dynamic> rabbit) async {
    final db = await database;
    return await db.insert('rabbits', rabbit, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ✅ Get All Rabbits
  Future<List<Map<String, dynamic>>> getAllRabbits() async {
    final db = await database;
    return await db.query('rabbits');
  }

  // ✅ Get Rabbit by ID
  Future<Map<String, dynamic>?> getRabbitById(int id) async {
    final db = await database;
    final result = await db.query('rabbits', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

// ✅ Get Health History for a Rabbit
  Future<List<Map<String, dynamic>>> getHealthHistory(int rabbitId) async {
    final db = await database;
    return await db.query(
      'health_status',
      where: 'rabbit_id = ?',
      whereArgs: [rabbitId],
      orderBy: 'date DESC', // Fetch latest first
    );
  }

  // ✅ Update Rabbit
  Future<int> updateRabbit(int id, Map<String, dynamic> updatedData) async {
    final db = await database;
    return await db.update('rabbits', updatedData, where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Delete Rabbit
  Future<int> deleteRabbit(int id) async {
    final db = await database;
    return await db.delete('rabbits', where: 'id = ?', whereArgs: [id]);
  }

  // ✅ Get Feces Records for a Rabbit
  Future<List<Map<String, dynamic>>> getFecesRecords(int rabbitId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT feces_records.* FROM feces_records
      JOIN health_status ON feces_records.health_status_id = health_status.id
      WHERE health_status.rabbit_id = ?
    ''', [rabbitId]);
  }

  // ✅ Get Feces Records by Health Status ID
  Future<List<Map<String, dynamic>>> getFecesRecordsByHealthStatus(int healthStatusId) async {
    final db = await database;
    return await db.query(
      'feces_records',
      where: 'health_status_id = ?',
      whereArgs: [healthStatusId],
      orderBy: 'time ASC', // Sort by time to display in chronological order
    );
  }

  // ✅ Insert Health Status
  Future<int> insertHealthStatus(int rabbitId, String date, String status, String recommendation) async {
    final db = await database;
    return await db.insert('health_status', {
      'rabbit_id': rabbitId,
      'date': date,
      'status': status,
      'recommendation': recommendation,
    });
  }

  // ✅ Insert Feces Record
  Future<int> insertFecesRecord(int healthStatusId, String time, int quantity) async {
    final db = await database;
    return await db.insert('feces_records', {
      'health_status_id': healthStatusId,
      'time': time,
      'quantity': quantity,
    });
  }

  // ✅ Insert Image
  Future<int> insertImage(int fecesRecordId, String imagePath) async {
    final db = await database;
    return await db.insert('images', {
      'feces_record_id': fecesRecordId,
      'image_path': imagePath,
    });
  }

  // ✅ Fetch Health Status for a Rabbit
  Future<Map<String, dynamic>?> getLatestHealthStatus(int rabbitId) async {
    final db = await database;
    final result = await db.query(
      'health_status',
      where: 'rabbit_id = ?',
      whereArgs: [rabbitId],
      orderBy: 'date DESC', // Get the latest health status
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ Fetch Health Status using Health ID
  Future<Map<String, dynamic>?> getHealthStatusById(int healthId) async {
    final db = await database;
    final result = await db.query(
      'health_status',
      columns: ['id', 'rabbit_id', 'date', 'status', 'recommendation'], // Explicitly select columns
      where: 'id = ?', // ✅ Filter by health_id
      whereArgs: [healthId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ Check if health status exists for rabbitId and date
  Future<Map<String, dynamic>?> getHealthStatusByRabbitIdAndDate(int rabbitId, String date) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'health_status',
      where: 'rabbit_id = ? AND date = ?',
      whereArgs: [rabbitId, date],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getHealthStatusByIdAndDate(int healthId, String date) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'health_status',
      where: 'id = ? AND date = ?',
      whereArgs: [healthId, date],
      limit: 1, // Ensure only one record is returned
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ✅ Get All Health Status Records for a Rabbit
  Future<List<Map<String, dynamic>>> getAllHealthStatusRecords(int rabbitId) async {
    final db = await database;
    return await db.query(
      'health_status',
      where: 'rabbit_id = ?',
      whereArgs: [rabbitId],
      orderBy: 'date DESC', // Sort by date (latest first)
    );
  }
}
