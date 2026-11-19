import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure local storage for sensitive authentication tokens and session data.
class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _userPhoneKey = 'user_phone';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  /// Saves the JWT access token.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the saved JWT access token.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Checks if a valid token exists.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Saves session identifiers for quick recall.
  Future<void> saveSession({required String userId, String? phone}) async {
    await _storage.write(key: _userIdKey, value: userId);
    if (phone != null) {
      await _storage.write(key: _userPhoneKey, value: phone);
    }
  }

  /// Retrieves the saved session user ID.
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Retrieves the saved user phone number.
  Future<String?> getUserPhone() async {
    return await _storage.read(key: _userPhoneKey);
  }

  /// Clears all saved credentials upon logout.
  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userPhoneKey);
  }
}
