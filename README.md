# zellij-filter

Replicate `sesh connect $(sesh list -i | gum filter)` using **zoxide**, **gum**, and **zellij**.

## Prerequisites

Install the three tools:

| Tool | Purpose | Install (macOS) |
|------|---------|-----------------|
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Tracks frequently used directories | `brew install zoxide` |
| [gum](https://github.com/charmbracelet/gum) | Interactive TUI filter/picker | `brew install gum` |
| [zellij](https://github.com/zellij-org/zellij) | Terminal multiplexer (sessions) | `brew install zellij` |

Make sure zoxide is initialized in your shell. Add to your `~/.zshrc` (or equivalent):

```sh
eval "$(zoxide init zsh)"
```

## The command

```sh
raw_target=$({
  zellij list-sessions -sn 2>/dev/null | awk '{printf "\033[36m%s\033[0m\n", $0}'
  zoxide query -l | awk '{printf "\033[34m%s\033[0m\n", $0}'
} | awk '!seen[$0]++' | gum filter --no-strip-ansi)

target=$(echo "$raw_target" | awk '{gsub(/\033\[[0-9;]*m/, ""); print}')
```

### What each piece does

1. **`zellij list-sessions -sn`** — lists the names of all currently active zellij sessions and pipes to `awk` to colorize them cyan.
2. **`zoxide query -l`** — lists all tracked directories, sorted by frecency, and pipes to `awk` to colorize them blue.
3. **`awk '!seen[$0]++'`** — deduplicates the combined list to ensure unique entries.
4. **`gum filter --no-strip-ansi`** — presents an interactive fuzzy-finder to pick a session or directory, maintaining the ANSI colors.
5. **`target="$(...)"`** — captures the selected value and strips the ANSI color codes so the path or session name can be used. The script then checks whether it's an existing session or a directory and connects accordingly.

## Shell function

Add this to your `~/.zshrc` (or `~/.bashrc`):

```sh
# Fuzzy-pick an existing zellij session or a zoxide directory
zj() {
  local raw_target
  raw_target=$({
    # Cyan for active sessions
    zellij list-sessions -sn 2>/dev/null | awk '{printf "\033[36m%s\033[0m\n", $0}'
    # Blue for tracked directories
    zoxide query -l | awk '{printf "\033[34m%s\033[0m\n", $0}'
  } | awk '!seen[$0]++' | gum filter --no-strip-ansi --placeholder 'Pick a session or project...')

  # Exit if nothing was selected (user pressed Esc)
  if [ -z "$raw_target" ]; then
    return 0
  fi

  # Strip ANSI codes from the selection
  local target
  target=$(echo "$raw_target" | awk '{gsub(/\033\[[0-9;]*m/, ""); print}')

  # Check if target is an existing session
  if zellij list-sessions -sn 2>/dev/null | grep -Fxq "$target"; then
    if [[ -n "$ZELLIJ" ]]; then
      zellij pipe --plugin "https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm" -- "--session \"$target\""
    else
      zellij attach "$target"
    fi
  elif [ -d "$target" ]; then
    local session_name
    session_name="$(basename "$target")"
    if [[ -n "$ZELLIJ" ]]; then
      local target_abs
      target_abs="$(cd "$target" && pwd)"
      
      # Bypass the zellij-switch plugin's flawed cwd handling by explicitly 
      # creating the session in the background from the correct directory first.
      (cd "$target_abs" && zellij attach -c "$session_name" -b)

      zellij pipe --plugin "https://github.com/mostafaqanbaryan/zellij-switch/releases/download/0.2.1/zellij-switch.wasm" -- "--session \"$session_name\""
    else
      zellij attach -c "$session_name" options --default-cwd "$target"
    fi
  else
    echo "Error: '$target' is neither an active session nor a valid directory."
    return 1
  fi
}
```

Then reload your shell:

```sh
source ~/.zshrc
```

Usage:

```sh
zj
```

## Comparison to sesh

| sesh workflow | zoxide + gum + zellij equivalent |
|---|---|
| `sesh list -i` | `{ zellij list-sessions -sn; zoxide query -l; }` |
| `gum filter` | `gum filter` (same) |
| `sesh connect <session>` | `zellij attach <session>` (or create via `-c`) |
| `sesh connect $(sesh list -i \| gum filter)` | `zj` (the function above) |

The key difference is that **sesh** maintains its own session list tied to tmux, while this approach combines **zellij's active sessions** with **zoxide's frecency-ranked directory history**.

## Tips

- **Customize gum filter appearance** — gum supports `--header`, `--prompt`, `--height`, and styling flags:
  ```sh
  { zellij list-sessions -sn 2>/dev/null; zoxide query -l; } | awk '!seen[$0]++' | gum filter --height 20 --header "Select project"
  ```
- **First time use** — The first time you switch sessions inside Zellij using the `zj` script, Zellij will ask for permissions to run the `zellij-switch` plugin. If the script appears to hang, toggle your floating panes (usually `Ctrl+p` + `w`) to reveal the hidden permission dialog. Press `y` to accept and it will be seamless from then on!
- **Bind to a key in zellij** — add a keybinding in your zellij config (`~/.config/zellij/config.kdl`) to run the picker from within zellij.
