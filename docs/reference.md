# 📚 Reference

### Dependencies
| Tool | Purpose | Source |
|------|---------|--------|
| **zoxide** | Tracks frequently used directories (frecency algorithm) | [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide) |
| **gum** | Interactive TUI filter/picker | [charmbracelet/gum](https://github.com/charmbracelet/gum) |
| **zellij** | Terminal multiplexer | [zellij-org/zellij](https://github.com/zellij-org/zellij) |
| **zellij-switch** | WASM Plugin for nested session switching | [mostafaqanbaryan/zellij-switch](https://github.com/mostafaqanbaryan/zellij-switch) |

### Core Command Breakdown
Understanding the data pipeline before it hits `gum filter`:

1. `zellij list-sessions -sn` — Lists the names of all currently active zellij sessions and pipes to `awk` to colorize them cyan.
2. `zoxide query -l` — Lists all tracked directories, sorted by frecency, and pipes to `awk` to colorize them blue.
3. `awk '!seen[$0]++'` — Deduplicates the combined list.
4. `gum filter --no-strip-ansi` — Presents the interactive fuzzy-finder.
5. `target="$(...)"` — Strips ANSI codes to produce a clean string for Zellij to attach to or create.
