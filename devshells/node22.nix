{ pkgs }:

pkgs.mkShell {
  name = "node22-shell";

  buildInputs = with pkgs; [
    nodejs_22
    pnpm
  ];
}
