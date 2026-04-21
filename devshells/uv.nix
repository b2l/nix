{ pkgs }:

pkgs.mkShell {
  name = "uv-shell";

  packages = with pkgs; [
    python3
    uv
  ];
}
