# Leo's NixOS & Home Manager Configuration

This repository contains the configuration for the `nix2505` system and the `leo` user environment.

## Architecture

This configuration uses a **Standalone Home Manager** architecture. 
This means the system configuration (managed by NixOS) and the user environment (managed by Home Manager) are decoupled.

### Benefits of this approach:

- **Speed:** Updating user configurations (like aliases, shell settings, or user packages) is nearly instantaneous because it doesn't require evaluating the entire system state.
- **Safety:** Modifying user configurations does not require `sudo` privileges.
- **Clean Boot Menu:** User configuration changes do not create new NixOS system generations in the bootloader.

## Repository Location

The configuration files are stored in `~/.config/nixos`. 
This adheres to the XDG Base Directory Specification and keeps the home directory clean while allowing management via Git without root ownership conflicts (which occurs if kept in `/etc/nixos`).

## Usage

Two helpful aliases are provided in `home.nix` for applying changes. Both aliases automatically route traffic through a local proxy to ensure reliable access to GitHub and the official Nix cache, bypassing network restrictions.

### Updating System Configuration (Requires `sudo`)

When you modify system-level settings (e.g., `configuration.nix`, hardware config, system packages):

```bash
nixup
```
*(This is an alias for: `sudo HTTP_PROXY=... HTTPS_PROXY=... nixos-rebuild switch --flake ~/.config/nixos#nix2505`)*

### Updating User Environment (Fast, No `sudo`)

When you modify user-level settings (e.g., `home.nix`, dotfiles, user packages):

```bash
userup
```
*(This is an alias for: `HTTP_PROXY=... HTTPS_PROXY=... home-manager switch --flake ~/.config/nixos#leo`)*

## Network & Caching Strategy

Due to the heavy reliance on GitHub for Nix Flakes and network restrictions (GFW), this configuration relies on a proxy setup.

- **Proxy Requirement:** Both update commands (`nixup`, `userup`) are explicitly prefixed with proxy environment variables.
- **Binary Cache:** We strictly use the official NixOS binary cache (`cache.nixos.org`). Domestic mirrors (like TUNA) are avoided because routing proxy traffic back to a domestic mirror is inefficient and often causes connection drops or slowdowns. The official Fastly-backed CDN provides the best performance when accessed through the proxy.
