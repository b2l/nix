{ pkgs }:

pkgs.mkShell {
  name = "node24-shell";

  buildInputs = with pkgs; [
    nodejs_24
    pnpm
  ];
}
