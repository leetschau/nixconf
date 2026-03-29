{ pkgs, lib, config, inputs, ... }: {
  home.username = "leo";
  home.homeDirectory = "/home/leo";
  home.stateVersion = "24.11"; 

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/share/go/bin"
  ];

  home.sessionVariables = {
    PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
    PYTHONIOENCODING = "utf-8";
    GOPATH = "$HOME/.local/share/go";
    # HTTP_PROXY = "http://192.168.1.123:7897";
    # HTTPS_PROXY = "http://192.168.1.123:7897";
  };

  programs.home-manager.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      navigate = true;
      dark = true;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
      fish_vi_key_bindings
      function take --description "Create directory and cd into it"
        mkdir -p $argv[1]; and cd $argv[1]
      end
    '';
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      nd = "nix develop";
      nixup = "sudo nixos-rebuild switch --flake ~/.config/nixos#nix2505";
      userup = "home-manager switch --flake ~/.config/nixos#leo";
    };
    shellAbbrs = {
      ga = "git add -A";
      gs = "git status";
      gci = "git commit -m";
      gd = "git diff";
      gl = "git log --stat --decorate";
      glg = "git log --all --decorate --oneline --graph";
      gco = "git checkout";
      gph = "git push";
      gpl = "git pull";
      che = "chezmoi";
      mm = "micromamba";
      pd = "podman";
      py = "python3";
      op = "rifle";
      ra = "ranger";
      l = "ls -la";
      lt = "ls -lt";
      va = "vagrant";
      zl = "zellij";
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "Leo";
      user.email = "leetschau@gmail.com";
      init.defaultBranch = "master";
      credential.helper = "cache";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      # Build tools for Tree-sitter and other plugins
      gcc
      gnumake
      # Common utilities used by Neovim plugins
      curl
      fd
      ripgrep
      stylua
      unzip
      wget
      # Language environments for LSP/formatters/linters
      cargo
      go
      lua-language-server
      python3
      rustc
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = [ "--cmd j" ];
  };

  programs.nix-index-database.comma.enable = true;

  home.packages = with pkgs; [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    age
    bat
    dos2unix
    fd
    htop
    jq
    nodejs
    opencode
    pet
    hack-font
    ranger
    rclone
    ripgrep
  ];

  xdg.configFile."pet/config.toml".source = ./pet/config.toml;
  xdg.configFile."pet/snippet.toml".source = ./pet/snippet.toml;

  xdg.configFile."ranger/rifle.conf".source = ./rifle.conf;

  xdg.configFile."zellij/config.kdl".source = ./zellij-config.kdl;

  xdg.configFile."konsolerc".source = ./konsole/konsolerc;
  xdg.dataFile."konsole/leo.profile".source = ./konsole/leo.profile;

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/master_age_key.txt" ];
  age.secrets."rclone.conf" = {
    file = ./secrets/rclone.conf.age;
    path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
  };

}
