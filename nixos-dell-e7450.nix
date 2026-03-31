{ config, pkgs, ... }:

{
  imports = [
    ./nixos-base.nix
    ./hardware-dell-e7450.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "dell-e7450";
    useDHCP = false;
    networkmanager.enable = true;
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.1.24";
      prefixLength = 24;
    }];

    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "4.2.2.2" ];
    firewall.allowedTCPPorts = [
      4444 5555 6666 7777 
    ];
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  users.users.leo.packages = with pkgs; [
    kdePackages.kate
  ];
}
