# Leo's NixOS & Home Manager Configuration

This repository contains a modular NixOS and Home Manager configuration designed for multiple environments (laptop and headless server).

## Architecture

This configuration uses a **Standalone Home Manager** architecture with a hierarchical module system.
The system configuration (managed by NixOS) and the user environment (managed by Home Manager) are decoupled.

### Hierarchical Structure:

- **`home-base.nix`**: Contains all shared CLI tools, shell settings (Fish/Git/Neovim), and core utilities.
- **`home-desktop.nix`**: Imports `home-base.nix` and adds GUI applications (Chrome, Remmina) and desktop-specific configs.
- **`home-headless.nix`**: Imports `home-base.nix` and serves as a stub for server-specific configurations.

### Benefits:

- **Single Source of Truth:** Basic configurations (like git aliases) are defined once in `home-base.nix` and sync across all machines.
- **Speed:** Updating user configurations is nearly instantaneous.
- **Safety:** Modifying user configurations does not require `sudo` privileges.

## Repository Location

The configuration files are stored in `~/.config/nixos`. 
This adheres to the XDG Base Directory Specification and keeps the home directory clean while allowing management via Git.

## Usage

Two helpful aliases are provided in `home-base.nix` for applying changes.

### Updating System Configuration (Requires `sudo`)

When you modify system-level settings (e.g., `nixos-*.nix`):

**For Headless Server:**
```bash
nixup
```
*(This is an alias for: `sudo nixos-rebuild switch --flake ~/.config/nixos#headless`)*

**For Laptop (Dell E7450):**
```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#dell-e7450
```

### Updating User Environment (Fast, No `sudo`)

When you modify user-level settings (e.g., any `home-*.nix` file):

**For Headless Server:**
```bash
userup
```
*(This is an alias for: `home-manager switch --flake ~/.config/nixos#headless`)*

**For Desktop (KDE + Hyprland):**
```bash
home-manager switch --flake ~/.config/nixos#desktop
```

## Network & Caching Strategy

Due to the heavy reliance on GitHub for Nix Flakes and potential network restrictions, ensure your environment is configured correctly.

- **Binary Cache:** We strictly use the official NixOS binary cache (`cache.nixos.org`). The official Fastly-backed CDN provides the best performance.
- **Optimized Stores:** The configuration enables `auto-optimise-store` to save disk space by hard-linking identical files in the Nix store.
