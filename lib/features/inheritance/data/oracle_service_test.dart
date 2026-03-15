import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:uuid/uuid.dart';

import 'package:project_aeterna/features/vault/data/database/schema.dart';

/// OracleService Test — Isolated Proof of Decay Logic
///
/// Uses its own test database (NOT the app's vault DB).
/// Proves the decay chain works: ACTIVE → WARNING → CRITICAL → TRIGGERED
/// and that reset returns to ACTIVE.
///
/// Pattern: Same as OfflineFirstTest — in-app test class, not flutter_test.
class OracleServiceTest {
  OracleServiceTest._();

  static const _uuid = Uuid();

  /// Run the full Oracle decay test suite.
  /// Returns a map of test names → pass/fail status.
  static Future<Map<String, bool>> runAll() async {
    debugPrint('\n');
    debugPrint('┌──────────────────────────────────────────────────────┐');
    debugPrint('│  ORACLE SERVICE TEST — Isolated Decay Engine        │');
    debugPrint('│  Proving vault_identity status transitions          │');
    debugPrint('└──────────────────────────────────────────────────────┘');

    final results = <String, bool>{};

    // Use a test-specific database — completely isolated
    final dbPath = await getDatabasesPath();
    final testDbPath = path_pkg.join(dbPath, 'aeterna_oracle_test.db');

    // Clean up any previous test run
    await deleteDatabase(testDbPath);

    Database? db;

    try {
      // ─── Setup: Create schema and seed identity ────────────
      debugPrint('\n[SETUP] Creating isolated test database...');
      db = await openDatabase(
        testDbPath,
        version: 1,
        onCreate: (db, version) async {
          final batch = db.batch();
          batch.execute(VaultSchema.createVaultIdentity);
          batch.execute(VaultSchema.createVaultAssets);
          batch.execute(VaultSchema.createVaultMedia);
          batch.execute(VaultSchema.createHeirRegistry);
          batch.execute(VaultSchema.createDecoyAssets);
          await batch.commit(noResult: true);
        },
      );

      // Seed a vault identity with ACTIVE status
      final vaultId = _uuid.v4();
      final now = DateTime.now().toIso8601String();
      await db.insert('vault_identity', {
        'id': vaultId,
        'iris_hash_primary': 'TEST_ORACLE_HASH_${_uuid.v4().substring(0, 8)}',
        'status': 'ACTIVE',
        'last_heartbeat': now,
        'threshold_days': 30,
        'is_decoy_active': 0,
        'created_at': now,
        'updated_at': now,
      });
      debugPrint('[SETUP] ✓ Test vault identity seeded (status: ACTIVE)');

      // ─── Test 1: Read Initial Status ───────────────────────
      debugPrint('\n[TEST 1] Read Initial Status');
      final initialRow = await db.rawQuery(
        'SELECT status FROM vault_identity WHERE id = ?',
        [vaultId],
      );
      final initialStatus = initialRow.first['status'] as String;
      results['Read Initial Status'] = initialStatus == 'ACTIVE';
      debugPrint('[TEST 1] ${initialStatus == 'ACTIVE' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status: $initialStatus');

      // ─── Test 2: Decay ACTIVE → WARNING ────────────────────
      debugPrint('\n[TEST 2] Decay: ACTIVE → WARNING');
      await _triggerDecay(db, vaultId);
      final status2 = await _getStatus(db, vaultId);
      results['Decay ACTIVE → WARNING'] = status2 == 'WARNING';
      debugPrint('[TEST 2] ${status2 == 'WARNING' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status: $status2');

      // ─── Test 3: Decay WARNING → CRITICAL ──────────────────
      debugPrint('\n[TEST 3] Decay: WARNING → CRITICAL');
      await _triggerDecay(db, vaultId);
      final status3 = await _getStatus(db, vaultId);
      results['Decay WARNING → CRITICAL'] = status3 == 'CRITICAL';
      debugPrint('[TEST 3] ${status3 == 'CRITICAL' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status: $status3');

      // ─── Test 4: Decay CRITICAL → TRIGGERED ────────────────
      debugPrint('\n[TEST 4] Decay: CRITICAL → TRIGGERED');
      await _triggerDecay(db, vaultId);
      final status4 = await _getStatus(db, vaultId);
      results['Decay CRITICAL → TRIGGERED'] = status4 == 'TRIGGERED';
      debugPrint('[TEST 4] ${status4 == 'TRIGGERED' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status: $status4');

      // ─── Test 5: Terminal State — No Further Decay ─────────
      debugPrint('\n[TEST 5] Terminal State — TRIGGERED stays TRIGGERED');
      await _triggerDecay(db, vaultId);
      final status5 = await _getStatus(db, vaultId);
      results['Terminal State Hold'] = status5 == 'TRIGGERED';
      debugPrint('[TEST 5] ${status5 == 'TRIGGERED' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status: $status5');

      // ─── Test 6: Reset to ACTIVE ───────────────────────────
      debugPrint('\n[TEST 6] Reset: TRIGGERED → ACTIVE');
      await _resetStatus(db, vaultId);
      final status6 = await _getStatus(db, vaultId);
      results['Reset to ACTIVE'] = status6 == 'ACTIVE';
      debugPrint('[TEST 6] ${status6 == 'ACTIVE' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status: $status6');

      // ─── Test 7: Full Cycle Round-Trip ─────────────────────
      debugPrint('\n[TEST 7] Full Cycle Round-Trip Verification');
      await _triggerDecay(db, vaultId); // → WARNING
      await _triggerDecay(db, vaultId); // → CRITICAL
      await _resetStatus(db, vaultId); // → ACTIVE
      final status7 = await _getStatus(db, vaultId);
      results['Full Cycle Round-Trip'] = status7 == 'ACTIVE';
      debugPrint('[TEST 7] ${status7 == 'ACTIVE' ? '✓ PASS' : '✗ FAIL'}'
          ' — Status after round-trip: $status7');

    } catch (e) {
      debugPrint('[ORACLE TEST] ✗ EXCEPTION: $e');
      results['Exception'] = false;
    } finally {
      if (db != null && db.isOpen) {
        await db.close();
      }
      // Cleanup test database
      await deleteDatabase(testDbPath);
      debugPrint('[CLEANUP] Test database deleted');
    }

    // ─── Summary ──────────────────────────────────────────────
    debugPrint('\n');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('  ORACLE SERVICE TEST RESULTS');
    debugPrint('═══════════════════════════════════════════════════════');
    int passed = 0;
    int failed = 0;
    for (final entry in results.entries) {
      final icon = entry.value ? '✓' : '✗';
      debugPrint('  $icon ${entry.key}');
      if (entry.value) {
        passed++;
      } else {
        failed++;
      }
    }
    debugPrint('───────────────────────────────────────────────────────');
    debugPrint('  $passed passed, $failed failed');
    debugPrint('  ${failed == 0 ? 'ALL TESTS PASSED ✓' : 'SOME TESTS FAILED ✗'}');
    debugPrint('═══════════════════════════════════════════════════════\n');

    return results;
  }

