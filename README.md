# zellij-filter

Replicate `sesh connect $(sesh list -i | gum filter)` using **zoxide**, **gum**, and **zellij**.

This project provides a simple shell function `zj` that combines Zellij's active sessions with Zoxide's frecency-ranked directory history, allowing you to quickly fuzzy-find and switch between projects. It seamlessly handles nested Zellij sessions via the `zellij-switch` plugin.

## Quick Links

We use the [Diátaxis framework](https://diataxis.fr/) for our documentation. Check out the `docs/` folder for more details:

- [🎓 Tutorial: Getting Started](docs/tutorial.md) - Step-by-step installation and first run.
- [🛠️ How-To Guides](docs/how-to-guides.md) - Customizing the UI and setting up Zellij keybindings.
- [📚 Reference](docs/reference.md) - Dependency details and script breakdown.
- [💡 Explanation](docs/explanation.md) - How the session switching and CWD workarounds function under the hood.