{ pkgs, pkgs-unstable }:

pkgs.mkShell {
  name = "node24-shell";

  buildInputs = [
    pkgs.nodejs_24
    pkgs-unstable.pnpm_11
    pkgs.vtsls
  ];

  shellHook = ''
    pnpm add -g @aikidosec/safe-chain@1.1.10 2>/dev/null
  '';
}
