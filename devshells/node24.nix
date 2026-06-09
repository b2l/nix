{ pkgs }:

pkgs.mkShell {
  name = "node24-shell";

  buildInputs = [
    pkgs.nodejs_24
    pkgs.vtsls
  ];
}
