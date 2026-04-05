{
  description = "Leo's Personalized NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-index-database, agenix, ... }@inputs: {
    nixosConfigurations.dell-e7450 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./nixos-dell-e7450.nix
      ];
    };

    nixosConfigurations.headless = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./nixos-headless.nix
      ];
    };

    homeConfigurations."desktop" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home-desktop.nix
        nix-index-database.homeModules.nix-index
        agenix.homeManagerModules.default
      ];
    };

    homeConfigurations."headless" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home-headless.nix
        nix-index-database.homeModules.nix-index
        agenix.homeManagerModules.default
      ];
    };
  };
}
