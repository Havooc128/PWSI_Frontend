import '../model/author.dart';
import 'dio_service.dart';

class AuthorService {
  // Szczegóły autora
  static Future<Author?> getAuthorDetails(int authorId) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.get('books/author/$authorId/');

      if (response.statusCode == 200) {
        return Author.fromJson(response.data);
      }
    } catch (e) {
      print('getAuthorDetails error: $e');
    }
    return null;
  }
}
