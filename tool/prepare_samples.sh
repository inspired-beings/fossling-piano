#!/usr/bin/env bash
# One-off sample build: Salamander Grand Piano V3 (Alexander Holm, CC BY 3.0)
# → 30 trimmed/faded Ogg files (velocity layer 8 of 16), assets/samples/m<midi>.ogg
set -euo pipefail
cd "$(dirname "$0")/.."

readonly URL="https://freepats.zenvoid.org/Piano/SalamanderGrandPiano/SalamanderGrandPianoV3+20161209_44khz16bit.tar.xz"
readonly VELOCITY=8
readonly TRIM_S=8
readonly FADE_START_S=7
readonly BUDGET_MIB=5
readonly WORK="${TMPDIR:-/tmp}/salamander"
readonly OUT="assets/samples"

# Salamander sample notes: every 3 semitones, A0 (midi 21) … C8 (midi 108).
readonly NOTES=(A0 C1 D#1 F#1 A1 C2 D#2 F#2 A2 C3 D#3 F#3 A3 C4 D#4 F#4 A4
                C5 D#5 F#5 A5 C6 D#6 F#6 A6 C7 D#7 F#7 A7 C8)

mkdir -p "$WORK" "$OUT"
tarball="$WORK/$(basename "$URL")"
[[ -f "$tarball" ]] || curl -fL --retry 3 -o "$tarball" "$URL"
sha256sum "$tarball"

[[ -d "$WORK/extracted" ]] || { mkdir -p "$WORK/extracted"; tar -xJf "$tarball" -C "$WORK/extracted"; }

for i in "${!NOTES[@]}"; do
  note="${NOTES[$i]}"
  midi=$((21 + 3 * i))
  src=$(find "$WORK/extracted" -name "${note}v${VELOCITY}.wav" | head -1)
  [[ -n "$src" ]] || { echo "FATAL: missing sample ${note}v${VELOCITY}.wav" >&2; exit 1; }
  ffmpeg -y -loglevel error -i "$src" -t "$TRIM_S" \
    -af "afade=t=out:st=${FADE_START_S}:d=$((TRIM_S - FADE_START_S))" \
    -c:a libvorbis -qscale:a 1 "$OUT/m${midi}.ogg"
done

total=$(du -cb "$OUT"/m*.ogg | tail -1 | cut -f1)
echo "Total: $((total / 1024 / 1024)) MiB ($total bytes), budget ${BUDGET_MIB} MiB"
((total <= BUDGET_MIB * 1024 * 1024)) || { echo "FATAL: over budget" >&2; exit 1; }
