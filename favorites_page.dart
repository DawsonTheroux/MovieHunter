import 'package:flutter/material.dart';
import 'dart:async';
import 'models/tmdb_movie.dart';
import 'models/tmdb_show.dart';
import 'api.dart';
import 'movie_db_helper.dart';
import 'show_db_helper.dart';

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key, this.api, this.movieDB, this.showDB})
      : super(key: key);
  final TMDBApi api;
  final MovieDatabaseHelper movieDB;
  final ShowDatabaseHelper showDB;

  @override
  _FavoritesPageState createState() =>
      _FavoritesPageState(this.api, this.movieDB, this.showDB);
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TMDBApi api;
  final MovieDatabaseHelper movieDB;
  final ShowDatabaseHelper showDB;
  _FavoritesPageState(this.api, this.movieDB, this.showDB);

  int selectedIndex = 0;

  @override
  void initState() {
    print("initState called");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
      ),
      body: showFavorites(),
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

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget showFavorites() {
    if (selectedIndex == 0) {
      return showFavoriteMovies();
    }
    return showFavoriteShows();
  }

  Widget showFavoriteMovies() {
    return FutureBuilder<List<TMDBMovie>>(
        future: getFavoriteMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            return Center(child: Text("snapshot error"));
          }

          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                final movie = snapshot.data[index];
                return movie.buildRow(context, api, movieDB);
              });
        });
  }

  Widget showFavoriteShows() {
    return FutureBuilder<List<TMDBShow>>(
        future: getFavoriteShows(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            return Center(child: Text("snapshot error"));
          }

          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                final show = snapshot.data[index];
                return show.buildRow(context, api, showDB);
              });
        });
  }

  Future<List<TMDBMovie>> getFavoriteMovies() async {
    var allMovies = await movieDB.getMovies();
    return allMovies;
  }

  Future<List<TMDBShow>> getFavoriteShows() async {
    var allShows = await showDB.getShows();
    return allShows;
  }
}
