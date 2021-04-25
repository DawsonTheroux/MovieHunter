import 'package:flutter/material.dart';
import 'genre_page.dart';
import 'api.dart';
import 'models/tmdb_movie.dart';
import 'models/tmdb_show.dart';
import 'models/tmdb_genre.dart';
import 'search_page.dart';
import 'package:flutter/widgets.dart';
import 'favorites_page.dart';
import 'movie_db_helper.dart';
import 'show_db_helper.dart';

MyTheme curTheme = MyTheme();
void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(MyApp(
      new TMDBApi(), new ShowDatabaseHelper(), new MovieDatabaseHelper()));
}

class MyApp extends StatefulWidget {
  final TMDBApi api;
  final dbShowHelper = ShowDatabaseHelper();
  final dbMovieHelper = MovieDatabaseHelper();

  MyApp(this.api, dbShowHelper, dbMovieHelper);
  _MyAppState createState() => _MyAppState(api, dbShowHelper, dbMovieHelper);
}

class _MyAppState extends State<MyApp> {
  final TMDBApi api;
  final dbShowHelper = ShowDatabaseHelper();
  final dbMovieHelper = MovieDatabaseHelper();
  _MyAppState(this.api, dbShowHelper, dbMovieHelper);

  @override
  Widget build(BuildContext context) {
    //Sets the listener to update the state when the theme changes.
    curTheme.addListener(() {
      setState(() {});
    });
    return MaterialApp(
      title: "MovieHunter",
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.red,
        accentColor: Colors.red[900],
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.red[900],
          accentColor: Colors.red[400]),
      themeMode: curTheme.currentTheme(),
      home: MainPage(this.api, dbShowHelper, dbMovieHelper),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  final TMDBApi api; //Makes api calls for the whole app.
  final dbShowHelper = ShowDatabaseHelper(); //helper for SQLite show db.
  final dbMovieHelper = MovieDatabaseHelper(); //helper for SQLite Movie db.
  MainPage(this.api, dbShowHelper, dbMovieHelper); //ctor.

  @override
  _MainPageState createState() =>
      _MainPageState(api, dbShowHelper, dbMovieHelper);
}

//Creates the state for the MainPage.
class _MainPageState extends State<MainPage> {
  final TMDBApi api;
  final dbShowHelper = ShowDatabaseHelper();
  final dbMovieHelper = MovieDatabaseHelper();
  _MainPageState(this.api, dbShowHelper, dbMovieHelper);

  int selectedIndex = 0; //Media selected by Bottom nav bar, 0: movies, 1: shows
  int moviePage = 1; //Index of page displayed for movies.
  int showPage = 1; //Index of page displayed for shows.
  bool isDarkTheme = false; //Determines if theme is dark.

