{ pkgs }:

pkgs.mkShell {
  name = "node24-shell";

  buildInputs = with pkgs; [
    nodejs_24
    pnpm
    vtsls
  ];

  shellHook = ''
    pnpm add -g @aikidosec/safe-chain@1.1.10 2>/dev/null
  '';
}
