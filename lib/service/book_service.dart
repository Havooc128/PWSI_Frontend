import 'package:pwsi/model/book.dart';
import 'package:pwsi/model/paginated_page.dart';

import '../model/user.dart';
import 'dio_service.dart';

class BookService {

  // Lista książek
  static Future<PaginatedPage<Book>?> getBookList({String? pageUrl}) async {
    try {
      final dio = (await DioService.getInstance()).dio;

      final response = await dio.get(pageUrl ?? 'books/books/');

      if (response.statusCode == 200) {
        return PaginatedPage.fromJson(response.data, Book.fromJson);
      }
    } catch (e) {
      print('getBookList error: $e');
    }
    return null;
  }

  // Szczegóły książki
  static Future<Book?> getBookDetails(int bookId) async {
    try {
      final dio = (await DioService.getInstance()).dio;

      final response = await dio.get('books/book/$bookId/');

      if (response.statusCode == 200) {
        return Book.fromJson(response.data);
      }
    } catch (e) {
      print('getBookDetails error: $e');
    }

    return null;
  }

  static Future<PaginatedPage<Book>?> getRecommendationsForUser(User user, {String? pageUrl}) async {
    try {
      final dio = (await DioService.getInstance()).dio;

      final response = await dio.get(pageUrl ?? 'books/user/${user.id}/recommendations/');

      if (response.statusCode == 200) {
        return PaginatedPage.fromJson(response.data, Book.fromJson);
      }
    } catch (e) {
      print('getRecommendationsForUser error: $e');
    }
    return null;
  }
}
