import 'tmdb_genre.dart';
import 'package:flutter/material.dart';
import '../show_page.dart';
import '../api.dart';
import '../show_db_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

//Creates a List of shows from result from TMDB.
class TMDBShowSearchResponse {
  TMDBShowSearchResponse({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  int page;
  List<TMDBShow> results;
  int totalPages;
  int totalResults;

  factory TMDBShowSearchResponse.fromJson(Map<String, dynamic> json) {
    return TMDBShowSearchResponse(
      page: json["page"],
      results: (json['results'] as List)
          ?.map((e) =>
              e == null ? null : TMDBShow.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      totalPages: json["total_pages"],
      totalResults: json["total_results"],
    );
  }

  Map<String, dynamic> toJson(TMDBShowSearchResponse search) {
    return <String, dynamic>{
      "page": search.page,
      "results": search.results,
      "total_pages": search.totalPages,
      "total_results": search.totalResults
    };
  }
}

class TMDBShow {
  TMDBShow({
    this.backdropPath,
    this.createdBy,
    this.episodeRunTime,
    this.genres,
    this.homepage,
    this.id,
    this.inProduction,
    this.languages,
    this.name,
    this.networks,
    this.numberOfEpisodes,
    this.numberOfSeasons,
    this.originalLanguage,
    this.originalName,
    this.overview,
    this.popularity,
    this.posterPath,
    this.productionCompanies,
    this.seasons,
    this.status,
    this.type,
    this.voteAverage,
    this.voteCount,
  });

  String backdropPath;
  List<CreatedBy> createdBy;
  List<int> episodeRunTime;
  List<Genre> genres;
  String homepage;
  int id;
  bool inProduction;
  List<String> languages;
  String name;
  List<Network> networks;
  int numberOfEpisodes;
  int numberOfSeasons;
  String originalLanguage;
  String originalName;
  String overview;
  double popularity;
  String posterPath;
  List<Network> productionCompanies;
  List<Season> seasons;
  String status;
  String type;
  double voteAverage;
  int voteCount;

  factory TMDBShow.fromJson(Map<String, dynamic> json) => TMDBShow(
        backdropPath: json["backdrop_path"] as String,
        createdBy: (json['created_by'] as List)
            ?.map((e) => e == null
                ? null
                : CreatedBy.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        episodeRunTime:
            (json['episode_run_time'] as List)?.map((e) => e as int)?.toList(),
        genres: (json['genres'] as List)
            ?.map((e) =>
                e == null ? null : Genre.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        homepage: json["homepage"] as String,
        id: json["id"] as int,
        inProduction: json["in_production"] as bool,
        languages:
            (json['languages'] as List)?.map((e) => e as String)?.toList(),
        name: json["name"] as String,
        networks: (json['networks'] as List)
            ?.map((e) =>
                e == null ? null : Network.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        numberOfEpisodes: json["number_of_episodes"] as int,
        numberOfSeasons: json["number_of_seasons"] as int,
        originalLanguage: json["original_language"] as String,
        originalName: json["original_name"] as String,
        overview: json["overview"] as String,
        popularity: (json['popularity'] as num)?.toDouble(),
        posterPath: json["poster_path"] as String,
        productionCompanies: (json['production_companies'] as List)
            ?.map((e) =>
                e == null ? null : Network.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        seasons: (json['seasons'] as List)
            ?.map((e) =>
                e == null ? null : Season.fromJson(e as Map<String, dynamic>))
            ?.toList(),
        status: json["status"] as String,
        type: json["type"] as String,
        voteAverage: (json['vote_average'] as num)?.toDouble(),
        voteCount: json["vote_count"] as int,
      );

  Map<String, dynamic> toJson(TMDBShow show) {
    return <String, dynamic>{
      "backdrop_path": show.backdropPath,
      "created_by": show.createdBy,
      "episode_run_time": show.episodeRunTime,
      "genres": show.genres,
      "homepage": show.homepage,
      "id": show.id,
      "in_production": show.inProduction,
      "languages": show.languages,
      "name": show.name,
      "networks": show.networks,
      "number_of_episodes": show.numberOfEpisodes,
      "number_of_seasons": show.numberOfSeasons,
      "original_language": show.originalLanguage,
      "original_name": show.originalName,
      "overview": show.overview,
      "popularity": show.popularity,
      "poster_path": show.posterPath,
      "production_companies": show.productionCompanies,
      "seasons": show.seasons,
      "status": show.status,
      "type": show.type,
      "vote_average": show.voteAverage,
      "vote_count": show.voteCount,
    };
  }

  Map<String, dynamic> toDBMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'number_of_episodes': numberOfEpisodes,
      'number_of_seasons': numberOfSeasons,
      'overview': overview,
      'poster_path': posterPath,
      'vote_average': voteAverage
    };
  }

  Widget createStars() {
    double num = voteAverage / 2;
    double starSize = 40;
    print(num);
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
      BuildContext context, TMDBApi api, ShowDatabaseHelper dbShowHelper) {
    return new Card(
        child: ListTile(
      leading: Container(
          child: CachedNetworkImage(
        imageUrl: "http://image.tmdb.org/t/p/w185/$posterPath",
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      )),
      title: Container(child: Text(name)),
      subtitle: Center(
          child: Text(
        overview,
        maxLines: 3,
      )),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ShowPage(show: this, api: api, db: dbShowHelper)),
        );
      },
    ));
  }
}

class CreatedBy {
  CreatedBy({
    this.id,
    this.creditId,
    this.name,
    this.gender,
    this.profilePath,
  });

  int id;
  String creditId;
  String name;
  int gender;
  dynamic profilePath;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        creditId: json["credit_id"],
        name: json["name"],
        gender: json["gender"],
        profilePath: json["profile_path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "credit_id": creditId,
        "name": name,
        "gender": gender,
        "profile_path": profilePath,
      };
}

class Network {
  Network({
    this.name,
    this.id,
    this.logoPath,
    this.originCountry,
  });

  String name;
  int id;
  String logoPath;
  String originCountry;

  factory Network.fromJson(Map<String, dynamic> json) => Network(
        name: json["name"],
        id: json["id"],
        logoPath: json["logo_path"],
        originCountry: json["origin_country"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "logo_path": logoPath,
        "origin_country": originCountry,
      };
}

class Season {
  Season({
    this.episodeCount,
    this.id,
    this.name,
    this.overview,
    this.posterPath,
    this.seasonNumber,
  });

  int episodeCount;
  int id;
  String name;
  String overview;
  String posterPath;
  int seasonNumber;

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        episodeCount: json["episode_count"],
        id: json["id"],
        name: json["name"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        seasonNumber: json["season_number"],
      );

  Map<String, dynamic> toJson() => {
        "episode_count": episodeCount,
        "id": id,
        "name": name,
        "overview": overview,
        "poster_path": posterPath,
        "season_number": seasonNumber,
      };
}
