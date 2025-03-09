#!/bin/bash

WALLPAPER_DIRS=(
  "$HOME/.wallpapers"
  "$HOME/.config/swww/Catppuccin-Latte/"
  "$HOME/.config/swww/Catppuccin-Mocha/"
  #"$HOME/.config/swww/Cyberpunk-Edge/"
  "$HOME/.config/swww/Decay-Green/"
  #"$HOME/.config/swww/Frosted-Glass/"
  "$HOME/.config/swww/Graphite-Mono/"
  "$HOME/.config/swww/Gruvbox-Retro/"
  #"$HOME/.config/swww/Material-Sakura/"
  "$HOME/.config/swww/Nordic-Blue/"
  "$HOME/.config/swww/One-Dark/"
  "$HOME/.config/swww/Rose-Pine/"
  "$HOME/.config/swww/Synth-Wave/"
  "$HOME/.config/swww/Tokyo-Night/"
)

RESOLVED_DIRS=()
for DIR in "${WALLPAPER_DIRS[@]}"; do
  REAL_DIR=$(readlink -f "$DIR")
  if [ -d "$REAL_DIR" ]; then
    RESOLVED_DIRS+=("$REAL_DIR")
  fi
done

if [ ${#RESOLVED_DIRS[@]} -eq 0 ]; then
  echo "Error: No valid wallpaper directories found."
  exit 1
fi

WALLPAPER_FILES=()
for DIR in "${RESOLVED_DIRS[@]}"; do
  while IFS= read -r -d '' FILE; do
    WALLPAPER_FILES+=("$FILE")
  done < <(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' -o -iname '*.gif' \) -print0)
done

if [ ${#WALLPAPER_FILES[@]} -eq 0 ]; then
  echo "Error: No images found in the specified directories."
  exit 1
fi

WALLPAPER=${WALLPAPER_FILES[RANDOM % ${#WALLPAPER_FILES[@]}]}

feh --bg-scale "$WALLPAPER"
