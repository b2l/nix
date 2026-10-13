{ config, pkgs, inputs, ... }:

{
  sops = {
    # sops-nix's go.mod now requires Go >= 1.26, but nixpkgs-25.11 still
    # defaults to Go 1.25 (GOTOOLCHAIN=local, so it can't fetch a newer one).
    # Build sops-install-secrets with the 1.26 toolchain that 25.11 ships.
    # Drop this once the pinned nixpkgs defaults to Go >= 1.26.
    package = (import inputs.sops-nix { inherit pkgs; }).sops-install-secrets.override {
      buildGoModule = pkgs.buildGo126Module;
    };

    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";

    secrets."lcdp_env" = {
      sopsFile = ../secrets/lcdp.yaml;
      key = "env_bash";
    };
  };
}
