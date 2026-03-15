import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:project_aeterna/features/vault/data/database/turso_client.dart';

/// Dashboard Data Service — connects the Sanctum Dashboard to the local vault.
///
/// Provides aggregated views of vault data for the dashboard UI:
///   - Asset summaries by category (Financial, Sentimental, Discrete)
///   - Vault identity + heartbeat vitality
///   - Demo data seeding on first launch
///
/// CTO Directive: "Seeds demo data silently on first run. The user
/// should land on a dashboard that feels populated and alive."
class DashboardDataService {
  static DashboardDataService? _instance;
  final TursoClient _client = TursoClient.instance;
  static const _uuid = Uuid();

  DashboardDataService._();

  static DashboardDataService get instance {
    _instance ??= DashboardDataService._();
    return _instance!;
  }

  /// Initialize the dashboard — seeds demo data if vault is empty.
  Future<void> initialize() async {
    final db = await _client.getDatabase();

    // Check if vault has any identity (first launch check)
    final identities = await db.rawQuery(
      'SELECT COUNT(*) as c FROM vault_identity',
    );
    final identityCount = identities.first['c'] as int? ?? 0;

    // Also check if assets exist (detect partial seed from prior failures)
    final assets = await db.rawQuery(
      'SELECT COUNT(*) as c FROM vault_assets',
    );
    final assetCount = assets.first['c'] as int? ?? 0;

    if (identityCount == 0 || assetCount == 0) {
      // Clean up any partial seed state
      if (identityCount > 0 && assetCount == 0) {
        debugPrint('[DashboardData] Detected partial seed — cleaning up');
        await db.delete('vault_identity');
        await db.delete('vault_media');
        await db.delete('heir_registry');
        await db.delete('decoy_assets');
      }
      debugPrint('[DashboardData] First launch detected — seeding demo data');
      await _seedDemoData(db);
    } else {
      debugPrint('[DashboardData] Vault populated ($identityCount identities, $assetCount assets)');
      // Update heartbeat on every launch
      await _recordHeartbeat(db);
    }
  }

  /// Get asset counts grouped by category.
  Future<Map<String, int>> getAssetSummary() async {
    final db = await _client.getDatabase();

    final financial = await db.rawQuery(
      "SELECT COUNT(*) as c FROM vault_assets WHERE category = 'FINANCIAL'",
    );
    final discrete = await db.rawQuery(
      "SELECT COUNT(*) as c FROM vault_assets WHERE category = 'DISCRETE'",
    );
    final media = await db.rawQuery(
      'SELECT COUNT(*) as c FROM vault_media',
    );

    return {
      'FINANCIAL': financial.first['c'] as int? ?? 0,
      'SENTIMENTAL': media.first['c'] as int? ?? 0,
      'DISCRETE': discrete.first['c'] as int? ?? 0,
    };
  }

