# Project Aeterna

> Sovereign Digital Vault — Built with Native Flutter Excellence

## Quick Start

```bash
# Ensure Flutter is on PATH
$env:Path = "C:\flutter\bin;" + $env:Path

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Windows
flutter run -d windows

# Build web release
flutter build web --release

# Run tests
flutter test
```

## Architecture

```
lib/
├── core/
│   ├── theme/
│   │   ├── sanctum_colors.dart     # Digital Sanctum palette
│   │   ├── sanctum_typography.dart  # Serif + Sans typography
│   │   └── sanctum_theme.dart       # Dark/Light themes
│   └── utils/
│       └── secure_memory.dart       # Volatile key manager
├── features/
│   ├── splash/                      # The Gateway (Iris Portal)
│   └── vault/
│       └── data/database/           # Turso libSQL bridge
├── security/
│   ├── argon2_service.dart          # Key derivation (Argon2id)
│   └── key_derivation.dart          # Bio-to-Entropy pipeline
└── main.dart                        # App entry with RTL/LTR
```

## Security

- **Master Key**: Lives only in volatile RAM (60s auto-purge)
- **Encryption**: AES-256-GCM via Argon2id-derived keys
- **Storage**: Salt in Secure Storage; key NEVER on disk
- **Duress**: Decoy vault with plausible deniability

## License

Proprietary — PAC Technologies
