class PaginatedPage<T> {
  final int totalElements;
  final String? previousUrl;
  final String? nextUrl;
  final List<T> items;

  const PaginatedPage({
    required this.totalElements,
    required this.items,
    this.previousUrl,
    this.nextUrl,
  });

  factory PaginatedPage.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonItem,
      ) {
    return PaginatedPage(
      totalElements: json['count'],
      previousUrl: json['previous'],
      nextUrl: json['next'],
      items: (json['results'] as List)
          .map((item) => fromJsonItem(item))
          .toList(),
    );
  }
}
