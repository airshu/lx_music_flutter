import 'package:lx_music_flutter/models/music_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MusicSQLManager {
  MusicSQLManager._() {
    init();
  }

  factory MusicSQLManager() => _instance;
  static final MusicSQLManager _instance = MusicSQLManager._();

  Database? _database;

  String tableName = 'music_item';

  void init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'lx_music.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)",
        );
      },
    );
  }

  Future<int?> insert<T>(T t) async {
    return _database?.insert(
      t.toString(),
      (t as dynamic).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMusicItem(MusicItem item) async {
    await _database?.insert(
      tableName,
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MusicItem>> getAllMusicItems() async {
    final List<Map<String, dynamic>> maps = await _database?.query(tableName) ?? [];

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return MusicItem.fromJson(maps[i]);
    });
  }

  Future<void> updateDog(MusicItem item) async {
    await _database?.update(
      tableName,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteMusicItem(int id) async {
    await _database?.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
