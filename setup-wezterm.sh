#!/bin/zsh
# =============================================================
# WezTerm + Shell + Neovim Setup Script
# Recreates the Neofusion-themed WezTerm environment
# with Josean's Neovim config (tokyonight theme)
# =============================================================

set -e

echo "🚀 Starting WezTerm environment setup..."
echo ""

# ---------------------------
# 1. Set default shell to zsh
# ---------------------------
if [ "$SHELL" != "/bin/zsh" ]; then
  echo "🔧 Changing default shell to zsh..."
  chsh -s /bin/zsh
else
  echo "✅ Default shell is already zsh"
fi

# ---------------------------
# 2. Install Homebrew (if needed)
# ---------------------------
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "✅ Homebrew already installed"
fi

# ---------------------------
# 3. Install dependencies
# ---------------------------
echo ""
echo "📦 Installing packages..."

PACKAGES=(starship eza fzf nushell neovim ripgrep tmux)
for pkg in "${PACKAGES[@]}"; do
  if ! brew list "$pkg" &>/dev/null; then
    echo "  Installing $pkg..."
    brew install "$pkg"
  else
    echo "  ✅ $pkg already installed"
  fi
done

# ---------------------------
# 4. Install JetBrainsMono Nerd Font
# ---------------------------
if ! ls ~/Library/Fonts/JetBrainsMonoNerdFont* &>/dev/null 2>&1 && \
   ! ls /Library/Fonts/JetBrainsMonoNerdFont* &>/dev/null 2>&1; then
  echo "🔤 Installing JetBrainsMono Nerd Font..."
  brew install --cask font-jetbrains-mono-nerd-font
else
  echo "✅ JetBrainsMono Nerd Font already installed"
fi

# ---------------------------
# 5. Install npm (via Node.js) if needed
# ---------------------------
if ! command -v npm &>/dev/null; then
  echo "📦 Installing Node.js (for npm)..."
  brew install node
else
  echo "✅ npm already installed"
fi

# ---------------------------
# 6. Write ~/.zshrc
# ---------------------------
echo ""
echo "📝 Writing ~/.zshrc..."
cat > ~/.zshrc << 'ZSHRC'
export PATH="$HOME/.local/bin:$PATH"
export PATH="$(npm config get prefix)/bin:$PATH"

# Set up fzf key binding and fuzzy completion
eval "$(fzf --zsh)"

# Initialize Starship prompt
eval "$(starship init zsh)"

# Use eza instead of ls (with icons)
alias ls="eza --icons"
alias ll="eza --icons -la"
alias la="eza --icons -a"
alias lt="eza --icons --tree --level=2"

# Nushell-style table output
alias lsn="nu -c 'ls'"

# Auto-attach to tmux session (or create one)
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
  tmux attach -t main 2>/dev/null || tmux new-session -s main
fi
ZSHRC
echo "  ✅ ~/.zshrc written"

# ---------------------------
# 7. Write Starship config
# ---------------------------
echo "📝 Writing Starship config..."
mkdir -p ~/.config
cat > ~/.config/starship.toml << 'STARSHIP'
format = """
[](fg:#2f516c)\
$directory\
[](fg:#2f516c bg:#ea6847)\
$git_branch\
$git_status\
[](fg:#ea6847 bg:#d943a8)\
$package\
[](fg:#d943a8)\
$fill\
$cmd_duration\
$status\
$line_break\
$character"""

[directory]
format = "[ $path ]($style)"
style = "fg:#e0d9c7 bg:#2f516c"
truncation_length = 3
truncate_to_repo = false

[git_branch]
format = "[ $symbol$branch ]($style)"
style = "fg:#e0d9c7 bg:#ea6847"
symbol = " "

[git_status]
format = "[$all_status$ahead_behind]($style)"
style = "fg:#e0d9c7 bg:#ea6847"

[package]
format = "[ $symbol$version ]($style)"
style = "fg:#e0d9c7 bg:#d943a8"
symbol = " "

[fill]
symbol = " "

[cmd_duration]
format = "[$duration]($style) "
style = "fg:#5db2f8"
min_time = 2000

[status]
format = "[$symbol]($style)"
symbol = "✓"
success_symbol = "[✓](fg:#ea6847)"
disabled = false

