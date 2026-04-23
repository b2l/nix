{ config, ... }:

{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";

    secrets."lcdp_env" = {
      sopsFile = ../secrets/lcdp.yaml;
      key = "env_bash";
    };
  };
}
