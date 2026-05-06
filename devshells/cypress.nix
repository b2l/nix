{ pkgs }:

pkgs.mkShell {
  name = "cypress-shell";

  nativeBuildInputs = with pkgs; [
    nodejs
    cypress
  ];
}
