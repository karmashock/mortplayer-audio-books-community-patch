# SPDX-License-Identifier: MIT
# =============================================================================
# patch.ps1 - build "MortPlayer 1.0.3-community" from YOUR OWN copy of the
#             original MortPlayer Audio Books 1.0.1 APK (Windows PowerShell 5.1+ / PowerShell 7).
#
# Usage:   double-click patch.bat and pick the APK, or run
#            powershell -ExecutionPolicy Bypass -File patch.ps1 "C:\path\MortPlayer 1.0.1.apk"
# Result:  out\MortPlayer-1.0.3-community-selfsigned.apk
#
# Needs:   Java 11 or newer, plus two downloads placed in .\tools (see README):
#            tools\apktool_2.4.0.jar           (exactly 2.4.0 - newer ones break the app)
#            tools\uber-apk-signer-1.3.0.jar   (any 1.x should work)
#
# This does exactly the same steps as patch.sh; see the comments there or below.
# =============================================================================
param([string]$Apk)

$ErrorActionPreference = 'Stop'          # stop on the first PowerShell error

# SHA-256 of the one and only APK these patches were made for (MortPlayer 1.0.1, versionCode 200014).
$OriginalSha256 = 'df150b90177d3fc331b5114d3cb38216d65b6a9f24cd4c64d1ec9bcd4989f14f'

$Kit     = $PSScriptRoot                                   # folder this script lives in
$Apktool = if ($env:APKTOOL_JAR) { $env:APKTOOL_JAR } else { Join-Path $Kit 'tools\apktool_2.4.0.jar' }
$Signer  = Get-ChildItem (Join-Path $Kit 'tools') -Filter 'uber-apk-signer-*.jar' -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName
$Work    = Join-Path $Kit 'work'                           # temporary build folder
$Out     = Join-Path $Kit 'out'                            # finished APK goes here
$KeyDir  = Join-Path $Kit 'my-signing-key'                 # YOUR key, made on first run

function Say($msg)  { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Fail($msg) { Write-Host "`nERROR: $msg" -ForegroundColor Red; exit 1 }

# Run java and stop if it reports an error (external programs don't trigger $ErrorActionPreference).
function Invoke-Java {
    & java @args
    if ($LASTEXITCODE -ne 0) { Fail "java $($args -join ' ') failed (exit $LASTEXITCODE)" }
}

# --- 0. Check the input and the tools ----------------------------------------------
if (-not $Apk) {
    # No argument (e.g. double-clicked): show a file picker.
    Add-Type -AssemblyName System.Windows.Forms
    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title  = 'Pick your original MortPlayer 1.0.1 APK'
    $dlg.Filter = 'Android app (*.apk)|*.apk'
    if ($dlg.ShowDialog() -ne 'OK') { Fail 'no APK chosen' }
    $Apk = $dlg.FileName
}
if (-not (Test-Path -LiteralPath $Apk -PathType Leaf)) { Fail "file not found: $Apk" }
$Apk = (Resolve-Path -LiteralPath $Apk).Path

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    Fail 'Java not found. Install Java 11+ (e.g. https://adoptium.net, tick "Add to PATH") and try again.'
}
# 'java -version' writes to stderr, e.g. openjdk version "17.0.9"; take the major number.
# (stderr lines become error records in PowerShell, so relax error handling for this one call)
$ErrorActionPreference = 'Continue'
$jv = (& java -version 2>&1 | Select-Object -First 1).ToString()
$ErrorActionPreference = 'Stop'
if ($jv -match '"(\d+)(\.(\d+))?') { $major = [int]$Matches[1]; if ($major -eq 1) { $major = [int]$Matches[3] } } else { $major = 0 }
if ($major -lt 11) { Fail "Java 11 or newer is needed (found: $jv)" }
if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) { Fail "'keytool' not found; it comes with Java - is Java's bin folder on PATH?" }
if (-not (Test-Path $Apktool)) { Fail "apktool 2.4.0 not found at $Apktool (see README, 'What you need')." }
if (-not $Signer) { Fail "uber-apk-signer jar not found in $Kit\tools (see README)." }

