# Update Packages

## Commands

```bash
nix flake update --flake ~/.config/nixos
home-manager switch --flake ~/.config/nixos#leo
```

## What each command does

1. `nix flake update` — Updates `flake.lock`, fetching the latest versions of all flake inputs (nixpkgs, home-manager, nix-index-database, agenix, etc.)

2. `home-manager switch` — Builds and activates your home-manager config using the current flake inputs, installing/upgrading any changed packages.

The first command updates the "recipe," and the second command "cooks" it.
