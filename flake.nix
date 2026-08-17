{
  description = "System-as-Code: Universal Environment";

  inputs = {
    # Stable channel — manually bump to the next release (nixos-26.05 etc.)
    # when you're ready to audit the release notes.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      # Track the branch that matches nixpkgs above. Bump both together when
      # upgrading to the next NixOS release.
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      # Pinned to release branch matching home-manager above. Bump together.
      url = "github:catppuccin/nix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-terraform129.url = "github:nixos/nixpkgs/17f716dbf88d1c224e3a62d762de4aaea375218e";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, catppuccin, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-tf129 = import inputs.nixpkgs-terraform129 { inherit system; };
      mkNixos = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs pkgs-unstable; };
        modules = [
          hostPath
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit inputs pkgs-unstable pkgs-tf129; };
            home-manager.sharedModules = [
              catppuccin.homeModules.catppuccin
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users.nicolas = import (builtins.dirOf hostPath + "/home.nix");
          }
        ];
      };
    in {
      nixosConfigurations = {
        nixos-laptop = mkNixos ./hosts/nixos-laptop/configuration.nix;
      };
    };
}
