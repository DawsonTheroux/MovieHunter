import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'main.dart';
import 'api.dart';
import 'show_db_helper.dart';
import 'movie_db_helper.dart';
import 'models/tmdb_movie.dart';
import 'models/tmdb_show.dart';
import 'models/tmdb_actor.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key, this.api, this.dbMovie, this.dbShow}) : super(key: key);
  final TMDBApi api;
  final MovieDatabaseHelper dbMovie;
  final ShowDatabaseHelper dbShow;
  _SearchPageState createState()=> _SearchPageState(this.api, this.dbMovie, this.dbShow);
}

class _SearchPageState extends State<SearchPage> {
  final TMDBApi api;
  final MovieDatabaseHelper dbMovie;
  final ShowDatabaseHelper dbShow;
  _SearchPageState(this.api, this.dbMovie, this.dbShow);
  final searchController = TextEditingController();
  Future<List<dynamic>>searchResults;   //List of search results.
  bool adultContent = false;            //Determines if adult content is allowed.

  //Creates the search page.
  Widget createSearchPage(){
    Map<String, dynamic> mapLangWords = getSecNames(api.apiLang);
    String dropDownValue = mapLangWords["dropValues"][0];
    return Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(20),
              child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 5.0,
                          )
                      ),
                      hintText: mapLangWords["Search"]
                  )
              )
          ),
          Container(
              padding: EdgeInsets.only(left:20),
              child: Row(
                  children: <Widget>[
                    Text(mapLangWords["MT"]),
                    Container(
                        padding: EdgeInsets.all(5),
                        child: DropdownButton<String>(
                          value: dropDownValue,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(color: Colors.red),
                          underline: Container(
                            height: 2,
                            color: Colors.redAccent,
                          ),
                          onChanged: (String newValue){
                            setState(() {
                              dropDownValue = newValue;
                            });
                          },
                          items: mapLangWords["dropValues"].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Row(
                            children: <Widget>[
                              Text(mapLangWords["AC"]),
                              Checkbox(
                                  checkColor: Colors.black,
                                  activeColor: Colors.redAccent,
                                  value: adultContent,
                                  onChanged: (bool newValue){
                                    setState((){
                                      adultContent = newValue;
                                    });
                                  }
                              )
                            ]
                        )
                    ),
                  ]
              )
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: ButtonTheme(
                  child: FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      padding: EdgeInsets.all(20),
                      child: Text("HUNT!"),
                      onPressed: () {
                        if (searchController.text == "" || searchController.text == null) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder:(BuildContext context){
                              return AlertDialog(
                                title: Text(mapLangWords["Alert"]),
                                content: Text(mapLangWords["Alert Message"]),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text("Ok"),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      }
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          setState(() {
                            FocusScope.of(context).unfocus();       //hides the keyboard when search button is pressed.
                            searchResults = api.searchMedia(
                                searchController.text, adultContent,
                                dropDownValue);
                          });
                        }
                      }
                  )
              )
          ),
          SingleChildScrollView(
              child: FutureBuilder <List<dynamic>>(
                  future: searchResults,
                  builder: (context, resultsSnap){
                    if(resultsSnap.hasData){
                      return Container(
                          height: MediaQuery.of(context).size.height - 300,
                          padding: EdgeInsets.all(10),
                          child: ListView.builder(
                              itemCount: resultsSnap.data.length,
                              itemBuilder: (BuildContext context, int index){
                                return Container(
                                    child: buildRowShowOrMovie(resultsSnap.data[index])
                                );
                              }
                          )
                      );
                    }else if(resultsSnap.hasError){
                      throw(resultsSnap.error);
                    }else{
                      return Container(
                          padding: EdgeInsets.all(20),
                          child: Text(mapLangWords["results"])
                      );
                    }
                  }
              )
          )
        ]
    );
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("MovieHunter"),
      ),
      body: createSearchPage(),
      resizeToAvoidBottomInset: false,
    );
  }

  //Calls the correct buildRow function depending on movie or show.
  Widget buildRowShowOrMovie(dynamic media){
    if(media is TMDBMovie){
      return media.buildRow(context, api, dbMovie);
    }else if(media is TMDBShow){
      return media.buildRow(context, api, dbShow);
    }else{
      return media.buildRow(context,api);
    }
  }

  //gets the words in the correct language.
  Map<String, dynamic> getSecNames (String apiLang){
    switch (apiLang) {
      case "fr":
        {
          return {
            "Search": "Chercher...",
            "MT" : "Type de Media:",
            "AC": "Contenu adulte:",
            "results": "Aucun résultat",
            "Alert" : "Alerte",
            "Alert Message" : "You must input something to search!",
            "dropValues" : ['Tout', 'Film','Télé','Personne'],
          };
        }
        break;

      case "es":
        {
          return {
            "Search": "Buscar...",
            "MT" : "Tipo de medio:",
            "AC": "Adulto:",
            "results": "No hay resultados",
            "Alert" : "Alerta",
            "Alert Message" : "¡Debes ingresar algo para buscar!",
            "dropValues" : ['Todas', 'Películas','Televisión','Personas'],
          };
        }
        break;

      default:
        {
          return {
            "Search": "Search...",
            "MT" : "Media Type:",
            "AC": "Allow Adult Content:",
            "results": "No results",
            "Alert" : "Alert",
            "Alert Message" : "You must input something to search!",
            "dropValues" : ['All', 'Movies','TV Shows','People'],
          };
        }
        break;
    }
  }

}

