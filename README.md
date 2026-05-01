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
dir="$(zoxide query -l | gum filter)" && zellij attach -c "$(basename "$dir")" options --default-cwd "$dir"
```

### What each piece does

1. **`zoxide query -l`** — lists all tracked directories, sorted by frequency/recency (frecency).
2. **`gum filter`** — presents an interactive fuzzy-finder to pick a directory.
3. **`dir="$(...)"`** — captures the selected directory path.
4. **`zellij attach -c <name> options --default-cwd <dir>`** — attaches to a zellij session named after the directory. The `-c` flag creates the session if it doesn't already exist. The `options --default-cwd` subcommand sets the working directory for new panes.

## Shell function

Add this to your `~/.zshrc` (or `~/.bashrc`):

```sh
# Fuzzy-pick a zoxide directory and open it in a zellij session
zj() {
  local dir
  dir="$(zoxide query -l | gum filter --placeholder 'Pick a project...')"

  # Exit if nothing was selected (user pressed Esc)
  if [ -z "$dir" ]; then
    return 0
  fi

  local session_name
  session_name="$(basename "$dir")"

  # Attach to existing session or create a new one in the target directory
  zellij attach -c "$session_name" options --default-cwd "$dir"
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
| `sesh list -i` | `zoxide query -l` |
| `gum filter` | `gum filter` (same) |
| `sesh connect <session>` | `zellij attach -c <session>` |
| `sesh connect $(sesh list -i \| gum filter)` | `zj` (the function above) |

The key difference is that **sesh** maintains its own session list tied to tmux, while this approach uses **zoxide's frecency-ranked directory history** as the source and **zellij** as the multiplexer.

## Tips

- **Customize gum filter appearance** — gum supports `--header`, `--prompt`, `--height`, and styling flags:
  ```sh
  zoxide query -l | gum filter --height 20 --header "Select project"
  ```
- **Include the current zellij sessions** — merge zoxide directories with existing sessions:
  ```sh
  { zellij list-sessions 2>/dev/null; zoxide query -l; } | sort -u | gum filter
  ```
- **Bind to a key in zellij** — add a keybinding in your zellij config (`~/.config/zellij/config.kdl`) to run the picker from within zellij.
