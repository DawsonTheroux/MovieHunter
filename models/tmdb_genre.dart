//Creates a LIst of genres from TBMD response.
class GenreSearchResponse {
  List<Genre> genres;

  GenreSearchResponse({this.genres});

  factory GenreSearchResponse.fromJson(Map<String, dynamic> json) {
    return GenreSearchResponse(
        genres: (json['genres'] as List)
            ?.map((e) =>
                e == null ? null : Genre.fromJson(e as Map<String, dynamic>))
            ?.toList());
  }

  Map<String, dynamic> toJson(GenreSearchResponse search) {
    return <String, List<Genre>>{
      'results': search.genres,
    };
  }
}

class Genre {
  Genre({
    this.id,
    this.name,
  });

  int id;
  String name;
  //Creates a MAP from a genre
  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
