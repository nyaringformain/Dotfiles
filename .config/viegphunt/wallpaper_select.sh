#!/usr/bin/env bash

if pidof rofi > /dev/null; then
    pkill rofi
fi

wallpapers_dir="$HOME/Pictures/Wallpapers"
current_wallpaper_file="${VIEGPHUNT_CURRENT_WALLPAPER:-$HOME/.cache/current_wallpaper}"

selected_wallpaper=$(for a in "$wallpapers_dir"/*; do
    echo -en "$(basename "${a%.*}")\0icon\x1f$a\n"
done | rofi -dmenu -p " ")

[[ -n "${selected_wallpaper:-}" ]] || exit 0

image_fullname_path=$(find "$wallpapers_dir" -type f -name "$selected_wallpaper.*" | head -n 1)
[[ -n "$image_fullname_path" && -f "$image_fullname_path" ]] || exit 1

awww img "$image_fullname_path" --transition-type any --transition-duration 2 || exit 1

mkdir -p "$(dirname "$current_wallpaper_file")"
printf '%s\n' "$image_fullname_path" > "$current_wallpaper_file"

~/.config/viegphunt/wallpaper_effects.sh
~/.config/viegphunt/theme_apply.sh --refresh
