#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# patch.sh - build "MortPlayer 1.0.3-community" from YOUR OWN copy of the
#            original MortPlayer Audio Books 1.0.1 APK (Linux / macOS / WSL).
#
# Usage:   ./patch.sh path/to/MortPlayer-1.0.1.apk
# Result:  out/MortPlayer-1.0.3-community-selfsigned.apk
#
# Needs:   Java 11 or newer, plus two downloads placed in ./tools (see README):
#            tools/apktool_2.4.0.jar           (exactly 2.4.0 - newer ones break the app)
#            tools/uber-apk-signer-1.3.0.jar   (any 1.x should work)
#
# Every step is explained below so you can follow along or do it by hand.
# =============================================================================

# Stop on the first error (-e), on unset variables (-u) and on failures inside pipes.
set -euo pipefail

# --- Settings ---------------------------------------------------------------
# SHA-256 of the one and only APK these patches were made for:
# de.stohelit.audiobookplayer, versionName 1.0.1, versionCode 200014.
ORIGINAL_SHA256="df150b90177d3fc331b5114d3cb38216d65b6a9f24cd4c64d1ec9bcd4989f14f"

# Folder this script lives in, so it works no matter where you call it from.
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APKTOOL="${APKTOOL_JAR:-$KIT/tools/apktool_2.4.0.jar}"          # override with APKTOOL_JAR=...
SIGNER="${SIGNER_JAR:-$(ls "$KIT"/tools/uber-apk-signer-*.jar 2>/dev/null | head -n1 || true)}"
WORK="$KIT/work"                    # temporary build folder (deleted and re-created each run)
OUT="$KIT/out"                      # finished APK goes here
KEYDIR="$KIT/my-signing-key"        # YOUR key, created on first run and reused afterwards

say()  { printf '\n==> %s\n' "$*"; }           # pretty step headings
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

# --- 0. Check the input and the tools ----------------------------------------
[ $# -eq 1 ] || fail "usage: $0 path/to/original-MortPlayer-1.0.1.apk"
INPUT="$1"
[ -f "$INPUT" ] || fail "file not found: $INPUT"

command -v java >/dev/null || fail "Java not found. Install Java 11+ (e.g. https://adoptium.net) and try again."
# 'java -version' prints e.g. 'openjdk version "17.0.9"'; take the major number (1.8 -> 8).
JV=$(java -version 2>&1 | head -n1 | sed -E 's/.*version "([0-9]+)(\.([0-9]+))?.*/\1 \3/')
JMAJOR=${JV%% *}; [ "$JMAJOR" = "1" ] && JMAJOR=${JV##* }
[ "$JMAJOR" -ge 11 ] 2>/dev/null || fail "Java 11 or newer is needed (found: $(java -version 2>&1 | head -n1))."
command -v keytool >/dev/null || fail "'keytool' not found; it comes with Java - is Java's bin folder on your PATH?"

[ -f "$APKTOOL" ] || fail "apktool 2.4.0 not found at $APKTOOL (see README, 'What you need')."
[ -n "$SIGNER" ] && [ -f "$SIGNER" ] || fail "uber-apk-signer jar not found in $KIT/tools (see README)."

# The checksum proves this is exactly the APK the patches were written for.
say "Checking your APK"
if command -v sha256sum >/dev/null; then SUM=$(sha256sum "$INPUT" | cut -d' ' -f1)
else SUM=$(shasum -a 256 "$INPUT" | cut -d' ' -f1); fi   # macOS has shasum instead
[ "$SUM" = "$ORIGINAL_SHA256" ] || fail "this is not the original MortPlayer 1.0.1 APK.
  expected $ORIGINAL_SHA256
  got      $SUM"
echo "    OK - original MortPlayer 1.0.1"

# Small helpers so the commands below stay readable.
apktool()   { java -jar "$APKTOOL" "$@"; }
mortpatch() { java "$KIT/tools/MortPatch.java" "$@"; }   # Java 11+ runs a .java file directly

# --- 1. Decode the APK twice ------------------------------------------------------
# "app":      apktool d -r  -> code (smali) is decoded, resources are left exactly as they are.
#             This is the project we finally rebuild; it keeps Mort's resources byte-identical.
# "manifest": full decode     -> the manifest becomes readable XML so patch 06 can edit it.
#             We only use it to produce the new binary AndroidManifest.xml.
say "Decoding with apktool 2.4.0 (takes a minute)"
rm -rf "$WORK"; mkdir -p "$WORK" "$OUT"
apktool d -r -f -o "$WORK/app"      "$INPUT"
apktool d    -f -o "$WORK/manifest" "$INPUT"

# --- 2. Apply our patches and add our new classes ----------------------------------
# Each .mpatch checks the SHA-256 of the file it edits first, so nothing is changed
# unless the file is exactly the expected one.
say "Applying patches"
mortpatch apply "$KIT/patches" "$WORK"
mortpatch copytree "$KIT/new-files" "$WORK/app"

# --- 3. Build the new manifest and move it into the app project --------------------
say "Building the new AndroidManifest.xml"
apktool b "$WORK/manifest" -o "$WORK/manifest-only.apk"
mortpatch extract "$WORK/manifest-only.apk" AndroidManifest.xml "$WORK/app/AndroidManifest.xml"

# --- 4. Rebuild the app -----------------------------------------------------------
say "Rebuilding the APK"
apktool b "$WORK/app" -o "$WORK/MortPlayer-1.0.3-community-unsigned.apk"

# --- 5. Make (once) and use YOUR OWN signing key -----------------------------------
# Android only installs signed apps. We never ship a key: you create your own here.
# Keep the my-signing-key folder - future rebuilds signed with the same key can be
# installed as updates without uninstalling (and keep your settings).
if [ ! -f "$KEYDIR/mortplayer.jks" ]; then
  say "Creating your personal signing key (first run only)"
  mkdir -p "$KEYDIR"
  # A random password, stored next to the key so later runs can reuse it.
  PASS=$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24 || true)
  printf '%s\n' "$PASS" > "$KEYDIR/password.txt"
  chmod 600 "$KEYDIR/password.txt" 2>/dev/null || true
  keytool -genkeypair -keystore "$KEYDIR/mortplayer.jks" -storetype JKS \
          -storepass "$PASS" -keypass "$PASS" -alias mortplayer \
          -keyalg RSA -keysize 2048 -validity 10000 \
          -dname "CN=MortPlayer community build (self-signed)" >/dev/null 2>&1  # hide the harmless "JKS format" notice
fi
PASS=$(head -n1 "$KEYDIR/password.txt")

say "Signing"
java -jar "$SIGNER" -a "$WORK/MortPlayer-1.0.3-community-unsigned.apk" -o "$WORK/signed" \
     --ks "$KEYDIR/mortplayer.jks" --ksAlias mortplayer --ksPass "$PASS" --ksKeyPass "$PASS" \
     --allowResign
# uber-apk-signer zipaligns, signs (v1+v2+v3) and verifies; pick up its output file.
SIGNED=$(ls "$WORK"/signed/*.apk | head -n1)
cp "$SIGNED" "$OUT/MortPlayer-1.0.3-community-selfsigned.apk"

say "Done!"
echo "    $OUT/MortPlayer-1.0.3-community-selfsigned.apk"
echo
echo "    IMPORTANT: uninstall the original MortPlayer first. Android refuses to install"
echo "    an app over one signed with a different key (export your bookmarks/settings first)."
echo "    Keep the 'my-signing-key' folder private and safe."
