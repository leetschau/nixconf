# Provision NixOS System

```bash
cd /etc/
sudo git clone git@bitbucket.org:leechau/nix-configurations.git nixos

sudo chgrp -R users /etc/nixos  # `users` is the group of the current user, use `id` to verify
sudo chmod -R g+w /etc/nixos

git config --global --add safe.directory /etc/nixos

sudo HTTP_PROXY=http://10.160.43.82:7897 \
    HTTPS_PROXY=http://10.160.43.82:7897 \
    nixos-rebuild switch --flake .#nix2505
```
