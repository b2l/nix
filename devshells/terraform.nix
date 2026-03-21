{ pkgs }:

pkgs.mkShell {
  name = "terraform-shell";

  buildInputs = with pkgs; [
    opentofu
    awscli2
    terraform-docs
  ];
}
