#!/usr/bin/env bash

wallpapers_dir="$HOME/Pictures/Wallpapers"
current_wallpaper_file="${VIEGPHUNT_CURRENT_WALLPAPER:-$HOME/.cache/current_wallpaper}"

random_wallpaper=$(find "$wallpapers_dir" -maxdepth 1 -type f | shuf -n 1)
[[ -n "$random_wallpaper" && -f "$random_wallpaper" ]] || exit 1

awww img "$random_wallpaper" --transition-type any --transition-duration 2

mkdir -p "$(dirname "$current_wallpaper_file")"
printf '%s\n' "$random_wallpaper" > "$current_wallpaper_file"

~/.config/viegphunt/wallpaper_effects.sh
~/.config/viegphunt/theme_apply.sh --refresh
