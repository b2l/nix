{ pkgs, pkgs-unstable }:

let
  pnpm_11_5 = pkgs-unstable.pnpm_11.overrideAttrs (old: rec {
    version = "11.5.2";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-${version}.tgz";
      hash = "sha256-dJ3FT709zenkFLquMsF3yoR3DT/NaciBbVea3D5qLJk=";
    };
  });
in
pkgs.mkShell {
  name = "pnpm11-shell";

  buildInputs = [ pnpm_11_5 ];

  shellHook = ''
    pnpm add -g @aikidosec/safe-chain@1.1.10 2>/dev/null
  '';
}
