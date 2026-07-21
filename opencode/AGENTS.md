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

## Web Proxy Configuration (GFW-banned / GitHub Sites)
Some websites are blocked by the GFW (e.g. github.com, patents.google.com, and other
offshore resources). Fetch them through the proxy server:
- **Proxy URL**: `http://192.168.1.123:7897`
- This applies to all github.com, api.github.com, and other GFW-banned requests

### How to Use
The `webfetch` tool has no proxy parameter, so it CANNOT be used for GFW-banned sites.
Instead, use the Bash tool with `curl` through the proxy:

```bash
# Download HTML/markdown through the proxy
curl -s --proxy http://192.168.1.123:7897 <url>
# or with https_proxy env var
https_proxy=http://192.168.1.123:7897 http_proxy=http://192.168.1.123:7897 curl -sL <url>
```

### Examples
- GitHub repositories, raw files, or API content: route through `http://192.168.1.123:7897`
- patents.google.com: route through `http://192.168.1.123:7897`
- Any other offshore URL that times out: route through `http://192.168.1.123:7897`
