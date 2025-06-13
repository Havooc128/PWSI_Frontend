import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../provider/auth_provider.dart';

class DioService {
  static DioService? _instance;
  late final Dio _dio;
  bool _isRefreshing = false;

  DioService._internal();

  static Future<DioService> getInstance() async {
    if (_instance == null) {
      _instance = DioService._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/',
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          final refreshToken = await _getRefreshToken();
          final context = navigatorKey.currentContext;

          if (refreshToken != null && context != null) {
            try {
              final dioRefresh = Dio();
              final response = await dioRefresh.post(
                'http://10.0.2.2:8000/api/token/refresh',
                data: {'refresh': refreshToken},
                options: Options(
                  headers: {'Content-Type': 'application/json'},
                ),
              );

              if (response.statusCode == 200) {
                final newAccess = response.data['access'];
                final newRefresh = response.data['refresh'];

                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.updateTokens(newAccess, newRefresh);

                // Powtórz poprzednie żądanie z nowym tokenem
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';

                final retryResponse = await _dio.fetch(opts);
                _isRefreshing = false;
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              print('Refresh token error: $e');
            }
          }

          // Nie udało się odświeżyć tokena
          if (context != null) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();
          }

          _isRefreshing = false;
        }

        return handler.next(error);
      },
    ));
  }

  Future<String?> _getAccessToken() async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      return provider.accessToken;
    }
    return null;
  }

  Future<String?> _getRefreshToken() async {
    final context = navigatorKey.currentContext;
    if (context != null) {
      final provider = Provider.of<AuthProvider>(context, listen: false);
      return provider.refreshToken;
    }
    return null;
  }

  Dio get dio => _dio;
}
