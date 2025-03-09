#!/usr/bin/env bash

type="type-1"
style="style-1"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --type)
    type="type-$2"
    shift 2
    ;;
  --style)
    style="style-$2"
    shift 2
    ;;
  *)
    echo "Unknown argument: $1"
    exit 1
    ;;
  esac
done

dir="$HOME/.config/rofi/launchers/$type"

rofi \
  -show drun \
  -theme "${dir}/${style}.rasi"