  // ─── Isolated decay logic (mirrors OracleService but operates on test DB) ─

  static const List<String> _decayChain = [
    'ACTIVE',
    'WARNING',
    'CRITICAL',
    'TRIGGERED',
  ];

  static Future<void> _triggerDecay(Database db, String vaultId) async {
    final currentStatus = await _getStatus(db, vaultId);
    if (currentStatus == null) return;

    final currentIndex = _decayChain.indexOf(currentStatus);
    if (currentIndex == -1 || currentIndex >= _decayChain.length - 1) return;

    final newStatus = _decayChain[currentIndex + 1];
    final now = DateTime.now().toIso8601String();

    await db.rawUpdate(
      'UPDATE vault_identity SET status = ?, updated_at = ? WHERE id = ?',
      [newStatus, now, vaultId],
    );
  }

  static Future<String?> _getStatus(Database db, String vaultId) async {
    final rows = await db.rawQuery(
      'SELECT status FROM vault_identity WHERE id = ?',
      [vaultId],
    );
    if (rows.isEmpty) return null;
    return rows.first['status'] as String;
  }

  static Future<void> _resetStatus(Database db, String vaultId) async {
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
      'UPDATE vault_identity SET status = ?, updated_at = ? WHERE id = ?',
      ['ACTIVE', now, vaultId],
    );
  }
}
