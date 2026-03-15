#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
# Project Aeterna — Vercel Flutter SDK Install Script
# ──────────────────────────────────────────────────────────────
# Runs during Vercel's "Install Command" phase.
# Downloads Flutter SDK (stable), configures it, and installs deps.

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║  Project Aeterna — Installing Flutter SDK        ║"
echo "╚══════════════════════════════════════════════════╝"

# Clone Flutter stable (shallow — fast)
if [ ! -d "flutter" ]; then
  echo "[Aeterna] Cloning Flutter SDK (stable channel)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
else
  echo "[Aeterna] Flutter SDK already present, skipping clone."
fi

# Disable analytics in CI environment
export PATH="$PWD/flutter/bin:$PATH"
flutter config --no-analytics
flutter config --no-cli-animations

# Pre-cache web artifacts
echo "[Aeterna] Pre-caching web build tools..."
flutter precache --web

# Doctor check
echo "[Aeterna] Flutter doctor..."
flutter doctor -v

# Install project dependencies
echo "[Aeterna] Installing project dependencies..."
flutter pub get

echo "╔══════════════════════════════════════════════════╗"
echo "║  ✓ Flutter SDK Ready — Proceeding to Build      ║"
echo "╚══════════════════════════════════════════════════╝"
