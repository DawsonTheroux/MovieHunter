import 'package:flutter/material.dart';
import '../api.dart';
import '../movie_page.dart';
import '../movie_db_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

//Creates a List of movies from TMDB response.
class TMDBMovieSearchResponse {
  int page;
  int totalResults;
  int totalPages;
  List<TMDBMovie> results;
  List<String> errors;

  TMDBMovieSearchResponse({
    this.page,
    this.totalResults,
    this.totalPages,
    this.results,
    this.errors,
  });

  //Creates a Map From json string.
  factory TMDBMovieSearchResponse.fromJson(Map<String, dynamic> json) {
    return TMDBMovieSearchResponse(
        page: json['page'] as int,
        totalResults: json['total_results'] as int,
        totalPages: json['total_pages'] as int,
        results: (json['results'] as List)
            ?.map((e) => e == null
                ? null
                : TMDBMovie.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        errors: (json['errors'] as List)?.map((e) => e as String)?.toList());
  }

  Map<String, dynamic> toJson(TMDBMovieSearchResponse search) {
    return <String, dynamic>{
      'page': search.page,
      'results': search.results,
      'total_results': search.totalResults,
      'total_pages': search.totalPages,
      'errors': search.errors
    };
  }
}

class TMDBMovie {
  int id;
  bool video;
  String title;
  double popularity;
  bool adult;
  String overview;
  String posterPath;
  String releaseDate;
  int voteCount;
  double voteAverage;
  String originalLanguage;
  String originalTitle;
  List<int> genreIds;
  String backdropPath;

  TMDBMovie(
      {this.id,
      this.video,
      this.title,
      this.popularity,
      this.adult,
      this.overview,
      this.posterPath,
      this.releaseDate,
      this.voteCount,
      this.voteAverage,
      this.originalLanguage,
      this.originalTitle,
      this.genreIds,
      this.backdropPath});

  factory TMDBMovie.fromJson(Map<String, dynamic> json) {
    return TMDBMovie(
        voteCount: json['vote_count'] as int,
        id: json['id'] as int,
        video: json['video'] as bool,
        voteAverage: (json['vote_average'] as num)?.toDouble(),
        title: json['title'] as String,
        popularity: (json['popularity'] as num)?.toDouble(),
        posterPath: json['poster_path'] as String,
        originalLanguage: json['original_language'] as String,
        originalTitle: json['original_title'] as String,
        genreIds: (json['genre_ids'] as List)?.map((e) => e as int)?.toList(),
        backdropPath: json['backdrop_path'] as String,
        adult: json['adult'] as bool,
        overview: json['overview'] as String,
        releaseDate: json['release_date'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'video': video,
      'title': title,
      'popularity': popularity,
      'adult': adult,
      'overview': overview,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'vote_count': voteCount,
      'vote_average': voteAverage,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'genre_ids': genreIds,
      'backdrop_path': backdropPath
    };
  }

  // sqflite DB can't have boolean values, so they aren't included in this function
  Map<String, dynamic> toDBMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'popularity': popularity,
      'overview': overview,
      'poster_path': posterPath,
      'release_date': releaseDate,
      'vote_count': voteCount,
      'vote_average': voteAverage,
      'original_language': originalLanguage,
      'original_title': originalTitle,
      'genre_ids': genreIds,
      'backdrop_path': backdropPath
    };
  }

  Widget createStars() {
    double starSize = 40;
    double num = voteAverage / 2;
    List<Icon> lst = List(5);
    for (int i = 0; i < (5); i++) {
      if (num > i) {
        if (num.floor() <= i) {
          lst[i] = Icon(Icons.star_half, size: starSize);
        } else {
          lst[i] = Icon(Icons.star, size: starSize);
        }
      } else {
        lst[i] = Icon(Icons.star_border, size: starSize);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: lst,
    );
  }

  Widget buildRow(
    BuildContext context,
    TMDBApi api,
    MovieDatabaseHelper dbMovieHelper,
  ) {
    return new Card(
        child: ListTile(
      leading: Container(
          child: CachedNetworkImage(
        imageUrl: "http://image.tmdb.org/t/p/w185/$posterPath",
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      )),
      title: Container(child: Text(title)),
      subtitle: Center(
          child: Text(
        overview,
        maxLines: 3,
      )),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MoviePage(
                    movie: this,
                    api: api,
                    db: dbMovieHelper,
                  )),
        );
      },
    ));
  }
}
