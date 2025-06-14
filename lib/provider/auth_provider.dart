import 'package:flutter/material.dart';
import 'package:pwsi/model/user.dart';
import 'package:pwsi/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  User? _user;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  User? get user => _user;

  AuthProvider() {
    //_loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    notifyListeners();
  }

  Future<void> setTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    print(accessToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _user = await UserService.getCurrentUser();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    notifyListeners();
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    notifyListeners();
  }

  bool get isLoggedIn => _accessToken != null;
}
