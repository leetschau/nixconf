{ pkgs, ... }: {
  imports = [
    ./options.nix
    ./ui.nix
    ./coding.nix
    ./lsp.nix
    ./utils.nix
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    
    # Core extra packages that were previously in home-base.nix
    extraPackages = with pkgs; [
      gcc
      gnumake
      curl
      fd
      ripgrep
      unzip
      wget
      cargo
      go
      python3
      rustc
    ];
  };
}