# The checksum proves this is exactly the APK the patches were written for.
Say 'Checking your APK'
$sum = (Get-FileHash -Algorithm SHA256 -LiteralPath $Apk).Hash.ToLower()
if ($sum -ne $OriginalSha256) { Fail "this is not the original MortPlayer 1.0.1 APK.`n  expected $OriginalSha256`n  got      $sum" }
Write-Host '    OK - original MortPlayer 1.0.1'

$MortPatch = Join-Path $Kit 'tools\MortPatch.java'        # Java 11+ runs a .java file directly

# --- 1. Decode twice: "app" (code only, resources untouched) and "manifest" (full, for patch 06)
Say 'Decoding with apktool 2.4.0 (takes a minute)'
if (Test-Path $Work) { Remove-Item -Recurse -Force $Work }
New-Item -ItemType Directory -Force -Path $Work, $Out | Out-Null
Invoke-Java -jar $Apktool d -r -f -o (Join-Path $Work 'app') $Apk
Invoke-Java -jar $Apktool d -f -o (Join-Path $Work 'manifest') $Apk

# --- 2. Apply our patches (each checks the file's SHA-256 first) and add our new classes
Say 'Applying patches'
Invoke-Java $MortPatch apply (Join-Path $Kit 'patches') $Work
Invoke-Java $MortPatch copytree (Join-Path $Kit 'new-files') (Join-Path $Work 'app')

# --- 3. Build the full project only to get the new binary AndroidManifest.xml
Say 'Building the new AndroidManifest.xml'
Invoke-Java -jar $Apktool b (Join-Path $Work 'manifest') -o (Join-Path $Work 'manifest-only.apk')
Invoke-Java $MortPatch extract (Join-Path $Work 'manifest-only.apk') AndroidManifest.xml (Join-Path $Work 'app\AndroidManifest.xml')

# --- 4. Rebuild the app (Mort's resources stay byte-identical)
Say 'Rebuilding the APK'
$Unsigned = Join-Path $Work 'MortPlayer-1.0.3-community-unsigned.apk'
Invoke-Java -jar $Apktool b (Join-Path $Work 'app') -o $Unsigned

# --- 5. Make (once) and use YOUR OWN signing key. Keep my-signing-key to install future rebuilds as updates.
$Jks = Join-Path $KeyDir 'mortplayer.jks'
$PwFile = Join-Path $KeyDir 'password.txt'
if (-not (Test-Path $Jks)) {
    Say 'Creating your personal signing key (first run only)'
    New-Item -ItemType Directory -Force -Path $KeyDir | Out-Null
    # Random 24-character password, stored next to the key so later runs can reuse it.
    $chars = [char[]]'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789'
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $bytes = New-Object byte[] 24; $rng.GetBytes($bytes)
    $pass = -join ($bytes | ForEach-Object { $chars[$_ % $chars.Length] })
    Set-Content -Path $PwFile -Value $pass -NoNewline
    & keytool -genkeypair -keystore $Jks -storetype JKS -storepass $pass -keypass $pass -alias mortplayer `
              -keyalg RSA -keysize 2048 -validity 10000 -dname 'CN=MortPlayer community build (self-signed)' 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { Fail 'keytool could not create the signing key' }
}
$pass = (Get-Content -Path $PwFile -TotalCount 1).Trim()

Say 'Signing'
$SignedDir = Join-Path $Work 'signed'
Invoke-Java -jar $Signer -a $Unsigned -o $SignedDir --ks $Jks --ksAlias mortplayer --ksPass $pass --ksKeyPass $pass --allowResign
$signed = Get-ChildItem $SignedDir -Filter '*.apk' | Select-Object -First 1
$final = Join-Path $Out 'MortPlayer-1.0.3-community-selfsigned.apk'
Copy-Item $signed.FullName $final -Force

Say 'Done!'
Write-Host "    $final"
Write-Host ''
Write-Host '    IMPORTANT: uninstall the original MortPlayer first. Android refuses to install' -ForegroundColor Yellow
Write-Host '    an app over one signed with a different key (export your bookmarks/settings first).' -ForegroundColor Yellow
Write-Host "    Keep the 'my-signing-key' folder private and safe."
