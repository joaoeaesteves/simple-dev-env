# Simple Dev Env

**Sets up a development environment on a new VM with common tools and basic configurations.**

This script automates the setup of a development environment on a fresh VM. It installs essential development tools, configures your environment, and ensures that you’re ready to start coding quickly.

## Features
- Installs commonly used tools.
- Installs **Python** (via `uv`).
- Installs **Rust** (via `rustup`).
- Installs and configures **CascadiaCode** (Nerd Font).
- Installs **Visual Studio Code**.
- Customizes `.bashrc` with useful aliases and environment variables.
- Works on Ubuntu-based systems (like Ubuntu or Debian).
- Simple one-liner installation using `curl | sh`.

## Usage
To install the development environment, run the following command:
```bash
curl -fsSL https://raw.githubusercontent.com/joaoeaesteves/simple-dev-env/main/install.sh | sh
```

## Requirements
- Ubuntu-based system (e.g., Ubuntu, Debian).
- `sh` as the default shell (should work on most systems).
- `curl` must be installed for the script to run. You can install `curl` with the following command:
```bash
sudo apt install curl
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
