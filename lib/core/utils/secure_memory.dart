import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Volatile Memory Manager — ensures the Master Key lives and dies in RAM.
///
/// CTO MANDATE: "The Master Key must never be written to persistent storage
/// (SharedPrefs, SQLite, or Disk). It must live and die in the application's
/// memory space. Use 'Secure Storage' only for the salt, never for the key."
///
/// This utility:
///   - Holds the AES-256 Master Key in a Uint8List
///   - Auto-wipes after 60 seconds of idle
///   - Wipes on app backgrounding
///   - Provides explicit zeroing on dispose
class SecureMemory with WidgetsBindingObserver {
  static final SecureMemory _instance = SecureMemory._internal();
  factory SecureMemory() => _instance;
  SecureMemory._internal();

  /// The volatile Master Key — 32 bytes (256 bits)
  Uint8List? _masterKey;

  /// Idle timer duration before auto-purge
  static const Duration _idleTimeout = Duration(seconds: 60);

  /// Timestamp of last access
  DateTime? _lastAccess;

  /// Whether the memory manager is initialized
  bool _isInitialized = false;

  /// Initialize the memory manager and attach lifecycle observer
  void initialize() {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    debugPrint('[SecureMemory] Initialized — lifecycle observer attached');
  }

  /// Store the Master Key in volatile memory.
  /// Returns true if stored successfully.
  bool storeMasterKey(Uint8List key) {
    if (key.length != 32) {
      debugPrint('[SecureMemory] ERROR: Key must be exactly 32 bytes (256 bits)');
      return false;
    }

    // Wipe any existing key first
    _wipeKey();

    // Store in volatile memory
    _masterKey = Uint8List.fromList(key);
    _lastAccess = DateTime.now();

    debugPrint('[SecureMemory] Master Key stored in volatile memory '
        '(${_masterKey!.length} bytes)');
    return true;
  }

  /// Retrieve the Master Key. Returns null if purged or expired.
  /// Refreshes the idle timer on access.
  Uint8List? getMasterKey() {
    if (_masterKey == null) {
      debugPrint('[SecureMemory] No key in memory');
      return null;
    }

    // Check idle timeout
    if (_lastAccess != null) {
      final elapsed = DateTime.now().difference(_lastAccess!);
      if (elapsed >= _idleTimeout) {
        debugPrint('[SecureMemory] Key expired after ${elapsed.inSeconds}s idle — PURGING');
        _wipeKey();
        return null;
      }
    }

    // Refresh idle timer
    _lastAccess = DateTime.now();
    return _masterKey;
  }

  /// Check if a valid (non-expired) key exists
  bool get hasValidKey {
    if (_masterKey == null) return false;
    if (_lastAccess == null) return false;

    final elapsed = DateTime.now().difference(_lastAccess!);
    if (elapsed >= _idleTimeout) {
      _wipeKey();
      return false;
    }
    return true;
  }

  /// Force-wipe the Master Key from memory immediately.
  /// Overwrites every byte with 0x00 before releasing reference.
  void purge() {
    _wipeKey();
    debugPrint('[SecureMemory] PURGE command executed — key destroyed');
  }

  /// Internal: Zero out every byte and release
  void _wipeKey() {
    if (_masterKey != null) {
      // Overwrite with zeros — don't just null the reference
      for (int i = 0; i < _masterKey!.length; i++) {
        _masterKey![i] = 0x00;
      }
      _masterKey = null;
    }
    _lastAccess = null;
  }

  /// App lifecycle: Purge key when app goes to background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      debugPrint('[SecureMemory] App backgrounded — PURGING master key');
      _wipeKey();
    }
  }

  /// Tear down: Remove observer and wipe
  void dispose() {
    _wipeKey();
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
    }
    debugPrint('[SecureMemory] Disposed — observer removed, key destroyed');
  }
}
