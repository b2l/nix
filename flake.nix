{
  description = "System-as-Code: Universal Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, catppuccin, nixgl, sops-nix, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ nixgl.overlay ];
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
