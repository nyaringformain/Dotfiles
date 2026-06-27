#!/usr/bin/env bash

current_wallpaper_file="${VIEGPHUNT_CURRENT_WALLPAPER:-$HOME/.cache/current_wallpaper}"
current_wallpaper_path=""

if [[ -f "$current_wallpaper_file" ]]; then
    IFS= read -r current_wallpaper_path < "$current_wallpaper_file" || current_wallpaper_path=""
fi

if [[ -z "$current_wallpaper_path" || ! -f "$current_wallpaper_path" ]]; then
    current_wallpaper_path=$(awww query | head -n 1 | awk -F'image: ' '/image:/ {print $2; exit}')
fi

[[ -n "$current_wallpaper_path" && -f "$current_wallpaper_path" ]] || exit 0

destination_wallpaper_dir="$HOME/.cache/awww"
mkdir -p "$destination_wallpaper_dir"

rm -f "$destination_wallpaper_dir/normal.png"
vipsthumbnail "$current_wallpaper_path" -o "$destination_wallpaper_dir/normal.png"
