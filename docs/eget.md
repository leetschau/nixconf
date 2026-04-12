# Eget Integration for NixOS

This document explains the `eget` integration in this NixOS configuration, which allows easy installation of prebuilt binaries from GitHub with automatic NixOS compatibility patching.

## Overview

**Eget** is a tool that downloads prebuilt binaries from GitHub releases. Normally, dynamically linked binaries won't work on NixOS due to different library paths. Our integration solves this by automatically patching binaries for NixOS compatibility.

## Architecture

### Components

1. **`eget.toml`** - Configuration file for downloaded tools
2. **`scripts/eget-nixos-wrapper.sh`** - Wrapper that patches binaries for NixOS
3. **Fish function** in `home-base.nix` - Intercepts `eget` commands
4. **Home Manager symlink** - Manages `eget.toml` across systems

### Flow Diagram

```
Your command: eget erickochen/purple
    ↓
Fish function (runs automatically)
    ↓
Wrapper script (creates dir, runs eget, patches)
    ↓
Real eget binary (downloads from GitHub)
    ↓
Wrapper script continues (patches binaries)
    ↓
Done! Binary ready to use
```

### How It Works

**When you type `eget <args>` in fish:**

1. **Fish function intercepts** (home-base.nix:70-77)
   ```fish
   function eget
     ~/.config/nixos/scripts/eget-nixos-wrapper.sh $argv
   ```

2. **Wrapper script runs** (scripts/eget-nixos-wrapper.sh)
   - Creates `~/.local/bin` if needed
   - Calls the real `eget` binary to download
   - Automatically patches downloaded binaries with `patchelf`
   - Updates binary interpreter and library paths for NixOS

### How patchelf Makes Binaries Work on NixOS

**The Problem:**

When you download a binary from GitHub (like `purple`), it expects standard Linux paths that don't exist on NixOS:

```bash
# Before patching, binary looks for:
/lib64/ld-linux-x86-64.so.2     # Interpreter (doesn't exist on NixOS)
/usr/lib/libssl.so.3            # Libraries (NixOS uses /nix/store)
```

Running `ldd ~/.local/bin/purple` shows missing dependencies:
```
libssl.so.3 => not found
libcrypto.so.3 => not found
```

**The Solution: patchelf**

patchelf modifies the ELF binary's internal headers to point to NixOS paths:

#### 1. Fix the Interpreter

The interpreter is the program that loads dynamic libraries at runtime.

```bash
# Check current interpreter (points to non-existent path):
patchelf --print-interpreter ~/.local/bin/purple
# Output: /lib64/ld-linux-x86-64.so.2

# Fix to point to NixOS glibc:
patchelf --set-interpreter \
  /nix/store/...-glibc-2.42-51/lib64/ld-linux-x86-64.so.2 \
  ~/.local/bin/purple
```

This tells the binary where to find the dynamic linker on NixOS.

#### 2. Fix Library Paths (RPATH)

RPATH tells the binary where to search for shared libraries.

```bash
# Check current RPATH (empty or wrong):
patchelf --print-rpath ~/.local/bin/purple
# Output: (empty)

# Add NixOS library paths:
patchelf --set-rpath \
  "/nix/store/...-openssl-3.6.1/lib:/nix/store/...-glibc-2.42-51/lib" \
  ~/.local/bin/purple
```

This tells the binary where to find libraries like `libssl.so.3` and `libcrypto.so.3` in the Nix store.

#### 3. Verification After Patching

```bash
ldd ~/.local/bin/purple
# Now shows:
libssl.so.3 => /nix/store/...-openssl-3.6.1/lib/libssl.so.3  ✓
libcrypto.so.3 => /nix/store/...-openssl-3.6.1/lib/libcrypto.so.3  ✓
```

All dependencies resolved correctly!

**Why This Works:**

- **NixOS stores everything in `/nix/store/`** - including system libraries
- **Dynamic binaries need exact paths** - they don't search directories like traditional Linux
- **patchelf rewrites these paths** - so binaries know where to look on NixOS

**The wrapper script automates this:**

For each binary downloaded, the wrapper:
1. Finds the NixOS glibc interpreter
2. Finds required libraries (OpenSSL, etc.) in `/nix/store/`
3. Uses `patchelf` to update the binary's headers
4. Binary now works on NixOS without manual intervention

## Setup

### Initial Setup (Already Done)

These components are already configured in this repository:

1. **`eget.toml`** - Configuration file in repository root
2. **`scripts/eget-nixos-wrapper.sh`** - Automated patching script
3. **`home-base.nix`** - Fish function and environment variables
4. **`patchelf`** - Added to packages for binary patching

### Environment Variables

- `EGET_BIN="$HOME/.local/bin"` - Where binaries are installed
- Automatically set in `home-base.nix`

## Usage

### Basic Usage

