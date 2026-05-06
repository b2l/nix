{ pkgs, pkgs-tf129 }:

pkgs.mkShell {
  name = "terraform129-shell";

  buildInputs = [
    pkgs-tf129.terraform
    pkgs.awscli2
    pkgs.terraform-docs
  ];
}
