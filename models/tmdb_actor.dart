import 'package:flutter/material.dart';
import '../api.dart';
import '../actor_page.dart';

class Actor {
  int id;
  String name;
  String biography;
  String profilePath;
  String knownForDept;
  String birthday;
  String placeOfBirth;
  String gender;
  String character;
  int order;

  Actor(
      {this.id,
      this.name,
      this.profilePath,
      this.birthday,
      this.knownForDept,
      this.gender,
      this.placeOfBirth,
      this.biography,
      this.character,
      this.order});

  //Maps a JSON string to a MAP.
  factory Actor.fromJson(Map<String, dynamic> json) {
    Actor actor = new Actor(
      id: json['id'],
      name: json["name"] == null ? "Unspecified" : json["name"],
      profilePath: json['profile_path'] == null
          ? "https://i.imgur.com/KsgMrLQ.jpg"
          : "http://image.tmdb.org/t/p/w400/" + json['profile_path'],
      knownForDept: json['known_for_department'] == null
          ? "Unspecified"
          : json['known_for_department'],
      gender: 'Unspecified',
      birthday: json['birthday'] == null ? "Unspecified" : json['birthday'],
      placeOfBirth: json['place_of_birth'] == null
          ? "Unspecified"
          : json['place_of_birth'],
      biography: json['biography'] == null || json['biography'] == ""
          ? "We don't have a biography for ${json["name"]}."
          : json['biography'],
      character: json['character'] == null ? "Unspecified" : json['character'],
      order: json['order'] == null ? -1 : json['order'],
    );

    if (json['gender'] == 1) {
      actor.gender = "Female";
    } else if (json['gender'] == 2) {
      actor.gender = "Male";
    }

    return actor;
  }

  //Builds a Card for this actor. (only used in search page currently).
  Widget buildRow(BuildContext context, TMDBApi api) {
    bool alreadySaved = false;
    String movieTitle;
    return new Card(
        child: ListTile(
          leading: Container(
              child: Image.network(profilePath)
          ),
          title: Container(
              child: Text(name)
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => ActorPage(actorID: id, api: api)),
            );
          },
        )
    );
  }

}
