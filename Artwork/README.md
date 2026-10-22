# Artwork

- `wake-icon.svg`: the app icon, used for every size from 32px up.
- `wake-icon-small.svg`: a simpler version for 16px, with only the main wake
  line and a bigger point.
- `IconSet/`: the PNGs added to the app icon in the Xojo IDE, rendered from
  the SVGs.

To render them again after changing an SVG:

```sh
cd Artwork
rsvg-convert -w 16 -h 16 wake-icon-small.svg -o IconSet/wake-16.png
for n in 32 48 64 128 256 512 1024; do
  rsvg-convert -w $n -h $n wake-icon.svg -o IconSet/wake-$n.png
done
```

## Social preview

`social-preview.png` (1280×640) is the image GitHub shows when the repository
is shared (Settings → General → Social preview). It is rendered from
`SocialPreview/social-preview.html`, which uses `SocialPreview/screenshot.png`
and the 512px icon:

```sh
cd Artwork
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless \
  --hide-scrollbars --force-device-scale-factor=1 --window-size=1280,640 \
  --screenshot="$PWD/social-preview.png" \
  "file://$PWD/SocialPreview/social-preview.html"
```
