# Update Packages

```bash
nix flake update --flake ~/.config/nixos
home-manager switch --flake ~/.config/nixos#leo
```

The first command updates the "recipe," and the second command "cooks" it:

* `nix flake update`: updates `flake.lock`, fetching the latest versions of all flake inputs
  (nixpkgs, home-manager, nix-index-database, agenix, etc.),
  like `apt update`, `pacman -Sy`, or `dnf check-update`.
* `home-manager switch`: builds and activates your home-manager config using the current flake inputs,
  installing/upgrading any changed packages, like `apt upgrade`, `pacman -Su`, or `dnf upgrade`.

Note:

* In Arch, the 2 commands are always combined into `pacman -Syu`.
* Fedora's dnf automatically refreshes its metadata (the "recipe") if it has expired
  before it proceeds to download and install the updates.
  So in most cases `dnf update` (or `upgrade`) alone is enough.

## How Updates Work (The `nixpkgs` Model)

Updating packages in NixOS is conceptually different from traditional
package managers like `apt` or `pacman`.
It is more akin to updating a snapshot in Haskell's *Stackage*.

### `nixpkgs` as a Curated Snapshot

When you run `nix flake update`,
you are updating the `nixpkgs` input in your `flake.lock` file to a newer Git commit.
A specific commit of `nixpkgs` represents a massive, curated set of over 100,000 software
packages that have been tested to compile and work together without dependency conflicts. 

Because of this model, you generally **do not update a single package in isolation**.
Instead, you advance your entire system to a newer, tested snapshot of the `nixpkgs` repository.
This guarantees that the specific combination of software defined by that commit will
build and run compatibly, eliminating "dependency hell."

### How Hydra Tests Everything

Testing such a massive repository is possible thanks to Nix's purely functional
build model and the *Hydra* continuous integration system:

1. *Purely Functional Builds*: Nix calculates a cryptographic hash for every package based on
   its entire dependency tree (source code, compiler, build flags, dependencies).
1. *Dependency Graph Analysi*s: When a commit is made (e.g., updating an app), Hydra doesn't rebuild everything.
   It recalculates the hashes and only rebuilds the specific packages and their
   reverse dependencies whose hashes have changed.
1. *The Binary Cache*: Successfully built packages are stored in the official NixOS binary cache (`cache.nixos.org`).
   When you update your system, Nix simply downloads the pre-compiled binaries
   matching your required hashes instead of building them locally.
1. *Channels*: Branches like `nixos-unstable` only advance to a newer commit *after* Hydra has verified
   that all critical system components and a high percentage of all packages build successfully.
   This automated gating ensures system stability even on bleeding-edge channels.
