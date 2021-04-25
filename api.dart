import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'models/tmdb_movie.dart';
import 'models/tmdb_show.dart';
import 'models/tmdb_genre.dart';
import 'models/tmdb_actor.dart';
import 'models/tmdb_credit.dart';

const String TMDB_API_URL = "https://api.themoviedb.org/3";
const String TMDB_API_KEY = /*API KEY REMOVED*/;

class TMDBApi {
  String language;

  TMDBApi() {
    this.language = "en";
  }

  get apiLang {
    return this.language;
  }

  set apiLang(String lang) {
    this.language = lang;
  }

  Future<GenreSearchResponse> getGenres() async {
    String url =
        "$TMDB_API_URL/genre/movie/list?api_key=$TMDB_API_KEY&language=${this.language}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return GenreSearchResponse.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load genres');
  }

  Future<TMDBMovieSearchResponse> getPopularMovies(int page) async {
    String url =
        "$TMDB_API_URL/movie/popular?api_key=$TMDB_API_KEY&language=${this.language}&page=$page";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return TMDBMovieSearchResponse.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load movie');
  }

  Future<TMDBMovieSearchResponse> getTrendingMovies(int page) async {
    String url =
        "$TMDB_API_URL/trending/movie/week?api_key=$TMDB_API_KEY&page=$page&language=${this.language}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return TMDBMovieSearchResponse.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load movie');
  }

  Future<TMDBMovie> getMovieByID(int id) async {
    String url =
        "$TMDB_API_URL/movie/$id?api_key=$TMDB_API_KEY&language=${this.language}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return TMDBMovie.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load movie');
  }

  Future<TMDBShowSearchResponse> getPopularShows(int page) async {
    String url =
        "$TMDB_API_URL/tv/popular?api_key=$TMDB_API_KEY&language=${this.language}&page=$page";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return TMDBShowSearchResponse.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load show');
  }

  Future<TMDBShowSearchResponse> getTrendingShows(int page) async {
    String url =
       
        "$TMDB_API_URL/trending/tv/week?api_key=$TMDB_API_KEY&page=$page&language=${this.language}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return TMDBShowSearchResponse.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load show');
  }

  Future<TMDBShow> getShowByID(int id) async {
    String url =
        "$TMDB_API_URL/tv/$id?api_key=$TMDB_API_KEY&language=${this.language}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return TMDBShow.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load show');
  }

  //Gets the cast for a movie based on the id.
  Future<List<Actor>> getCast(int movieId, String contentType) async {
    List<Actor> cast = List();
    print("Loading movie");
    final resCredits = await http.get(
		//API key removed from next line
        'https://api.themoviedb.org/3/$contentType/$movieId/credits?api_key=&language=${this.language}');

    if (resCredits.statusCode == 200) {
      Map<String, dynamic> jsonCredits = jsonDecode(resCredits.body);
      for (int i = 0; i < jsonCredits['cast'].length; i++) {
        Actor a = Actor.fromJson(jsonCredits['cast'][i]);
        cast.add(a);
      }
      return cast;
    } else {
      print("Failed to load movie");
      throw Exception('Failed to load movie.');
    }
  }

  //Gets the available streaming services for a movie from the id and the content type.
  Future<List<Map<String, dynamic>>> getWatchOn(int id) async {
    List<Map<String, dynamic>> lstWatchOn = List();
    // final utelliRes = await http.get(
    //     'https://rapidapi.p.rapidapi.com/idlookup?source_id=$id&source=tmdb&country=ca',
    //     headers: ({
    //       "x-rapidapi-host":
    //           "utelly-tv-shows-and-movies-availability-v1.p.rapidapi.com",
    //       "x-rapidapi-key": "/API KEY REMOVED*/"
    //     }));

    // if (utelliRes.statusCode == 200) {
    //   Map<String, dynamic> jsonWatchOn = jsonDecode(utelliRes.body);

    //   if (jsonWatchOn['collection'].containsKey('locations')) {
    //     for (int i = 0;
    //         i < jsonWatchOn['collection']['locations'].length;
    //         i++) {
    //       Map<String, dynamic> sService = Map();
    //       sService['displayName'] =
    //           jsonWatchOn['collection']['locations'][i]['display_name'];
    //       sService['icon'] = jsonWatchOn['collection']['locations'][i]['icon'];
    //       sService['url'] = jsonWatchOn['collection']['locations'][i]['url'];
    //       sService['source_url'] =
    //           jsonWatchOn['collection']['source_ids']['tmdb']['url'];
    //       lstWatchOn.add(sService);
    //     }
    //   }
    // }
    return lstWatchOn;
  }

