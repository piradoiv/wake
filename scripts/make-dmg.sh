#!/bin/bash
# Makes a signed, notarized and stapled Wake.dmg next to a built Wake.app. The name
# has no version, so release downloads keep one link (releases/latest/download/Wake.dmg).
#
#   make-dmg.sh [--unsigned] <path to Wake.app> [notarytool keychain profile]
#
# The image opens on a fixed window: Wake on the left, Applications on the
# right, over Artwork/DiskImage/background.tiff, and the volume has the app's
# icon. Finder lays the window out (an AppleScript sent with osascript), so
# whatever runs this needs Automation permission for Finder; macOS asks once.
# --unsigned stops before signing and notarizing, to check the layout.
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

unsigned=""
if [ "${1:-}" = "--unsigned" ]; then
  unsigned=1
  shift
fi
app="${1:-}"
profile="${2:-wake-notary}"
repo="$(cd "$(dirname "$0")/.." && pwd)"
background="$repo/Artwork/DiskImage/background.tiff"
dmg=""
work=""
mount=""

fail() {
  [ -n "$mount" ] && hdiutil detach "$mount" -force >/dev/null 2>&1
  [ -n "$work" ] && rm -rf "$work"
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
[ -n "$identity" ] || [ -n "$unsigned" ] || fail "the app isn't signed with a Developer ID Application certificate"

# The wake CLI ships inside the app, signed by the app's Sign step with the same
# identity (check-cli.sh checks it in full after Sign).
tool="$app/Contents/Helpers/wake/wake"
[ -x "$tool" ] || fail "the app has no CLI at Contents/Helpers/wake/wake"
[ -n "$unsigned" ] || codesign --verify --strict "$tool" 2>/dev/null || fail "the CLI inside the app isn't validly signed"
[ -n "$unsigned" ] || codesign -dvv "$tool" 2>&1 | grep -q "^Authority=$identity\$" || fail "the CLI isn't signed with the app's identity"
"$tool" --version >/dev/null 2>&1 || fail "the CLI inside the app doesn't run"

[ -f "$background" ] || fail "no background at '$background': run Artwork/DiskImage/render.sh"
icon="$app/Contents/Resources/$(defaults read "$app/Contents/Info.plist" CFBundleIconFile 2>/dev/null)"
[ "${icon%.icns}" = "$icon" ] && icon="$icon.icns"
[ -f "$icon" ] || fail "no app icon at '$icon'"

dmg="$(dirname "$app")/$name.dmg"
rm -f "$dmg"

work="$(mktemp -d "${TMPDIR:-/tmp}/wake-dmg.XXXXXX")" || fail "couldn't create a work folder"
staging="$work/staging"
mkdir -p "$staging/.background" || fail "couldn't create the staging folder"
ditto "$app" "$staging/$name.app" || fail "couldn't copy the app to the staging folder"
ln -s /Applications "$staging/Applications" || fail "couldn't link Applications"
cp "$background" "$staging/.background/background.tiff" || fail "couldn't copy the background"

# A read-write image with room for Finder's .DS_Store, laid out, then compressed.
size=$(( $(du -sm "$staging" | cut -f1) + 20 ))
hdiutil create -volname "$name" -srcfolder "$staging" -fs HFS+ -format UDRW -size "${size}m" "$work/rw.dmg" >/dev/null \
  || fail "hdiutil create failed"
# Found by its mount path, not its name: another volume called Wake may be mounted.
mount="$(hdiutil attach "$work/rw.dmg" -readwrite -noverify -noautoopen | sed -n 's|^/dev/[^[:space:]]*[[:space:]]*Apple_HFS[[:space:]]*||p' | head -n 1)"
[ -d "$mount" ] || { mount=""; fail "couldn't mount the read-write image"; }

# Window: 540 x 380 points of content (the bounds include the 28-point title
# bar), no toolbar or status bar, 128 px icons centred where the background
# expects them.
osascript - "$mount" "$name.app" <<'APPLESCRIPT' >/dev/null 2>"$work/finder.txt" || fail "Finder couldn't lay out the window: $(cat "$work/finder.txt")"
on run argv
  set volumePath to item 1 of argv
  set appName to item 2 of argv
  tell application "Finder"
    set theDisk to item ((POSIX file volumePath) as alias)
    open theDisk
    set theWindow to container window of theDisk
    set current view of theWindow to icon view
    set toolbar visible of theWindow to false
    set statusbar visible of theWindow to false
    set bounds of theWindow to {200, 120, 740, 528}
    set theOptions to icon view options of theWindow
    set arrangement of theOptions to not arranged
    set icon size of theOptions to 128
    set text size of theOptions to 13
    set label position of theOptions to bottom
    set shows item info of theOptions to false
    set shows icon preview of theOptions to false
    set background picture of theOptions to file ".background:background.tiff" of theDisk
    set position of item appName of theDisk to {140, 170}
    set position of item "Applications" of theDisk to {400, 170}
    -- Reopening shows the background; Finder then forgets the size, so set it again.
    close theWindow
    open theDisk
    set theWindow to container window of theDisk
    set bounds of theWindow to {200, 120, 740, 528}
    update theDisk without registering applications
    delay 1
    close theWindow
  end tell
end run
APPLESCRIPT

# Finder writes the layout to .DS_Store on its own time.
for _ in $(seq 1 30); do
  [ -f "$mount/.DS_Store" ] && break
  sleep 1
done
[ -f "$mount/.DS_Store" ] || fail "Finder didn't save the window layout"
rm -rf "$mount/.fseventsd"
# The volume icon goes in last: hdiutil leaves .VolumeIcon.icns out of
# -srcfolder, and Finder's layout removes it.
cp "$icon" "$mount/.VolumeIcon.icns" && SetFile -a C "$mount" || fail "couldn't give the volume its icon"
sync
for _ in $(seq 1 5); do
  hdiutil detach "$mount" >/dev/null 2>&1 && { mount=""; break; }
  sleep 2
done
[ -z "$mount" ] || fail "couldn't eject the read-write image"

hdiutil convert "$work/rw.dmg" -format ULFO -o "$dmg" >/dev/null || fail "hdiutil convert failed"
rm -rf "$work"
work=""

if [ -n "$unsigned" ]; then
  echo "DMG UNSIGNED: $dmg"
  exit 0
fi

codesign --sign "$identity" --timestamp "$dmg" || fail "codesign failed"

notary="$(xcrun notarytool submit "$dmg" --keychain-profile "$profile" --wait 2>&1)"
echo "$notary"
echo "$notary" | grep -q "status: Accepted" \
  || fail "notarization wasn't accepted (profile '$profile'); see notarytool's output above"

xcrun stapler staple "$dmg" >/dev/null || fail "stapler staple failed"

spctl -a -t open --context context:primary-signature "$dmg" 2>/dev/null \
  || fail "Gatekeeper rejects the image"

echo "DMG OK: $dmg"
