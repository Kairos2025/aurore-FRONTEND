import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aurore_school/utils/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio;
  final SecureStorage _storage;
  User? _user;
  String? _role;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._dio, this._storage);

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();

      final accessToken = await _storage.getAccessToken();
      if (accessToken != null) {
        final response = await _dio.get(
          'https://aurore-backend.onrender.com/auth/me',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        _user = FirebaseAuth.instance.currentUser;
        _role = response.data['role'] as String;
      } else {
        _user = null;
        _role = null;
      }
    } catch (e) {
      _error = e.toString();
      _user = null;
      _role = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      final response = await _dio.post(
        'https://aurore-backend.onrender.com/auth/login',
        data: {'email': email, 'password': password},
      );
      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      _role = response.data['role'] as String;

      await _storage.storeTokens(accessToken, refreshToken);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await _user?.updateDisplayName(name);

      final response = await _dio.post(
        'https://aurore-backend.onrender.com/auth/signup',
        data: {'name': name, 'email': email, 'password': password},
      );
      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      _role = response.data['role'] as String;

      await _storage.storeTokens(accessToken, refreshToken);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> googleSignIn() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign-In cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      _user = userCredential.user;

      final response = await _dio.post(
        'https://aurore-backend.onrender.com/auth/google',
        data: {'idToken': googleAuth.idToken},
      );
      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      _role = response.data['role'] as String;

      await _storage.storeTokens(accessToken, refreshToken);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await _storage.clearTokens();
      _user = null;
      _role = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
}