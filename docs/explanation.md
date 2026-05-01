# 💡 Explanation

### Why not just `zellij attach`?
Zellij actively prevents you from nesting a session within another session (running `zellij attach` from a pane that is already inside Zellij). To circumvent this, `zellij-filter` checks if the `$ZELLIJ` environment variable is present.

If you are already inside Zellij, it uses the `zellij pipe` command to send a message to a background WASM plugin (`zellij-switch.wasm`). The plugin communicates directly with the Zellij server to swap the active client session natively without nesting.

### The CWD Background Hack
The `zellij-switch` plugin currently has limitations when setting the Current Working Directory (CWD) for new sessions. If it tries to create a session in a new directory, it incorrectly inherits the pane's directory instead. 

To bypass this, when `zellij-filter` detects you want to open a directory, it spawns a detached background session natively in bash first:
```sh
(cd "$target_abs" && zellij attach -c "$session_name" -b)
```
Once the session exists with the correct directory, the script delegates to the WASM plugin to merely *switch* to it.

### Comparison to `sesh`
If you are coming from `tmux` and `sesh`, this tool replicates that workflow:

| sesh workflow | zellij-filter equivalent |
|---|---|
| `sesh list -i` | `{ zellij list-sessions -sn; zoxide query -l; }` |
| `gum filter` | `gum filter` |
| `sesh connect <session>` | `zellij attach <session>` (or create via `-c`) |
| `sesh connect $(sesh list -i \| gum filter)` | `zj` |

The key difference is that **sesh** maintains its own custom SQLite database and session list tied to tmux. This approach is much lighter, combining **Zellij's native active sessions** directly with **Zoxide's frecency-ranked directory history**.
