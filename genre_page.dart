import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'models/tmdb_movie.dart';
import 'models/tmdb_show.dart';
import 'api.dart';
import 'movie_db_helper.dart';
import 'show_db_helper.dart';

class GenrePage extends StatefulWidget {
  GenrePage(
      {Key key, this.genre, this.genreID, this.api, this.movieDB, this.showDB})
      : super(key: key);
  final String genre;
  final int genreID;
  final TMDBApi api;
  final MovieDatabaseHelper movieDB;
  final ShowDatabaseHelper showDB;
  int page = 1;

  @override
  _GenrePageState createState() =>
      _GenrePageState(this.api, this.movieDB, this.showDB);
}

class _GenrePageState extends State<GenrePage> {
  final TMDBApi api;
  final MovieDatabaseHelper movieDB;
  final ShowDatabaseHelper showDB;
  _GenrePageState(this.api, this.movieDB, this.showDB);

  String displayValue = 'Most Popular';
  String convertedValue = 'popularity.desc';
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genre),
        actions: [
          //dropdown menu to display sorting options
          buildDropDownButton()
        ],
      ),
      body: Center(
          child:
              buildPage() //function that creates the list of movies from given genre
          ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Shows',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }

  //Updates the bottom nav bar.
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      widget.page = 1;
    });
  }

  //builds the page based of shows and movies.
  Widget buildPage() {
    if (selectedIndex == 0) {
      return buildGenreMovies();
    } else
      return buildGenreShows();
  }

  //builds the a genre page for movies.
  Widget buildGenreMovies() {
    Future<TMDBMovieSearchResponse> genreMovies;
    genreMovies = api.getGenreMovies(widget.page, widget.genreID,
        convertedValue); //get first page of movies from genre

    return FutureBuilder<TMDBMovieSearchResponse>(
        future: genreMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            print("snapshot loading");
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            print("snapshot error");
            return Center(child: Text("snapshot error"));
          }
          return Container(
            child: ListView.builder(
              itemCount: 21,
              itemBuilder: (BuildContext context, int index) {
                // map index to movie in dictionary?
                if (index != 20) {
                  int movieID = snapshot.data.results[index].id;
                  return FutureBuilder<TMDBMovie>(
                    future: api.getMovieByID(movieID),
                    builder: (context, futureMovie) {
                      if (futureMovie.hasData) {
                        return futureMovie.data.buildRow(context, api, movieDB);
                      } else if (futureMovie.hasError) {
                        return Text("Error retrieving movie");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
                } else {
                  if (widget.page == 1) {
                    return ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text('Next Page'),
                              onPressed: () {
                                setState(() {
                                  widget.page++;
                                });
                              })
                        ]);
                  } else {
                    return ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text('Previous Page'),
                              onPressed: () {
                                setState(() {
                                  widget.page--;
                                });
                              }),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text('Next Page'),
                              onPressed: () {
                                setState(() {
                                  widget.page++;
                                });
                              })
                        ]);
                  }
                }
              },
            ),
          );
        });
  }

  //builds the genre page for shows.
  Widget buildGenreShows() {
    Future<TMDBShowSearchResponse> genreShows;
    genreShows = api.getGenreShows(widget.page, widget.genreID,
        convertedValue); //get first page of shows from genre

    return FutureBuilder<TMDBShowSearchResponse>(
        future: genreShows,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            print("snapshot loading");
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            print("snapshot error");
            return Center(child: Text("snapshot error"));
          }
          return Container(
            child: ListView.builder(
              itemCount: 21,
              itemBuilder: (BuildContext context, int index) {
                if (index != 20) {
                  int showID = snapshot.data.results[index].id;
                  return FutureBuilder<TMDBShow>(
                    future: api.getShowByID(showID),
                    builder: (context, futureShow) {
                      if (futureShow.hasData) {
                        return futureShow.data.buildRow(context, api, showDB);
                      } else if (futureShow.hasError) {
                        return Text("Error retrieving movie");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
                } else {
                  if (widget.page == 1) {
                    return ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text('Next Page'),
                              onPressed: () {
                                setState(() {
                                  widget.page++;
                                });
                              })
                        ]);
                  } else {
                    return ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text('Previous Page'),
                              onPressed: () {
                                setState(() {
                                  widget.page--;
                                });
                              }),
                          ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                              ),
                              child: Text('Next Page'),
                              onPressed: () {
                                setState(() {
                                  widget.page++;
                                });
                              })
                        ]);
                  }
                }
              },
            ),
          );
        });
  }

  //builds the drop down menu button.
  Widget buildDropDownButton() {
    return DropdownButton<String>(
        dropdownColor: Colors.red,
        value: displayValue,
        items: <String>[
          'Most Popular',
          'Least Popular',
          'Newest',
          'Highly Rated'
        ].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: (String newValue) {
          if (newValue != displayValue) {
            widget.page = 1;
            setState(() {
              displayValue = newValue;
              convertedValue = matchString(displayValue);
            });
          }
        });
  }

  String matchString(String input) {
    if (input == 'Most Popular')
      return 'popularity.desc';
    else if (input == 'Least Popular')
      return 'popularity.asc';
    else if (input == 'Newest') if (selectedIndex == 0)
      return 'release_date.desc';
    else
      return 'first_air_date.desc';
    else //if (input == 'Highly Rated')
      return 'vote_average.desc';
  }
}
