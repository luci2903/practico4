import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY,
        title TEXT,
        year TEXT,
        runtime INTEGER,
        genre TEXT,
        director TEXT,
        synopsis TEXT,
        poster_url TEXT,
        rating REAL,
        vote_count INTEGER,
        created_at INTEGER
      )
    ''');
  }

  Future<int> insertOrUpdateMovie(Movie movie) async {
    final db = await instance.database;
    final data = movie.toMap();
    data['created_at'] = DateTime.now().millisecondsSinceEpoch;

    return await db.insert(
      'movies',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Movie>> getHistory() async {
    final db = await instance.database;
    final result = await db.query(
      'movies',
      orderBy: 'created_at DESC',
    );

    return result.map((json) => Movie.fromMap(json)).toList();
  }

  Future<int> deleteMovie(int id) async {
    final db = await instance.database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearAll() async {
    final db = await instance.database;
    return await db.delete('movies');
  }
}
