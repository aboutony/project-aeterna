import 'package:flutter/foundation.dart';
import 'package:project_aeterna/features/vault/data/database/turso_client.dart';

/// Sovereign Auth Service — Session management for Project Aeterna.
///
/// Stores session state in the local `app_settings` table.
/// Production: Will integrate with Turso Edge + mTLS certificates.
/// Current: Mock auth with persistent session token.
class AuthService {
  static AuthService? _instance;
  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  // Cached session state
  bool _isAuthenticated = false;
  Map<String, String> _userProfile = {};

  bool get isAuthenticated => _isAuthenticated;
  Map<String, String> get userProfile => Map.unmodifiable(_userProfile);

  /// Check if user has an active session.
  Future<bool> checkSession() async {
    try {
      final db = await TursoClient.instance.getDatabase();

      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      final result = await db.rawQuery(
        "SELECT value FROM app_settings WHERE key = 'auth_session'",
      );

      if (result.isNotEmpty && result.first['value'] == 'active') {
        _isAuthenticated = true;
        await _loadProfile();
        debugPrint('[AuthService] Session restored: active');
        return true;
      }

      _isAuthenticated = false;
      debugPrint('[AuthService] No active session found');
      return false;
    } catch (e) {
      debugPrint('[AuthService] Session check error: $e');
      return false;
    }
  }

  /// Mock OTP verification — always succeeds for demo.
  /// In production: verify via Twilio/Firebase Auth.
  Future<bool> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    // Mock: any 6-digit OTP is valid
    if (otp.length != 6) return false;

    try {
      final db = await TursoClient.instance.getDatabase();
      final now = DateTime.now().toIso8601String();

      // Store session
      await db.rawInsert(
        "INSERT OR REPLACE INTO app_settings (key, value, updated_at) "
        "VALUES ('auth_session', 'active', ?)",
        [now],
      );

      // Store phone
      final fullPhone = '$countryCode$phoneNumber';
      await db.rawInsert(
        "INSERT OR REPLACE INTO app_settings (key, value, updated_at) "
        "VALUES ('user_phone', ?, ?)",
        [fullPhone, now],
      );
      await db.rawInsert(
        "INSERT OR REPLACE INTO app_settings (key, value, updated_at) "
        "VALUES ('user_country_code', ?, ?)",
        [countryCode, now],
      );

      _isAuthenticated = true;
      _userProfile['phone'] = fullPhone;
      _userProfile['country_code'] = countryCode;

      debugPrint('[AuthService] ✓ Authenticated: $fullPhone');
      return true;
    } catch (e) {
      debugPrint('[AuthService] Auth error: $e');
      return false;
    }
  }

  /// Clear session completely — returns to Welcome screen.
  Future<void> logout() async {
    try {
      final db = await TursoClient.instance.getDatabase();
      await db.rawDelete(
        "DELETE FROM app_settings WHERE key IN "
        "('auth_session', 'user_phone', 'user_country_code', "
        "'user_full_name', 'user_legal_id', 'user_legal_id_type')",
      );

      _isAuthenticated = false;
      _userProfile.clear();
      debugPrint('[AuthService] ✓ Session cleared — logout complete');
    } catch (e) {
      debugPrint('[AuthService] Logout error: $e');
    }
  }

  /// Save profile field to DB.
  Future<void> saveProfileField(String key, String value) async {
    try {
      final db = await TursoClient.instance.getDatabase();
      final now = DateTime.now().toIso8601String();
      await db.rawInsert(
        "INSERT OR REPLACE INTO app_settings (key, value, updated_at) "
        "VALUES (?, ?, ?)",
        [key, value, now],
      );
      _userProfile[key] = value;
      debugPrint('[AuthService] Profile saved: $key');
    } catch (e) {
      debugPrint('[AuthService] Save error: $e');
    }
  }

  /// Load profile from DB.
  Future<void> _loadProfile() async {
    try {
      final db = await TursoClient.instance.getDatabase();
      final keys = [
        'user_phone', 'user_country_code',
        'user_full_name', 'user_legal_id', 'user_legal_id_type',
      ];

      for (final key in keys) {
        final result = await db.rawQuery(
          "SELECT value FROM app_settings WHERE key = ?", [key],
        );
        if (result.isNotEmpty) {
          _userProfile[key] = result.first['value'] as String;
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Profile load error: $e');
    }
  }
}
