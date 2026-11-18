#!/bin/sh
# Renders the disk image window's background from background.svg: a 1x and a
# 2x PNG, combined into background.tiff, which scripts/make-dmg.sh puts in the
# image. Needs rsvg-convert (brew install librsvg); the release build doesn't,
# because background.tiff is committed.
set -e
cd "$(dirname "$0")"
rsvg-convert -w 540 -h 380 background.svg -o background.png
rsvg-convert -w 1080 -h 760 background.svg -o background@2x.png
tiffutil -cathidpicheck background.png background@2x.png -out background.tiff >/dev/null
rm background.png background@2x.png
echo "Wrote $PWD/background.tiff"
