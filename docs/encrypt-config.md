# Encrypting Config Files with Agenix

## File Reference
* `./secrets.nix`: Only for **encryption** (maps `.age` files to authorized public keys).
* `./secrets/*.age`: The actual **encrypted secrets** (safe to commit to Git).
* `./home.nix`: Only for **decryption** (defines the final destination and private key path).
* `~/.ssh/master_age_key.txt`: Your **private key** (MUST NOT be committed to Git).

Follow this workflow to add or edit encrypted secrets (like `rclone.conf`) in your Home Manager configuration.

## 1. Create or Edit the Secret
Run the `agenix` CLI from the **root of your configuration** (where `secrets.nix` is located).

```bash
# From ~/.config/nixos
agenix -e secrets/new-secret.age
```
*Paste your secrets, save, and exit. Agenix will encrypt the file automatically.*

## 2. Update `secrets.nix`
Tell `agenix` which public keys are authorized to edit the new file by adding it to the mapping. Ensure you use the full relative path to the `.age` file:

```nix
{
  "secrets/new-secret.age".publicKeys = [ leo ];
}
```

## 3. Register the Secret in `home.nix`
Add the secret mapping to the `age.secrets` block in `home.nix`:

```nix
age.secrets."friendly-name" = {
  file = ./secrets/new-secret.age;
  path = "${config.home.homeDirectory}/.config/app/destination.conf";
};
```

## 4. Stage and Deploy
Nix Flakes ignore files that are not tracked by Git. You **must** stage the new `.age` file before applying changes.

```bash
git add secrets/new-secret.age
userup
```