  /// Get the primary vault identity with heartbeat data.
  Future<Map<String, dynamic>?> getVaultIdentity() async {
    final db = await _client.getDatabase();
    final results = await db.rawQuery(
      'SELECT * FROM vault_identity ORDER BY created_at DESC LIMIT 1',
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Record a heartbeat pulse — updates the vault_identity timestamp.
  Future<void> recordHeartbeat() async {
    final db = await _client.getDatabase();
    await _recordHeartbeat(db);
  }

  /// Get recent vault assets for the activity feed.
  Future<List<Map<String, dynamic>>> getRecentAssets({int limit = 5}) async {
    final db = await _client.getDatabase();
    return db.rawQuery(
      'SELECT * FROM vault_assets ORDER BY updated_at DESC LIMIT ?',
      [limit],
    );
  }

  /// Get financial asset total value (mock — encrypted payloads)
  Future<Map<String, dynamic>> getFinancialSummary() async {
    final db = await _client.getDatabase();
    final assets = await db.rawQuery(
      "SELECT * FROM vault_assets WHERE category = 'FINANCIAL'",
    );
    return {
      'count': assets.length,
      'tiers': assets.map((a) => a['access_tier'] as int? ?? 4).toList(),
      'hasWallets': assets.any((a) => a['heir_wallet_address'] != null),
    };
  }

  /// Get media summary for sentimental legacy
  Future<Map<String, dynamic>> getMediaSummary() async {
    final db = await _client.getDatabase();
    final media = await db.rawQuery('SELECT * FROM vault_media');
    final totalSize = media.fold<int>(
      0,
      (sum, m) => sum + (m['file_size_bytes'] as int? ?? 0),
    );
    return {
      'count': media.length,
      'totalSizeBytes': totalSize,
      'types': media.map((m) => m['media_type'] as String).toSet().toList(),
    };
  }

  /// Get assets for a specific category.
  /// Returns vault_assets rows for FINANCIAL/DISCRETE,
  /// or vault_media rows for SENTIMENTAL.
  Future<List<Map<String, dynamic>>> getAssetsByCategory(String category) async {
    final db = await _client.getDatabase();
    if (category == 'SENTIMENTAL') {
      return db.rawQuery('SELECT * FROM vault_media ORDER BY created_at DESC');
    }
    return db.rawQuery(
      'SELECT * FROM vault_assets WHERE category = ? ORDER BY updated_at DESC',
      [category],
    );
  }

  // ─── Private: Demo Data Seeding ──────────────────────────────────────

  Future<void> _seedDemoData(dynamic db) async {
    final vaultId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    // Seed vault identity with active heartbeat
    await db.insert('vault_identity', {
      'id': vaultId,
      'iris_hash_primary': 'DEMO_IRIS_HASH_${_uuid.v4().substring(0, 8)}',
      'status': 'ACTIVE',
      'last_heartbeat': now,
      'threshold_days': 30,
      'is_decoy_active': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Seed Financial assets (3 items — wealth portfolio)
    final financialAssets = [
      {
        'name': 'Primary Holdings',
        'wallet': '0x7a3F...e91B',
        'tier': 4,
      },
      {
        'name': 'Sovereign Reserve',
        'wallet': '0x2dC8...f47A',
        'tier': 5,
      },
      {
        'name': 'Legacy Trust',
        'wallet': null,
        'tier': 3,
      },
    ];

    for (final asset in financialAssets) {
      await db.insert('vault_assets', {
        'asset_id': _uuid.v4(),
        'vault_id': vaultId,
        'category': 'FINANCIAL',
        'encrypted_payload': _generateMockPayload(64),
        'heir_wallet_address': asset['wallet'],
        'access_tier': asset['tier'],
        'created_at': now,
        'updated_at': now,
      });
    }

    // Seed Discrete assets (2 items — confidential credentials)
    final discreteAssets = [
      {'tier': 5},
      {'tier': 4},
    ];

    for (final asset in discreteAssets) {
      await db.insert('vault_assets', {
        'asset_id': _uuid.v4(),
        'vault_id': vaultId,
        'category': 'DISCRETE',
        'encrypted_payload': _generateMockPayload(32),
        'access_tier': asset['tier'],
        'created_at': now,
        'updated_at': now,
      });
    }

    // Seed Sentimental media (4 items — legacy media)
    final mediaItems = [
      {'type': 'VIDEO_LEGACY', 'size': 524288000},   // ~500 MB
      {'type': 'PHOTO_ARCHIVE', 'size': 157286400},  // ~150 MB
      {'type': 'VOICE_VAULT', 'size': 31457280},      // ~30 MB
      {'type': 'VIDEO_LEGACY', 'size': 1073741824},   // ~1 GB
    ];

    for (final media in mediaItems) {
      await db.insert('vault_media', {
        'media_id': _uuid.v4(),
        'vault_id': vaultId,
        'r2_pointer': 'r2://aeterna-vault/${_uuid.v4()}',
        'media_type': media['type'],
        'access_tier': 1,
        'file_size_bytes': media['size'],
        'encryption_iv': _uuid.v4().substring(0, 16),
        'created_at': now,
      });
    }

    // Seed heir registry (1 entry)
    await db.insert('heir_registry', {
      'heir_id': _uuid.v4(),
      'vault_id': vaultId,
      'contact_alias': 'The Successor',
      'contact_method': 'TELEGRAM',
      'heir_bio_ref': 'HEIR_BIO_REF_${_uuid.v4().substring(0, 8)}',
      'is_active': 1,
      'notification_sent': 0,
      'created_at': now,
      'updated_at': now,
    });

    // Seed decoy assets
    final decoys = [
      {'name': 'Personal Savings', 'value': 'SAR 12,400', 'balance': 75.00},
      {'name': 'Travel Fund', 'value': 'USD 2,100', 'balance': 45.50},
    ];

    for (final decoy in decoys) {
      await db.insert('decoy_assets', {
        'asset_id': _uuid.v4(),
        'category': 'PUBLIC',
        'display_name': decoy['name'],
        'display_value': decoy['value'],
        'mock_balance': decoy['balance'],
        'created_at': now,
      });
    }

    debugPrint('[DashboardData] ✓ Demo vault seeded: '
        '3 financial, 2 discrete, 4 media, 1 heir, 2 decoy');
  }

  Future<void> _recordHeartbeat(dynamic db) async {
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
      'UPDATE vault_identity SET last_heartbeat = ?, updated_at = ? '
      'WHERE id = (SELECT id FROM vault_identity ORDER BY created_at DESC LIMIT 1)',
      [now, now],
    );
    debugPrint('[DashboardData] ♥ Heartbeat recorded: $now');
  }

  /// Generate a mock encrypted payload as a hex string.
  /// Uses hex string instead of binary BLOB for sqflite_ffi_web compatibility.
  static String _generateMockPayload(int length) {
    final bytes = List.generate(length, (i) => (i * 7 + 13) % 256);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
