import 'package:lx_music_flutter/models/music_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// 播放列表数据库管理
class MusicDbManager {
  MusicDbManager._();

  factory MusicDbManager() => _instance;
  static final MusicDbManager _instance = MusicDbManager._();

  Database? _database;
  static String table = 'music';
  static String database = 'music_database.db';

  void init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), database),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE ${table}(id INTEGER PRIMARY KEY, singer TEXT, name TEXT, albumName TEXT, albumId TEXT, songmid TEXT, source TEXT, interval TEXT, img TEXT, lrc TEXT, otherSource TEXT, hash TEXT)",
        );
      },
    );
  }

  Future<List<MusicItem>> getAllMusic() async {
    final List<Map<String, dynamic>> maps = await _database!.query(table);
    return List.generate(maps.length, (i) {
      return MusicItem(
        singer: maps[i]['singer'],
        name: maps[i]['name'],
        albumName: maps[i]['albumName'],
        albumId: maps[i]['albumId'],
        songmid: maps[i]['songmid'],
        source: maps[i]['source'],
        interval: maps[i]['interval'],
        img: maps[i]['img'],
        lrc: maps[i]['lrc'],
        otherSource: maps[i]['otherSource'],
        hash: maps[i]['hash'],
        qualityList: [],
        qualityMap: {},
        urlMap: {},
      );
    });
  }

  Future<int?> insertMusic(MusicItem music) async {
    return _database?.insert(
      table,
      music.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> deleteMusic(MusicItem music) async {
    return await _database?.delete(
      table,
      where: 'songmid = ?',
      whereArgs: [music.songmid],
    ) == 1;
  }

  Future<bool> deleteMusicSongmid(String songmid) async {
    return await _database?.delete(
      table,
      where: 'songmid = ?',
      whereArgs: [songmid],
    ) == 1;
  }

  Future<void> deleteAllMusic() async {
    await _database?.delete(
      table,
    );
  }

  Future<void> updateMusic(MusicItem music) async {
    await _database?.update(
      table,
      music.toJson(),
      where: 'songmid = ?',
      whereArgs: [music.songmid],
    );
  }

  Future<void> close() async {
    await _database?.close();
  }

  Future<void> deleteDb() async {
    await deleteDatabase(join(await getDatabasesPath(), database));
  }

  Future<void> clearTable() async {
    await _database?.delete(table);
  }
}
