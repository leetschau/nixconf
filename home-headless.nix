{ pkgs, ... }: {
  imports = [
    ./home-base.nix
  ];

  home.packages = with pkgs; [
    fx
    glow
    gping
    hyperfine
    mamba
    miller
    mise
    navi
    podman
    podman-compose
    podman-tui
    tldr
    uv
    xan
  ];

  home.sessionVariables = {
    http_proxy = "http://10.160.43.82:7897";
    https_proxy = "http://10.160.43.82:7897";
    HTTP_PROXY = "http://10.160.43.82:7897";
    HTTPS_PROXY = "http://10.160.43.82:7897";
  };

  programs.fish = {
    shellAbbrs = {
      pd = "podman";
      pdc = "podman-compose";
      docker = "podman";
      va = "vagrant";
    };
  };
}
