{ pkgs }:

let
  pnpm_10_24 = pkgs.pnpm_10.overrideAttrs (old: rec {
    version = "10.24.0";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/pnpm/-/pnpm-${version}.tgz";
      hash = "sha256-GW9L0XTry9mXhrM0UvFEyy3DLvTnE47URJHp1D1wLXU=";
    };
  });
in
pkgs.mkShell {
  name = "pnpm10-shell";

  buildInputs = [ pnpm_10_24 ];

  shellHook = ''
    pnpm add -g @aikidosec/safe-chain@1.1.10 2>/dev/null
  '';
}