  //Build function for the MainPage.
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> drawerWords =
        getDrawLangMap(); //Initially sets the language of all the words in the drawer.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text("MovieHunter")),
          actions: [
            IconButton(icon: Icon(Icons.search), onPressed: _pushSearch),
            IconButton(
                icon: Icon(Icons.favorite), onPressed: _displayFavorites),
          ],
          bottom: TabBar(
            tabs: getTabs(),
            indicatorColor: Color.alphaBlend(Colors.white, Colors.black),
          ),
        ),
        drawer: Container(
          child: Drawer(
              child: Column(children: [
            Container(
              height: 160,
              child: DrawerHeader(
                  margin: EdgeInsetsDirectional.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Container(
                      alignment: Alignment.center,
                      child: Row(children: [
                        Icon(Icons.settings, size: 30, color: Colors.white),
                        Text(drawerWords["Settings"],
                            style:
                                TextStyle(fontSize: 30, color: Colors.white)),
                      ]))),
            ),
            Container(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  Text(drawerWords["LS"]),
                  ListTile(
                    title: const Text('English'),
                    leading: Radio(
                      activeColor: Theme.of(context).accentColor,
                      value: 'en',
                      groupValue: this.api.language,
                      onChanged: (value) {
                        setState(() {
                          this.api.language = value;
                          drawerWords = getDrawLangMap();
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Français'),
                    leading: Radio(
                      activeColor: Theme.of(context).accentColor,
                      value: 'fr',
                      groupValue: this.api.language,
                      onChanged: (value) {
                        setState(() {
                          this.api.language = value;
                          drawerWords = getDrawLangMap();
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Español'),
                    leading: Radio(
                      activeColor: Theme.of(context).accentColor,
                      value: 'es',
                      groupValue: this.api.language,
                      onChanged: (value) {
                        setState(() {
                          this.api.language = value;
                          drawerWords = getDrawLangMap();
                        });
                      },
                    ),
                  ),
                ])),
            Container(
                padding:
                    EdgeInsets.only(top: 50, right: 10, left: 10, bottom: 10),
                child: Column(children: [
                  Text(drawerWords["Theme"]),
                  ListTile(
                    title: Text(drawerWords["ThemeOp"][0]),
                    leading: Radio(
                      activeColor: Theme.of(context).accentColor,
                      value: true,
                      groupValue: isDarkTheme,
                      onChanged: (value) {
                        setState(() {
                          curTheme.switchTheme();
                          isDarkTheme = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(drawerWords["ThemeOp"][1]),
                    leading: Radio(
                      activeColor: Theme.of(context).accentColor,
                      value: false,
                      groupValue: isDarkTheme,
                      onChanged: (value) {
                        setState(() {
                          curTheme.switchTheme();
                          isDarkTheme = value;
                        });
                      },
                    ),
                  ),
                ])),
          ])),
        ),
        body: showTabBody(),
        bottomNavigationBar: BottomNavigationBar(
          items: showBottomTabs(),
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }

  //Sets the state of the Bottom nav bar.
  void onItemTapped(int index) {
    setState(() {
      moviePage = 1;
      showPage = 1;
      selectedIndex = index;
    });
  }

  //Gets the words for the tabs in the correct language.
  List<Tab> getTabs() {
    switch (this.api.apiLang) {
      //If the language is french.
      case "fr":
        {
          return [
            Tab(text: "Populaire"),
            Tab(text: "Tendance"),
            Tab(text: "Genres")
          ];
        }
        break;
      //if the language is spanish.
      case "es":
        {
          return [
            Tab(text: "Popular"),
            Tab(text: "Tendencias"),
            Tab(text: "Géneros")
          ];
        }
        break;
      //If the language is English/Default.
      default:
        {
          return [
            Tab(text: "Popular"),
            Tab(text: "Trending"),
            Tab(text: "Genres")
          ];
        }
        break;
    }
  }

  //Display the results of the Navbar using tabs.
  Widget showTabBody() {
    // show movie tabs
    if (selectedIndex == 0) {
      return TabBarView(
        children: <Widget>[
          popularMoviesTab(),
          trendingMoviesTab(),
          genreTab(),
        ],
      );
    }

    // show tv show tabs
    return TabBarView(
      children: <Widget>[
        popularShowsTab(),
        trendingShowsTab(),
        genreTab(),
      ],
    );
  }

  //Creates the items in the Navbar with the correct language.
  List<BottomNavigationBarItem> showBottomTabs() {
    switch (this.api.apiLang) {
      //if french.
      case "fr":
        {
          return const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Les Films',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tv),
              label: 'Série ',
            ),
          ];
        }
        break;
      //If spanish
      case "es":
        {
          return const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Películas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tv),
              label: 'TV',
            ),
          ];
        }
        break;
      //if Engligh/default.
      default:
        {
          return const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Movies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tv),
              label: 'Shows',
            ),
          ];
        }
        break;
    }
  }

  //Builder for a list of movies.
  FutureBuilder<TMDBMovieSearchResponse> getMovieList(Function listType) {
    return FutureBuilder<TMDBMovieSearchResponse>(
        future: listType(moviePage),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            print("snapshot loading");
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            print("snapshot error");
            return Center(child: Text("snapshot error"));
          }
          return createMovieRow(snapshot.data.results);
        });
  }

  //Construct the popular tab for movies.
  Widget popularMoviesTab() {
    return getMovieList(api.getPopularMovies);
  }

  //Construct the trending tab for movies.
  Widget trendingMoviesTab() {
    return getMovieList(api.getTrendingMovies);
  }

