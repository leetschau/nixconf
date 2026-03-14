# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Open ports in the firewall.
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking = {
    hostName = "nix2505";
    useDHCP = false;
    networkmanager.enable = true;
    interfaces.ens18.ipv4.addresses = [{
      address = "10.160.43.22";
      prefixLength = 24;
    }];

    defaultGateway = "10.160.43.1";
    nameservers = [ "10.160.31.231" "8.8.8.8" ];
    firewall.allowedTCPPorts = [ 4444 5555 6666 7777 ];
  };
  services.cloud-init.enable = false;

  # Set your time zone.
  time.timeZone = "Asia/HongKong";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.shell = pkgs.bash;
  users.users.leo = {
    isNormalUser = true;
    home = "/home/leo";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      # starship
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/hAd9cYKzwOp1a2ZWFeBe23uAPpEXlfTG/7/ANHdcs44XPuxdM7WjvaYK1+Dh9T525YJ+hjwwTgNDJkSdgg64t7HpzLwoFKV9So5mGCQSe6UuTl28JJnVFOirEE/0kjzLN4Jcyx76FdwlghE9IHZDJYuntLk/2C/+wjBHfJDyFUjOmy1J34RSXhYPrP2DtsLL7JOFxMBVjZ6xmZTyOuNoyMBDqKIHTJERayus08r4EHDbM/upEHMQ245TcLmwM7DHzI1fkDyue6NfXrwaKUPbb2EcA+yKO8sJWztXW17V/MjjykdL3hbAEwrkjd+R1a08I6FEVrRtT32bw9cijtv8Rslob62t9PYUC5GFwUrGPa2sb9NaqApzPoxuEs8c9a8v+CtduQzicx+6FLixiEoAjhUyBag3tCrrZu+LTjYT/GpPO49qfL4K2yMIOfIIgsw6F7racCkRFsVM/G7AubAKgSt4ds05uWRDz+NJ0cGhp8aTCk7oxy3nRuyPYw7Yx8= leo@labrint2"
    ];
  };

  # programs.firefox.enable = true;
  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    neovim
    git
    htop
    curl
    tree
    fish
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };


  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

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
}
