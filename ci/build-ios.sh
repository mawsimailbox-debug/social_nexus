#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/../app-flutter"
[[ "$(uname -s)" == Darwin ]] || { printf '%s\n' 'macOS signing runner required' >&2; exit 2; }
for name in NEXUS_IOS_CERTIFICATE_BASE64 NEXUS_IOS_CERTIFICATE_PASSWORD NEXUS_IOS_PROFILE_BASE64 NEXUS_IOS_EXPORT_OPTIONS_BASE64 NEXUS_IOS_KEYCHAIN_PASSWORD; do
  [[ -n "${!name:-}" ]] || { printf 'Missing protected signing secret: %s\n' "$name" >&2; exit 2; }
done
umask 077
tmp=$(mktemp -d "${RUNNER_TEMP:?Required}/nexus-signing.XXXXXXXX")
keychain="$tmp/build.keychain-db"
profile_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
profile_path=''
cleanup() {
  if [[ -s "$tmp/keychains.json" ]]; then
    python3 -c 'import json,subprocess,sys; subprocess.run(["security","list-keychains","-d","user","-s",*json.load(open(sys.argv[1]))],check=False)' "$tmp/keychains.json" || true
  fi
  security delete-keychain "$keychain" >/dev/null 2>&1 || true
  [[ -z "$profile_path" ]] || rm -f -- "$profile_path"
  rm -rf -- "$tmp"
}
trap cleanup EXIT
export NEXUS_IOS_SIGNING_TMP="$tmp"
python3 -c 'import os,base64,pathlib; p=pathlib.Path(os.environ["NEXUS_IOS_SIGNING_TMP"]); [(p/n).write_bytes(base64.b64decode(os.environ[k],validate=True)) for k,n in [("NEXUS_IOS_CERTIFICATE_BASE64","certificate.p12"),("NEXUS_IOS_PROFILE_BASE64","profile.mobileprovision"),("NEXUS_IOS_EXPORT_OPTIONS_BASE64","ExportOptions.plist")]]'
plutil -lint "$tmp/ExportOptions.plist"
security create-keychain -p "$NEXUS_IOS_KEYCHAIN_PASSWORD" "$keychain"
security set-keychain-settings -lut 21600 "$keychain"
security unlock-keychain -p "$NEXUS_IOS_KEYCHAIN_PASSWORD" "$keychain"
security list-keychains -d user | python3 -c 'import json,shlex,sys; print(json.dumps(shlex.split(sys.stdin.read())))' > "$tmp/keychains.json"
python3 -c 'import json,subprocess,sys; subprocess.run(["security","list-keychains","-d","user","-s",sys.argv[2],*json.load(open(sys.argv[1]))],check=True)' "$tmp/keychains.json" "$keychain"
security import "$tmp/certificate.p12" -P "$NEXUS_IOS_CERTIFICATE_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security -t cert -f pkcs12 -k "$keychain"
security set-key-partition-list -S apple-tool:,apple:,codesign: -k "$NEXUS_IOS_KEYCHAIN_PASSWORD" "$keychain"
security cms -D -i "$tmp/profile.mobileprovision" > "$tmp/profile.plist"
uuid=$(/usr/libexec/PlistBuddy -c 'Print UUID' "$tmp/profile.plist")
[[ "$uuid" =~ ^[A-Fa-f0-9-]+$ ]] || exit 2
mkdir -p "$profile_dir"
profile_path="$profile_dir/$uuid.mobileprovision"
[[ ! -e "$profile_path" ]] || { printf '%s\n' 'Refusing to overwrite existing profile'; profile_path=''; exit 2; }
cp "$tmp/profile.mobileprovision" "$profile_path"
flutter pub get --enforce-lockfile
flutter build ipa --release --export-options-plist="$tmp/ExportOptions.plist"
python3 -c 'from pathlib import Path; p=list(Path("build/ios/ipa").glob("*.ipa")); assert p and all(x.stat().st_size for x in p), "No nonempty signed IPA exported"'
# Certificate, team, entitlements and export-options must match actual Xcode project.
# Platform signing validation/review is still required; no fake signing identity.