  FutureBuilder<TMDBShowSearchResponse> getShowList(Function listType) {
    return FutureBuilder<TMDBShowSearchResponse>(
        future: listType(showPage),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            print("snapshot loading");
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            print("snapshot SHOW error");
            return Center(child: Text("snapshot error"));
          }

          return createShowRow(snapshot.data.results);
        });
  }

  Widget popularShowsTab() {
    return getShowList(api.getPopularShows);
  }

  Widget trendingShowsTab() {
    return getShowList(api.getTrendingShows);
  }

  Widget genreTab() {
    Future<GenreSearchResponse> genreList = api.getGenres();

    return FutureBuilder<GenreSearchResponse>(
        future: genreList,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            print("snapshot loading");
            return Center(child: Text("in progress"));
          }

          if (snapshot.hasError) {
            print("snapshot error");
            return Center(child: Text("snapshot error"));
          }

          return ListView.builder(
            itemCount: snapshot.data.genres.length,
            itemBuilder: (BuildContext context, int index) {
              return new Card(
                  child: ListTile(
                title: Center(child: Text(snapshot.data.genres[index].name)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GenrePage(
                              genre: snapshot.data.genres[index].name,
                              genreID: snapshot.data.genres[index].id,
                              api: api,
                              movieDB: dbMovieHelper,
                              showDB: dbShowHelper,
                            )),
                  );
                }, //navigates to genrepage with appropriate genre name and id
              ));
            },
          );
        });
  }

  Widget createShowRow(List<TMDBShow> results) {
    return Container(
        child: ListView.builder(
      itemCount: 21,
      itemBuilder: (BuildContext context, int index) {
        if (index != 20) {
          int showID = results[index].id;
          return FutureBuilder<TMDBShow>(
              future: api.getShowByID(showID),
              builder: (context, futureShow) {
                if (futureShow.hasData) {
                  return futureShow.data.buildRow(context, api, dbShowHelper);
                } else if (futureShow.hasError) {
                  return Text("Error retrieving a popular show");
                } else {
                  return CircularProgressIndicator();
                }
              });
        } else {
          if (showPage == 1) {
            return ButtonBar(alignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Next Page'),
                  onPressed: () {
                    setState(() {
                      showPage++;
                    });
                  })
            ]);
          } else {
            return ButtonBar(alignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Previous Page'),
                  onPressed: () {
                    setState(() {
                      showPage--;
                    });
                  }),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Next Page'),
                  onPressed: () {
                    setState(() {
                      showPage++;
                    });
                  })
            ]);
          }
        }
      },
    ));
  }

  Widget createMovieRow(List<TMDBMovie> results) {
    return Container(
        child: ListView.builder(
      itemCount: 21,
      itemBuilder: (BuildContext context, int index) {
        if (index != 20) {
          int movieID = results[index].id;
          return FutureBuilder<TMDBMovie>(
              future: api.getMovieByID(movieID),
              builder: (context, futureMovie) {
                if (futureMovie.hasData) {
                  return futureMovie.data.buildRow(context, api, dbMovieHelper);
                } else if (futureMovie.hasError) {
                  return Text("Error retrieving a popular movie");
                } else {
                  return CircularProgressIndicator();
                }
              });
        } else {
          if (moviePage == 1) {
            return ButtonBar(alignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Next Page'),
                  onPressed: () {
                    setState(() {
                      moviePage++;
                    });
                  })
            ]);
          } else {
            return ButtonBar(alignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Previous Page'),
                  onPressed: () {
                    setState(() {
                      moviePage--;
                    });
                  }),
              ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  child: Text('Next Page'),
                  onPressed: () {
                    setState(() {
                      moviePage++;
                    });
                  })
            ]);
          }
        }
      },
    ));
  }

  //Navigates to favourite page.
  void _displayFavorites() async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FavoritesPage(
                api: api,
                movieDB: dbMovieHelper,
                showDB: dbShowHelper,
              )),
    );
  }

  //Navigates to search page.
  void _pushSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage(api: api)),
    );
  }

  //Creates a Map of all the words for the drawer in the correct language.
  Map<String, dynamic> getDrawLangMap() {
    switch (this.api.apiLang) {
      case "fr":
        {
          return {
            "Settings": "Paramètres",
            "LS": "Choisir la langue:",
            "Theme": "Thème:",
            "ThemeOp": ["Sombre", "Brillant"]
          };
        }
        break;

      case "es":
        {
          return {
            "Settings": "Configuraciones",
            "LS": "Cambiar idioma:",
            "Theme": "Tema:",
            "ThemeOp": ["Oscuro", "Ligero"]
          };
        }
        break;

      default:
        {
          return {
            "Settings": "Settings",
            "LS": "Change Language:",
            "Theme": "Theme:",
            "ThemeOp": ["Dark", "Light"]
          };
        }
        break;
    }
  }
}

//Theme class with notifyer to update the listener that sets the state for the whole app.
class MyTheme with ChangeNotifier {
  static bool _isDark = true;
  ThemeMode currentTheme() {
    return _isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void switchTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
