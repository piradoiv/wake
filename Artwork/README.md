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
