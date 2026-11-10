#!/bin/bash
# Makes a signed, notarized and stapled Wake.dmg next to a built Wake.app. The name
# has no version, so release downloads keep one link (releases/latest/download/Wake.dmg).
#
#   make-dmg.sh <path to Wake.app> [notarytool keychain profile]
#
# The signing identity comes from the app's own signature, so nothing here
# changes between releases. The profile
# defaults to "wake-notary" (create it once with `xcrun notarytool
# store-credentials wake-notary`).
#
# The Xojo IDE runs this from the "Make Disk Image" build step after Sign. A
# post-build step can't cancel the build, so the last line printed is
# "DMG OK: <path>" or "DMG FAILED: <reason>", and a failed run removes the image
# so an unnotarized one can't be shipped by mistake.

set -u

app="${1:-}"
profile="${2:-wake-notary}"
dmg=""
staging=""

fail() {
  [ -n "$staging" ] && rm -rf "$staging"
  [ -n "$dmg" ] && rm -f "$dmg"
  echo "DMG FAILED: $1"
  exit 1
}

[ -d "$app" ] || fail "no app at '$app'"
# The IDE's CurrentBuildLocation is the build folder, not the app, despite the
# docs, so take the one app inside a folder.
if [ "${app%.app}" = "$app" ] && [ "${app%.app/}" = "$app" ]; then
  apps=("$app"/*.app)
  [ ${#apps[@]} -eq 1 ] && [ -d "${apps[0]}" ] || fail "expected one app in '$app'"
  app="${apps[0]}"
fi
app="$(cd "$(dirname "$app")" && pwd)/$(basename "$app")"
name="$(basename "$app" .app)"

identity="$(codesign -dvv "$app" 2>&1 | sed -n 's/^Authority=\(Developer ID Application: .*\)$/\1/p' | head -n 1)"
[ -n "$identity" ] || fail "the app isn't signed with a Developer ID Application certificate"

dmg="$(dirname "$app")/$name.dmg"
rm -f "$dmg"

staging="$(mktemp -d "${TMPDIR:-/tmp}/wake-dmg.XXXXXX")" || fail "couldn't create a staging folder"
ditto "$app" "$staging/$name.app" || fail "couldn't copy the app to the staging folder"
ln -s /Applications "$staging/Applications" || fail "couldn't link Applications"

hdiutil create -volname "$name" -srcfolder "$staging" -format UDZO -ov "$dmg" >/dev/null \
  || fail "hdiutil create failed"
rm -rf "$staging"
staging=""

codesign --sign "$identity" --timestamp "$dmg" || fail "codesign failed"

notary="$(xcrun notarytool submit "$dmg" --keychain-profile "$profile" --wait 2>&1)"
echo "$notary"
echo "$notary" | grep -q "status: Accepted" \
  || fail "notarization wasn't accepted (profile '$profile'); see notarytool's output above"

xcrun stapler staple "$dmg" >/dev/null || fail "stapler staple failed"

spctl -a -t open --context context:primary-signature "$dmg" 2>/dev/null \
  || fail "Gatekeeper rejects the image"

echo "DMG OK: $dmg"
