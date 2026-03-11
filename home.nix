{ pkgs, ... }: {
  home.stateVersion = "24.11"; 

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
    shellAliases = {
      ll = "ls -l";
      ".." = "cd ..";
      nd = "nix develop";
      nixup = "sudo HTTP_PROXY=http://10.160.43.82:7897 HTTPS_PROXY=http://10.160.43.82:7897 nixos-rebuild switch --flake /etc/nixos#nix2505";
    };
  };

  home.packages = with pkgs; [
    pkgs.comma
    ripgrep
    miller
    xan
    jq
    fzf
    htop
  ];
}
