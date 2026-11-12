#!/usr/bin/env python3
"""Copy the site's art from the game repos into img/, so nobody tracks it by hand.

    python3 tools/sync_art.py SORCMERC_DIR TRAILPARTYOPS_DIR [SHOTS_DIR]

Store art and the studio splash come straight from the game repos (SorcMerc's store/ and
assets/, Horde's store/). Screenshots come from SHOTS_DIR, which tools/render_shots.sh fills
with one <name>.png per shot; without it the screenshots are left alone.

A shot is written only if it differs visibly from the one already in img/: a fresh render is
never byte-identical, and every rewritten 4K JPEG stays in the repo's history for good.
Prints one line per file it changed; prints nothing when everything is current.
"""
import shutil
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageStat

IMG = Path(__file__).resolve().parent.parent / "img"

# site name -> (repo, path in it). "pair" writes <name>-full.jpg plus a 1600 px <name>.jpg.
STORE = {
    "sorcmerc-capsule": ("sorcmerc", "store/main_capsule.png", "single"),
    "horde-title": ("trailpartyops", "store/main_capsule.png", "pair"),
    "studio-vista": ("sorcmerc", "assets/generated/studio-vista.png", "single"),
}
COPY = {"lorebound-mark.svg": ("sorcmerc", "assets/icons/brand/lorebound.svg")}
SHOTS = [
    "sorcmerc-combat", "sorcmerc-ambush", "sorcmerc-world", "sorcmerc-roads", "sorcmerc-company",
    "sorcmerc-inn", "sorcmerc-jobs", "sorcmerc-coop", "sorcmerc-mods",
    "horde-wave", "horde-swarm", "horde-levelup", "horde-boss", "horde-camp",
    "horde-wages", "horde-coop", "horde-memorial", "horde-weekly",
]
SAME = 1.5  # mean per-channel difference (0-255) on a 160x90 thumbnail below which a render counts as unchanged


def same(a: Image.Image, dest: Path) -> bool:
    if not dest.exists():
        return False
    b = Image.open(dest).convert("RGB")
    if b.size != a.size:
        return False
    small = (160, 90)
    diff = ImageChops.difference(a.resize(small), b.resize(small))
    return sum(ImageStat.Stat(diff).mean) / 3 < SAME


def write(im: Image.Image, name: str, kind: str, fuzzy: bool) -> bool:
    main = IMG / (f"{name}-full.jpg" if kind == "pair" else f"{name}.jpg")
    if fuzzy and same(im, main):
        return False
    if kind == "pair":
        im.save(main, quality=90, optimize=True, progressive=True)
        small = im.copy()
        small.thumbnail((1600, 1600))
        small.save(IMG / f"{name}.jpg", quality=84, optimize=True, progressive=True)
    else:
        im.save(main, quality=92, optimize=True, progressive=True)
    return True


def main() -> None:
    repos = {"sorcmerc": Path(sys.argv[1]), "trailpartyops": Path(sys.argv[2])}
    shots = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    for name, (repo, rel, kind) in STORE.items():
        src = repos[repo] / rel
        # Store art is encoded from the same PNG each time, so an exact re-encode is a no-op for git;
        # the fuzzy check still stops a JPEG round-trip from counting as a change.
        if write(Image.open(src).convert("RGB"), name, kind, fuzzy=True):
            print(f"store  {name} <- {repo}/{rel}")
    for name, (repo, rel) in COPY.items():
        src, dest = repos[repo] / rel, IMG / name
        if not dest.exists() or src.read_bytes() != dest.read_bytes():
            shutil.copyfile(src, dest)
            print(f"copy   {name} <- {repo}/{rel}")
    if shots is None:
        return
    for name in SHOTS:
        src = shots / f"{name}.png"
        if not src.exists():
            print(f"MISSING shot {name} (render_shots.sh did not produce it)", file=sys.stderr)
            sys.exit(1)
        if write(Image.open(src).convert("RGB"), name, "pair", fuzzy=True):
            print(f"shot   {name}")


if __name__ == "__main__":
    main()
