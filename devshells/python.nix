{ pkgs }:

pkgs.mkShell {
  name = "python-shell";

  buildInputs = with pkgs; [
    python312
    poetry
    postgresql.lib
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.postgresql.lib}/lib:''${LD_LIBRARY_PATH:-}"
  '';
}
