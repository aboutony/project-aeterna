/// Turso (libSQL) Schema — The "Sovereign" Database
///
/// Implements the 4-table "Chapter" isolation model from Document 7.
/// Each table is a "Chapter" in the user's vault:
///   A. vault_identity — biometric hashes and vitality pulse
///   B. vault_assets — encrypted credentials and USDT metadata
///   C. vault_media — R2 pointers for sentimental legacy
///   D. heir_registry — Ghost Protocol beneficiary data
///
/// Sprint 1: Local SQLite via sqflite (Turso libSQL embedded replica
/// will be integrated once the Dart package stabilizes).
class VaultSchema {
  VaultSchema._();

  /// Create all vault tables
  static const String createAll = '''
    $createVaultIdentity
    $createVaultAssets
    $createVaultMedia
    $createHeirRegistry
    $createDecoyAssets
  ''';

  // ─── Table A: vault_identity (The Anchor) ──────────────────────────
  static const String createVaultIdentity = '''
    CREATE TABLE IF NOT EXISTS vault_identity (
      id TEXT PRIMARY KEY,
      iris_hash_primary TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'ACTIVE'
        CHECK(status IN ('ACTIVE', 'WARNING', 'CRITICAL', 'TRIGGERED')),
      last_heartbeat TEXT NOT NULL,
      threshold_days INTEGER NOT NULL DEFAULT 30,
      is_decoy_active INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  ''';

  // ─── Table B: vault_assets (Wealth & Sovereign Information) ────────
  static const String createVaultAssets = '''
    CREATE TABLE IF NOT EXISTS vault_assets (
      asset_id TEXT PRIMARY KEY,
      vault_id TEXT NOT NULL,
      category TEXT NOT NULL
        CHECK(category IN ('FINANCIAL', 'LEGAL', 'DISCRETE')),
      encrypted_payload BLOB NOT NULL,
      heir_wallet_address TEXT,
      release_signature TEXT,
      access_tier INTEGER NOT NULL DEFAULT 4,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (vault_id) REFERENCES vault_identity(id) ON DELETE CASCADE
    );
  ''';

  // ─── Table C: vault_media (The Sentimental Legacy) ─────────────────
  static const String createVaultMedia = '''
    CREATE TABLE IF NOT EXISTS vault_media (
      media_id TEXT PRIMARY KEY,
      vault_id TEXT NOT NULL,
      r2_pointer TEXT NOT NULL,
      media_type TEXT NOT NULL
        CHECK(media_type IN ('VIDEO_LEGACY', 'PHOTO_ARCHIVE', 'VOICE_VAULT')),
      access_tier INTEGER NOT NULL DEFAULT 1,
      file_size_bytes INTEGER DEFAULT 0,
      encryption_iv TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (vault_id) REFERENCES vault_identity(id) ON DELETE CASCADE
    );
  ''';

  // ─── Table D: heir_registry (The Ghost Protocol) ───────────────────
  static const String createHeirRegistry = '''
    CREATE TABLE IF NOT EXISTS heir_registry (
      heir_id TEXT PRIMARY KEY,
      vault_id TEXT NOT NULL,
      contact_alias TEXT NOT NULL,
      contact_method TEXT NOT NULL
        CHECK(contact_method IN ('WHATSAPP', 'TELEGRAM', 'EMAIL')),
      heir_bio_ref TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      notification_sent INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      updated_at TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY (vault_id) REFERENCES vault_identity(id) ON DELETE CASCADE
    );
  ''';

  // ─── Decoy Assets (Duress Mode — Shadow Vault) ─────────────────────
  /// Populated with realistic but harmless data per Document 9.
  /// Completely isolated from sovereign tables.
  static const String createDecoyAssets = '''
    CREATE TABLE IF NOT EXISTS decoy_assets (
      asset_id TEXT PRIMARY KEY,
      category TEXT NOT NULL DEFAULT 'PUBLIC',
      display_name TEXT NOT NULL,
      display_value TEXT,
      mock_balance REAL DEFAULT 75.00,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  ''';

  // ─── Indices for query performance ─────────────────────────────────
  static const String createIndices = '''
    CREATE INDEX IF NOT EXISTS idx_vault_assets_vault_id
      ON vault_assets(vault_id);
    CREATE INDEX IF NOT EXISTS idx_vault_assets_category
      ON vault_assets(category);
    CREATE INDEX IF NOT EXISTS idx_vault_media_vault_id
      ON vault_media(vault_id);
    CREATE INDEX IF NOT EXISTS idx_heir_registry_vault_id
      ON heir_registry(vault_id);
    CREATE INDEX IF NOT EXISTS idx_vault_identity_status
      ON vault_identity(status);
  ''';
}
