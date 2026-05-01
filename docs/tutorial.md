# 🎓 Tutorial: Getting Started

This tutorial will guide you through setting up `zellij-filter` on your machine and using it for the first time.

### 1. Install Dependencies
You need three tools installed on your system. On macOS, you can use Homebrew:
```sh
brew install zoxide gum zellij
```

Ensure `zoxide` is initialized in your shell (`~/.zshrc` or `~/.bashrc`):
```sh
eval "$(zoxide init zsh)"
```

### 2. Add the Shell Function
Add the `zj` function to your `~/.zshrc` or `~/.bashrc`:

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

### 3. Run Your First Switch
Reload your shell config:
```sh
source ~/.zshrc
```

Run the command to open the picker:
```sh
zj
```

**Note on first-time use inside Zellij:** If you are already inside a Zellij session, running `zj` will ask for permissions to run the `zellij-switch` plugin. If the script appears to hang, toggle your floating panes (usually `Ctrl+p` + `w`) to reveal the hidden permission dialog. Press `y` to accept, and it will be seamless from then on!
