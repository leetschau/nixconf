{ pkgs, ... }: {
  imports = [
    ./home-base.nix
  ];

  home.packages = with pkgs; [
    fx
    glow
    google-cloud-sdk
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
    visidata
    xan
  ];

  programs.fish = {
    shellAbbrs = {
      pd = "podman";
      pdc = "podman-compose";
      docker = "podman";
      va = "vagrant";
      gemini = "http_proxy=http://10.160.43.82:7897 https_proxy=http://10.160.43.82:7897 gemini";
    };
  };
}
