class Credit {
  final int id;
  final int order;
  final String title;
  final String posterPath;
  final String character;
  final String media_type;

  Credit({
    this.id,
    this.title,
    this.posterPath,
    this.character,
    this.order,
    this.media_type,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    Credit credit = new Credit(
        id: json['id'],
        title: json["title"] == null ? "Unspecified" : json["title"],
        posterPath: json['poster_path'] == null
            ? "https://i.imgur.com/KsgMrLQ.jpg"
            : "http://image.tmdb.org/t/p/w400/" + json['poster_path'],
        character:
            json['character'] == null ? "Unspecified" : json['character'],
        order: json["order"] == null ? -1 : json["order"],
        media_type: json["media_type"]);

    return credit;
  }
}
