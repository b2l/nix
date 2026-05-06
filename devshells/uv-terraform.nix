{ pkgs, pkgs-tf129 }:

pkgs.mkShell {
  name = "uv-terraform-shell";

  packages = with pkgs; [
    python3
    uv
    pkgs-tf129.terraform
  ];
}
