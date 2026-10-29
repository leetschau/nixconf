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
    shellInit = ''
      if test -f ${config.age.secrets."glm-api-key".path}
        set -gx ZHIPU_API_KEY (cat ${config.age.secrets."glm-api-key".path} | string trim)
      end
    '';
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
      op = "rifle";
      py = "python3";
      ra = "ranger";
      wtf = "wtfutil";
      zl = "zellij";
    };
    functions = {
      pon = ''
        set -gx http_proxy http://192.168.1.123:7897
        set -gx https_proxy $http_proxy
        set -gx all_proxy $http_proxy
        set -gx HTTP_PROXY $http_proxy
        set -gx HTTPS_PROXY $http_proxy
        set -gx ALL_PROXY $http_proxy
        set -gx no_proxy "127.0.0.1,localhost,internal.domain"
        set -gx NO_PROXY $no_proxy
        echo "proxy on -> $http_proxy"
      '';
      poff = ''
        set -e http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY no_proxy NO_PROXY
        echo "proxy off"
      '';
      nixup = ''
        set -l flake ~/.config/nixos
        set -l this_host (hostname)

        set -l nixos_target
        set -l home_target
        switch $this_host
          case thinkcentre
            set nixos_target headless-thinkcentre
            set home_target headless
          case nix2505
            set nixos_target headless-wired
            set home_target headless
          case dell-e7450
            set nixos_target dell-e7450
            set home_target desktop
          case "*"
            echo "nixup: unknown hostname '$this_host', cannot auto-detect targets" >&2
            echo "Usage: nixup --list | nixup <target>" >&2
            return 1
        end

        if test (count $argv) -gt 0
          set -l nixos_targets (nix eval --raw $flake#nixosConfigurations \
            --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' 2>/dev/null)
          set -l home_targets (nix eval --raw $flake#homeConfigurations \
            --apply 'x: builtins.concatStringsSep "\n" (builtins.attrNames x)' 2>/dev/null)

          if test $argv[1] = --list
            echo "NixOS targets:"
            printf '  %s\n' $nixos_targets
            echo "Home-manager targets:"
            printf '  %s\n' $home_targets
            echo "Usage: nixup [target]  (no args = detect uncommitted changes)"
            return 0
          end

          set -l target $argv[1]
          if contains -- $target $nixos_targets
            sudo nixos-rebuild switch --flake $flake#$target
          else if contains -- $target $home_targets
            home-manager switch --flake $flake#$target
          else
            echo "nixup: unknown target '$target' (run nixup --list)" >&2
            return 1
          end
          return 0
        end

        if not git -C $flake rev-parse --is-inside-work-tree >/dev/null 2>&1
          echo "nixup: $flake is not a git repo" >&2
          return 1
        end

        set -l files
        for line in (git -C $flake status --porcelain --untracked-files=all)
          set -l f (string sub --start=4 -- $line)
          if string match -q "* -> *" -- $f
            set f (string split -r -m1 " -> " -- $f)[2]
          end
          set -a files $f
        end

        if test (count $files) -eq 0
          echo "nixup: no uncommitted changes in $flake"
          return 0
        end

        set -l do_nixos 0
        set -l do_home 0
        set -l skipped
        for f in $files
          if test $f = flake.nix; or test $f = flake.lock
            set do_nixos 1
            set do_home 1
            continue
          end
          set -l host ""
          switch $f
            case "nixos-dell-e7450.nix" "hardware-dell-e7450.nix"
              set host dell-e7450
            case "nixos-headless-wired.nix" "hardware-headless-wired.nix"
              set host headless-wired
            case "nixos-headless-thinkcentre.nix" "hardware-headless-thinkcentre.nix"
              set host headless-thinkcentre
            case "nixos-base.nix"
              set host ALL
          end
          if test -n "$host"
            if test $host = ALL; or test $host = $nixos_target
              set do_nixos 1
            else
              set -a skipped "$host (NixOS)"
            end
            continue
          end
          switch $f
            case "home-desktop.nix"
              set host desktop
            case "home-headless.nix"
              set host headless
            case "*"
              set host BOTH
          end
          if test $host = BOTH; or test $host = $home_target
            set do_home 1
          else
            set -a skipped "$host (home-manager)"
          end
        end

        set -l cmds
        if test $do_nixos -eq 1
          set -a cmds "sudo nixos-rebuild switch --flake $flake#$nixos_target"
        end
        if test $do_home -eq 1
          set -a cmds "home-manager switch --flake $flake#$home_target"
        end

        echo "Uncommitted changes:"
        printf '  %s\n' $files
        echo
        if test (count $skipped) -gt 0
          echo "Affecting other hosts (skipped): "(string join ", " $skipped)
          echo
        end

        if test (count $cmds) -eq 0
          echo "Nothing to rebuild on this host ($this_host)."
          return 0
        end

        echo "Will run on $this_host:"
        printf '  %s\n' $cmds
        echo "Run? [y/N]"
        read -l confirm
        if not test "$confirm" = y; and not test "$confirm" = Y
          echo "Aborted."
          return 1
        end
        for c in $cmds
          echo "==> $c"
          eval $c; or return 1
        end
      '';
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
    gh
    hack-font
    htop
    jid
    jless
    jq
    mdcat
    nettools
    nodejs
    opencode
    p7zip
    patchelf
    pet
    ranger
    rclone
    ripgrep
    treemd
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
  age.secrets."glm-api-key" = {
    file = ./secrets/glm-api-key.age;
    path = "${config.home.homeDirectory}/.local/share/secrets/glm-api-key";
  };
}