After running `userup` to apply Home Manager changes:

```bash
# Install a single tool
eget erickochen/purple

# Install with specific asset filters
eget neovim/neovim --asset appimage

# Install all tools from eget.toml
eget --download-all

# Install a specific version
eget cli/cli --tag v1.2.3
```

### Configuration

Edit `~/.config/nixos/eget.toml` to add tools:

```toml
[global]
target = "~/.local/bin"
upgrade_only = true

["erickochen/purple"]
asset_filters = ["linux", "x86_64"]

["cli/cli"]
asset_filters = ["linux", "amd64"]

["neovim/neovim"]
asset_filters = ["linux", "amd64", "appimage"]
```

After editing, apply changes:

```bash
# Apply Home Manager changes
userup

# Install all configured tools
eget --download-all
```

## How Tools Are Auto-Added

When you run `eget <author>/<repo>`:

1. Binary downloads to `~/.local/bin`
2. Binary is automatically patched for NixOS
3. Manual step: Add configuration to `eget.toml` for future reinstalls

**Note:** Currently, the wrapper script doesn't auto-update `eget.toml`. You need to manually add repos to the config file for `--download-all` support.

## Examples

### Installing purple

```bash
# One-time installation
eget erickochen/purple

# Add to eget.toml for future:
# ["erickochen/purple"]
# asset_filters = ["linux", "x86_64"]

# Reinstall all tools (including purple)
eget --download-all
```

### Installing multiple tools

```bash
# Install individually
eget junegunn/fzf
eget BurntSushi/ripgrep
eget sharkdp/fd

# Then add to eget.toml:
# ["junegunn/fzf"]
# ["BurntSushi/ripgrep"]
# ["sharkdp/fd"]

# Batch reinstall
eget --download-all
```

## Troubleshooting

### "Could not start dynamically linked executable"

This means the binary wasn't patched. The wrapper script should handle this automatically.

**Solution:** Ensure the fish function is loaded:
```bash
# Apply Home Manager changes
userup

# Restart fish shell or run:
source ~/.config/fish/config.fish
```

### "asset `amd64` not found"

Different projects use different architecture names. Check the actual asset names on GitHub.

**Solution:** Update `eget.toml` with correct architecture name:
```toml
["author/repo"]
asset_filters = ["linux", "x86_64"]  # Try x86_64 instead of amd64
```

### Directory doesn't exist in new environment

The wrapper script automatically creates `~/.local/bin` if it doesn't exist.

**Manual fix:**
```bash
mkdir -p ~/.local/bin
```

### Wrapper script not found

This means the fish function can't find the wrapper script.

**Check:**
```bash
ls -la ~/.config/nixos/scripts/eget-nixos-wrapper.sh
```

If missing, the repository might not be synced properly.

### patchelf not found

`patchelf` is required for binary patching and should be installed via Home Manager.

**Check:**
```bash
command -v patchelf
```

If not found, ensure `patchelf` is in `home.packages` in `home-base.nix`.

## Architecture-Specific Notes

### Static vs Dynamic Binaries

- **Static binaries** (Go, Rust): Often work without patching
- **Dynamic binaries** (C, C++): Require patching for NixOS

The wrapper script handles both cases automatically.

### Common Architecture Names

Check GitHub releases to find the correct architecture name:
- `amd64` or `x86_64` - 64-bit Intel/AMD
- `arm64` or `aarch64` - 64-bit ARM
- `armv7` or `armv7l` - 32-bit ARM

## Advanced Usage

### Installing from Direct URLs

```bash
eget https://example.com/tool.tar.gz --file tool --to ~/.local/bin
```

### Installing Specific Files from Archives

```bash
# Extract only specific files
eget author/repo --file "specific-binary"
```

### Upgrading Only

```bash
# Only download if newer version exists
eget author/repo --upgrade-only
```

## File Structure

```
~/.config/nixos/
├── eget.toml                    # Configuration file
├── scripts/
│   └── eget-nixos-wrapper.sh   # Patching wrapper
└── home-base.nix               # Fish function & env vars

~/.local/bin/                   # Installed binaries
├── purple
├── fzf
└── ...

~/.config/eget/
└── eget.toml -> ~/.config/nixos/eget.toml  # Managed symlink
```

## Benefits

1. **Automatic NixOS patching** - No manual `patchelf` commands needed
2. **Centralized configuration** - All tools defined in one file
3. **Easy reinstallation** - `eget --download-all` restores everything
4. **Git-tracked configs** - Tool definitions version controlled
5. **Cross-system sync** - Same tools on all your machines

## Related Links

- [Eget GitHub Repository](https://github.com/zyedidia/eget)
- [Eget Documentation](https://github.com/zyedidia/eget/blob/master/DOCS.md)
- [NixOS Dynamic Executables Guide](https://nix.dev/permalink/stub-ld)
