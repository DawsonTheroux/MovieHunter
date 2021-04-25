import 'dart:async';
import 'package:flutter/material.dart';
import 'api.dart';
import 'movie_page.dart';
import 'show_page.dart';
import 'models/tmdb_actor.dart';
import 'models/tmdb_credit.dart';
import 'models/tmdb_movie.dart';
import 'models/tmdb_show.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_db_helper.dart';
import 'show_db_helper.dart';

class ActorPage extends StatefulWidget {
  ActorPage(
      {Key key, this.actorID, this.api, this.dbMovieHelper, this.dbShowHelper})
      : super(key: key);
  final int actorID;
  final TMDBApi api;
  final MovieDatabaseHelper dbMovieHelper;
  final ShowDatabaseHelper dbShowHelper;

  @override
  _ActorPageState createState() =>
      _ActorPageState(this.api, this.dbMovieHelper, this.dbShowHelper);
}

class _ActorPageState extends State<ActorPage> {
  Future<Actor> futureActor;
  Future<TMDBMovie> futureMovie;
  Future<TMDBShow> futureShow;
  Future<List<Credit>> futureCredits;
  final TMDBApi api;
  final MovieDatabaseHelper dbMovieHelper;
  final ShowDatabaseHelper dbShowHelper;
  _ActorPageState(this.api, this.dbMovieHelper, this.dbShowHelper);

  @override
  Widget build(BuildContext context) {
    print('Actor ID ${widget.actorID}');
    futureActor = api.fetchActor(widget.actorID);
    futureCredits = api.fetchCredits(widget.actorID);

    Widget headerSection = Container(
      child: FutureBuilder<Actor>(
        future: futureActor,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: 50, left: 120, right: 120, bottom: 30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: snapshot.data.profilePath,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Text(
                  snapshot.data.name,
                  style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );

    Widget actingSection = Container(
      child: FutureBuilder<List<Credit>>(
        future: futureCredits,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding:
                  EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 30),
              child: Container(
                constraints: BoxConstraints(maxHeight: 300, maxWidth: 250),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      if (snapshot.data[index].media_type == "movie") {
                        futureMovie = api.getMovieByID(snapshot.data[index].id);
                        return FutureBuilder<TMDBMovie>(
                            future: futureMovie,
                            builder: (context, snapMovie) {
                              if (snapMovie.hasData) {
                                print(snapMovie.data.title);
                                return SizedBox(
                                    width: 200,
                                    child: Card(
                                      margin: EdgeInsets.all(10),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MoviePage(
                                                    movie: snapMovie.data,
                                                    api: api,
                                                    db: dbMovieHelper)),
                                          );
                                        },
                                        child: Column(children: <Widget>[
                                          CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            imageUrl:
                                                snapshot.data[index].posterPath,
                                            height: 200,
                                            width: 200,
                                          ),
                                          Text(
                                            snapshot.data[index].title,
                                            style: TextStyle(fontSize: 18),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                          Text(
                                              "as " +
                                                  snapshot
                                                      .data[index].character,
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                        ]),
                                      ),
                                    ));
                              } else if (snapMovie.hasError) {
                                print("ERROR");
                                return Text("${snapMovie.error}");
                              }
                              // By default, show a loading spinner.
                              return CircularProgressIndicator();
                            });
                      }

                      futureShow = api.getShowByID(snapshot.data[index].id);
                      return FutureBuilder<TMDBShow>(
                          future: futureShow,
                          builder: (context, snapShow) {
                            if (snapShow.hasData) {
                              print(snapShow.data.name);
                              return SizedBox(
                                  width: 200,
                                  child: Card(
                                    margin: EdgeInsets.all(10),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ShowPage(
                                                  show: snapShow.data,
                                                  api: api,
                                                  db: dbShowHelper)),
                                        );
                                      },
                                      child: Column(children: <Widget>[
                                        CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          imageUrl:
                                              snapshot.data[index].posterPath,
                                          height: 200,
                                          width: 200,
                                        ),
                                        Text(
                                          snapshot.data[index].title,
                                          style: TextStyle(fontSize: 18),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3,
                                        ),
                                        Text(
                                            "as " +
                                                snapshot.data[index].character,
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ]),
                                    ),
                                  ));
                            } else if (snapShow.hasError) {
                              print("ERROR");
                              return Text("${snapShow.error}");
                            }
                            // By default, show a loading spinner.
                            return CircularProgressIndicator();
                          });
                    }),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );

    Widget personalInfoSection = Container(
      child: FutureBuilder<Actor>(
        future: futureActor,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 35, left: 25, right: 25),
                    child: Text(
                      "Personal Info",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, left: 25, right: 25),
                    child: Text(
                      "Known For",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 4, left: 25, right: 25),
                    child: Text(
                      snapshot.data.knownForDept,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, left: 25, right: 25),
                    child: Text(
                      "Gender",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 4, left: 25, right: 25),
                    child: Text(
                      snapshot.data.gender,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, left: 25, right: 25),
                    child: Text(
                      "Birthday",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 4, left: 25, right: 25),
                    child: Text(
                      snapshot.data.birthday,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, left: 25, right: 25),
                    child: Text(
                      "Place of Birth",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 4, left: 25, right: 25),
                    child: Text(
                      snapshot.data.placeOfBirth,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );

    Widget biographySection = Container(
      child: FutureBuilder<Actor>(
        future: futureActor,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 35, left: 25, right: 25),
                    child: Text(
                      "Biography",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, left: 25, right: 25),
                    child: Text(
                      snapshot.data.biography,
                      style: TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return CircularProgressIndicator();
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Actor details'),
      ),
      body: ListView(
        children: [
          headerSection,
          personalInfoSection,
          biographySection,
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 35, left: 25, right: 25),
              child: Text(
                "Acting",
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          actingSection
        ],
      ),
    );
  }
}
