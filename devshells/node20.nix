{ pkgs }:

pkgs.mkShell {
  name = "node20-shell";

  buildInputs = with pkgs; [
    nodejs_20
    pnpm
  ];
}
