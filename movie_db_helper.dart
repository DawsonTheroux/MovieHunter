import 'dart:io';
import 'models/tmdb_movie.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class MovieDatabaseHelper {
  static final _databaseName = "FavoriteMovies.db";
  static final _databaseVersion = 1;

  static final table = 'favoriteMovies';
  // static final table = 'favoriteMovies2';

  static final columnID = 'id';
  static final columnTitle = 'title';
  static final columnPopularity = 'popularity';
  static final columnOverview = 'overview';
  static final columnPosterPath = 'poster_path';
  static final columnReleaseDate = 'release_date';
  static final columnVoteCount = 'vote_count';
  static final columnVoteAverage = 'vote_average';
  static final columnOriginalLanguage = 'original_language';
  static final columnOriginalTitle = 'original_title';
  static final columnGenreIDs = 'genre_ids';
  static final columnBackdropPath = 'backdrop_path';

  // make this a singleton class
  MovieDatabaseHelper._privateConstructor();
  static final MovieDatabaseHelper instance =
      MovieDatabaseHelper._privateConstructor();

  factory MovieDatabaseHelper() {
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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  //Creates the database.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnID INTEGER PRIMARY KEY,
            $columnTitle TEXT,
            $columnPopularity REAL,
            $columnOverview TEXT,
            $columnPosterPath TEXT,
            $columnReleaseDate TEXT,
            $columnVoteCount INTEGER,
            $columnVoteAverage REAL,
            $columnOriginalLanguage TEXT,
            $columnOriginalTitle TEXT,
            $columnGenreIDs TEXT,
            $columnBackdropPath TEXT
          )
          ''');
  }

  //Update function for DB
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    var query = await db
        .rawQuery('SELECT * FROM $table WHERE $columnID="${row["id"]}"');

    int movieId = row["id"];

    if (query.isNotEmpty) {
      print("we deleting: ${row['title']}, with id: $movieId");
      return await db
          .delete(table, where: '$columnID = ?', whereArgs: ['$movieId']);
    } else {
      print("we adding ${row['title']}, with id: $movieId");
      return await db.insert(table, row);
    }
  }

  //Queries all rows for DB.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    // print("we querying!");
    Database db = await instance.database;
    return await db.query(table);
  }

  //Drops a tables of DB
  Future<void> drop() async {
    print("DROPPING DB");
    Database db = await instance.database;
    return db.execute("DROP TABLE IF EXISTS $_databaseName");
  }

  //Gets the list of saved movies from the DB.
  Future<List<TMDBMovie>> getMovies() async {
    print("get movies called!");

    Database db = await instance.database;

    final List<Map<String, dynamic>> movies = await db.query('$table');

    return List.generate(movies.length, (i) {
      return TMDBMovie(
          id: movies[i]['id'],
          title: movies[i]['title'],
          popularity: movies[i]['popularity'],
          overview: movies[i]['overview'],
          posterPath: movies[i]['poster_path'],
          releaseDate: movies[i]['release_date'],
          voteCount: movies[i]['vote_count'],
          voteAverage: movies[i]['vote_average'],
          originalLanguage: movies[i]['original_language'],
          originalTitle: movies[i]['original_title'],
          genreIds: movies[i]['genre_ids'],
          backdropPath: movies[i]['backdropPath']);
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
