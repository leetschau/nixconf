# Provision NixOS System

```bash
sudo mv /etc/nixos /etc/nixos-bak
sudo git clone git@bitbucket.org:leechau/nix-configurations.git /etc/nixos

id  # get the group of the current user, here it is `users`
sudo chgrp -R users /etc/nixos
sudo chmod -R g+w /etc/nixos

git config --global --add safe.directory /etc/nixos

sudo HTTP_PROXY=http://10.160.43.82:7897 \
    HTTPS_PROXY=http://10.160.43.82:7897 \
    nixos-rebuild switch --flake /etc/nixos#nix2505
```
