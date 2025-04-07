#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status

# ============================================================
# Define XDG base directories for configuration, cache, data, and state
# ============================================================
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ============================================================
# Create necessary XDG base directories
# ============================================================
echo "📁 Creating XDG base directories..."
mkdir -p "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME/bash"

# ============================================================
# Update and upgrade system packages
# ============================================================
echo "📦 Updating and upgrading system packages..."
sudo apt update -y && sudo apt upgrade -y

# ============================================================
# Install essential packages
# ============================================================
sudo apt install -y git curl

TEMP_DIR=$(mktemp -d)

# ============================================================
# Install CascadiaCode font (Nerd Font)
# ============================================================
echo "🎨 Installing CascadiaCode font (Nerd Font)..."
FONT_DIR="$XDG_DATA_HOME/fonts"
if [ -d "$FONT_DIR/CascadiaCode" ]; then
    echo "🖋️ CascadiaCode font is already installed. Skipping font installation..."
else
    curl -LsSf https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.tar.xz -o "$TEMP_DIR/CascadiaCode.tar.xz"
    mkdir -p "$FONT_DIR"
    tar -xf "$TEMP_DIR/CascadiaCode.tar.xz" -C "$FONT_DIR"
    fc-cache -f                        # Refresh font cache
    rm "$TEMP_DIR/CascadiaCode.tar.xz" # Clean up font tarball
fi

# ============================================================
# Clone the setup repository to a temporary directory
# ============================================================
echo "📁 Cloning setup repo to a temporary directory..."
git clone --depth=1 https://github.com/joaoeaesteves/simple-dev-env.git "$TEMP_DIR"

# ============================================================
# Backup and apply .bashrc
# ============================================================
if [ -f "$HOME/.bashrc" ]; then
    echo "💾 Backing up existing .bashrc..."
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi
echo "📝 Applying new .bashrc..."
cp "$TEMP_DIR/.bashrc" "$HOME/.bashrc"

# ============================================================
# Install additional essential packages
# ============================================================
echo "🛠️ Installing packages..."
sudo apt install -y htop vim build-essential neovim atool bat lsd ripgrep

# ============================================================
# Configure bat
# ============================================================
echo "⚙️ Copying bat configuration..."
mkdir -p "$XDG_CONFIG_HOME/bat"
cp "$TEMP_DIR/config/bat/config" "$XDG_CONFIG_HOME/bat/"

# ============================================================
# Configure lsd
# ============================================================
echo "⚙️ Copying lsd configuration..."
mkdir -p "$XDG_CONFIG_HOME/lsd"
cp "$TEMP_DIR/config/lsd/config.yaml" "$XDG_CONFIG_HOME/lsd/"

# ============================================================
# Install Fastfetch
# ============================================================
echo "🛠️ Installing Fastfetch..."
curl -LsSf https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -o "$TEMP_DIR/fastfetch.deb"
sudo apt install -y "$TEMP_DIR/fastfetch.deb"
rm "$TEMP_DIR/fastfetch.deb"
echo "⚙️ Copying fastfetch configuration..."
mkdir -p "$XDG_CONFIG_HOME/fastfetch"
cp "$TEMP_DIR/config/fastfetch/config.jsonc" "$XDG_CONFIG_HOME/fastfetch/"

# ============================================================
# Install Rust
# ============================================================
if [ "$(command -v rustup)" ]; then
    echo "🦀 Rust is already installed. Skipping installation..."
else
    echo "🦀 Installing Rust (via rustup)..."
    export CARGO_HOME="$XDG_DATA_HOME/cargo"
    export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# ============================================================
# Install Rust tools
# ============================================================
if [ -f "$CARGO_HOME/env" ]; then
    . "$CARGO_HOME/env"
    echo "📦 Installing Rust tools..."
    cargo install tlrc --locked
else
    echo "⚠️ Rust environment not found. Skipping Rust tools installation..."
fi

# ============================================================
# Configure rustfmt
# ============================================================
echo "⚙️ Copying rustfmt configuration..."
mkdir -p "$XDG_CONFIG_HOME/rustfmt"
cp "$TEMP_DIR/config/rustfmt/rustfmt.toml" "$XDG_CONFIG_HOME/rustfmt/"

# ============================================================
# Install uv (Python toolchain manager)
# ============================================================
if [ "$(command -v uv)" ]; then
    echo "🚀 uv is already installed. Skipping installation..."
else
    echo "🚀 Installing uv (Python toolchain manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ============================================================
# Install Visual Studio Code
# ============================================================
if [ "$(command -v code)" ]; then
    echo "🖥️ Visual Studio Code is already installed. Skipping installation..."
else
    echo "🖥️ Installing Visual Studio Code..."
    curl -LsSf "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o "$TEMP_DIR/code.deb"
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
    sudo apt install -y "$TEMP_DIR/code.deb"
    rm "$TEMP_DIR/code.deb" # Clean up the downloaded .deb file
fi

# ============================================================
# Clean up temporary files
# ============================================================
echo "🧼 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# ============================================================
# Migrate bash history
# ============================================================
echo "🕓 Migrating bash history..."
BASH_HISTORY="$XDG_STATE_HOME/bash/history"
if [ -f "$HOME/.bash_history" ]; then
    echo "📂 Moving existing bash history to $BASH_HISTORY..."
    mv "$HOME/.bash_history" "$BASH_HISTORY"
else
    echo "📂 Creating an empty bash history file at $BASH_HISTORY..."
    touch "$BASH_HISTORY"
fi
if [ -f "$HOME/.bash_history" ]; then
    echo "🗑️ Removing old bash history file..."
    rm "$HOME/.bash_history"
fi

# ============================================================
# Final message
# ============================================================
echo "✅ Setup complete!"
echo "🔄 Please restart your terminal or run: source ~/.bashrc"
