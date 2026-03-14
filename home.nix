{ pkgs, ... }: {
  home.username = "leo";
  home.homeDirectory = "/home/leo";
  home.stateVersion = "24.11"; 

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
    PYTHONIOENCODING = "utf-8";
  };

  programs.home-manager.enable = true;

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
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
    '';
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      nd = "nix develop";
      nixup = "sudo HTTP_PROXY=http://10.160.43.82:7897 HTTPS_PROXY=http://10.160.43.82:7897 nixos-rebuild switch --flake ~/.config/nixos#nix2505";
      userup = "HTTP_PROXY=http://10.160.43.82:7897 HTTPS_PROXY=http://10.160.43.82:7897 home-manager switch --flake ~/.config/nixos#leo";
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
      hx = "~/.local/opt/helix/hx";
      kak = "~/.local/opt/kakoune/src/kak";
      mm = "micromamba";
      vi = "nvim";
      pa = "sudo pacman";
      pd = "podman";
      py = "python3";
      op = "rifle";
      ra = "ranger";
      l = "ls -la";
      lt = "ls -lt";
      tl = "tmux ls";
      ta = "tmux -u attach -t";
      tn = "tmux -u new -A -s";
      va = "vagrant";
      zl = "zellij";
    };
  };

  home.packages = with pkgs; [
    pkgs.comma
    ripgrep
    miller
    xan
    jq
    htop
    pkgs.gemini-cli
  ];
}
