{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-headless-thinkcentre.nix
      ./nixos-base.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkcentre"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  # For example, set IPv4 address to "192.168.1.82", etc.
  networking.networkmanager.enable = true;

  # No system-wide proxy. Use `pon`/`poff` in fish shells to toggle it per session.
  # The nix daemon keeps the proxy so substituter downloads still work.
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://192.168.1.123:7897";
    https_proxy = "http://192.168.1.123:7897";
    no_proxy = "127.0.0.1,localhost";
  };

  # NAS: lazy-mount via systemd so boot never blocks if the NAS is offline.
  fileSystems."/mnt/nas" = {
    device = "192.168.1.123:/volume1/Public";
    fsType = "nfs";
    options = [
      "rw"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "noatime"
      "x-gvfs-hide"
    ];
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  services.xserver.xkb.layout = "us";
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
  # users.users.leo = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   home = "/home/leo";
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  virtualisation.podman = {    
    enable = true;    
    dockerCompat = true;    
    defaultNetwork.settings.dns_enabled = true;    
  };

  # mlops-demo VM host support (managed by ~/docs/mlops-demo, see its README)
  virtualisation.libvirtd.enable = true;
  # DNAT: fixed host ports -> mlops VM (192.168.100.10 on libvirt net "mlops", bridge virbr1)
  networking.nat = {
    enable = true;
    internalInterfaces = [ "virbr1" ];
    externalInterface = "wlp0s20f0u6";
    forwardPorts = [
      { sourcePort = 3000; destination = "192.168.100.10:3000"; proto = "tcp"; }
      { sourcePort = 5000; destination = "192.168.100.10:5000"; proto = "tcp"; }
      { sourcePort = 9000; destination = "192.168.100.10:9000"; proto = "tcp"; }
      { sourcePort = 9001; destination = "192.168.100.10:9001"; proto = "tcp"; }
      { sourcePort = 2222; destination = "192.168.100.10:22"; proto = "tcp"; }
    ];
  };
  # libvirt's LIBVIRT_FWI chain rejects externally-initiated DNAT'd flows into the NAT net;
  # pre-empt it with an early ACCEPT for the mlops VM
  networking.nat.extraCommands = ''
    iptables -w -I FORWARD 1 -d 192.168.100.10 -j ACCEPT
  '';
  # this host's TPM is unusable; upstream secret-encryption init crashes systemd-creds (TPM path).
  # Keep the same logic but encrypt with the local host key instead of TPM:
  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart =
    lib.mkForce [
      ""
      "/run/current-system/sw/bin/sh -c 'mkdir -p /var/lib/libvirt/secrets && dd if=/dev/urandom status=none bs=32 count=1 | systemd-creds encrypt --with-key=host --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key'"
    ];
  # repeated switches trigger start-rate-limit cascades on these oneshots; disable the limiter
  systemd.services.virt-secret-init-encryption.unitConfig.StartLimitIntervalSec = 0;
  systemd.services.libvirtd-config.unitConfig.StartLimitIntervalSec = 0;
  users.users.leo.extraGroups = [ "libvirtd" ];

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
  # system.stateVersion = "25.11"; # Did you read the comment?

}

