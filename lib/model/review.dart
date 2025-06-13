import 'package:pwsi/model/user.dart';

import 'book.dart';

class Review {
  final int id;
  //final Book book;
  final User user;
  final String sentiment;
  final String content;
  final DateTime createdAt;

  Review({
    required this.id,
    //required this.book,
    required this.user,
    required this.sentiment,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      //book: Book.fromJson(json['book']),
      user: User.fromJson(json['user']),
      sentiment: json['sentiment'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    //'book': book.toJson(),
    'user': user.toJson(),
    'sentiment': sentiment,
    'content': content,
    'created_at': createdAt.toIso8601String(),
  };
}
