# Troubleshootings

## Hyprland

### WiFi password not persisting after suspend/resume

**Symptom:** After waking from sleep in Hyprland, NetworkManager prompts for the WiFi password instead of auto-connecting.

**Cause:** NetworkManager stores WiFi secrets in the user session keyring (e.g. KDE Wallet, GNOME Keyring). After suspend/resume, the keyring may be locked or unavailable, so NetworkManager cannot retrieve the password.

**Fix:** Disable PolicyKit auth for NetworkManager so it stores secrets system-wide instead of per-user:

```nix
networking.networkmanager = {
  enable = true;
  settings."main" = {
    auth-polkit = false;
  };
};
```

If above method doesn't work, you can run the following command to persist the specified <SSID>:
`sudo nmcli connection modify "<SSID>" 802-11-wireless-security.psk-flags 0`

### Suspend on lid close

**Goal:** Make the system sleep when the laptop lid is closed.

**Fix:** Add the following to your Hyprland keybinds config (e.g. `keybinds.conf`):

```
bindl = , switch:on:Lid Switch, exec, systemctl suspend
```

- `bindl` — locked bind, works even when the screen is locked
- `switch:on:Lid Switch` — hardware switch event, fires when lid closes
- `exec, systemctl suspend` — suspends the system to RAM

Note: this dosn't work on my Dell E7450 laptop when a HDMI monitor connected.
