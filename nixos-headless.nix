{ config, lib, pkgs, ... }:

{
  imports = [
    ./nixos-base.nix
    ./hardware-headless.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.kernelParams = [ "console=ttyS0,115200" ];

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
    firewall.allowedTCPPorts = [
      4040 4444 5252 5555 6464 6666 7123 7777 8000 8080 8222
    ];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "min protocol" = "SMB2";
        workgroup = "WORKGROUP";
        "server string" = "nixos-samba";
        security = "user";
        "map to guest" = "bad user";
      };
      leo = {
        path = "/home/leo";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "leo";
      };
    };
  };

  services.xserver.enable = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  users.users.leo.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCx/hAd9cYKzwOp1a2ZWFeBe23uAPpEXlfTG/7/ANHdcs44XPuxdM7WjvaYK1+Dh9T525YJ+hjwwTgNDJkSdgg64t7HpzLwoFKV9So5mGCQSe6UuTl28JJnVFOirEE/0kjzLN4Jcyx76FdwlghE9IHZDJYuntLk/2C/+wjBHfJDyFUjOmy1J34RSXhYPrP2DtsLL7JOFxMBVjZ6xmZTyOuNoyMBDqKIHTJERayus08r4EHDbM/upEHMQ245TcLmwM7DHzI1fkDyue6NfXrwaKUPbb2EcA+yKO8sJWztXW17V/MjjykdL3hbAEwrkjd+R1a08I6FEVrRtT32bw9cijtv8Rslob62t9PYUC5GFwUrGPa2sb9NaqApzPoxuEs8c9a8v+CtduQzicx+6FLixiEoAjhUyBag3tCrrZu+LTjYT/GpPO49qfL4K2yMIOfIIgsw6F7racCkRFsVM/G7AubAKgSt4ds05uWRDz+NJ0cGhp8aTCk7oxy3nRuyPYw7Yx8= leo@labrint2"
  ];
}
