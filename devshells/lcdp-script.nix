{ pkgs }:

pkgs.mkShell {
  name = "lcdp-script-shell";

  buildInputs = with pkgs; [
    # Node.js / TypeScript
    nodejs_22
    pnpm

    # Python
    python3
    python3Packages.pip

    # Deno
    deno

    # Kotlin scripting
    kotlin

    # SQL tools
    postgresql_16
  ];
}
