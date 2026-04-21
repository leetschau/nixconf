# Nix Development Environment Rules

## Environment Detection
- Check for `flake.nix` or `shell.nix` in project root
- If found, this is a Nix-based project

## Command Wrapping
When a Nix development environment is detected, ALL development tool commands must be prefixed with:
`nix develop --command <tool>`

### Tools to Wrap
- **Python**: `python`, `python3`, `pip`, `python3 -m pip`, `pytest`, `black`, `ruff`
- **Node.js**: `node`, `npm`, `npx`, `yarn`, `pnpm`, `bun`
- **Rust**: `cargo`, `rustc`
- **Go**: `go`
- **Other**: `make`, `cmake`, `gcc`, `clang`

### Examples
- ❌ `python script.py`
- ✅ `nix develop --command python script.py`

- ❌ `npm install`
- ✅ `nix develop --command npm install`

### Exception
- Git commands (`git add`, `git commit`, etc.) should NOT be wrapped
- Shell builtins (`cd`, `ls`, `cat`, etc.) should NOT be wrapped

## GitHub Proxy Configuration
When fetching content from GitHub using webfetch, use the proxy server:
- **Proxy URL**: `http://10.160.43.82:7897`
- This applies to all github.com and api.github.com requests

### Examples
- When using webfetch to fetch GitHub repositories, raw files, or API content, route through the proxy
- Example proxy usage pattern: ensure GitHub requests are proxied through `http://10.160.43.82:7897`
