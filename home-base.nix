{ pkgs, lib, config, inputs, ... }: {
  imports = [
    ./nvim
  ];

  nixpkgs.config.allowUnfree = true;
  home.username = "leo";
  home.homeDirectory = "/home/leo";
  home.stateVersion = "24.11"; 

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/share/go/bin"
  ];

  home.sessionVariables = {
    PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
    PYTHONIOENCODING = "utf-8";
    GOPATH = "$HOME/.local/share/go";
    EGET_BIN = "$HOME/.local/bin";
  };

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
      bind -M insert ctrl-g history-token-search-backward
      function take --description "Create directory and cd into it"
        mkdir -p $argv[1]; and cd $argv[1]
      end
    '';
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
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
      l = "ls -la";
      ll = "ls -l";
      lt = "ls -ltr";
      mm = "micromamba";
      nd = "nix develop";
      nixup = "sudo nixos-rebuild switch --flake ~/.config/nixos#headless";
      op = "rifle";
      py = "python3";
      ra = "ranger";
      userup = "home-manager switch --flake ~/.config/nixos#headless";
      wtf = "wtfutil";
      zl = "zellij";
    };
    functions = {
      eget = ''
        set -l eget_wrapper ~/.config/nixos/scripts/eget-nixos-wrapper.sh
        if test -f $eget_wrapper
          $eget_wrapper $argv
        else
          command eget $argv
        end
      '';
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
      alias = {
        search-history = "!f() { pattern=$1; shift; git_flags=\"--all --oneline --color=always\"; grep_flags=\"-C 5 --color=always\"; for arg in \"$@\"; do if [ \"$arg\" = \"-i\" ]; then git_flags=\"$git_flags -i\"; grep_flags=\"$grep_flags -i\"; elif [ \"$arg\" = \"-w\" ]; then grep_flags=\"$grep_flags -w\"; pattern=\"\\\\b$pattern\\\\b\"; else git_flags=\"$git_flags $arg\"; fi; done; git log -E -G \"$pattern\" $git_flags | fzf --ansi --preview \"git show --color=always {1} | grep $grep_flags '$pattern'\"; }; f";
      };
      user.name = "Leo";
      user.email = "leetschau@gmail.com";
      init.defaultBranch = "master";
      credential.helper = "cache";
    };
  };

  programs.home-manager.enable = true;

  programs.nix-index-database.comma.enable = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        before_repo_root_style = "dimmed cyan";
        repo_root_style = "bold underline cyan";
      };
    };
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

  home.packages = with pkgs; [
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    age
    bat
    bc
    dos2unix
    eget
    fd
    file
    gemini-cli
    hack-font
    htop
    jid
    jless
    jq
    nettools
    nodejs
    opencode
    p7zip
    patchelf
    pet
    ranger
    rclone
    ripgrep
    wiper
    wtfutil
    yt-dlp
    zip
  ];

  xdg.configFile."ranger/rifle.conf".source = ./rifle.conf;
  xdg.configFile."zellij/config.kdl".source = ./zellij-config.kdl;
  xdg.configFile."eget/eget.toml".source = ./eget.toml;
  xdg.configFile."opencode".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos/opencode";

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/master_age_key.txt" ];
  age.secrets."rclone.conf" = {
    file = ./secrets/rclone.conf.age;
    path = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
  };
  age.secrets."pet-config" = {
    file = ./secrets/pet-config.age;
    path = "${config.home.homeDirectory}/.config/pet/config.toml";
  };
}
