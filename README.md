# Leo's NixOS & Home Manager Configuration

This repository contains a modular NixOS and Home Manager configuration designed for multiple environments (laptop and headless server).

## Architecture

This configuration uses a **Standalone Home Manager** architecture with a hierarchical module system.
The system configuration (managed by NixOS) and the user environment (managed by Home Manager) are decoupled.

### Hierarchical Structure

- **`home-base.nix`**: Contains all shared CLI tools, shell settings (Fish/Git/Neovim), and core utilities.
- **`home-desktop.nix`**: Imports `home-base.nix` and adds GUI applications (Chrome, Remmina) and desktop-specific configs.
- **`home-headless.nix`**: Imports `home-base.nix` and serves as a stub for server-specific configurations.

### Benefits

- **Single Source of Truth:** Basic configurations (like git aliases) are defined once in `home-base.nix` and sync across all machines.
- **Speed:** Updating user configurations is nearly instantaneous.
- **Safety:** Modifying user configurations does not require `sudo` privileges.

## Repository Location

The configuration files are stored in `~/.config/nixos`. 
This adheres to the XDG Base Directory Specification and keeps the home directory clean while allowing management via Git.

## Usage

The `nixup` fish function (defined in `home-base.nix`) applies changes. It resolves this machine's targets from the hostname:

| Hostname | NixOS target | Home Manager target |
|---|---|---|
| `thinkcentre` | `headless-thinkcentre` | `headless` |
| `nix2505` | `headless-wired` | `headless` |
| `dell-e7450` | `dell-e7450` | `desktop` |

### Auto Mode (default)

```bash
nixup
```

1. Collects uncommitted changes in `~/.config/nixos` via `git status` (staged, unstaged, and untracked).
2. Maps each changed file to the targets it affects, shows the plan, and skips changes belonging to other hosts.
3. After confirmation, runs `sudo nixos-rebuild switch` and/or `home-manager switch` for this host only.

File-to-target mapping:

- `nixos-<host>.nix`, `hardware-<host>.nix` → that host's NixOS config only
- `nixos-base.nix` → all NixOS hosts
- `flake.nix`, `flake.lock` → both layers (all NixOS + Home Manager)
- `home-desktop.nix`, `home-headless.nix` → that Home Manager target only
- anything else (`home-base.nix`, `nvim/`, `secrets/`, dotfiles) → all Home Manager targets

### Explicit Mode

```bash
nixup --list                          # list all flake targets
nixup headless                        # home-manager switch --flake ~/.config/nixos#headless
nixup headless-thinkcentre            # sudo nixos-rebuild switch --flake ~/.config/nixos#headless-thinkcentre
```

Equivalent raw commands, e.g. for other hosts or debugging:

```bash
sudo nixos-rebuild switch --flake ~/.config/nixos#<nixos-target>
home-manager switch --flake ~/.config/nixos#<home-target>
```

The NixOS and Home Manager layers are switched independently: user-level changes (`home-*.nix`, `nvim/`) never need `sudo`, and system-level changes (`nixos-*.nix`) only affect the machine whose hostname matches.

## Network Configuration

### Setup IPv4 Address Interactively

The WiFi configurations (SSID, IP address, gateway, etc.) always change for different hosts.
So it's a good strategy to move these configurations out of NixOS configurations in this repo.
See nixos-headless-thinkcentre.nix for details.

### Caching Strategy

Due to the heavy reliance on GitHub for Nix Flakes and potential network restrictions, ensure your environment is configured correctly.

- **Binary Cache:** We strictly use the official NixOS binary cache (`cache.nixos.org`). The official Fastly-backed CDN provides the best performance.
- **Optimized Stores:** The configuration enables `auto-optimise-store` to save disk space by hard-linking identical files in the Nix store.
