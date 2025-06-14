import '../model/user.dart';
import 'dio_service.dart';

class UserService {
  // Dane zalogowanego użytkownika
  static Future<User?> getCurrentUser() async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.get('api/user/');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
    } catch (e) {
      print('getCurrentUser error: $e');
    }
    return null;
  }

  // Publiczny profil użytkownika po ID
  static Future<User?> getPublicUserInfo(int userId) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.get('api/user/$userId/');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
    } catch (e) {
      print('getPublicUserInfo error: $e');
    }
    return null;
  }

  // Aktualizacja bio
  static Future<bool> updateBio(String newBio) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.patch('api/user/edit-bio/', data: {'bio': newBio});

      return response.statusCode == 200;
    } catch (e) {
      print('updateBio error: $e');
    }
    return false;
  }

  static Future<bool> updateProfilePicUrl(String newProfilePicUrl) async {
    try {
      final dio = (await DioService.getInstance()).dio;
      final response = await dio.patch('api/user/update-image/', data: {'profile_image_url': newProfilePicUrl});

      return response.statusCode == 200;
    } catch (e) {
      print('updateProfilePicUrl error: $e');
    }
    return false;
  }
}
