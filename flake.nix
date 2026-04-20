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
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, catppuccin, nixgl, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixgl.overlay ];
      };
      sharedHomeModules = [
        catppuccin.homeModules.catppuccin
        sops-nix.homeManagerModules.sops
      ];
      mkNixos = hostPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          hostPath
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.sharedModules = sharedHomeModules;
            home-manager.users.nicolas = import (builtins.dirOf hostPath + "/home.nix");
          }
        ];
      };
    in {
      homeConfigurations."work-pc" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/fedora/home.nix
          catppuccin.homeModules.catppuccin
          sops-nix.homeManagerModules.sops
        ];
      };

      nixosConfigurations = {
        nixos-vm = mkNixos ./hosts/nixos-vm/configuration.nix;
        nixos-laptop = mkNixos ./hosts/nixos-laptop/configuration.nix;
      };

      devShells.x86_64-linux = {
        tauri = import ./devshells/tauri.nix { inherit pkgs; };
        java21 = import ./devshells/java21.nix { inherit pkgs; };
        java-legacy = import ./devshells/java-legacy.nix { inherit pkgs; };
        node20 = import ./devshells/node20.nix { inherit pkgs; };
        node22 = import ./devshells/node22.nix { inherit pkgs; };
        node24 = import ./devshells/node24.nix { inherit pkgs; };
        python = import ./devshells/python.nix { inherit pkgs; };
        scala = import ./devshells/scala.nix { inherit pkgs; };
        terraform = import ./devshells/terraform.nix { inherit pkgs; };
      };
    };
}