[character]
success_symbol = "[  ](fg:#86dbf5)"
error_symbol = "[  ](fg:#ea6847)"
STARSHIP
echo "  ✅ Starship config written"

# ---------------------------
# 8. Write tmux config
# ---------------------------
echo "📝 Writing ~/.tmux.conf..."
cat > ~/.tmux.conf << 'TMUXCONF'
# Prefix: CTRL+A (instead of default CTRL+B)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# True color support
set -g default-terminal "tmux-256color"
set -as terminal-overrides ",xterm*:Tc"

# Mouse support
set -g mouse on

# Start windows and panes at 1 (not 0)
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Faster key repetition
set -s escape-time 0

# Window switching: ALT+1-5 (no prefix needed)
bind-key -n M-1 select-window -t 1
bind-key -n M-2 select-window -t 2
bind-key -n M-3 select-window -t 3
bind-key -n M-4 select-window -t 4
bind-key -n M-5 select-window -t 5

# Pane navigation: ALT+H/J/K/L (vim-style, no prefix)
bind-key -n M-h select-pane -L
bind-key -n M-j select-pane -D
bind-key -n M-k select-pane -U
bind-key -n M-l select-pane -R

# Splits and windows (no prefix needed)
bind-key -n M-| split-window -h -c "#{pane_current_path}"
bind-key -n M-- split-window -v -c "#{pane_current_path}"
bind-key -n M-t new-window -c "#{pane_current_path}"
bind-key -n M-w kill-pane

# Neofusion status bar
set -g status-style "bg=#022236,fg=#e0d9c7"
set -g status-left "#[bg=#2f516c,fg=#e0d9c7] #S #[bg=#022236,fg=#2f516c]"
set -g status-right "#[fg=#2f516c,bg=#022236]#[bg=#2f516c,fg=#e0d9c7] %H:%M "
set -g window-status-format "#[fg=#2f516c] #I:#W "
set -g window-status-current-format "#[bg=#070f1c,fg=#ea6847] #I:#W "
set -g status-left-length 30
set -g status-position bottom
TMUXCONF
echo "  ✅ ~/.tmux.conf written"

# ---------------------------
# 9. Write WezTerm config
# ---------------------------
echo "📝 Writing ~/.wezterm.lua..."
cat > ~/.wezterm.lua << 'WEZTERM'
local wezterm = require("wezterm")
local config = wezterm.config_builder()

local neofusion_theme = {
  foreground = "#e0d9c7",
  background = "#070f1c",
  cursor_bg = "#e0d9c7",
  cursor_border = "#e0d9c7",
  cursor_fg = "#070f1c",
  selection_bg = "#ea6847",
  selection_fg = "#e0d9c7",
  ansi = {
    "#070f1c", -- Black (Host)
    "#ea6847", -- Red (Syntax string)
    "#ea6847", -- Green (Command)
    "#5db2f8", -- Yellow (Command second)
    "#2f516c", -- Blue (Path)
    "#d943a8", -- Magenta (Syntax var)
    "#86dbf5", -- Cyan (Prompt)
    "#e0d9c7", -- White
  },
  brights = {
    "#2f516c", -- Bright Black
    "#d943a8", -- Bright Red (Command error)
    "#ea6847", -- Bright Green (Exec)
    "#86dbf5", -- Bright Yellow
    "#5db2f8", -- Bright Blue (Folder)
    "#d943a8", -- Bright Magenta
    "#ea6847", -- Bright Cyan
    "#e0d9c7", -- Bright White
  },
  tab_bar = {
    background = "#022236",
    active_tab = {
      bg_color = "#070f1c",
      fg_color = "#e0d9c7",
      intensity = "Normal",
    },
    inactive_tab = {
      bg_color = "#022236",
      fg_color = "#2f516c",
    },
    inactive_tab_hover = {
      bg_color = "#032a40",
      fg_color = "#e0d9c7",
    },
    new_tab = {
      bg_color = "#022236",
      fg_color = "#2f516c",
    },
    new_tab_hover = {
      bg_color = "#032a40",
      fg_color = "#e0d9c7",
    },
  },
}