  //Gets the list of genres for a movie by id
  Future<List<Genre>> getGenresById(int id, String contentType) async {
    List<Genre> retLst = List();
    String url =
        "$TMDB_API_URL/$contentType/$id?api_key=$TMDB_API_KEY&language=${this.language}";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      for (int i = 0; i < json.decode(response.body)['genres'].length; i++) {
        Genre g = Genre.fromJson(json.decode(response.body)['genres'][i]);
        retLst.add(g);
      }
      return retLst;
    } else {
      print("failed to load genres");
      return null;
    }
  }

  Future<TMDBMovieSearchResponse> getGenreMovies(
      int page, int genreID, String sort) async {
    String url =
        "$TMDB_API_URL/discover/movie?api_key=$TMDB_API_KEY&language=${this.language}&sort_by=$sort&" +
            "include_adult=false&include_video=false&page=$page&with_genres=$genreID";
    final response = await http.get(url);
    return TMDBMovieSearchResponse.fromJson(json.decode(response.body));
  }

  Future<TMDBShowSearchResponse> getGenreShows(
      int page, int genreID, String sort) async {
    String url =
        "$TMDB_API_URL/discover/tv?api_key=$TMDB_API_KEY&language=${this.language}&sort_by=$sort&" +
            "&page=$page&with_genres=$genreID&include_null_first_air_dates=false";
    final response = await http.get(url);
    return TMDBShowSearchResponse.fromJson(json.decode(response.body));
  }

  Future<Actor> fetchActor(int actorID) async {
    final response = await http.get(
        'https://api.themoviedb.org/3/person/${actorID}?api_key=/*API KEY REMOVED*/&language=${this.language}');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Actor.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load actor');
    }
  }

  Future<List<Credit>> fetchCredits(int actorID) async {
    List<Credit> credits = List();

    final response = await http.get(
        'https://api.themoviedb.org/3/person/${actorID}/combined_credits?api_key=/*API KEY REMOVED*/&language=${this.language}');

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonCredits = jsonDecode(response.body);

      for (int i = 0; i < jsonCredits['cast'].length; i++) {
        Credit credit = Credit.fromJson(jsonCredits['cast'][i]);
        credits.add(credit);
      }

      return credits;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load credits');
    }
  }

  //Used in the search page.
  Future<List<dynamic>> searchMedia(
      String searchTerm, bool allowAdult, String mediaType) async {
    List<dynamic> resLst = List();
    List<dynamic> objLst = List();
    String url;
    //Determine if the media type the user wants to search for.
    if (mediaType == "Movies") {
      url =
          "$TMDB_API_URL/search/movie?api_key=$TMDB_API_KEY&language=${this.language}&query=$searchTerm&page=1&include_adult=$allowAdult";
    } else if (mediaType == "TV Shows") {
      url =
          "$TMDB_API_URL/search/tv?api_key=$TMDB_API_KEY&language=${this.language}&query=$searchTerm&page=1&include_adult=$allowAdult";
    } else if (mediaType == "People") {
      url =
          "$TMDB_API_URL/search/person?api_key=$TMDB_API_KEY&language=${this.language}&query=$searchTerm&page=1&include_adult=$allowAdult";
    } else {
      //all
      url =
          "$TMDB_API_URL/search/multi?api_key=$TMDB_API_KEY&language=${this.language}&query=$searchTerm&page=1&include_adult=$allowAdult";
    }
    //print("URL: " + url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      resLst = json.decode(response.body)['results'];
      //Loop through the json response and add create each object and add it to the list.
      for (int i = 0; i < resLst.length; i++) {
        if (resLst[i]['media_type'] == "movie" || mediaType == "Movies") {
          TMDBMovie m = TMDBMovie.fromJson(resLst[i]);
          objLst.add(m);
        } else if (resLst[i]['media_type'] == "tv" || mediaType == "TV Shows") {
          TMDBShow s = TMDBShow.fromJson(resLst[i]);
          objLst.add(s);
        } else if (resLst[i]['media_type'] == "person" ||
            mediaType == "People") {
          Actor a = Actor.fromJson(resLst[i]);
          objLst.add(a);
        }
      }
      return objLst;
    } else {
      throw Exception("Failed to load search response.");
    }
  }
}
