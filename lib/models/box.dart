class Box {
  final String title;
  final String username;
  final String password;
  final String url;

  final List<String>? tags;
  final bool favorite;

  Box({
    required this.title,
    this.username = "",
    required this.password,
    this.url = "",
    this.tags,
    this.favorite = false,
  });

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      title: json['title'],
      username: json['username'],
      password: json['password'],
      url: json['url'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      favorite: json['favorite'],
    );
  }

  factory Box.fromMap(Map<String, dynamic> map) {
    return Box(
      title: map['title'],
      username: map['username'],
      password: map['password'],
      url: map['url'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      favorite: map['favorite'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'username': username,
      'password': password,
      'url': url,
      'tags': tags,
      'favorite': favorite,
    };
  }
}
