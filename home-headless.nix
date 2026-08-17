{ pkgs, ... }: {
  imports = [
    ./home-base.nix
  ];

  home.packages = with pkgs; [
    fx
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
      gemini = "pon; gemini";
    };
  };
}
