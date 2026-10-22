#!/bin/sh
# Renders social-preview.png (1280x640) from SocialPreview/social-preview.html.
set -e
cd "$(dirname "$0")"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$chrome" ]; then
  echo "Google Chrome not found at $chrome" >&2
  exit 1
fi
"$chrome" --headless --hide-scrollbars --force-device-scale-factor=1 \
  --window-size=1280,640 \
  --screenshot="$PWD/social-preview.png" \
  "file://$PWD/SocialPreview/social-preview.html" 2>/dev/null
echo "Wrote $PWD/social-preview.png"
