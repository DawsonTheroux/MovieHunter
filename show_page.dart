import 'package:flutter/material.dart';
import 'dart:async';
import 'genre_page.dart';
import 'actor_page.dart';
import 'api.dart';
import 'models/tmdb_show.dart';
import 'models/tmdb_genre.dart';
import 'models/tmdb_actor.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'show_db_helper.dart';

class ShowPage extends StatefulWidget {
  ShowPage({Key key, this.title, this.show, this.api, this.db})
      : super(key: key);
  final String title;
  final TMDBShow show;
  final TMDBApi api;
  final ShowDatabaseHelper db;

  @override
  _ShowPageState createState() => _ShowPageState(this.api, this.db);
}

class _ShowPageState extends State<ShowPage> {
  final TMDBApi api;
  final ShowDatabaseHelper db;
  _ShowPageState(this.api, this.db);

  Set<String> savedShows = {};

  Widget build(BuildContext context) {
    final TextStyle _biggerFont = const TextStyle(fontSize: 18);
    return FutureBuilder<List<TMDBShow>>(
        future: getFavoriteShows(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            return Center(child: Text("snapshot error"));
          }

          for (int i = 0; i < snapshot.data.length; i++) {
            savedShows.add(snapshot.data[i].name);
          }
          bool alreadySaved = savedShows.contains(widget.show.name);
          Map<String,String> mapSectionNames = getSecNames(api.apiLang);
          return Scaffold(
            appBar: AppBar(title: Text(widget.show.name), actions: [
              IconButton(
                  icon: Icon(
                    alreadySaved ? Icons.favorite : Icons.favorite_border,
                    color:
                        alreadySaved // if it's saved, make it white, otherwise, no color.
                            ? Colors.white
                            : null,
                  ),
                  onPressed: () async {
                    setState(() {
                      if (alreadySaved) {
                        savedShows.remove(widget.show.name);
                      } else {
                        savedShows.add(widget.show.name);
                      }
                    });
                    _updateFavoriteShow(widget.show);
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
                        "http://image.tmdb.org/t/p/w400/${widget.show.posterPath}",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                Container(
                  //VoteAverage (rating).
                  child: widget.show.createStars(),
                  height: 50,
                ),
                Container(
                  height: 50,
                  child: Row(//Release date.
                      children: <Text>[
                    Text(mapSectionNames["Seasons"],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18)),
                    Text(" " + widget.show.numberOfSeasons.toString(),
                        style: _biggerFont),
                  ]),
                ),
                Container(
                  child: Row(//Release date.
                      children: <Text>[
                    Text(mapSectionNames["Episodes"],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18)),
                    Text(" " + widget.show.numberOfEpisodes.toString(),
                        style: _biggerFont),
                  ]),
                ),
                Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Text(mapSectionNames["Genres"],
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18))),
                FutureBuilder<List<Genre>>(
                    future: api.getGenresById(widget.show.id, "tv"),
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
                  alignment: Alignment.centerLeft,
                  child: Text(mapSectionNames["AO"],
                      style: TextStyle(
                          decoration: TextDecoration.underline, fontSize: 18)),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                    future: api.getWatchOn(widget.show.id),
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
                  child: Text(widget.show.overview,
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
                    future: api.getCast(widget.show.id, "tv"),
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
                                                      dbShowHelper: db,
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

  //updates the list of fav shows from the DB.
  void _updateFavoriteShow(TMDBShow show) async {
    await db.update(show.toDBMap());
  }

  //Gets the list of fav shows from the DB.
  Future<List<TMDBShow>> getFavoriteShows() async {
    var allMovies = await db.getShows();
    return allMovies;
  }

  //Gets the correct words for the Show page.
  Map<String, String> getSecNames (String apiLang){
    switch (apiLang) {
      case "fr":
        {
          return {
            "Seasons" : "Saisons:",
            "Episodes" : "Épisodes:",
            "Desc" : "Description:",
            "Genres": "Genres:",
            "AO": "Disponible sur:",
            "Cast": "Role des Acteurs:",
          };
        }
        break;

      case "es":
        {
          return {
            "Seasons" : "Estaciones:",
            "Episodes" : "Episodios:",
            "Desc": "Descripción:",
            "Genres": "Géneros:",
            "AO": "Disponible en:",
            "Cast": "elenco:",
          };
        }
        break;

      default:
        {
          return {
            "Seasons" : "Seasons:",
            "Episodes" : "Episodes:",
            "Desc" : "Description:",
            "Genres": "Genres:",
            "AO": "Available on:",
            "Cast": "Cast:",
          };
        }
        break;
    }
  }
}
