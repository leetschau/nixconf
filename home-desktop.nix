{ pkgs, ... }: {
  imports = [
    ./home-base.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    remmina
    clash-verge-rev
  ];

  xdg.configFile."konsolerc".source = ./konsole/konsolerc;
  xdg.dataFile."konsole/leo.profile".source = ./konsole/leo.profile;
}
