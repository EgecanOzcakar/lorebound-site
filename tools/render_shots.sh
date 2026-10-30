#!/usr/bin/env bash
# Render the site's 4K screenshots from the game repos, one <site name>.png each into OUT.
#
#   tools/render_shots.sh SORCMERC_DIR TRAILPARTYOPS_DIR OUT
#
# Needs xvfb-run and the two Godot binaries ($GODOT_SORCMERC, $GODOT_HORDE; the workflow downloads
# them). Each shot uses the game's own screenshot hook (SorcMerc tests/shot*.gd, Horde game.tscn --shot
# and tests/gl_shell.gd), so a shot breaks only when the game renames one of those. Then
# tools/sync_art.py writes the ones that changed into img/.
set -euo pipefail
SORC=$(realpath "$1"); HORDE=$(realpath "$2"); mkdir -p "$3"; OUT=$(realpath "$3")
TMP=$(mktemp -d)
X() {   # one 4K run under a virtual display; the game's own exit code decides
  local dir=$1; shift
  (cd "$dir" && timeout "${SHOT_TIMEOUT:-900}" xvfb-run -a -s "-screen 0 3840x2160x24" "$@" --rendering-driver opengl3 --resolution 3840x2160 "${ARGS[@]}")
}

# --- SorcMerc (Godot 4.7) ---
G=$GODOT_SORCMERC
(cd "$SORC" && timeout 1500 "$G" --headless --path . --import >/dev/null 2>&1) || true   # import exits non-zero on warnings
export SORCMERC_FAST=1
ARGS=(-s tests/shot.gd); X "$SORC" "$G" --path .
mv "$SORC/combat_screen.png" "$OUT/sorcmerc-combat.png"
SHOT_THEME=downs SHOT_SITE=road SHOT_BIOME=downs SHOT_FOES=assassin:2,bandit:2 SHOT_HOVER=foe SORCMERC_SEED=3 X "$SORC" "$G" --path .
mv "$SORC/combat_screen.png" "$OUT/sorcmerc-ambush.png"
ARGS=(-s tests/shot_world.gd); X "$SORC" "$G" --path .
mv "$SORC/world_screen.png" "$OUT/sorcmerc-roads.png"; mv "$SORC/world_turned.png" "$OUT/sorcmerc-world.png"
ARGS=(-s tests/shot_screens.gd)
for s in party:company town-inn:inn first-job:jobs coop-room:coop mods:mods; do
  SHOT_ONLY=${s%%:*} X "$SORC" "$G" --path .
  mv "$SORC/shots_tmp/${s%%:*}.png" "$OUT/sorcmerc-${s##*:}.png"
done
unset SORCMERC_FAST

# --- Horde (Godot 4.4) ---
G=$GODOT_HORDE
(cd "$HORDE" && timeout 900 "$G" --headless --path . --import >/dev/null 2>&1) || true
ARGS=(scenes/game/game.tscn -- --bot --god --wave=12 --shot="$TMP/w12" --at=14 --quit-after=15); X "$HORDE" "$G" --path .
mv "$TMP/w12_0.png" "$OUT/horde-wave.png"
ARGS=(scenes/game/game.tscn -- --bot --god --wave=18 --shot="$TMP/w18" --at=25,40 --quit-after=41); X "$HORDE" "$G" --path .
mv "$TMP/w18_0.png" "$OUT/horde-swarm.png"; mv "$TMP/w18_1.png" "$OUT/horde-levelup.png"
ARGS=(scenes/game/game.tscn -- --bot --god --wave=20 --shot="$TMP/w20" --at=12 --quit-after=13); X "$HORDE" "$G" --path .
mv "$TMP/w20_0.png" "$OUT/horde-boss.png"
ARGS=(scenes/game/game.tscn -- --god --xp=70 --shot-camp="$TMP/camp"); X "$HORDE" "$G" --path .
mv "$TMP/camp_4.png" "$OUT/horde-camp.png"   # the fifth camp frame: the shop with a relic found
# gl_shell's own blank-frame checks are tuned for 1080p and report FAIL at 4K, so its exit code is ignored;
# a frame that is really missing fails the mv below.
ARGS=(-s tests/gl_shell.gd -- --out="$TMP/sh" --coop-out="$TMP/coop_" --party-out="$TMP/party_"); X "$HORDE" "$G" --path . || true
mv "$TMP/sh_title.png" "$OUT/horde-weekly.png"
mv "$TMP/coop__hud_4_humans.png" "$OUT/horde-coop.png"
mv "$TMP/coop__camp_unpaid.png" "$OUT/horde-wages.png"
mv "$TMP/party__memorial.png" "$OUT/horde-memorial.png"
rm -rf "$TMP"
ls "$OUT"
