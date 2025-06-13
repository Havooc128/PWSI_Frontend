import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import 'dio_service.dart';

class AuthService {

  static Future<bool> login(BuildContext context, String email, String password) async {
    try {
      final dio = (await DioService.getInstance()).dio;

      final response = await dio.post('api/login/', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final tokens = response.data['tokens'];
        await Provider.of<AuthProvider>(context, listen: false).setTokens(
          accessToken: tokens['access'],
          refreshToken: tokens['refresh'],
        );
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  static Future<bool> register(BuildContext context, String email, String username, String password1, String password2) async {
    try {
      final dio = (await DioService.getInstance()).dio;

      final response = await dio.post('api/register/', data: {
        'email': email,
        'username': username,
        'password1': password1,
        'password2': password2,
      });

      if (response.statusCode == 201) {
        final tokens = response.data['tokens'];
        await Provider.of<AuthProvider>(context, listen: false).setTokens(
          accessToken: tokens['access'],
          refreshToken: tokens['refresh'],
        );
        return true;
      }
    } catch (e) {
      print('Register error: $e');
    }
    return false;
  }

  static Future<bool> logout(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = authProvider.accessToken;
      final refreshToken = authProvider.refreshToken;

      if (accessToken == null || refreshToken == null) return false;

      final dio = (await DioService.getInstance()).dio;

      final response = await dio.post('api/logout/',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
        data: {
          'refresh': refreshToken,
        },
      );

      if (response.statusCode == 205) {
        await authProvider.logout();
        return true;
      }
    } catch (e) {
      print('Logout error: $e');
    }
    return false;
  }
}
