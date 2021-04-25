import 'dart:io';
import 'models/tmdb_show.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class ShowDatabaseHelper {
  static final _databaseName = "FavoriteShows.db";
  static final _databaseVersion = 1;

  static final table = 'favoriteShows';

  static final columnID = 'id';
  static final columnName = 'name';
  static final columnNumberOfEpisodes = 'number_of_episodes';
  static final columnNumberOfSeasons = 'number_of_seasons';
  static final columnOverview = 'overview';
  static final columnPosterPath = 'poster_path';
  static final columnVoteAverage = 'vote_average';

  // make this a singleton class
  ShowDatabaseHelper._privateConstructor();
  static final ShowDatabaseHelper instance =
      ShowDatabaseHelper._privateConstructor();

  factory ShowDatabaseHelper() {
    return instance;
  }

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // opens db connection or create it if it doesn't exist
  _initDatabase() async {
    print("init database is called!");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print("path is: $path");
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    print("create table is called with table: $table");
    await db.execute('''
          CREATE TABLE $table (
            $columnID INTEGER PRIMARY KEY,
            $columnName TEXT,
            $columnNumberOfEpisodes INTEGER,
            $columnNumberOfSeasons INTEGER,
            $columnOverview TEXT,
            $columnPosterPath TEXT,
            $columnVoteAverage REAL
          )
          ''');
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    print("proceeding from catch");

    var query = await db
        .rawQuery('SELECT * FROM $table WHERE $columnID="${row["id"]}"');

    int showID = row["id"];

    if (query.isNotEmpty) {
      print("we deleting: ${row['name']}, with id: $showID");
      return await db
          .delete(table, where: '$columnID = ?', whereArgs: ['$showID']);
    } else {
      print("we adding ${row['name']}, with id: $showID");
      return await db.insert(table, row);
    }
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<void> drop() async {
    print("DROPPING DB");
    Database db = await instance.database;
    return db.execute("DROP TABLE IF EXISTS $_databaseName");
  }

  Future<List<TMDBShow>> getShows() async {
    print("get shows called!");
    Database db = await instance.database;
    // createDB(db);
    final List<Map<String, dynamic>> shows = await db.query('$table');

    return List.generate(shows.length, (i) {
      return TMDBShow(
          id: shows[i]['id'],
          name: shows[i]['name'],
          numberOfEpisodes: shows[i]['number_of_episodes'],
          numberOfSeasons: shows[i]['number_of_seasons'],
          overview: shows[i]['overview'],
          posterPath: shows[i]['poster_path'],
          voteAverage: shows[i]['vote_average']);
    });
  }

  void createDB(db) {
    try {
      _onCreate(db, _databaseVersion);
    } catch (e) {
      print(e);
    }
  }
}
