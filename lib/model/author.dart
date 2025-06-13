class Author {
  final int id;
  final String name;
  final String description;
  final String nationality;
  final DateTime? birthDate;

  Author({
    required this.id,
    required this.name,
    required this.description,
    required this.nationality,
    this.birthDate,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      nationality: json['nationality'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'nationality': nationality,
    'birth_date': birthDate?.toIso8601String(),
  };

  @override
  String toString() => name;
}
