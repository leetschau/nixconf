#!/usr/bin/env bash
# Wrapper script for eget that automatically patches binaries for NixOS compatibility

set -e

EGET_BIN="${EGET_BIN:-$HOME/.local/bin}"
PATCHELF=$(command -v patchelf || find /nix/store -name patchelf -type f 2>/dev/null | head -1)

if [ -z "$PATCHELF" ]; then
    echo "Error: patchelf not found. Install it with: nix-shell -p patchelf"
    exit 1
fi

# Create EGET_BIN directory if it doesn't exist
if [ ! -d "$EGET_BIN" ]; then
    echo "Creating directory: $EGET_BIN"
    mkdir -p "$EGET_BIN"
fi

# Run eget with all arguments
if ! eget "$@"; then
    echo "Error: eget failed to download. Aborting."
    exit 1
fi

# Find and patch all binaries in EGET_BIN that are not shell scripts
find "$EGET_BIN" -type f -executable | while read -r binary; do
    # Skip if already patched or is a script
    if head -1 "$binary" | grep -qE "^(#!|ELF)" && ! head -1 "$binary" | grep -q "#!"; then
        echo "Patching $binary for NixOS..."
        
        # Get current interpreter
        interpreter=$($PATCHELF --print-interpreter "$binary" 2>/dev/null || true)
        
        # Set correct NixOS interpreter if needed
        if [[ "$interpreter" == /lib64/* ]]; then
            # Find glibc in nix store
            glibc_ld=$(find /nix/store -name "ld-linux-x86-64.so.2" 2>/dev/null | head -1)
            if [ -n "$glibc_ld" ]; then
                $PATCHELF --set-interpreter "$glibc_ld" "$binary"
            fi
        fi
        
        # Add common library paths to rpath
        current_rpath=$($PATCHELF --print-rpath "$binary" 2>/dev/null || echo "")
        
        # Find common libraries
        openssl_lib=$(find /nix/store -name "libssl.so.3" -exec dirname {} \; 2>/dev/null | head -1)
        glibc_lib=$(find /nix/store -name "libc.so.6" -exec dirname {} \; 2>/dev/null | head -1)
        
        new_rpath="$current_rpath"
        if [ -n "$openssl_lib" ] && [[ ! "$new_rpath" == *"$openssl_lib"* ]]; then
            new_rpath="$openssl_lib${new_rpath:+:$new_rpath}"
        fi
        if [ -n "$glibc_lib" ] && [[ ! "$new_rpath" == *"$glibc_lib"* ]]; then
            new_rpath="$glibc_lib${new_rpath:+:$new_rpath}"
        fi
        
        if [ -n "$new_rpath" ]; then
            $PATCHELF --set-rpath "$new_rpath" "$binary"
        fi
        
        echo "✓ Patched $binary"
    fi
done

echo "All binaries patched for NixOS!"
