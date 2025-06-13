import 'package:pwsi/model/paginated_page.dart';

import '../model/review.dart';
import 'dio_service.dart';

class ReviewService {
  // Lista recenzji dla książki
  static Future<PaginatedPage<Review>?> getReviewsForBook(int bookId, {String? pageUrl}) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.get(pageUrl ?? 'books/book/$bookId/review/');

      if (response.statusCode == 200) {
        return PaginatedPage.fromJson(response.data, Review.fromJson);
      }
    } catch (e) {
      print('getReviewsForBook error: $e');
    }
    return null;
  }

  // Szczegóły recenzji
  static Future<Review?> getReviewDetails(int bookId, int reviewId) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.get('books/book/$bookId/review/$reviewId/');

      if (response.statusCode == 200) {
        return Review.fromJson(response.data);
      }
    } catch (e) {
      print('getReviewDetails error: $e');
    }
    return null;
  }

  // Dodanie recenzji do książki
  static Future<bool> createReview(int bookId, Review review) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.post('books/create/$bookId/', data: review.toJson());

      return response.statusCode == 201;
    } catch (e) {
      print('createReview error: $e');
    }
    return false;
  }

  // Aktualizacja recenzji
  static Future<bool> updateReview(Review review) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.put('books/update/${review.id}/', data: review);

      return response.statusCode == 200;
    } catch (e) {
      print('updateReview error: $e');
    }
    return false;
  }

  // Usunięcie recenzji
  static Future<bool> deleteReview(int reviewId) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.delete('books/delete/$reviewId/');

      return response.statusCode == 204;
    } catch (e) {
      print('deleteReview error: $e');
    }
    return false;
  }

  // Lista recenzji użytkownika
  static Future<PaginatedPage<Review>?> getUserReviews(int userId, {String? pageUrl}) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.get(pageUrl ?? 'books/user/$userId/reviews/');

      if (response.statusCode == 200) {
        return PaginatedPage.fromJson(response.data, Review.fromJson);
      }
    } catch (e) {
      print('getUserReviews error: $e');
    }
    return null;
  }
}
