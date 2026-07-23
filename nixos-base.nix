{ config, pkgs, ... }:

{
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  users.users.leo = {
    isNormalUser = true;
    description = "Leo";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  security.sudo.extraRules = [
    {
      users = [ "leo" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  programs.fish.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "a0cbf4b62af9b50f" ];
  };

  environment.systemPackages = with pkgs; [
    curl
    fish
    git
    home-manager
    htop
    neovim
    tree
    unzip
    vim
    wget
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://cache.nixos.org" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "25.11"; 
}
