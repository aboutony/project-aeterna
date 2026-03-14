import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'package:project_aeterna/features/vault/data/database/schema.dart';

/// Turso (libSQL) Client — Local-First Database
///
/// Sprint 1: Uses sqflite for local SQLite (Embedded Replica pattern).
/// Production: Will migrate to libsql_dart for native Turso sync.
///
/// Architecture:
///   - All reads/writes hit the LOCAL database instantly
///   - Background sync pushes encrypted data to Turso Edge
///   - 100% functional offline — zero "Loading..." states
class TursoClient {
  static TursoClient? _instance;
  Database? _db;

  TursoClient._();

  static TursoClient get instance {
    _instance ??= TursoClient._();
    return _instance!;
  }

  /// Initialize the local database.
  /// Creates all vault tables if they don't exist.
  Future<Database> getDatabase() async {
    if (_db != null && _db!.isOpen) return _db!;

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, 'aeterna_vault.db');

    debugPrint('[TursoClient] Initializing local vault at: $fullPath');

    _db = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        debugPrint('[TursoClient] Creating Sovereign Schema (v$version)...');

        // Create tables individually (sqflite batch)
        final batch = db.batch();
        batch.execute(VaultSchema.createVaultIdentity);
        batch.execute(VaultSchema.createVaultAssets);
        batch.execute(VaultSchema.createVaultMedia);
        batch.execute(VaultSchema.createHeirRegistry);
        batch.execute(VaultSchema.createDecoyAssets);
        await batch.commit(noResult: true);

        // Create indices
        final indexStatements = VaultSchema.createIndices
            .split(';')
            .where((s) => s.trim().isNotEmpty);
        for (final stmt in indexStatements) {
          await db.execute(stmt);
        }

        debugPrint('[TursoClient] ✓ Sovereign Schema created (5 tables, 5 indices)');
      },
    );

    debugPrint('[TursoClient] ✓ Database ready');
    return _db!;
  }

  /// Check if the database is initialized and accessible
  bool get isReady => _db != null && _db!.isOpen;

  /// Get table row counts for health check
  Future<Map<String, int>> getTableCounts() async {
    final db = await getDatabase();
    final tables = [
      'vault_identity',
      'vault_assets',
      'vault_media',
      'heir_registry',
      'decoy_assets',
    ];

    final counts = <String, int>{};
    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as c FROM $table');
      counts[table] = Sqflite.firstIntValue(result) ?? 0;
    }
    return counts;
  }

  /// Close the database connection
  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
      debugPrint('[TursoClient] Database closed');
    }
  }
}
