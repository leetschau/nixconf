# Encrypting Config Files with Agenix

## File Reference
* `./secrets.nix`: Only for **encryption** (maps `.age` files to authorized public keys).
* `./secrets/*.age`: The actual **encrypted secrets** (safe to commit to Git).
* `./home.nix`: Only for **decryption** (defines the final destination and private key path).
* `~/.ssh/master_age_key.txt`: Your **private key** (MUST NOT be committed to Git).

## Create a New Encrypted File

Follow the following workflow to add or edit encrypted secrets (like `rclone.conf`)
in your Home Manager configuration.

Step 1: Create the Encrypted File:

Run the `agenix` CLI from the **root of your configuration** (where `secrets.nix` is located):
```bash
cd ~/.config/nixos
agenix -i ~/.ssh/master_age_key.txt -e secrets/new-secret.age
```

Paste your secrets, save, and exit. Agenix will encrypt the file automatically.

Step 2: Update `secrets.nix`

Tell `agenix` which public keys are authorized to edit the new file by adding it to the mapping.
Ensure you use the full relative path to the `.age` file:
```nix
{
  "secrets/new-secret.age".publicKeys = [ leo ];
}
```

Step 3: Register the Secret in `home.nix`:

Add the secret mapping to the `age.secrets` block in `home.nix`:
```nix
age.secrets."friendly-name" = {
  file = ./secrets/new-secret.age;
  path = "${config.home.homeDirectory}/.config/app/destination.conf";
};
```

## Update An Existing Encrypted File

You need to update the encrypted file manually and validate it:
```fish
agenix -i ~/.ssh/master_age_key.txt -e secrets/pet-config.age
home-manager switch --flake ~/.config/nixos#headless
```

Note: if the configuration file is updated by the app itself, for example `rclone config`,
you have to open the nix-managed configuration file in the <EDITOR> with above `agenix -i ...`,
then copy the contents from ~/.config/rclone/rclone.conf into this editor, save and exit.
Without this step, you new configurations in ~/.config/rclone/rclone.conf will be overwritten
by the encrypted (old) version after `home-manager switch ...`.

## Stage and Deploy

Nix Flakes ignore files that are not tracked by Git.
A new `.age` file must be added into the git repo before applying changes:
```bash
git add secrets/new-secret.age
userup
```

`userup` is necessary for both creating and updating secret files.
