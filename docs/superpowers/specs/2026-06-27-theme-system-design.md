# Dotfiles Theme System Design

## Goal

Create a practical theme system for the Hyprland dotfiles that keeps the desktop usable, consistent, and easy to change. The system separates the base theme from the accent color so the user can change the general look and the highlight color independently.

## Scope

This design covers:

- Base theme selection.
- Accent selection.
- Wallpaper-based accent extraction.
- Waybar color integration.
- Rofi menu integration.
- Hyprland active border color integration.
- A simple Waybar weather module.
- Current wallpaper path tracking.

This design does not cover Neovim, Ghostty, tmux, or shell prompt theming yet.

## Theme Model

The theme system has two independent settings:

- `base`: `catppuccin` or `mono`
- `accent`: `none`, `pink`, `blue`, or `wallpaper`

Changing the base must preserve the current accent. Changing the accent must preserve the current base.

The base theme controls stable UI colors such as background, foreground, muted text, surface, border, and selection background.

The accent controls highlight colors such as active workspace, hover state, selected Rofi item, Hyprland active border, and visually important Waybar modules.

## Base Themes

`catppuccin` keeps the existing Catppuccin Mocha-inspired palette already present in the dotfiles.

`mono` uses a grayscale palette:

- Near-black background.
- Dark gray surfaces.
- Mid-gray borders.
- Light gray muted text.
- White or near-white primary text.

The mono theme can still use an accent color unless the selected accent is `none`.

## Accent Modes

`none` disables chromatic accent usage where practical. It should use contrast, border weight, or grayscale brightness instead of color.

`pink` uses a fixed Catppuccin-compatible pink accent.

`blue` uses a fixed Catppuccin-compatible blue accent.

`wallpaper` reads the current wallpaper path, extracts a representative color, and uses that color as the accent. If extraction fails, it should fall back to the fixed `blue` accent.

## Current Wallpaper Tracking

Wallpaper scripts should store the current wallpaper path in:

```text
~/.cache/current_wallpaper
```

The file must contain one absolute path to the currently applied wallpaper.

Both wallpaper selection and random wallpaper scripts should update this file after applying a wallpaper. Theme scripts should read this file when `accent=wallpaper`.

## Menus And Keybindings

Theme selection should use Rofi menus launched from Hyprland keybindings:

- `SUPER + T`: choose base theme.
- `SUPER + Shift + T`: choose accent.

The base menu options are:

- `Catppuccin`
- `Mono`

The accent menu options are:

- `None`
- `Pink`
- `Blue`
- `Wallpaper Auto`

Menu choices should update the saved theme state, regenerate generated color files, and reload affected UI components.

## Generated Files

The implementation should keep source palette definitions separate from generated files.

Generated outputs should include formats needed by the existing tools:

- CSS variables or GTK-compatible color names for Waybar.
- Rasi variables for Rofi.
- Hyprland-compatible color values for active borders.

Generated files should be safe to overwrite.

## Runtime State

The current theme state should be saved at:

```text
~/.cache/viegphunt/theme_state
```

It should contain the selected base and accent in a simple shell-readable format.

Example:

```sh
BASE_THEME=mono
ACCENT=wallpaper
```

All theme scripts should read and write this state file.

The generated Hyprland colors should be written to:

```text
~/.config/hypr/conf/theme.conf
```

The existing Hyprland appearance config should source this generated file.

## Waybar

Waybar should use the generated color file instead of hardcoded Catppuccin-only colors.

The bar should stay practical and readable:

- Workspaces on the left.
- Existing status modules on the right.
- Weather as a compact right-side module.
- Accent used for active workspace and selected highlights.
- Grayscale fallback when accent is `none`.

The weather module should be a simple `custom/weather` module. It should show a short current-condition summary and avoid blocking Waybar for a long time if the network is unavailable.

## Hyprland

Hyprland should consume the generated accent color for active window borders. Inactive borders should stay grayscale and low-emphasis.

The new keybindings should be added without replacing existing browser, launcher, terminal, lock, screenshot, or workspace bindings.

## Rofi

Rofi should consume generated Rasi color variables. The same Rofi style should work for app launching, clipboard, emoji, wallpaper selection, base theme selection, and accent selection.

Rofi selected and hover states should use the current accent unless accent is `none`.

## Reload Behavior

After a theme change:

- Regenerate color files.
- Reload Waybar if running.
- Reload Hyprland config.
- Future Rofi menus should use the new generated colors.

The implementation should avoid killing unrelated user processes.

## Error Handling

If the state file is missing, default to:

```sh
BASE_THEME=catppuccin
ACCENT=pink
```

If wallpaper accent extraction fails, use the fixed `blue` accent and keep the desktop readable.

If weather fetching fails, Waybar should show a short neutral fallback instead of an error dump.

## Verification

Manual verification should cover:

- `SUPER + T` changes only the base theme.
- `SUPER + Shift + T` changes only the accent.
- `mono + none` produces a grayscale UI.
- `mono + pink` and `mono + blue` preserve grayscale structure with colored highlights.
- `catppuccin + wallpaper` applies an extracted wallpaper accent.
- Wallpaper selection and random wallpaper scripts update `~/.cache/current_wallpaper` with an absolute path.
- Waybar reloads and displays weather without breaking other modules.
- Hyprland active border updates after theme changes.