config.colors = neofusion_theme
config.font = wezterm.font("JetBrainsMono Nerd Font", { weight = "Medium" })
config.font_size = 14.0
config.line_height = 1.2
config.window_padding = {
  left = 16,
  right = 16,
  top = 16,
  bottom = 16,
}
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- Pass ALT keys through to tmux (disable WezTerm's ALT interception)
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
config.keys = {
  { key = "1", mods = "ALT", action = wezterm.action.SendKey { key = "1", mods = "ALT" } },
  { key = "2", mods = "ALT", action = wezterm.action.SendKey { key = "2", mods = "ALT" } },
  { key = "3", mods = "ALT", action = wezterm.action.SendKey { key = "3", mods = "ALT" } },
  { key = "4", mods = "ALT", action = wezterm.action.SendKey { key = "4", mods = "ALT" } },
  { key = "5", mods = "ALT", action = wezterm.action.SendKey { key = "5", mods = "ALT" } },
  { key = "h", mods = "ALT", action = wezterm.action.SendKey { key = "h", mods = "ALT" } },
  { key = "j", mods = "ALT", action = wezterm.action.SendKey { key = "j", mods = "ALT" } },
  { key = "k", mods = "ALT", action = wezterm.action.SendKey { key = "k", mods = "ALT" } },
  { key = "l", mods = "ALT", action = wezterm.action.SendKey { key = "l", mods = "ALT" } },
  { key = "t", mods = "ALT", action = wezterm.action.SendKey { key = "t", mods = "ALT" } },
  { key = "w", mods = "ALT", action = wezterm.action.SendKey { key = "w", mods = "ALT" } },
  { key = "|", mods = "ALT", action = wezterm.action.SendKey { key = "|", mods = "ALT" } },
  { key = "-", mods = "ALT", action = wezterm.action.SendKey { key = "-", mods = "ALT" } },
}

return config
WEZTERM
echo "  ✅ ~/.wezterm.lua written"

# ---------------------------
# 10. Setup Neovim (Josean's config)
# ---------------------------
echo ""
echo "📝 Setting up Neovim config..."
NVIM_DIR="$HOME/.config/nvim"

if [ -d "$NVIM_DIR" ] && [ "$(ls -A $NVIM_DIR 2>/dev/null)" ]; then
  echo "  ⚠️  Existing nvim config found. Backing up to ~/.config/nvim.bak..."
  mv "$NVIM_DIR" "$HOME/.config/nvim.bak.$(date +%s)"
  mkdir -p "$NVIM_DIR"
fi

echo "  Cloning Josean's dev environment config..."
TMPDIR_JOSEAN=$(mktemp -d)
git clone --depth 1 https://github.com/josean-dev/dev-environment-files.git "$TMPDIR_JOSEAN"
cp -r "$TMPDIR_JOSEAN/.config/nvim/"* "$NVIM_DIR/"
rm -rf "$TMPDIR_JOSEAN"
echo "  ✅ Neovim config installed"
echo ""
echo "  ℹ️  On first 'nvim' launch, lazy.nvim will auto-install all plugins."
echo "  Press 'U' to update plugins, then 'q' to close the plugin manager."

# ---------------------------
# Done!
# ---------------------------
echo ""
echo "============================================="
echo "✅ Setup complete!"
echo "============================================="
echo ""
echo "What was configured:"
echo "  • Default shell → zsh"
echo "  • Starship prompt (Neofusion powerline theme)"
echo "  • eza (ls replacement with icons)"
echo "  • fzf (fuzzy finder)"
echo "  • Nushell (lsn alias for table output)"
echo "  • JetBrainsMono Nerd Font"
echo "  • WezTerm (Neofusion color scheme + styling + ALT key passthrough)"
echo "  • tmux (session persistence, ALT shortcuts, Neofusion status bar)"
echo "  • Neovim (Josean's config with tokyonight theme)"
echo "  • ripgrep (for Telescope fuzzy search in nvim)"
echo ""
echo "👉 Restart WezTerm → lands in tmux automatically."
echo "   ALT+T = new window  |  ALT+1-5 = switch windows  |  ALT+H/J/K/L = move panes"
echo "   Then run 'nvim' to finish plugin setup."
