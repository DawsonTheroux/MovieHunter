import 'package:flutter/material.dart';
import 'dart:async';
import 'models/tmdb_movie.dart';
import 'models/tmdb_genre.dart';
import 'models/tmdb_actor.dart';
import 'genre_page.dart';
import 'actor_page.dart';
import 'api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_db_helper.dart';

class MoviePage extends StatefulWidget {
  MoviePage({Key key, this.title, this.movie, this.api, this.db})
      : super(key: key);
  final String title;
  final TMDBMovie movie;
  final TMDBApi api;
  final MovieDatabaseHelper db;

  @override
  _MoviePageState createState() => _MoviePageState(this.api, this.db);
}

class _MoviePageState extends State<MoviePage> {
  final TMDBApi api;
  final MovieDatabaseHelper db;
  _MoviePageState(this.api, this.db);

  Set<String> savedMovies = {};

  Widget build(BuildContext context) {
    final TextStyle _biggerFont = const TextStyle(fontSize: 18);
    return FutureBuilder<List<TMDBMovie>>(
        future: getFavoriteMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            return Center(child: Text("snapshot error"));
          }

          for (int i = 0; i < snapshot.data.length; i++) {
            savedMovies.add(snapshot.data[i].title);
          }
          Map<String,String> mapSectionNames = getSecNames(api.apiLang);
          bool alreadySaved = savedMovies.contains(widget.movie.title);
          return Scaffold(
            appBar: AppBar(title: Text(widget.movie.title), actions: [
              IconButton(
                  icon: Icon(
                    alreadySaved ? Icons.favorite : Icons.favorite_border,
                    color:
                        alreadySaved // if it's saved, make it white, otherwise, no color
                            ? Colors.white
                            : null,
                  ),
                  onPressed: () async {
                    setState(() {
                      if (alreadySaved) {
                        savedMovies.remove(widget.movie.title);
                      } else {
                        savedMovies.add(widget.movie.title);
                      }
                    });

                    _updateFavoriteMovie(widget.movie);
                  }),
            ]),
            body: SingleChildScrollView(
                child: Column(
              children: <Widget>[
                Container(
                  //Poster Container.
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  child: CachedNetworkImage(
                    imageUrl:
                        "http://image.tmdb.org/t/p/w400/${widget.movie.posterPath}",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Container(
                  //VoteAverage (rating).
                  child: widget.movie.createStars(),
                  height: 50,
                ),
                Container(
                  height: 50,
                  child: Row(//Release date.
                      children: <Widget>[
                    Text(mapSectionNames["RD"],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18)),
                    Text(widget.movie.releaseDate.toString(),
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18)),
                  ]),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(mapSectionNames["Genres"],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18))),
                FutureBuilder<List<Genre>>(
                    future: api.getGenresById(widget.movie.id, "movie"),
                    builder: (context, snapGenre) {
                      if (snapGenre.hasData) {
                        return Container(
                            constraints:
                                BoxConstraints(maxHeight: 100, minHeight: 10),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapGenre.data.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      width: 135,
                                      alignment: Alignment.center,
                                      child: Card(
                                          margin: EdgeInsets.all(10),
                                          child: ListTile(
                                              title: Text(
                                                  snapGenre.data[index].name),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          GenrePage(
                                                              genre: snapGenre
                                                                  .data[index]
                                                                  .name,
                                                              genreID: snapGenre
                                                                  .data[index]
                                                                  .id,
                                                              api: api)),
                                                );
                                              })));
                                }));
                      } else if (snapGenre.hasError) {
                        print(snapGenre.error);
                        return Text("${snapGenre.error}");
                      } else {
                        return Text("Loading");
                      }
                    }),
                Container(
                  //Text("Description: ")
                  alignment: Alignment.centerLeft,
                  child: Text(mapSectionNames["AO"],
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 18)),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: api.getWatchOn(widget.movie.id),
                    builder: (context, watchList) {
                      if (watchList.hasData) {
                        return Container(
                            constraints:
                                BoxConstraints(maxHeight: 100, minHeight: 10),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: watchList.data.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      width: 100,
                                      alignment: Alignment.center,
                                      child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          imageUrl: watchList.data[index]
                                              ['icon']));
                                }));
                      } else if (watchList.hasError) {
                        print(watchList.error);
                        return Text("${watchList.error}");
                      } else {
                        return Text("Loading");
                      }
                    }),
                Container(
                  //Text("Description: ")
                  alignment: Alignment.centerLeft,
                  child: Text(mapSectionNames["Desc"],
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 18)),
                ),
                Container(
                  //Overview (description).
                  alignment: Alignment.center,
                  child: Text(widget.movie.overview,
                      style: _biggerFont, textAlign: TextAlign.left),
                  padding: EdgeInsets.all(10.0),
                ),
                Container(
                  //Text("cast ")
                  alignment: Alignment.centerLeft,
                  child: Text(mapSectionNames["Cast"],
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 18)),
                ),
                FutureBuilder<List<Actor>>(
                    future: api.getCast(widget.movie.id, "movie"),
                    builder: (context, snapActor) {
                      if (snapActor.hasData) {
                        return Container(
                            constraints:
                                BoxConstraints(maxHeight: 275, minHeight: 10),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapActor.data.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: EdgeInsets.all(10),
                                    child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ActorPage(
                                                      actorID: snapActor
                                                          .data[index].id,
                                                      api: api,
                                                      dbMovieHelper: db,
                                                    )),
                                          );
                                        },
                                        child: Column(children: <Widget>[
                                          Image.network(
                                              snapActor.data[index].profilePath,
                                              scale: 3),
                                          Text(snapActor.data[index].name,
                                              style: _biggerFont),
                                          Text(snapActor.data[index].character,
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ])),
                                  );
                                }));
                      } else if (snapActor.hasError) {
                        print(snapActor.error);
                        return Text("${snapActor.error}");
                      } else {
                        return Text("Loading");
                      }
                    }),
              ],
            )),
          );
        });
  }

  //updates fav movies when a movies is favourited.
  void _updateFavoriteMovie(TMDBMovie movie) async {
    await db.update(movie.toDBMap());
  }

  //gets the list of fav movies.
  Future<List<TMDBMovie>> getFavoriteMovies() async {
    var allMovies = await db.getMovies();
    return allMovies;
  }

  //gets all the words in the correct languages.
  Map<String, String> getSecNames (String apiLang){
    switch (apiLang) {
      case "fr":
        {
          return {
            "RD": "Date de sortie:",
            "Desc" : "Description",
            "Genres": "Genres",
            "AO": "Disponible sur:",
            "Cast": "Role des Acteurs:",
          };
        }
        break;

      case "es":
        {
          return {
            "RD": "Fecha de lanzamiento:",
            "Desc": "Descripción:",
            "Genres": "Géneros",
            "AO": "Disponible en:",
            "Cast": "elenco:",
          };
        }
        break;

      default:
        {
          return {
            "RD": "Release Date",
            "Desc" : "Description",
            "Genres": "Genres:",
            "AO": "Available on:",
            "Cast": "Cast:",
          };
        }
        break;
    }
  }
}
