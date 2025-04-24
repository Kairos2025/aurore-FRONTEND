import 'package:dio/dio.dart';
import 'package:aurore_school/utils/secure_storage.dart';

class ApiService {
  final Dio _dio;
  final SecureStorage _storage;

  ApiService(this._dio, this._storage) {
    _dio.options.baseUrl = 'https://aurore-backend.onrender.com';
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              final refreshToken = await _storage.getRefreshToken();
              if (refreshToken == null) {
                return handler.reject(e);
              }

              final response = await _dio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken = response.data['accessToken'] as String;
              final newRefreshToken = response.data['refreshToken'] as String;
              await _storage.storeTokens(newAccessToken, newRefreshToken);

              e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              return handler.resolve(await _dio.fetch(e.requestOptions));
            } catch (refreshError) {
              return handler.reject(e);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> login(String email, String password) async {
    return await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> signUp(String name, String email, String password) async {
    return await _dio.post(
      '/auth/signup',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response> googleSignIn(String idToken) async {
    final response = await _dio.post(
      '/auth/google',
      data: {
        'idToken': idToken,
      },
    );
    final accessToken = response.data['accessToken'] as String;
    final refreshToken = response.data['refreshToken'] as String;
    await _storage.storeTokens(accessToken, refreshToken);
    return response;
  }

  Future<Response> fetchSchedules(String userId, String role) async {
    return await _dio.get(
      '/schedules',
      queryParameters: {
        'userId': userId,
        'role': role,
      },
    );
  }

  Future<Response> fetchAdminSchedules() async {
    return await _dio.get('/admin/schedules');
  }

  Future<Response> fetchConflicts() async {
    return await _dio.get('/conflicts');
  }

  Future<Response> resolveConflict(String conflictId, String resolution) async {
    return await _dio.post(
      '/conflicts/resolve',
      data: {
        'conflictId': conflictId,
        'resolution': resolution,
      },
    );
  }

  Future<Response> generateTimetable(Map<String, dynamic> params) async {
    return await _dio.post(
      '/admin/generate-timetable',
      data: params,
    );
  }
}