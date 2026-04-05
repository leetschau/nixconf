{ pkgs, ... }: {
  imports = [
    ./home-base.nix
  ];

  home.packages = with pkgs; [
    google-chrome
    remmina
    clash-verge-rev
    calibre
  ];

  xdg.configFile."hypr".source = ./hyprland;
  xdg.configFile."waybar/config".source = ./waybar/config;
  xdg.configFile."waybar/style.css".source = ./waybar/style.css;
  xdg.configFile."konsolerc".source = ./konsole/konsolerc;
  xdg.dataFile."konsole/leo.profile".source = ./konsole/leo.profile;
}
