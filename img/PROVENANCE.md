# Image provenance

- `studio-vista.jpg`: the Lorebound Games studio card's backdrop, from `sorcmerc/assets/generated/studio-vista.png`
  (Qwen-Image-2512, seed 7202; the full record is in that directory's PROVENANCE.md).
- `lorebound-mark.svg`: the studio's gate mark, hand-drawn SVG, from `sorcmerc/assets/icons/brand/lorebound.svg`.
- `sorcmerc-capsule.jpg`: SorcMerc's main store capsule, from `sorcmerc/store/main_capsule.png`
  (Qwen-Image-2512 with the Lightning LoRA, main seed 2, title set in code; see that directory's PROVENANCE.md).
- `horde-title*.jpg`: Horde's main store capsule, from `trailpartyops/store/main_capsule.png`
  (FLUX.2 Klein 4B, main seed 2, title set in code; see that directory's PROVENANCE.md).
- `sorcmerc-*.jpg`, `horde-*.jpg` (all others): in-game screenshots rendered at 3840x2160 on 2026-10-22 from the current builds
  (SorcMerc `tests/shot.gd`, `shot_world.gd`, `shot_screens.gd`; Horde `game.tscn --shot`, `tests/gl_shell.gd`).
  `*-full.jpg` is the 4K frame, the plain name a 1600 px copy.
- `ya4x-capsule.jpg`, `ya4x-*.jpg`: yetanother4x's key art and press stills (`store/main_capsule.png`, `store/shots/`, rendered in the game by `Game/Press.cs` at 3840x2160; see that repo's store/PROVENANCE.md), copied by `tools/sync_art.py`.
- `ya4x-trailer.mp4`, `ya4x-trailer.jpg`: yetanother4x's trailer (1080p H.264 web encode, about 14 MB) and its poster frame, made by that repo's `tools/trailer.sh` (`Game/Trailer.cs`, recorded in the game with Godot's Movie Maker) from yetanother4x commit 895f5de.
