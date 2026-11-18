#!/bin/bash
# Checks the wake command-line tool inside a built, signed Wake.app:
#
#   check-cli.sh <path to Wake.app, or the build folder holding it>
#
# The Xojo IDE runs this from the "CheckCLI" build step, after "CopyCLI" has
# copied WakeCLI's build (the folder holding `wake` and `wake Libs`) into
# Contents/Helpers and Sign has signed and notarized the app, which signs the
# CLI with it. It signs nothing itself. It refuses a CLI build older than the
# Core sources, with another version than the app, or with any binary not
# signed with the app's Developer ID Application certificate, hardened runtime
# and a secure timestamp.
#
# A build step can't cancel the build, so the last line printed is
# "CLI CHECK OK" or "CLI CHECK FAILED: <reason>". make-dmg.sh, the next step,
# refuses an app whose CLI isn't signed like the app, so a failure can't ship.

set -u

app="${1:-}"
repo="$(cd "$(dirname "$0")/.." && pwd)"

fail() {
  echo "CLI CHECK FAILED: $1"
  exit 1
}

[ -d "$app" ] || fail "no app at '$app'"
# The IDE's CurrentBuildLocation is the build folder, not the app, so take the
# one app inside a folder.
if [ "${app%.app}" = "$app" ] && [ "${app%.app/}" = "$app" ]; then
  apps=("$app"/*.app)
  [ ${#apps[@]} -eq 1 ] && [ -d "${apps[0]}" ] || fail "expected one app in '$app'"
  app="${apps[0]}"
fi
app="$(cd "$(dirname "$app")" && pwd)/$(basename "$app")"

helper="$app/Contents/Helpers/wake"
tool="$helper/wake"
[ -x "$tool" ] || fail "no CLI at '$tool': build WakeCLI/WakeCLI.xojo_project before Wake"

# The copy comes from WakeCLI's build folder. Every Core source must be older
# than that build, or the tool would ship without the latest changes.
built="$repo/WakeCLI/Builds - WakeCLI/macOS ARM 64 bit/wake/wake"
[ -f "$built" ] || fail "no WakeCLI build at '$built'"
newer="$(find "$repo/Wake/Core" "$repo/WakeCLI" -name '*.xojo_code' -newer "$built" -print -quit)"
[ -z "$newer" ] || fail "the WakeCLI build is older than '$newer': build WakeCLI again"

app_version="$(defaults read "$app/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null)"
tool_version="$("$tool" --version 2>/dev/null)"
[ "$tool_version" = "wake $app_version" ] \
  || fail "the CLI says '$tool_version' but the app is $app_version: give both projects the same version"

# Every binary must carry the app's Developer ID signature, hardened runtime
# and a timestamp, as notarization requires.
identity="$(codesign -dvv "$app" 2>&1 | sed -n 's/^Authority=\(Developer ID Application: .*\)$/\1/p' | head -n 1)"
[ -n "$identity" ] || fail "the app isn't signed with a Developer ID Application certificate: run this after Sign"
for f in "$tool" "$helper/wake Libs"/*; do
  [ -f "$f" ] || continue
  name="${f#"$helper"/}"
  codesign --verify --strict "$f" 2>/dev/null || fail "'$name' isn't validly signed"
  info="$(codesign -dvv --verbose=4 "$f" 2>&1)"
  signer="$(echo "$info" | sed -n 's/^Authority=\(Developer ID Application: .*\)$/\1/p' | head -n 1)"
  [ "$signer" = "$identity" ] || fail "'$name' is signed by '${signer:-no Developer ID}', not the app's '$identity'"
  echo "$info" | grep -q "^CodeDirectory .*flags=0x[0-9a-f]*(.*runtime" || fail "'$name' has no hardened runtime"
  echo "$info" | grep -q "^Timestamp=" || fail "'$name' has no secure timestamp"
done

echo "CLI CHECK OK: $tool ($identity)"
