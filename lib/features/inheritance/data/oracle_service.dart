import 'package:flutter/foundation.dart';

import 'package:project_aeterna/features/vault/data/database/turso_client.dart';

/// OracleService — Background-Only Vitality Decay Engine
///
/// Manages the vault's "life pulse" status transitions:
///   ACTIVE → WARNING → CRITICAL → TRIGGERED
///
/// This class is **completely isolated** — no UI, no dashboard coupling.
/// It only reads/writes the `vault_identity.status` column in the local DB.
///
/// CTO Directive: "Build the engine separately. No UI toggle yet."
class OracleService {
  static OracleService? _instance;
  final TursoClient _client = TursoClient.instance;

  OracleService._();

  static OracleService get instance {
    _instance ??= OracleService._();
    return _instance!;
  }

  /// The decay chain — each call advances one step.
  static const List<String> _decayChain = [
    'ACTIVE',
    'WARNING',
    'CRITICAL',
    'TRIGGERED',
  ];

  /// Read the current vault status from the local DB.
  ///
  /// Returns the status string (ACTIVE, WARNING, CRITICAL, TRIGGERED)
  /// or null if no vault identity exists.
  Future<String?> getVaultStatus() async {
    final db = await _client.getDatabase();
    final results = await db.rawQuery(
      'SELECT status FROM vault_identity '
      'ORDER BY created_at DESC LIMIT 1',
    );

    if (results.isEmpty) {
      debugPrint('[OracleService] No vault identity found');
      return null;
    }

    final status = results.first['status'] as String;
    debugPrint('[OracleService] Current vault status: $status');
    return status;
  }

  /// Advance the vault status one step through the decay chain.
  ///
  /// ACTIVE → WARNING → CRITICAL → TRIGGERED
  ///
  /// If already at TRIGGERED, status remains TRIGGERED (terminal state).
  /// Returns the new status after decay, or null if no vault identity exists.
  Future<String?> triggerDecay() async {
    final currentStatus = await getVaultStatus();
    if (currentStatus == null) return null;

    final currentIndex = _decayChain.indexOf(currentStatus);
    if (currentIndex == -1) {
      debugPrint('[OracleService] Unknown status: $currentStatus');
      return currentStatus;
    }

    // If already at terminal state, stay there
    if (currentIndex >= _decayChain.length - 1) {
      debugPrint('[OracleService] Already at terminal state: $currentStatus');
      return currentStatus;
    }

    final newStatus = _decayChain[currentIndex + 1];
    final now = DateTime.now().toIso8601String();

    final db = await _client.getDatabase();
    await db.rawUpdate(
      'UPDATE vault_identity SET status = ?, updated_at = ? '
      'WHERE id = (SELECT id FROM vault_identity ORDER BY created_at DESC LIMIT 1)',
      [newStatus, now],
    );

    debugPrint('[OracleService] ⚡ Decay triggered: $currentStatus → $newStatus');
    return newStatus;
  }

  /// Reset vault status back to ACTIVE.
  ///
  /// Used for testing and development — resets the decay chain.
  Future<String?> resetStatus() async {
    final db = await _client.getDatabase();
    final now = DateTime.now().toIso8601String();

    final count = await db.rawUpdate(
      'UPDATE vault_identity SET status = ?, updated_at = ? '
      'WHERE id = (SELECT id FROM vault_identity ORDER BY created_at DESC LIMIT 1)',
      ['ACTIVE', now],
    );

    if (count == 0) {
      debugPrint('[OracleService] No vault identity to reset');
      return null;
    }

    debugPrint('[OracleService] ✓ Status reset to ACTIVE');
    return 'ACTIVE';
  }
}
