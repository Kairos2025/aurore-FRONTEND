import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aurore_school/core/constants/app_colors.dart';

/// A secure storage manager for sensitive data, providing robust error handling,
/// analytics, and advanced features for token and profile management.
class SecureStorage {
  final FlutterSecureStorage _storage;
  final String _keyPrefix;

  /// Timestamp of the last storage operation.
  DateTime lastUpdated;

  /// Error message for the last operation, null if successful.
  String? errorMessage;

  /// Numeric error code for specific error types (e.g., 200 for storage error).
  int? errorCode;

  SecureStorage({
    String keyPrefix = 'aurore_',
    FlutterSecureStorage? storage,
  })  : _keyPrefix = keyPrefix,
        _storage = storage ?? const FlutterSecureStorage(),
        lastUpdated = DateTime.now();

  /// Writes a value to secure storage with the given key.
  Future<void> write(String key, String value) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Key cannot be empty');
      }
      if (value.length > 1024 * 1024) {
        // 1MB limit
        throw ArgumentError('Value size exceeds 1MB limit');
      }
      await _storage.write(key: '$_keyPrefix$key', value: value);
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
    } catch (e) {
      errorMessage = 'Failed to write to storage: $e';
      errorCode = 200; // Storage write error
      rethrow;
    }
  }

  /// Reads a value from secure storage for the given key.
  Future<String?> read(String key) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Key cannot be empty');
      }
      final value = await _storage.read(key: '$_keyPrefix$key');
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
      return value;
    } catch (e) {
      errorMessage = 'Failed to read from storage: $e';
      errorCode = 201; // Storage read error
      rethrow;
    }
  }

  /// Deletes a value from secure storage for the given key.
  Future<void> delete(String key) async {
    try {
      if (key.isEmpty) {
        throw ArgumentError('Key cannot be empty');
      }
      await _storage.delete(key: '$_keyPrefix$key');
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
    } catch (e) {
      errorMessage = 'Failed to delete from storage: $e';
      errorCode = 202; // Storage delete error
      rethrow;
    }
  }

  /// Reads all key-value pairs from secure storage.
  Future<Map<String, String>> readAll() async {
    try {
      final allData = await _storage.readAll();
      final filteredData = <String, String>{};
      for (final entry in allData.entries) {
        if (entry.key.startsWith(_keyPrefix)) {
          filteredData[entry.key.substring(_keyPrefix.length)] = entry.value;
        }
      }
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
      return filteredData;
    } catch (e) {
      errorMessage = 'Failed to read all from storage: $e';
      errorCode = 203; // Storage read all error
      rethrow;
    }
  }

  /// Deletes all key-value pairs from secure storage.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
    } catch (e) {
      errorMessage = 'Failed to delete all from storage: $e';
      errorCode = 204; // Storage delete all error
      rethrow;
    }
  }

  /// Stores authentication tokens with expiration tracking.
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
  }) async {
    try {
      await write('auth_token', accessToken);
      await write('refresh_token', refreshToken);
      await write('access_token_expiry', accessTokenExpiry.toIso8601String());
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
    } catch (e) {
      errorMessage = 'Failed to store tokens: $e';
      errorCode = 205; // Token storage error
      rethrow;
    }
  }

  /// Stores a user profile as JSON-encoded data.
  Future<void> storeUserProfile(Map<String, dynamic> profile) async {
    try {
      final jsonString = jsonEncode(profile);
      await write('user_profile', jsonString);
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
    } catch (e) {
      errorMessage = 'Failed to store user profile: $e';
      errorCode = 206; // Profile storage error
      rethrow;
    }
  }

  /// Reads and decodes the user profile from storage.
  Future<Map<String, dynamic>?> readUserProfile() async {
    try {
      final jsonString = await read('user_profile');
      if (jsonString == null) {
        return null;
      }
      final profile = jsonDecode(jsonString) as Map<String, dynamic>;
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
      return profile;
    } catch (e) {
      errorMessage = 'Failed to read user profile: $e';
      errorCode = 207; // Profile read error
      rethrow;
    }
  }

  /// Checks if the access token is still valid based on its expiry.
  Future<bool> checkTokenExpiration() async {
    try {
      final expiryString = await read('access_token_expiry');
      if (expiryString == null) {
        errorMessage = 'No token expiry found';
        errorCode = 208; // Token expiry missing
        return false;
      }
      final expiry = DateTime.tryParse(expiryString);
      if (expiry == null) {
        errorMessage = 'Invalid token expiry format';
        errorCode = 209; // Token expiry format error
        return false;
      }
      final isValid = DateTime.now().isBefore(expiry);
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
      return isValid;
    } catch (e) {
      errorMessage = 'Failed to check token expiration: $e';
      errorCode = 210; // Token expiry check error
      return false;
    }
  }

  /// Exports storage to an encrypted file for backup (placeholder implementation).
  Future<void> backupToEncryptedFile(String filePath) async {
    try {
      final allData = await readAll();
      final jsonString = jsonEncode(allData);
      // Placeholder: Implement file encryption and writing logic
      // e.g., use a package like `encrypt` to encrypt jsonString
      // then write to filePath
      lastUpdated = DateTime.now();
      errorMessage = null;
      errorCode = null;
    } catch (e) {
      errorMessage = 'Failed to backup storage: $e';
      errorCode = 211; // Backup error
      rethrow;
    }
  }

  /// Returns the number of keys in storage.
  Future<int> get keyCount async {
    try {
      final allData = await readAll();
      return allData.length;
    } catch (e) {
      errorMessage = 'Failed to get key count: $e';
      errorCode = 212; // Key count error
      return 0;
    }
  }

  /// Returns the timestamp of the last storage access.
  DateTime get lastAccessed => lastUpdated;

  /// Checks if the storage operation was successful.
  bool get isOperationSuccessful => errorMessage == null && errorCode == null;
}