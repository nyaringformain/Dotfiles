#!/usr/bin/env bash

if pidof yad > /dev/null; then
    pkill yad
fi

yad --center --title="Keybinding Hints" --no-buttons --list \
    --column=Key: --column="" --column=Description: \
    --timeout-indicator=bottom \
"  =   "          "        "  "SUPER KEY (Windows Key Button)" \
"" "" "" \
"Launchers"          "        "  "--------------------------------" \
"  H"              "        "  "Show keybinding hints" \
"  Space"          "        "  "Open terminal" \
"  E"              "        "  "Open file manager" \
"  B"              "        "  "Open browser" \
"ALT Space"         "        "  "Application launcher" \
"  ."              "        "  "Emoji selector" \
"  V"              "        "  "Clipboard manager" \
"" "" "" \
"Window / Session"   "        "  "--------------------------------" \
"  Shift Ctrl Esc" "        "  "Exit Hyprland" \
"  Q"              "        "  "Close active window" \
"  Shift Q"        "        "  "Kill active window by PID" \
"  F"              "        "  "Toggle floating" \
"  P"              "        "  "Toggle pseudo (dwindle)" \
"  J"              "        "  "Toggle split (dwindle)" \
"  L"              "        "  "Lock screen" \
"" "" "" \
"Appearance / Tools" "        "  "--------------------------------" \
"  W"              "        "  "Choose wallpaper" \
"  Shift W"        "        "  "Random wallpaper" \
"  T"              "        "  "Base theme selector" \
"  Shift T"        "        "  "Accent selector" \
"  Print"          "        "  "Screenshot monitor" \
"  Shift Print"    "        "  "Screenshot region" \
"" "" "" \
"Workspaces"         "        "  "--------------------------------" \
"  [1 -> 0]"       "        "  "Switch workspace 1-10" \
"  Shift [1 -> 0]" "        "  "Move window to workspace 1-10" \
"  Scroll"         "        "  "Scroll through workspaces" \
"  Left/Right/Up/Down" "    "  "Move focus" \
"" "" "" \
"Media / Hardware"   "        "  "--------------------------------" \
"XF86 Volume"        "        "  "Volume up/down/mute" \
"XF86 Brightness"    "        "  "Brightness up/down" \
"XF86 Media"         "        "  "Previous/play-pause/next" \
"" "" "" \
"More Keybinding"   "        "  "$HOME/.config/hypr/conf/keybinding.conf"
