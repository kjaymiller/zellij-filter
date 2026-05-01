# 🛠️ How-To Guides

### How to customize the picker appearance
Gum supports various UI tweaks through flags like `--header`, `--prompt`, and `--height`. You can modify the `gum filter` line in your `zj` function:

```sh
gum filter --height 20 --header "Select project" --no-strip-ansi
```

### How to bind the picker to a Zellij shortcut
To avoid typing `zj` in the terminal every time, you can bind it to a key combination in your Zellij config (`~/.config/zellij/config.kdl`):

```kdl
keybinds {
    shared_except "locked" {
        bind "Ctrl f" {
            Run "zsh" "-ic" "zj" {
                floating true
                close_on_exit true
            }
        }
    }
}
```
*(Ensure your shell configuration is sourced correctly so Zellij knows the `zj` command).*
