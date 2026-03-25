# tmux Keyboard Shortcuts

This environment runs tmux automatically inside WezTerm. All shortcuts below work without any prefix key — just press them directly.

## Windows

| Shortcut | Action |
|----------|--------|
| `ALT+T` | New window (opens in current directory) |
| `ALT+1` | Switch to window 1 |
| `ALT+2` | Switch to window 2 |
| `ALT+3` | Switch to window 3 |
| `ALT+4` | Switch to window 4 |
| `ALT+5` | Switch to window 5 |

## Panes

| Shortcut | Action |
|----------|--------|
| `ALT+|` | Split pane vertically (side by side) |
| `ALT+-` | Split pane horizontally (top / bottom) |
| `ALT+H` | Move focus left |
| `ALT+J` | Move focus down |
| `ALT+K` | Move focus up |
| `ALT+L` | Move focus right |
| `ALT+W` | Close current pane |

## Sessions (prefix required: `CTRL+A`)

| Shortcut | Action |
|----------|--------|
| `CTRL+A d` | Detach session (keeps it running in background) |
| `CTRL+A $` | Rename current session |
| `CTRL+A s` | List and switch sessions |

## Other

- WezTerm opens directly into a tmux session named `main`
- Closing WezTerm does **not** kill the session — reopen and you're back where you left off
- Use `tmux attach -t main` from any terminal to reconnect
