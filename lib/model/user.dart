class User {
  final int id;
  final String email;
  final String username;
  final DateTime dateJoined;
  String? bio;
  String profileUrl;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.dateJoined,
    required this.profileUrl,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      dateJoined: DateTime.parse(json['date_joined']),
      profileUrl: json['profile_image_url'] ?? 'https://fastly.picsum.photos/id/237/200/300.jpg?hmac=TmmQSbShHz9CdQm0NkEjx1Dyh_Y984R9LpNrpvH2D_U',
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'date_joined': dateJoined.toIso8601String(),
    'bio': bio,
    'profile_image_url': profileUrl,
    //'profile_url': profileUrl,
  };
}
