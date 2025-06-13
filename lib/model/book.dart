import 'author.dart';

class Book {
  final int id;
  final String title;
  final Author author;
  final String category;
  final String description;
  final DateTime publishedDate;
  final String imageUrl;
  final double avgRating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.publishedDate,
    required this.imageUrl,
    required this.avgRating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: Author.fromJson(json['author']),
      category: json['category'] ?? 'none',
      description: json['description'] ?? '',
      publishedDate: DateTime.parse(json['published_date']),
      imageUrl: json['cover_url'] ?? 'https://fastly.picsum.photos/id/237/200/300.jpg?hmac=TmmQSbShHz9CdQm0NkEjx1Dyh_Y984R9LpNrpvH2D_U',
      avgRating: json['average_rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author.toJson(),
    'category': category,
    'description': description,
    'published_date': publishedDate.toIso8601String(),
    'cover_url': imageUrl,
    'average_rating': avgRating == 0 ? null : avgRating,
  };
}
